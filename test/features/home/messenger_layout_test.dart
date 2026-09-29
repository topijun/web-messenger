import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/core/theme/app_theme.dart';
import 'package:mobile_messenger/features/auth/application/auth_controller.dart';
import 'package:mobile_messenger/features/auth/presentation/auth_scope.dart';
import 'package:mobile_messenger/features/chats/application/chat_controller.dart';
import 'package:mobile_messenger/features/chats/presentation/chat_detail_screen.dart';
import 'package:mobile_messenger/features/chats/presentation/chats_home_screen.dart';
import 'package:mobile_messenger/features/home/presentation/messenger_layout.dart';
import 'package:mobile_messenger/features/messaging/presentation/conversation_screen.dart';
import 'package:mobile_messenger/features/messaging/presentation/message_scope.dart';
import 'package:mobile_messenger/features/profile/data/profile_image_store.dart';
import 'package:mobile_messenger/features/profile/presentation/profile_scope.dart';

import '../../support/auth_fakes.dart';
import '../../support/chat_fakes.dart';
import '../../support/message_fakes.dart';
import '../../support/profile_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('narrow layout pushes a full-screen chat and back returns', (
    tester,
  ) async {
    _setSurface(tester, const Size(400, 800));

    final controller = ChatController(
      repository: FakeChatRepository(
        chats: [testDirectChat(id: 1, otherUsername: 'Bob')],
      ),
    );
    await controller.load();

    await tester.pumpWidget(_home(controller));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('messengerWideLayout')), findsNothing);
    expect(find.byKey(const Key('chatList')), findsOneWidget);

    await tester.tap(find.byKey(const Key('chatListItem-1')));
    await tester.pumpAndSettle();

    expect(find.byType(ChatDetailScreen), findsOneWidget);
    expect(find.byType(ConversationScreen), findsNothing);
    expect(controller.activeChatId, 1);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(ChatDetailScreen), findsNothing);
    expect(find.byKey(const Key('chatList')), findsOneWidget);
    expect(controller.activeChatId, isNull);

    controller.dispose();
  });

  testWidgets('wide layout shows an empty conversation beside the chat list', (
    tester,
  ) async {
    final controller = await _pumpWide(
      tester,
      chats: [testDirectChat(id: 1, otherUsername: 'Bob')],
    );

    expect(find.byKey(const Key('messengerWideLayout')), findsOneWidget);
    expect(find.byKey(const Key('chatListPane')), findsOneWidget);
    expect(find.byKey(const Key('conversationPane')), findsOneWidget);
    expect(find.text('Select a conversation'), findsOneWidget);
    expect(find.byKey(const Key('chatListItem-1')), findsOneWidget);
    expect(find.byType(ConversationScreen), findsNothing);

    controller.dispose();
  });

  testWidgets('wide layout keeps both selected conversations open', (
    tester,
  ) async {
    final messages = FakeMessageRepository(
      history: [
        testMessageView(id: 11, chatId: 1, text: 'Hello from Bob'),
        testMessageView(id: 22, chatId: 2, text: 'Hello from Carol'),
      ],
    );
    final controller = await _pumpWide(
      tester,
      messages: messages,
      chats: [
        testDirectChat(id: 1, otherUsername: 'Bob'),
        testDirectChat(id: 2, otherUsername: 'Carol'),
      ],
    );

    expect(find.byKey(const Key('conversationPane')), findsOneWidget);
    expect(find.byType(ConversationScreen), findsNothing);

    await tester.tap(find.byKey(const Key('chatListItem-1')));
    await tester.pumpAndSettle();

    expect(find.byType(ConversationScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('conversation-1')), findsOneWidget);
    expect(find.text('Hello from Bob'), findsOneWidget);
    expect(find.text('Hello from Carol'), findsNothing);
    expect(controller.activeChatId, 1);

    await tester.tap(find.byKey(const Key('chatListItem-1')));
    await tester.pumpAndSettle();

    expect(find.byType(ConversationScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('conversation-1')), findsOneWidget);

    await tester.tap(find.byKey(const Key('chatListItem-2')));
    await tester.pumpAndSettle();

    expect(find.byType(ConversationScreen), findsNWidgets(2));
    expect(find.byKey(const ValueKey('conversation-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('conversation-2')), findsOneWidget);
    expect(find.text('Hello from Bob'), findsOneWidget);
    expect(find.text('Hello from Carol'), findsOneWidget);
    expect(find.byType(ChatDetailScreen), findsNothing);
    expect(controller.activeChatId, 2);

    final carolState = tester.state(
      find.byKey(const ValueKey('conversation-2')),
    );
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('conversation-1')),
        matching: find.byType(TextField),
      ),
      'draft for bob',
    );
    await tester.pump();

    expect(find.text('draft for bob'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('conversation-2')),
        matching: find.text('draft for bob'),
      ),
      findsNothing,
    );
    expect(
      tester.state(find.byKey(const ValueKey('conversation-2'))),
      same(carolState),
    );

    controller.dispose();
    messages.dispose();
  });

  testWidgets('a third wide chat replaces the least recently selected panel', (
    tester,
  ) async {
    final messages = FakeMessageRepository(
      history: [
        testMessageView(id: 11, chatId: 1, text: 'Hello from Bob'),
        testMessageView(id: 22, chatId: 2, text: 'Hello from Carol'),
        testMessageView(id: 33, chatId: 3, text: 'Hello from Dave'),
      ],
    );
    final controller = await _pumpWide(
      tester,
      messages: messages,
      chats: [
        testDirectChat(id: 1, otherUsername: 'Bob'),
        testDirectChat(id: 2, otherUsername: 'Carol'),
        testDirectChat(id: 3, otherUsername: 'Dave'),
      ],
    );

    await tester.tap(find.byKey(const Key('chatListItem-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chatListItem-2')));
    await tester.pumpAndSettle();
    final carolState = tester.state(
      find.byKey(const ValueKey('conversation-2')),
    );

    await tester.tap(find.byKey(const Key('chatListItem-3')));
    await tester.pumpAndSettle();

    expect(find.byType(ConversationScreen), findsNWidgets(2));
    expect(find.byKey(const ValueKey('conversation-1')), findsNothing);
    expect(find.byKey(const ValueKey('conversation-2')), findsOneWidget);
    expect(find.byKey(const ValueKey('conversation-3')), findsOneWidget);
    expect(find.text('Hello from Bob'), findsNothing);
    expect(find.text('Hello from Carol'), findsOneWidget);
    expect(find.text('Hello from Dave'), findsOneWidget);
    expect(
      tester.state(find.byKey(const ValueKey('conversation-2'))),
      same(carolState),
    );
    expect(controller.activeChatId, 3);

    await tester.tap(find.byKey(const Key('chatListItem-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chatListItem-1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('conversation-2')), findsOneWidget);
    expect(find.byKey(const ValueKey('conversation-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('conversation-3')), findsNothing);
    expect(find.text('Hello from Carol'), findsOneWidget);
    expect(find.text('Hello from Bob'), findsOneWidget);
    expect(find.text('Hello from Dave'), findsNothing);

    controller.dispose();
    messages.dispose();
  });

  testWidgets('shrinking below the breakpoint leaves the chat list', (
    tester,
  ) async {
    final messages = FakeMessageRepository(
      history: [
        testMessageView(id: 11, chatId: 1, text: 'Hello from Bob'),
        testMessageView(id: 22, chatId: 2, text: 'Hello from Carol'),
      ],
    );
    final controller = await _pumpWide(
      tester,
      messages: messages,
      chats: [
        testDirectChat(id: 1, otherUsername: 'Bob'),
        testDirectChat(id: 2, otherUsername: 'Carol'),
      ],
    );

    await tester.tap(find.byKey(const Key('chatListItem-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chatListItem-2')));
    await tester.pumpAndSettle();
    expect(find.byType(ConversationScreen), findsNWidgets(2));

    _setSurface(tester, const Size(messengerWideLayoutBreakpoint - 1, 800));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('messengerWideLayout')), findsNothing);
    expect(find.byType(ConversationScreen), findsNothing);
    expect(find.byKey(const Key('chatList')), findsOneWidget);
    expect(controller.activeChatId, isNull);

    _setSurface(tester, const Size(1200, 800));
    await tester.pumpAndSettle();

    expect(find.text('Select a conversation'), findsOneWidget);
    expect(find.byType(ConversationScreen), findsNothing);

    controller.dispose();
    messages.dispose();
  });

  testWidgets('wide empty state uses the active theme', (tester) async {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      final controller = await _pumpWide(
        tester,
        theme: theme,
        chats: [testDirectChat(otherUsername: 'Bob')],
      );
      final context = tester.element(find.text('Select a conversation'));
      expect(Theme.of(context).brightness, theme.brightness);
      expect(
        DefaultTextStyle.of(context).style.color,
        Theme.of(context).colorScheme.onSurface,
      );
      controller.dispose();
    }
  });
}

Future<ChatController> _pumpWide(
  WidgetTester tester, {
  required List<ChatSummary> chats,
  FakeMessageRepository? messages,
  ThemeData? theme,
}) async {
  _setSurface(tester, const Size(1200, 800));

  final controller = ChatController(
    repository: FakeChatRepository(chats: chats),
  );
  await controller.load();
  await tester.pumpWidget(_home(controller, messages: messages, theme: theme));
  await tester.pumpAndSettle();
  return controller;
}

void _setSurface(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _home(
  ChatController controller, {
  FakeMessageRepository? messages,
  ThemeData? theme,
}) {
  final profiles = FakeProfileRepository();
  Widget home = ChatHomeScreen(
    controller: controller,
    homePollInterval: const Duration(days: 1),
    invitationPollInterval: const Duration(days: 1),
  );
  if (messages != null) {
    home = MessageScope(repository: messages, child: home);
  }
  return ProfileScope(
    repository: profiles,
    images: ProfileImageStore(profiles),
    child: AuthScope(
      controller: AuthController(
        repository: FakeAuthRepository(currentUser: testMessengerUser()),
        session: FakeAuthSession(authenticated: true),
      ),
      child: MaterialApp(theme: theme ?? AppTheme.light, home: home),
    ),
  );
}
