import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/features/auth/application/auth_controller.dart';
import 'package:mobile_messenger/features/auth/presentation/auth_scope.dart';
import 'package:mobile_messenger/features/chats/application/chat_controller.dart';
import 'package:mobile_messenger/features/chats/presentation/chats_home_screen.dart';
import 'package:mobile_messenger/features/messaging/presentation/message_scope.dart';
import 'package:mobile_messenger/features/profile/application/profile_controller.dart';
import 'package:mobile_messenger/features/profile/data/profile_image_store.dart';
import 'package:mobile_messenger/features/profile/presentation/profile_scope.dart';
import 'package:mobile_messenger/features/profile/presentation/widgets/default_avatar.dart';
import 'package:mobile_messenger/features/profile/presentation/widgets/profile_avatar.dart';

import '../../support/auth_fakes.dart';
import '../../support/chat_fakes.dart';
import '../../support/message_fakes.dart';
import '../../support/profile_fakes.dart';

void main() {
  testWidgets('Profile Archived shows archived chats and hides others', (
    tester,
  ) async {
    final controller = await _loadedController(
      chats: [
        testDirectChat(otherUsername: 'Active'),
        testDirectChat(
          id: 3,
          otherUsername: 'ArchivedBob',
          otherProfileImageId: 21,
          archived: true,
        ),
      ],
    );

    await tester.pumpWidget(_home(controller));
    await tester.pumpAndSettle();
    expect(find.text('ArchivedBob'), findsNothing);

    await _openArchived(tester);
    expect(find.byKey(const Key('archivedChatsScreen')), findsOneWidget);
    expect(find.text('ArchivedBob'), findsOneWidget);
    expect(find.text('Active'), findsNothing);
    expect(
      tester
          .widget<ProfileAvatar>(find.byKey(const Key('directChatAvatar-3')))
          .profileImageId,
      21,
    );

    controller.dispose();
  });

  testWidgets('archived direct chat without a picture uses the placeholder', (
    tester,
  ) async {
    final controller = await _loadedController(
      chats: [
        testDirectChat(id: 3, otherUsername: 'ArchivedBob', archived: true),
      ],
    );

    await tester.pumpWidget(_home(controller));
    await tester.pumpAndSettle();
    await _openArchived(tester);

    expect(find.byKey(const Key('directChatAvatar-3')), findsOneWidget);
    expect(
      tester
          .widget<ProfileAvatar>(find.byKey(const Key('directChatAvatar-3')))
          .profileImageId,
      isNull,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('directChatAvatar-3')),
        matching: find.byType(DefaultAvatar),
      ),
      findsOneWidget,
    );

    controller.dispose();
  });

  testWidgets('tapping an archived chat opens the conversation', (tester) async {
    final controller = await _loadedController(
      chats: [
        testDirectChat(id: 3, otherUsername: 'ArchivedBob', archived: true),
      ],
    );
    final messages = FakeMessageRepository(
      history: [testMessageView(chatId: 3, text: 'Archived hello')],
    );

    await tester.pumpWidget(_home(controller, messages: messages));
    await tester.pumpAndSettle();
    await _openArchived(tester);
    await tester.tap(find.byKey(const Key('archivedChatListItem-3')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('conversationScreen')), findsOneWidget);
    expect(find.text('Archived hello'), findsOneWidget);
    expect(controller.chats.single.membership.archived, isTrue);
    expect(controller.archivedChats, hasLength(1));

    controller.dispose();
    messages.dispose();
  });

  testWidgets('unarchive returns the chat to Home and leaves Archived', (
    tester,
  ) async {
    final controller = await _loadedController(
      chats: [
        testDirectChat(otherUsername: 'Active'),
        testDirectChat(id: 3, otherUsername: 'ArchivedBob', archived: true),
      ],
    );

    await tester.pumpWidget(_home(controller));
    await tester.pumpAndSettle();
    expect(find.text('ArchivedBob'), findsNothing);

    await _openArchived(tester);
    await tester.tap(find.byKey(const Key('archivedChatListItem-3')));
    await tester.pumpAndSettle();
    expect(find.text('Unarchive'), findsOneWidget);

    await tester.tap(find.byKey(const Key('archiveChat')));
    await tester.pumpAndSettle();
    expect(controller.activeChats.map((chat) => chat.chat.id), [1, 3]);
    expect(controller.archivedChats, isEmpty);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('archivedChatsScreen')), findsOneWidget);
    expect(find.text('ArchivedBob'), findsNothing);
    expect(find.byKey(const Key('emptyArchivedChatList')), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('ArchivedBob'), findsOneWidget);
    expect(find.byKey(const Key('chatListItem-3')), findsOneWidget);

    controller.dispose();
  });

  testWidgets('archived group chats keep the existing avatar stack', (
    tester,
  ) async {
    final controller = await _loadedController(
      chats: [
        testGroupChat(
          archived: true,
          otherAvatars: [
            UserAvatarRef(username: 'Alice', profileImageId: 1),
            UserAvatarRef(username: 'Bob'),
          ],
        ),
      ],
    );

    await tester.pumpWidget(_home(controller));
    await tester.pumpAndSettle();
    expect(find.text('Weekend trip'), findsNothing);

    await _openArchived(tester);
    expect(find.text('Weekend trip'), findsOneWidget);
    expect(find.byKey(const Key('groupChatAvatar-2')), findsOneWidget);

    controller.dispose();
  });
}

Future<ChatController> _loadedController({
  required List<ChatSummary> chats,
}) async {
  final controller = ChatController(
    repository: FakeChatRepository(chats: chats),
  );
  await controller.load();
  return controller;
}

Future<void> _openArchived(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('openProfile')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('archivedChatsEntry')));
  await tester.pumpAndSettle();
}

Widget _home(ChatController controller, {FakeMessageRepository? messages}) {
  final profiles = FakeProfileRepository(profile: testProfile());
  final profile = ProfileController(repository: profiles, username: 'Topi.J');
  Widget home = ProfileScope(
    repository: profiles,
    images: ProfileImageStore(profiles),
    child: AuthScope(
      controller: AuthController(
        repository: FakeAuthRepository(currentUser: testMessengerUser()),
        session: FakeAuthSession(authenticated: true),
      ),
      child: MaterialApp(
        home: ChatHomeScreen(
          controller: controller,
          profile: profile,
          homePollInterval: const Duration(days: 1),
          invitationPollInterval: const Duration(days: 1),
        ),
      ),
    ),
  );
  if (messages != null) {
    home = MessageScope(repository: messages, child: home);
  }
  return home;
}
