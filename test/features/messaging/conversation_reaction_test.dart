import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/features/chats/application/chat_controller.dart';
import 'package:mobile_messenger/features/messaging/presentation/conversation_screen.dart';
import 'package:mobile_messenger/features/profile/data/profile_image_store.dart';
import 'package:mobile_messenger/features/profile/presentation/profile_scope.dart';

import '../../support/chat_fakes.dart';
import '../../support/message_fakes.dart';
import '../../support/profile_fakes.dart';
import '../../support/video_poster_fakes.dart';

void main() {
  testWidgets('one reaction renders the emoji without a count', (tester) async {
    await _pump(
      tester,
      FakeMessageRepository(
        history: [
          testMessageView(
            id: 1,
            text: 'Thanks',
            reactions: [_reaction('❤️', count: 1)],
          ),
        ],
      ),
    );

    expect(find.text('❤️'), findsOneWidget);
    expect(find.text('❤️ 1'), findsNothing);
    expect(find.byKey(const Key('reactionLabel-s-1-❤️')), findsOneWidget);
  });

  testWidgets('two reactions render the emoji and the count', (tester) async {
    await _pump(
      tester,
      FakeMessageRepository(
        history: [
          testMessageView(
            id: 1,
            text: 'Thanks',
            reactions: [_reaction('❤️', count: 2)],
          ),
        ],
      ),
    );

    expect(find.text('❤️ 2'), findsOneWidget);
  });

  testWidgets('different emoji render independently', (tester) async {
    await _pump(
      tester,
      FakeMessageRepository(
        history: [
          testMessageView(
            id: 1,
            text: 'Thanks',
            reactions: [
              _reaction('❤️', count: 2),
              _reaction('👍', count: 3),
              _reaction('😂'),
            ],
          ),
        ],
      ),
    );

    expect(find.text('❤️ 2'), findsOneWidget);
    expect(find.text('👍 3'), findsOneWidget);
    expect(find.text('😂'), findsOneWidget);
    expect(find.text('😂 1'), findsNothing);
  });

  testWidgets('the current user reaction uses the selected state', (
    tester,
  ) async {
    await _pump(
      tester,
      FakeMessageRepository(
        history: [
          testMessageView(
            id: 1,
            text: 'Thanks',
            reactions: [_reaction('❤️', mine: true), _reaction('👍', count: 2)],
          ),
        ],
      ),
    );

    expect(find.byKey(const Key('reactionMine-s-1-❤️')), findsOneWidget);
    expect(find.byKey(const Key('reaction-s-1-👍')), findsOneWidget);
    expect(find.byKey(const Key('reactionMine-s-1-👍')), findsNothing);
  });

  testWidgets('long press and right click open the reaction chooser', (
    tester,
  ) async {
    final messages = FakeMessageRepository(
      history: [testMessageView(id: 1, text: 'Thanks')],
    );
    await _pump(tester, messages);

    await tester.longPress(find.byKey(const Key('messageBubble-s-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('reactionChoice-👍')), findsOneWidget);
    await tester.tap(find.byKey(const Key('reactionChoice-👍')));
    await tester.pumpAndSettle();

    expect(messages.reactCalls, [(messageId: 1, emoji: '👍')]);
    expect(find.text('👍'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('messageBubble-s-1')),
      buttons: kSecondaryMouseButton,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('reactionChoice-😂')), findsOneWidget);
  });

  testWidgets('selecting the same reaction removes it', (tester) async {
    final messages = FakeMessageRepository(
      history: [
        testMessageView(
          id: 1,
          text: 'Thanks',
          reactions: [_reaction('👍', mine: true)],
        ),
      ],
    );
    await _pump(tester, messages);

    await tester.longPress(find.byKey(const Key('messageBubble-s-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reactionChoice-👍')));
    await tester.pumpAndSettle();

    expect(messages.reactCalls, [(messageId: 1, emoji: '👍')]);
    expect(find.byKey(const Key('reactionMine-s-1-👍')), findsNothing);
    expect(find.text('Thanks'), findsOneWidget);
  });

  testWidgets('a failed reaction keeps the conversation usable', (
    tester,
  ) async {
    final messages = FakeMessageRepository(
      history: [testMessageView(id: 1, text: 'Thanks')],
    );
    messages.reactionError = MessengerInvalidChatInputException(
      field: 'emoji',
      message: 'Choose one of the available reactions.',
    );
    await _pump(tester, messages);

    await tester.longPress(find.byKey(const Key('messageBubble-s-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reactionChoice-😢')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('conversationErrorBanner')), findsOneWidget);
    expect(find.text('Choose one of the available reactions.'), findsOneWidget);
    expect(find.text('Thanks'), findsOneWidget);
  });

  testWidgets('a realtime reaction update changes only that message', (
    tester,
  ) async {
    final messages = FakeMessageRepository(
      history: [
        testMessageView(id: 1, text: 'First'),
        testMessageView(id: 2, text: 'Second'),
      ],
    );
    await _pump(tester, messages);

    messages.events.add(
      ChatEvent(
        kind: ChatEventKind.messageReactionUpdated,
        chatId: 1,
        message: testMessageView(
          id: 1,
          text: 'First',
          reactions: [_reaction('😮', count: 2)],
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('😮 2'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);
    expect(find.byKey(const Key('reactionLabel-s-2-😮')), findsNothing);
  });

  testWidgets('poll image video and audio bubbles show reactions', (
    tester,
  ) async {
    final messages = FakeMessageRepository(
      history: [
        testMessageView(
          id: 4,
          type: MessageType.poll,
          text: '',
          poll: PollView(
            id: 4,
            question: 'Where should we go?',
            anonymous: true,
            totalVotes: 0,
            options: [
              PollOptionView(
                id: 41,
                text: 'Helsinki',
                position: 0,
                voteCount: 0,
                voters: const [],
              ),
              PollOptionView(
                id: 42,
                text: 'Tampere',
                position: 1,
                voteCount: 0,
                voters: const [],
              ),
            ],
          ),
          reactions: [_reaction('❤️')],
        ),
        testMessageView(
          id: 5,
          type: MessageType.image,
          text: '',
          mediaId: 50,
          reactions: [_reaction('👍', count: 2)],
        ),
        testMessageView(
          id: 6,
          type: MessageType.video,
          text: '',
          mediaId: 60,
          thumbnailMediaId: 61,
          reactions: [_reaction('😂')],
        ),
        testMessageView(
          id: 7,
          type: MessageType.audio,
          text: '',
          mediaId: 70,
          reactions: [_reaction('😮', mine: true)],
        ),
      ],
    );
    messages.mediaById[50] = testChatMedia(
      mediaId: 50,
      mimeType: 'image/png',
      bytes: testPngBytes,
    );
    messages.mediaById[60] = testChatMedia(
      mediaId: 60,
      type: MediaType.video,
      mimeType: 'video/mp4',
    );
    messages.mediaById[61] = testChatMedia(
      mediaId: 61,
      mimeType: 'image/png',
      bytes: testPngBytes,
    );
    messages.mediaById[70] = testChatMedia(
      mediaId: 70,
      type: MediaType.audio,
      mimeType: 'audio/wav',
      bytes: testWavBytes(),
    );
    await _pump(tester, messages);

    expect(find.text('Where should we go?'), findsOneWidget);
    expect(find.byKey(const Key('reactionLabel-s-4-❤️')), findsOneWidget);
    expect(find.byKey(const Key('reactionLabel-s-5-👍')), findsOneWidget);
    expect(find.text('👍 2'), findsOneWidget);
    expect(find.byKey(const Key('reactionLabel-s-6-😂')), findsOneWidget);
    expect(find.byKey(const Key('reactionMine-s-7-😮')), findsOneWidget);
    expect(find.byKey(const Key('audioMessage-s-7')), findsOneWidget);
  });
}

MessageReactionView _reaction(
  String emoji, {
  int count = 1,
  bool mine = false,
}) {
  return MessageReactionView(emoji: emoji, count: count, mine: mine);
}

Future<void> _pump(WidgetTester tester, FakeMessageRepository messages) async {
  final summary = testDirectChat();
  final chats = FakeChatRepository(chats: [summary]);
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
          summary: summary,
          messages: messages,
          poster: FakeVideoPoster(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
