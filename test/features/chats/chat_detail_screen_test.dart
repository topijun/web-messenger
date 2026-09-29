import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/features/auth/application/auth_controller.dart';
import 'package:mobile_messenger/features/auth/presentation/auth_scope.dart';
import 'package:mobile_messenger/features/chats/application/chat_controller.dart';
import 'package:mobile_messenger/features/chats/presentation/chat_detail_screen.dart';
import 'package:mobile_messenger/features/profile/presentation/widgets/profile_avatar.dart';

import '../../support/auth_fakes.dart';
import '../../support/chat_fakes.dart';

void main() {
  testWidgets('archived chat settings shows Unarchive', (tester) async {
    final summary = testDirectChat(id: 3, otherUsername: 'Bob', archived: true);
    final controller = ChatController(
      repository: FakeChatRepository(chats: [summary]),
    );
    await controller.load();
    await tester.pumpWidget(_detail(controller, summary));
    await tester.pumpAndSettle();

    expect(find.text('Unarchive'), findsOneWidget);
    expect(
      tester.widget<SwitchListTile>(find.byKey(const Key('archiveChat'))).value,
      isTrue,
    );

    controller.dispose();
  });

  testWidgets('group search by username shows the result', (tester) async {
    final repository = FakeChatRepository(
      chats: [testGroupChat()],
      searchResult: testContact(username: 'Carol'),
    );
    final controller = ChatController(repository: repository);
    await controller.load();
    await tester.pumpWidget(_detail(controller, testGroupChat()));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('groupInviteUsername')),
      'Carol',
    );
    await tester.tap(find.byKey(const Key('groupSearchContact')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('groupContactSearchResult')), findsOneWidget);
    expect(find.byKey(const Key('groupContactSearchUsername')), findsOneWidget);
    expect(find.byKey(const Key('inviteToGroup')), findsOneWidget);
    expect(repository.lastSearchQuery, 'Carol');

    controller.dispose();
  });

  testWidgets('group search by email shows the resolved username', (
    tester,
  ) async {
    final repository = FakeChatRepository(
      chats: [testGroupChat()],
      searchResult: testContact(username: 'Carol'),
    );
    final controller = ChatController(repository: repository);
    await controller.load();
    await tester.pumpWidget(_detail(controller, testGroupChat()));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('groupInviteUsername')),
      'carol@example.com',
    );
    await tester.tap(find.byKey(const Key('groupSearchContact')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('groupContactSearchUsername')), findsOneWidget);
    expect(find.text('Carol'), findsOneWidget);
    expect(repository.lastSearchQuery, 'carol@example.com');

    controller.dispose();
  });

  testWidgets('empty group search shows feedback', (tester) async {
    final repository = FakeChatRepository(
      chats: [testGroupChat()],
      searchResult: testContact(username: 'Carol'),
    );
    final controller = ChatController(repository: repository);
    await controller.load();
    await tester.pumpWidget(_detail(controller, testGroupChat()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('groupSearchContact')));
    await tester.pumpAndSettle();

    expect(find.text('Enter a username or email.'), findsOneWidget);
    expect(find.byKey(const Key('groupContactSearchResult')), findsNothing);
    expect(repository.lastSearchQuery, isNull);

    controller.dispose();
  });

  testWidgets('group search shows a loading indicator then clears it', (
    tester,
  ) async {
    final pending = Completer<ContactSearchResult?>();
    final repository = FakeChatRepository(
      chats: [testGroupChat()],
      searchCompleter: pending,
    );
    final controller = ChatController(repository: repository);
    await controller.load();
    await tester.pumpWidget(_detail(controller, testGroupChat()));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('groupInviteUsername')),
      'Carol',
    );
    await tester.tap(find.byKey(const Key('groupSearchContact')));
    await tester.pump();

    expect(find.byKey(const Key('groupContactSearchLoading')), findsOneWidget);

    pending.complete(testContact(username: 'Carol'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('groupContactSearchLoading')), findsNothing);
    expect(find.byKey(const Key('groupContactSearchResult')), findsOneWidget);

    controller.dispose();
  });

  testWidgets('group search with no match shows feedback', (tester) async {
    final repository = FakeChatRepository(chats: [testGroupChat()]);
    final controller = ChatController(repository: repository);
    await controller.load();
    await tester.pumpWidget(_detail(controller, testGroupChat()));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('groupInviteUsername')),
      'nobody@example.com',
    );
    await tester.tap(find.byKey(const Key('groupSearchContact')));
    await tester.pumpAndSettle();

    expect(find.text('No matching user was found.'), findsOneWidget);
    expect(find.byKey(const Key('inviteToGroup')), findsNothing);

    controller.dispose();
  });

  testWidgets('group search error shows feedback', (tester) async {
    final repository = FakeChatRepository(
      chats: [testGroupChat()],
      searchError: ServerpodClientException('down', 503),
    );
    final controller = ChatController(repository: repository);
    await controller.load();
    await tester.pumpWidget(_detail(controller, testGroupChat()));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('groupInviteUsername')),
      'Carol',
    );
    await tester.tap(find.byKey(const Key('groupSearchContact')));
    await tester.pumpAndSettle();

    expect(find.textContaining('connection'), findsOneWidget);
    expect(find.byKey(const Key('groupContactSearchResult')), findsNothing);
    expect(find.byKey(const Key('groupContactSearchLoading')), findsNothing);

    controller.dispose();
  });

  testWidgets('already-member search hides Invite', (tester) async {
    final repository = FakeChatRepository(
      chats: [testGroupChat()],
      searchResult: testContact(username: 'Bob'),
    );
    final controller = ChatController(repository: repository);
    await controller.load();
    await tester.pumpWidget(_detail(controller, testGroupChat()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('groupInviteUsername')), 'Bob');
    await tester.tap(find.byKey(const Key('groupSearchContact')));
    await tester.pumpAndSettle();

    expect(find.text('Already a member'), findsOneWidget);
    expect(find.byKey(const Key('inviteToGroup')), findsNothing);

    controller.dispose();
  });

  testWidgets('self search hides Invite', (tester) async {
    final repository = FakeChatRepository(
      chats: [testGroupChat()],
      searchResult: testContact(
        username: 'Topi.J',
        relation: ContactSearchRelation.self,
      ),
    );
    final controller = ChatController(repository: repository);
    await controller.load();
    await tester.pumpWidget(_detail(controller, testGroupChat()));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('groupInviteUsername')),
      'Topi.J',
    );
    await tester.tap(find.byKey(const Key('groupSearchContact')));
    await tester.pumpAndSettle();

    expect(find.text('You cannot invite yourself'), findsOneWidget);
    expect(find.byKey(const Key('inviteToGroup')), findsNothing);

    controller.dispose();
  });

  testWidgets('Invite uses the resolved username and refreshes members', (
    tester,
  ) async {
    final repository = FakeChatRepository(
      chats: [testGroupChat()],
      searchResult: testContact(username: 'Carol'),
    );
    final controller = ChatController(repository: repository);
    await controller.load();
    await tester.pumpWidget(_detail(controller, testGroupChat()));
    await tester.pumpAndSettle();
    final membersBefore = repository.listMembersCalls;

    await tester.enterText(
      find.byKey(const Key('groupInviteUsername')),
      'carol@example.com',
    );
    await tester.tap(find.byKey(const Key('groupSearchContact')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('groupContactSearchResult')), findsOneWidget);
    await _tapGroupInvite(tester);
    await tester.pumpAndSettle();

    expect(repository.lastGroupInviteUsername, 'Carol');
    expect(repository.lastGroupInviteChatId, 2);
    expect(repository.listMembersCalls, greaterThan(membersBefore));
    expect(find.text('Carol'), findsOneWidget);
    expect(find.byKey(const Key('groupContactSearchResult')), findsNothing);
    expect(find.text('Invitation sent.'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('group settings show stacked nav avatars and member avatars', (
    tester,
  ) async {
    final summary = testGroupChat(
      otherAvatars: [
        UserAvatarRef(username: 'Alice', profileImageId: 1),
        UserAvatarRef(username: 'Bob'),
        UserAvatarRef(username: 'Carol', profileImageId: 3),
      ],
    );
    final repository = FakeChatRepository(
      chats: [summary],
      members: [
        testChatMember(role: ChatParticipantRole.admin, profileImageId: 11),
        testChatMember(userId: 2, username: 'Bob'),
        testChatMember(userId: 3, username: 'Carol', profileImageId: 3),
      ],
    );
    final controller = ChatController(repository: repository);
    await controller.load();
    await tester.pumpWidget(_detail(controller, summary));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('groupNavAvatar-2')), findsOneWidget);
    expect(find.byType(GroupAvatarStack), findsOneWidget);
    expect(find.byKey(const Key('chatMemberAvatar-1')), findsOneWidget);
    expect(find.byKey(const Key('chatMemberAvatar-2')), findsOneWidget);
    expect(find.byKey(const Key('chatMemberAvatar-3')), findsOneWidget);
    expect(find.text('Weekend trip'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('failed group invite keeps the result and shows feedback', (
    tester,
  ) async {
    final repository = FakeChatRepository(
      chats: [testGroupChat()],
      searchResult: testContact(username: 'Carol'),
      actionError: MessengerAlreadyChatParticipantException(username: 'Carol'),
    );
    final controller = ChatController(repository: repository);
    await controller.load();
    await tester.pumpWidget(_detail(controller, testGroupChat()));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('groupInviteUsername')),
      'Carol',
    );
    await tester.tap(find.byKey(const Key('groupSearchContact')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('groupContactSearchResult')), findsOneWidget);
    await _tapGroupInvite(tester);
    await tester.pump();

    expect(find.text('Carol is already in this chat.'), findsOneWidget);
    expect(find.byKey(const Key('groupContactSearchResult')), findsOneWidget);

    controller.dispose();
  });
}

Future<void> _tapGroupInvite(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.byKey(const Key('inviteToGroup')),
    80,
    scrollable: find
        .descendant(
          of: find.byKey(const Key('chatDetailScroll')),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('inviteToGroup')));
}

Widget _detail(ChatController controller, ChatSummary summary) {
  return AuthScope(
    controller: AuthController(
      repository: FakeAuthRepository(currentUser: testMessengerUser()),
      session: FakeAuthSession(authenticated: true),
    ),
    child: MaterialApp(
      home: ChatDetailScreen(controller: controller, summary: summary),
    ),
  );
}
