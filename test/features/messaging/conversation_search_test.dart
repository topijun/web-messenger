import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/features/chats/application/chat_controller.dart';
import 'package:mobile_messenger/features/messaging/application/conversation_controller.dart';
import 'package:mobile_messenger/features/messaging/presentation/conversation_screen.dart';
import 'package:mobile_messenger/features/profile/data/profile_image_store.dart';
import 'package:mobile_messenger/features/profile/presentation/profile_scope.dart';

import '../../support/chat_fakes.dart';
import '../../support/message_fakes.dart';
import '../../support/profile_fakes.dart';
import '../../support/video_poster_fakes.dart';

void main() {
  test('search finds matching text and ignores other messages', () async {
    final repository = FakeMessageRepository(
      history: [
        testMessageView(id: 3, text: 'hello again', senderUsername: 'Alice'),
        testMessageView(id: 2, text: 'How are you?', senderUsername: 'Bob'),
        testMessageView(id: 1, text: 'Hello Bob', senderUsername: 'Alice'),
      ],
    );
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );

    await controller.search('hello');

    expect(controller.searchResults.map((view) => view.message.encryptedText), [
      'hello again',
      'Hello Bob',
    ]);
    expect(repository.searchQueries, [(chatId: 1, query: 'hello')]);
    controller.dispose();
    repository.dispose();
  });

  test('search is case-insensitive', () async {
    final repository = FakeMessageRepository(
      history: [
        testMessageView(id: 3, text: 'HELLO'),
        testMessageView(id: 2, text: 'hello'),
        testMessageView(id: 1, text: 'Hello'),
      ],
    );
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );

    await controller.search('HELLO');

    expect(controller.searchResults.map((view) => view.message.encryptedText), [
      'HELLO',
      'hello',
      'Hello',
    ]);
    controller.dispose();
    repository.dispose();
  });

  test('a query with no matches returns an empty result', () async {
    final repository = FakeMessageRepository(
      history: [testMessageView(id: 1, text: 'Hello Bob')],
    );
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );

    await controller.search('missing');

    expect(controller.searchPerformed, isTrue);
    expect(controller.searchResults, isEmpty);
    expect(controller.searchError, isNull);
    controller.dispose();
    repository.dispose();
  });

  test('an empty query does not search', () async {
    final repository = FakeMessageRepository(
      history: [testMessageView(id: 1, text: 'Hello Bob')],
    );
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );
    await controller.search('hello');

    await controller.search('   ');

    expect(repository.searchQueries, [(chatId: 1, query: 'hello')]);
    expect(controller.searchPerformed, isFalse);
    expect(controller.searchResults, isEmpty);
    controller.dispose();
    repository.dispose();
  });

  test('search failure uses the message error mapper', () async {
    final repository = FakeMessageRepository(
      history: [testMessageView(id: 1, text: 'Hello Bob')],
    );
    repository.searchError = MessengerNotChatMemberException(chatId: 9);
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );

    await controller.search('hello');

    expect(controller.searchError, 'You are not a member of this chat.');
    expect(controller.searchResults, isEmpty);
    controller.dispose();
    repository.dispose();
  });

  test(
    'selecting a result loads older history until that message is present',
    () async {
      final repository = FakeMessageRepository(
        pageSize: 1,
        history: [
          testMessageView(id: 3, text: 'How are you?'),
          testMessageView(id: 2, text: 'hello again'),
          testMessageView(id: 1, text: 'Hello Bob'),
        ],
      );
      final controller = ConversationController(
        repository: repository,
        chatId: 1,
      );
      await controller.load();
      expect(controller.items.map((item) => item.serverId), [3]);

      final found = await controller.revealMessage(1);

      expect(found, isTrue);
      expect(controller.focusedMessageId, 1);
      expect(controller.items.map((item) => item.serverId), contains(1));
      controller.dispose();
      repository.dispose();
    },
  );

  testWidgets('empty search text does not search or show no results', (
    tester,
  ) async {
    final messages = FakeMessageRepository(
      history: [testMessageView(id: 1, text: 'Hello Bob')],
    );
    await _pumpConversation(tester, messages);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('openMessageSearch')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('messageSearchField')), '   ');
    await tester.pump();

    final submit = tester.widget<IconButton>(
      find.byKey(const Key('submitMessageSearch')),
    );
    expect(submit.onPressed, isNull);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(messages.searchQueries, isEmpty);
    expect(find.byKey(const Key('messageSearchEmpty')), findsNothing);
    expect(find.text('No messages found.'), findsNothing);
    expect(find.text('Hello Bob'), findsOneWidget);
  });

  testWidgets('a search with no matches shows an empty result', (tester) async {
    final messages = FakeMessageRepository(
      history: [testMessageView(id: 1, text: 'Hello Bob')],
    );
    await _pumpConversation(tester, messages);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('openMessageSearch')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('messageSearchField')),
      'missing',
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('messageSearchEmpty')), findsOneWidget);
    expect(find.text('No messages found.'), findsOneWidget);
    expect(find.byKey(const Key('messageSearchResults')), findsNothing);
  });

  testWidgets('selecting a search result reveals that message', (tester) async {
    final messages = FakeMessageRepository(
      pageSize: 1,
      history: [
        testMessageView(id: 3, text: 'How are you?', senderUsername: 'Bob'),
        testMessageView(id: 2, text: 'hello again', senderUsername: 'Alice'),
        testMessageView(id: 1, text: 'Hello Bob', senderUsername: 'Alice'),
      ],
    );
    await _pumpConversation(tester, messages);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('messageText-s-1')), findsNothing);

    await tester.tap(find.byKey(const Key('openMessageSearch')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('messageSearchField')),
      'hello',
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('searchResult-1')), findsOneWidget);
    expect(find.byKey(const Key('searchResult-2')), findsOneWidget);
    expect(find.byKey(const Key('searchResult-3')), findsNothing);

    tester.testTextInput.hide();
    await tester.pump();
    await tester.tap(find.byKey(const Key('searchResult-1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('messageText-s-1')), findsOneWidget);
    expect(find.text('Hello Bob'), findsWidgets);
  });
}

Future<void> _pumpConversation(
  WidgetTester tester,
  FakeMessageRepository messages,
) async {
  final chats = FakeChatRepository(chats: [testDirectChat()]);
  final chatController = ChatController(repository: chats);
  await chatController.load();
  addTearDown(chatController.dispose);
  addTearDown(messages.dispose);

  final profiles = FakeProfileRepository();
  await tester.pumpWidget(
    ProfileScope(
      repository: profiles,
      images: ProfileImageStore(profiles),
      child: MaterialApp(
        home: ConversationScreen(
          chatController: chatController,
          summary: testDirectChat(),
          messages: messages,
          poster: FakeVideoPoster(),
        ),
      ),
    ),
  );
}
