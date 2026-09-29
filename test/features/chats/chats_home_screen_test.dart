import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/app/messenger_app.dart';
import 'package:mobile_messenger/features/auth/application/auth_controller.dart';
import 'package:mobile_messenger/features/auth/domain/auth_state.dart';
import 'package:mobile_messenger/features/auth/presentation/auth_scope.dart';
import 'package:mobile_messenger/features/chats/application/chat_controller.dart';
import 'package:mobile_messenger/features/chats/presentation/chat_detail_screen.dart';
import 'package:mobile_messenger/features/chats/presentation/chats_home_screen.dart';

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
  testWidgets('shows a loading state while chats are fetched', (tester) async {
    final load = Completer<List<ChatSummary>>();
    final controller = ChatController(
      repository: FakeChatRepository(chatsCompleter: load),
    );

    await tester.pumpWidget(_home(controller));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);

    load.complete([testDirectChat(otherUsername: 'Bob')]);
    await tester.pumpAndSettle();
    controller.dispose();
  });

  testWidgets('authenticated home shows username and incoming invitations', (
    tester,
  ) async {
    final auth = AuthController(
      repository: FakeAuthRepository(currentUser: testMessengerUser()),
      session: FakeAuthSession(authenticated: true),
    );
    final repository = FakeChatRepository(
      invitations: [testInvitation(id: 10, senderUsername: 'Alice')],
    );

    await tester.pumpWidget(MessengerApp(auth: auth, chats: repository));
    await tester.pumpAndSettle();

    expect(auth.state.status, AuthStatus.authenticated);
    expect(find.byKey(const Key('homeUsername')), findsOneWidget);
    expect(find.text('Topi.J'), findsOneWidget);

    await tester.tap(find.text('Invitations'));
    await tester.pumpAndSettle();
    expect(find.text('Alice invited you to a direct chat'), findsOneWidget);
  });

  testWidgets('invitation load failure is an error, not an empty list', (
    tester,
  ) async {
    final controller = ChatController(
      repository: FakeChatRepository(loadError: Exception('down')),
    );

    await tester.pumpWidget(_home(controller));
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not load chats'), findsOneWidget);
    expect(find.byKey(const Key('emptyChatList')), findsNothing);

    await tester.tap(find.text('Invitations'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('invitationLoadError')), findsOneWidget);
    expect(find.byKey(const Key('emptyInvitationList')), findsNothing);

    controller.dispose();
  });

  testWidgets('resume refreshes the chat list without stacking requests', (
    tester,
  ) async {
    final repository = FakeChatRepository(
      chats: [testDirectChat(otherUsername: 'Bob')],
    );
    final controller = ChatController(repository: repository);
    await controller.load();
    final callsAfterLoad = repository.listMineCalls;

    await tester.pumpWidget(_home(controller));
    await tester.pumpAndSettle();

    repository.chats = [testDirectChat(otherUsername: 'Carol')];
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(repository.listMineCalls, callsAfterLoad + 1);
    expect(find.text('Carol'), findsOneWidget);
    expect(find.text('Bob'), findsNothing);

    controller.dispose();
  });

  testWidgets('failed silent refresh keeps chats and shows an error banner', (
    tester,
  ) async {
    final repository = FakeChatRepository(
      chats: [testDirectChat(otherUsername: 'Bob')],
    );
    final controller = ChatController(repository: repository);
    await controller.load();

    await tester.pumpWidget(_home(controller));
    await tester.pumpAndSettle();

    repository.loadError = Exception('down');
    await controller.load(silent: true);
    await tester.pumpAndSettle();

    expect(find.text('Bob'), findsOneWidget);
    expect(find.byKey(const Key('chatRefreshError')), findsOneWidget);
    expect(find.textContaining('Could not load chats'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    controller.dispose();
  });

  testWidgets('loads the chat list', (tester) async {
    final controller = ChatController(
      repository: FakeChatRepository(
        chats: [
          testDirectChat(otherUsername: 'Bob'),
          testGroupChat(name: 'Weekend trip'),
        ],
      ),
    );

    await tester.pumpWidget(_home(controller));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('chatList')), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Weekend trip'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('shows pending invitations and can accept or decline', (
    tester,
  ) async {
    final repository = FakeChatRepository(
      invitations: [
        testInvitation(id: 10, senderUsername: 'Alice'),
        testInvitation(
          id: 11,
          senderUsername: 'Carol',
          isGroup: true,
          chatName: 'Book club',
        ),
      ],
    );
    final controller = ChatController(repository: repository);

    await tester.pumpWidget(_home(controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Invitations'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('invitationList')), findsOneWidget);
    expect(find.text('Alice invited you to a direct chat'), findsOneWidget);
    expect(find.text('Carol invited you to Book club'), findsOneWidget);

    await tester.tap(find.byKey(const Key('acceptInvitation-10')));
    await tester.pumpAndSettle();
    expect(repository.lastAcceptedId, 10);
    expect(find.text('Alice invited you to a direct chat'), findsNothing);

    await tester.tap(find.byKey(const Key('declineInvitation-11')));
    await tester.pumpAndSettle();
    expect(repository.lastDeclinedId, 11);
    expect(find.text('Invitation declined.'), findsOneWidget);
    expect(find.text('No pending invitations.'), findsOneWidget);

    await tester.tap(find.text('Chats'));
    await tester.pumpAndSettle();
    expect(find.text('Alice'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('archived chats are hidden from the normal chat list', (
    tester,
  ) async {
    final controller = ChatController(
      repository: FakeChatRepository(
        chats: [
          testDirectChat(otherUsername: 'Active'),
          testDirectChat(id: 3, otherUsername: 'ArchivedBob', archived: true),
        ],
      ),
    );
    await controller.load();

    await tester.pumpWidget(_home(controller));
    await tester.pumpAndSettle();

    expect(find.text('Active'), findsOneWidget);
    expect(find.byKey(const Key('chatListItem-1')), findsOneWidget);
    expect(find.text('ArchivedBob'), findsNothing);
    expect(find.byKey(const Key('chatListItem-3')), findsNothing);

    controller.dispose();
  });

  testWidgets('archive and mute state can be toggled', (tester) async {
    final summary = testDirectChat(id: 3, otherUsername: 'Bob');
    final repository = FakeChatRepository(chats: [summary]);
    final controller = ChatController(repository: repository);
    await controller.load();

    await tester.pumpWidget(_detail(controller, summary));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('archiveChat')));
    await tester.pumpAndSettle();
    expect(repository.lastArchivedValue, isTrue);
    expect(
      tester.widget<SwitchListTile>(find.byKey(const Key('archiveChat'))).value,
      isTrue,
    );

    await tester.tap(find.byKey(const Key('muteChat')));
    await tester.pumpAndSettle();
    expect(repository.lastMutedValue, isTrue);
    expect(
      tester.widget<SwitchListTile>(find.byKey(const Key('muteChat'))).value,
      isTrue,
    );

    controller.dispose();
  });

  testWidgets('creating a group adds it to the chat list', (tester) async {
    final repository = FakeChatRepository();
    final controller = ChatController(repository: repository);

    await tester.pumpWidget(_home(controller));
    await tester.pumpAndSettle();
    expect(find.text('No chats yet.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('newChat')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('newGroupChat')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('groupName')), 'Weekend trip');
    await tester.tap(find.byKey(const Key('createGroup')));
    await tester.pumpAndSettle();

    expect(repository.lastCreatedGroupName, 'Weekend trip');
    expect(find.text('Weekend trip'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('direct invitation can be sent by username', (tester) async {
    final repository = FakeChatRepository(
      searchResult: testContact(username: 'Bob'),
    );
    final controller = ChatController(repository: repository);

    await tester.pumpWidget(_home(controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('newChat')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('newDirectChat')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('directInviteUsername')),
      'Bob',
    );
    await tester.tap(find.byKey(const Key('lookupUsername')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('contactSearchResult')), findsOneWidget);
    expect(find.byKey(const Key('contactSearchUsername')), findsOneWidget);
    expect(find.byKey(const Key('contactSearchAvatar')), findsOneWidget);

    await tester.tap(find.byKey(const Key('sendDirectInvitation')));
    await tester.pumpAndSettle();
    expect(repository.lastInvitedUsername, 'Bob');

    controller.dispose();
  });

  testWidgets('non-admin group invite shows the server error', (tester) async {
    final summary = testGroupChat(role: ChatParticipantRole.member);
    final repository = FakeChatRepository(
      chats: [summary],
      searchResult: testContact(username: 'Carol'),
      actionError: MessengerNotChatAdminException(chatId: summary.chat.id!),
    );
    final controller = ChatController(repository: repository);
    await controller.load();

    await tester.pumpWidget(_detail(controller, summary));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('groupInviteUsername')),
      'Carol',
    );
    await tester.tap(find.byKey(const Key('groupSearchContact')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('groupContactSearchResult')), findsOneWidget);
    expect(find.byKey(const Key('groupContactSearchAvatar')), findsOneWidget);
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
    await tester.pumpAndSettle();

    expect(repository.lastGroupInviteUsername, 'Carol');
    expect(find.text('Only a group admin can invite people.'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('unread and invitation badges render from authoritative counts', (
    tester,
  ) async {
    final controller = ChatController(
      repository: FakeChatRepository(
        chats: [testDirectChat(otherUsername: 'Bob', unreadCount: 2)],
        invitations: [
          testInvitation(id: 10, senderUsername: 'Alice'),
          testInvitation(id: 11, senderUsername: 'Carol'),
        ],
      ),
    );

    await tester.pumpWidget(_home(controller));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('unreadBadge-1')), findsOneWidget);
    expect(find.text('2'), findsWidgets);
    expect(find.byKey(const Key('invitationBadge')), findsOneWidget);
    expect(
      _badgeColor(tester, const Key('unreadBadge-1')),
      Theme.of(tester.element(find.byKey(const Key('unreadBadge-1'))))
          .colorScheme
          .primary,
    );

    controller.dispose();
  });

  testWidgets('muted chat greys out the unread badge in light and dark', (
    tester,
  ) async {
    final controller = ChatController(
      repository: FakeChatRepository(
        chats: [
          testDirectChat(
            otherUsername: 'Bob',
            unreadCount: 3,
            notificationsMuted: true,
          ),
        ],
      ),
    );

    Future<void> expectMutedAppearance(ThemeData theme) async {
      await tester.pumpWidget(_home(controller, theme: theme));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('unreadBadge-1')), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Muted'), findsOneWidget);
      final scheme = Theme.of(
        tester.element(find.byKey(const Key('unreadBadge-1'))),
      ).colorScheme;
      expect(
        _badgeColor(tester, const Key('unreadBadge-1')),
        scheme.surfaceContainerHighest,
      );
      expect(
        _badgeColor(tester, const Key('unreadBadge-1')),
        isNot(scheme.primary),
      );
    }

    await expectMutedAppearance(ThemeData.light());
    await expectMutedAppearance(ThemeData.dark());

    controller.dispose();
  });

  testWidgets('realtime incoming message updates the chat-list badge', (
    tester,
  ) async {
    final events = StreamController<ChatEvent>.broadcast();
    final controller = ChatController(
      repository: FakeChatRepository(
        chats: [testDirectChat(otherUsername: 'Bob')],
      ),
      events: events.stream,
    );
    await controller.load();

    await tester.pumpWidget(_home(controller));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('unreadBadge-1')), findsNothing);

    events.add(
      ChatEvent(
        kind: ChatEventKind.message,
        chatId: 1,
        message: testMessageView(id: 44, chatId: 1),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('unreadBadge-1')), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    await events.close();
    controller.dispose();
  });

  testWidgets(
    'realtime invitation updates the Home badge without duplicating',
    (tester) async {
      final events = StreamController<ChatEvent>.broadcast();
      final invitation = testInvitation(id: 70, senderUsername: 'Alice');
      final controller = ChatController(
        repository: FakeChatRepository(),
        events: events.stream,
      );
      await controller.load();

      await tester.pumpWidget(_home(controller));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('invitationBadge')), findsNothing);

      events.add(
        ChatEvent(
          kind: ChatEventKind.invitation,
          chatId: 0,
          invitation: invitation,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('invitationBadge')), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      events.add(
        ChatEvent(
          kind: ChatEventKind.invitation,
          chatId: 0,
          invitation: invitation,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);

      await events.close();
      controller.dispose();
    },
  );

  testWidgets('opening Invitations fetches current pending invitations', (
    tester,
  ) async {
    final repository = FakeChatRepository();
    final controller = ChatController(repository: repository);
    await controller.load();
    final pendingAfterLoad = repository.listPendingMineCalls;

    await tester.pumpWidget(_home(controller));
    await tester.pumpAndSettle();

    repository.invitations = [testInvitation(id: 12, senderUsername: 'Dana')];
    await tester.tap(find.text('Invitations'));
    await tester.pumpAndSettle();

    expect(repository.listPendingMineCalls, greaterThan(pendingAfterLoad));
    expect(find.text('Dana invited you to a direct chat'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('home polling reconciles a missed invitation event', (
    tester,
  ) async {
    final repository = FakeChatRepository();
    final controller = ChatController(repository: repository);
    await controller.load();

    await tester.pumpWidget(
      _home(controller, homePollInterval: _testPollInterval),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('invitationBadge')), findsNothing);

    repository.invitations = [testInvitation(id: 13, senderUsername: 'Eve')];
    await tester.pump(_testPollInterval);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('invitationBadge')), findsOneWidget);
    expect(controller.pendingInvitationCount, 1);

    controller.dispose();
  });

  testWidgets('invitation polling updates the open Invitations list', (
    tester,
  ) async {
    final repository = FakeChatRepository();
    final controller = ChatController(repository: repository);
    await controller.load();

    await tester.pumpWidget(
      _home(controller, invitationPollInterval: _testPollInterval),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Invitations'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('emptyInvitationList')), findsOneWidget);

    repository.invitations = [testInvitation(id: 14, senderUsername: 'Frank')];
    await tester.pump(_testPollInterval);
    await tester.pumpAndSettle();

    expect(find.text('Frank invited you to a direct chat'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('polling does not overlap an in-flight load', (tester) async {
    final load = Completer<List<ChatSummary>>();
    final repository = FakeChatRepository(
      chats: [testDirectChat(otherUsername: 'Bob')],
    );
    final controller = ChatController(repository: repository);
    await controller.load();

    await tester.pumpWidget(
      _home(controller, homePollInterval: _testPollInterval),
    );
    await tester.pumpAndSettle();
    final callsAfterReady = repository.listMineCalls;

    repository.chatsCompleter = load;
    await tester.pump(_testPollInterval);
    expect(repository.listMineCalls, callsAfterReady + 1);

    await tester.pump(_testPollInterval);
    expect(repository.listMineCalls, callsAfterReady + 1);

    load.complete([testDirectChat(otherUsername: 'Carol')]);
    await tester.pumpAndSettle();
    expect(find.text('Carol'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('polling does not run while the application is paused', (
    tester,
  ) async {
    final repository = FakeChatRepository(
      chats: [testDirectChat(otherUsername: 'Bob')],
    );
    final controller = ChatController(repository: repository);
    await controller.load();

    await tester.pumpWidget(
      _home(controller, homePollInterval: _testPollInterval),
    );
    await tester.pumpAndSettle();
    final callsAfterReady = repository.listMineCalls;

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    repository.chats = [testDirectChat(otherUsername: 'Carol')];
    await tester.pump(_testPollInterval * 2);

    expect(repository.listMineCalls, callsAfterReady);
    expect(find.text('Bob'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('polling stops when the Home screen is disposed', (tester) async {
    final repository = FakeChatRepository(
      chats: [testDirectChat(otherUsername: 'Bob')],
    );
    final controller = ChatController(repository: repository);
    await controller.load();

    await tester.pumpWidget(
      _home(controller, homePollInterval: _testPollInterval),
    );
    await tester.pumpAndSettle();
    final callsAfterReady = repository.listMineCalls;

    await tester.pumpWidget(const SizedBox());
    repository.chats = [testDirectChat(otherUsername: 'Carol')];
    await tester.pump(_testPollInterval * 2);

    expect(repository.listMineCalls, callsAfterReady);

    controller.dispose();
  });

  testWidgets('manual Refresh still reconciles Home state', (tester) async {
    final repository = FakeChatRepository(
      chats: [testDirectChat(otherUsername: 'Bob')],
    );
    final controller = ChatController(repository: repository);
    await controller.load();

    await tester.pumpWidget(_home(controller));
    await tester.pumpAndSettle();

    repository.chats = [testDirectChat(otherUsername: 'Carol')];
    await tester.tap(find.byKey(const Key('refreshChats')));
    await tester.pumpAndSettle();

    expect(find.text('Carol'), findsOneWidget);
    expect(find.text('Bob'), findsNothing);

    controller.dispose();
  });

  testWidgets('pull-to-refresh still reconciles Home state', (tester) async {
    final repository = FakeChatRepository(
      chats: [testDirectChat(otherUsername: 'Bob')],
    );
    final controller = ChatController(repository: repository);
    await controller.load();

    await tester.pumpWidget(_home(controller));
    await tester.pumpAndSettle();

    repository.chats = [testDirectChat(otherUsername: 'Carol')];
    await tester.fling(
      find.byKey(const Key('chatList')),
      const Offset(0, 300),
      1000,
    );
    await tester.pumpAndSettle();

    expect(find.text('Carol'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('home shows the current user avatar or placeholder', (
    tester,
  ) async {
    final profiles = FakeProfileRepository(
      profile: testProfile(profileImageId: 9),
      image: testProfileImage(mediaId: 9, bytes: testPngBytes),
    );
    final profile = ProfileController(
      repository: profiles,
      username: 'Topi.J',
    );
    await profile.load();
    final controller = ChatController(repository: FakeChatRepository());
    await controller.load();

    await tester.pumpWidget(_home(controller, profile: profile));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('homeProfileAvatar')), findsOneWidget);
    expect(find.byType(DefaultAvatar), findsNothing);

    final emptyProfile = ProfileController(
      repository: FakeProfileRepository(),
      username: 'Topi.J',
    );
    await emptyProfile.load();
    await tester.pumpWidget(_home(controller, profile: emptyProfile));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('homeProfileAvatar')), findsOneWidget);
    expect(find.byType(DefaultAvatar), findsWidgets);

    profile.dispose();
    emptyProfile.dispose();
    controller.dispose();
  });

  testWidgets('home avatar updates after the profile picture is replaced', (
    tester,
  ) async {
    final profiles = FakeProfileRepository(profile: testProfile());
    final profile = ProfileController(
      repository: profiles,
      username: 'Topi.J',
    );
    await profile.load();
    final controller = ChatController(repository: FakeChatRepository());
    await controller.load();

    await tester.pumpWidget(_home(controller, profile: profile));
    await tester.pumpAndSettle();
    expect(find.byType(DefaultAvatar), findsWidgets);

    await profile.uploadProfileImage(testPngBytes);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('homeProfileAvatar')), findsOneWidget);
    expect(profile.usesDefaultAvatar, isFalse);

    profile.dispose();
    controller.dispose();
  });

  testWidgets('direct chat row shows the other user avatar only', (
    tester,
  ) async {
    final controller = ChatController(
      repository: FakeChatRepository(
        chats: [
          testDirectChat(otherUsername: 'Bob', otherProfileImageId: 21),
        ],
      ),
    );

    await tester.pumpWidget(_home(controller));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('directChatAvatar-1')), findsOneWidget);
    expect(find.byKey(const Key('homeProfileAvatar')), findsOneWidget);
    expect(
      tester
          .widget<ProfileAvatar>(find.byKey(const Key('directChatAvatar-1')))
          .profileImageId,
      21,
    );

    controller.dispose();
  });

  testWidgets('direct chat without a profile image uses the placeholder', (
    tester,
  ) async {
    final controller = ChatController(
      repository: FakeChatRepository(
        chats: [testDirectChat(otherUsername: 'Bob')],
      ),
    );

    await tester.pumpWidget(_home(controller));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('directChatAvatar-1')), findsOneWidget);
    expect(
      tester
          .widget<ProfileAvatar>(find.byKey(const Key('directChatAvatar-1')))
          .profileImageId,
      isNull,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('directChatAvatar-1')),
        matching: find.byType(DefaultAvatar),
      ),
      findsOneWidget,
    );

    controller.dispose();
  });

  testWidgets('group chat row stacks participant avatars deterministically', (
    tester,
  ) async {
    final controller = ChatController(
      repository: FakeChatRepository(
        chats: [
          testGroupChat(
            otherAvatars: [
              UserAvatarRef(username: 'Alice', profileImageId: 1),
              UserAvatarRef(username: 'Bob'),
              UserAvatarRef(username: 'Carol', profileImageId: 3),
              UserAvatarRef(username: 'Dan', profileImageId: 4),
            ],
          ),
        ],
      ),
    );

    await tester.pumpWidget(_home(controller));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('groupChatAvatar-2')), findsOneWidget);
    expect(find.byType(GroupAvatarStack), findsOneWidget);
    final stack = tester.widget<GroupAvatarStack>(
      find.byType(GroupAvatarStack),
    );
    expect(stack.imageIds, [1, null, 3, 4]);
    expect(stack.maxAvatars, 3);

    controller.dispose();
  });

  testWidgets('incoming invitation shows the sender avatar', (tester) async {
    final controller = ChatController(
      repository: FakeChatRepository(
        invitations: [
          testInvitation(id: 10, senderUsername: 'Alice', senderProfileImageId: 8),
        ],
      ),
    );

    await tester.pumpWidget(_home(controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Invitations'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('invitationAvatar-10')), findsOneWidget);

    controller.dispose();
  });

  testWidgets('opening a chat clears the unread badge', (tester) async {
    final controller = ChatController(
      repository: FakeChatRepository(
        chats: [testDirectChat(otherUsername: 'Bob', unreadCount: 2)],
      ),
    );

    await tester.pumpWidget(_home(controller));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('unreadBadge-1')), findsOneWidget);

    await tester.tap(find.byKey(const Key('chatListItem-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('unreadBadge-1')), findsNothing);

    controller.dispose();
  });
}

Color? _badgeColor(WidgetTester tester, Key key) {
  final container = tester.widget<Container>(
    find.descendant(of: find.byKey(key), matching: find.byType(Container)),
  );
  return (container.decoration as BoxDecoration?)?.color;
}

const _testPollInterval = Duration(seconds: 1);

Widget _home(
  ChatController controller, {
  ProfileController? profile,
  ThemeData? theme,
  Duration homePollInterval = const Duration(days: 1),
  Duration invitationPollInterval = const Duration(days: 1),
}) {
  final profiles = FakeProfileRepository();
  return ProfileScope(
    repository: profiles,
    images: ProfileImageStore(profiles),
    child: AuthScope(
      controller: AuthController(
        repository: FakeAuthRepository(currentUser: testMessengerUser()),
        session: FakeAuthSession(authenticated: true),
      ),
      child: MaterialApp(
        theme: theme,
        home: ChatHomeScreen(
          controller: controller,
          profile: profile,
          homePollInterval: homePollInterval,
          invitationPollInterval: invitationPollInterval,
        ),
      ),
    ),
  );
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
