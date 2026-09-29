import 'dart:async';

import 'package:messenger_server/src/generated/protocol.dart';
import 'package:messenger_server/src/messages/messages.dart';
import 'package:messenger_server/src/users/messenger_users.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given an unauthenticated session', (
    sessionBuilder,
    endpoints,
  ) {
    test('when listing chats then it is rejected', () async {
      await expectLater(
        () => endpoints.chat.listMine(sessionBuilder),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });

    test('when inviting to a direct chat then it is rejected', () async {
      await expectLater(
        () => endpoints.chatInvitation.inviteDirect(
          sessionBuilder,
          username: 'bob',
        ),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });
  });

  withServerpod('Given two authenticated MessengerUsers', (
    sessionBuilder,
    endpoints,
  ) {
    late Session session;
    late _User alice;
    late _User bob;

    setUp(() async {
      session = sessionBuilder.build();
      alice = await _createUser(
        session,
        sessionBuilder,
        username: 'alice_chat',
      );
      bob = await _createUser(session, sessionBuilder, username: 'bob_chat');
    });

    test('when inviting yourself then it is rejected', () async {
      await expectLater(
        () => endpoints.chatInvitation.inviteDirect(
          alice.client,
          username: 'alice_chat',
        ),
        throwsA(isA<MessengerSelfInvitationException>()),
      );
    });

    test('when inviting an unknown user then it is rejected', () async {
      await expectLater(
        () => endpoints.chatInvitation.inviteDirect(
          alice.client,
          username: 'nobody',
        ),
        throwsA(isA<MessengerUserNotFoundException>()),
      );
    });

    test(
      'when sending a direct invitation then Bob can see it pending',
      () async {
        await endpoints.chatInvitation.inviteDirect(
          alice.client,
          username: 'bob_chat',
        );

        final rows = await ChatInvitation.db.find(session);
        expect(rows, hasLength(1));
        expect(rows.single.senderId, alice.user.id);
        expect(rows.single.receiverId, bob.user.id);
        expect(rows.single.chatId, isNull);
        expect(rows.single.status, ChatInvitationStatus.pending);

        final pending = await endpoints.chatInvitation.listPendingMine(
          bob.client,
        );
        expect(pending, hasLength(1));
        expect(pending.single.senderUsername, 'alice_chat');
        expect(pending.single.receiverUsername, 'bob_chat');
        expect(pending.single.isGroup, isFalse);
        expect(pending.single.invitation.status, ChatInvitationStatus.pending);
        expect(pending.single.invitation.senderId, alice.user.id);
        expect(pending.single.invitation.receiverId, bob.user.id);

        final alicePending = await endpoints.chatInvitation.listPendingMine(
          alice.client,
        );
        expect(alicePending, isEmpty);
      },
    );

    test(
      'when inviting then Bob receives an invitation ChatEvent',
      () async {
        final events = <ChatEvent>[];
        final stream = session.messages.createStream<ChatEvent>(
          Messages.channelForUser(bob.user.id!),
        );
        final subscription = stream.listen(events.add);

        final view = await endpoints.chatInvitation.inviteDirect(
          alice.client,
          username: 'bob_chat',
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));
        final invitations = events
            .where((event) => event.kind == ChatEventKind.invitation)
            .toList();
        expect(invitations, hasLength(1));
        expect(invitations.single.chatId, 0);
        expect(
          invitations.single.invitation?.invitation.id,
          view.invitation.id,
        );
        expect(invitations.single.invitation?.senderUsername, 'alice_chat');
        await subscription.cancel();
      },
    );

    test(
      'when sending the same direct invitation twice then it is rejected',
      () async {
        await endpoints.chatInvitation.inviteDirect(
          alice.client,
          username: 'bob_chat',
        );

        await expectLater(
          () => endpoints.chatInvitation.inviteDirect(
            alice.client,
            username: 'bob_chat',
          ),
          throwsA(isA<MessengerDuplicateInvitationException>()),
        );
      },
    );

    test(
      'when Bob also invites Alice while pending then it is a duplicate',
      () async {
        await endpoints.chatInvitation.inviteDirect(
          alice.client,
          username: 'bob_chat',
        );

        await expectLater(
          () => endpoints.chatInvitation.inviteDirect(
            bob.client,
            username: 'alice_chat',
          ),
          throwsA(isA<MessengerDuplicateInvitationException>()),
        );
      },
    );

    test(
      'when Bob accepts then one direct chat with two participants is created',
      () async {
        final invitation = await endpoints.chatInvitation.inviteDirect(
          alice.client,
          username: 'bob_chat',
        );

        final summary = await endpoints.chatInvitation.accept(
          bob.client,
          invitationId: invitation.invitation.id!,
        );

        expect(summary.chat.type, ChatType.direct);
        expect(summary.chat.name, isNull);
        expect(summary.membership.userId, bob.user.id);
        expect(summary.otherUsernames, ['alice_chat']);

        final members = await endpoints.chat.listMembers(
          bob.client,
          chatId: summary.chat.id!,
        );
        expect(members, hasLength(2));
        expect(members.map((member) => member.username).toSet(), {
          'alice_chat',
          'bob_chat',
        });

        final aliceChats = await endpoints.chat.listMine(alice.client);
        final bobChats = await endpoints.chat.listMine(bob.client);
        expect(aliceChats, hasLength(1));
        expect(bobChats, hasLength(1));
        expect(aliceChats.single.chat.id, bobChats.single.chat.id);

        final stored = await ChatInvitation.db.findById(
          session,
          invitation.invitation.id!,
        );
        expect(stored?.status, ChatInvitationStatus.accepted);
        expect(stored?.chatId, summary.chat.id);
        expect(await Chat.db.find(session), hasLength(1));
        expect(await ChatParticipant.db.find(session), hasLength(2));
      },
    );

    test('when Bob declines then no chat is created', () async {
      final invitation = await endpoints.chatInvitation.inviteDirect(
        alice.client,
        username: 'bob_chat',
      );

      await endpoints.chatInvitation.decline(
        bob.client,
        invitationId: invitation.invitation.id!,
      );

      expect(await endpoints.chat.listMine(alice.client), isEmpty);
      expect(await endpoints.chat.listMine(bob.client), isEmpty);
      expect(await Chat.db.find(session), isEmpty);
      expect(await ChatParticipant.db.find(session), isEmpty);
      final stored = await ChatInvitation.db.findById(
        session,
        invitation.invitation.id!,
      );
      expect(stored?.status, ChatInvitationStatus.declined);
      expect(stored?.chatId, isNull);
    });

    test(
      'when a direct chat exists then another invitation is rejected',
      () async {
        final invitation = await endpoints.chatInvitation.inviteDirect(
          alice.client,
          username: 'bob_chat',
        );
        await endpoints.chatInvitation.accept(
          bob.client,
          invitationId: invitation.invitation.id!,
        );

        await expectLater(
          () => endpoints.chatInvitation.inviteDirect(
            alice.client,
            username: 'bob_chat',
          ),
          throwsA(isA<MessengerDirectChatAlreadyExistsException>()),
        );
        expect(await endpoints.chat.listMine(alice.client), hasLength(1));
      },
    );

    test('when accepting twice then it is rejected', () async {
      final invitation = await endpoints.chatInvitation.inviteDirect(
        alice.client,
        username: 'bob_chat',
      );
      await endpoints.chatInvitation.accept(
        bob.client,
        invitationId: invitation.invitation.id!,
      );

      await expectLater(
        () => endpoints.chatInvitation.accept(
          bob.client,
          invitationId: invitation.invitation.id!,
        ),
        throwsA(isA<MessengerInvitationAlreadyHandledException>()),
      );
    });

    test('when declining twice then it is rejected', () async {
      final invitation = await endpoints.chatInvitation.inviteDirect(
        alice.client,
        username: 'bob_chat',
      );
      await endpoints.chatInvitation.decline(
        bob.client,
        invitationId: invitation.invitation.id!,
      );

      await expectLater(
        () => endpoints.chatInvitation.decline(
          bob.client,
          invitationId: invitation.invitation.id!,
        ),
        throwsA(isA<MessengerInvitationAlreadyHandledException>()),
      );
    });

    test(
      'when Alice tries to accept Bob\'s invitation then it is rejected',
      () async {
        final invitation = await endpoints.chatInvitation.inviteDirect(
          alice.client,
          username: 'bob_chat',
        );

        await expectLater(
          () => endpoints.chatInvitation.accept(
            alice.client,
            invitationId: invitation.invitation.id!,
          ),
          throwsA(isA<MessengerInvitationNotFoundException>()),
        );
      },
    );

    test('when looking up a username then the user is returned', () async {
      final found = await endpoints.messengerUser.lookupByUsername(
        alice.client,
        username: 'Bob_Chat',
      );
      expect(found?.id, bob.user.id);
      expect(found?.username, 'bob_chat');
    });
  });

  withServerpod('Given an authenticated group admin and a member', (
    sessionBuilder,
    endpoints,
  ) {
    late _User alice;
    late _User bob;
    late ChatSummary group;

    setUp(() async {
      final session = sessionBuilder.build();
      alice = await _createUser(session, sessionBuilder, username: 'alice_g');
      bob = await _createUser(session, sessionBuilder, username: 'bob_g');
      await _createUser(session, sessionBuilder, username: 'carol_g');
      group = await endpoints.chat.createGroup(alice.client, name: ' Weekend ');
    });

    test('when creating a group then the creator is admin', () async {
      expect(group.chat.type, ChatType.group);
      expect(group.chat.name, 'Weekend');
      expect(group.membership.role, ChatParticipantRole.admin);
      expect(group.membership.userId, alice.user.id);

      final members = await endpoints.chat.listMembers(
        alice.client,
        chatId: group.chat.id!,
      );
      expect(members, hasLength(1));
      expect(members.single.role, ChatParticipantRole.admin);
    });

    test('when a non-member lists members then it is rejected', () async {
      await expectLater(
        () => endpoints.chat.listMembers(bob.client, chatId: group.chat.id!),
        throwsA(isA<MessengerNotChatMemberException>()),
      );
    });

    test(
      'when Alice invites Bob then only Bob sees the pending invitation',
      () async {
        await endpoints.chatInvitation.inviteToGroup(
          alice.client,
          chatId: group.chat.id!,
          username: 'bob_g',
        );

        final bobPending = await endpoints.chatInvitation.listPendingMine(
          bob.client,
        );
        expect(bobPending, hasLength(1));
        expect(bobPending.single.isGroup, isTrue);
        expect(bobPending.single.chatName, 'Weekend');
        expect(bobPending.single.invitation.chatId, group.chat.id);
        expect(bobPending.single.invitation.receiverId, bob.user.id);

        final alicePending = await endpoints.chatInvitation.listPendingMine(
          alice.client,
        );
        expect(alicePending, isEmpty);
      },
    );

    test('when a non-admin invites then it is rejected', () async {
      final invite = await endpoints.chatInvitation.inviteToGroup(
        alice.client,
        chatId: group.chat.id!,
        username: 'bob_g',
      );
      await endpoints.chatInvitation.accept(
        bob.client,
        invitationId: invite.invitation.id!,
      );

      await expectLater(
        () => endpoints.chatInvitation.inviteToGroup(
          bob.client,
          chatId: group.chat.id!,
          username: 'carol_g',
        ),
        throwsA(isA<MessengerNotChatAdminException>()),
      );
    });

    test('when Bob accepts a group invite then he becomes a member', () async {
      final invite = await endpoints.chatInvitation.inviteToGroup(
        alice.client,
        chatId: group.chat.id!,
        username: 'bob_g',
      );
      final accepted = await endpoints.chatInvitation.accept(
        bob.client,
        invitationId: invite.invitation.id!,
      );

      expect(accepted.chat.id, group.chat.id);
      expect(accepted.membership.role, ChatParticipantRole.member);
      final members = await endpoints.chat.listMembers(
        alice.client,
        chatId: group.chat.id!,
      );
      expect(members.map((member) => member.username).toSet(), {
        'alice_g',
        'bob_g',
      });
    });

    test('when Bob declines a group invite then he is not added', () async {
      final invite = await endpoints.chatInvitation.inviteToGroup(
        alice.client,
        chatId: group.chat.id!,
        username: 'bob_g',
      );
      await endpoints.chatInvitation.decline(
        bob.client,
        invitationId: invite.invitation.id!,
      );

      final members = await endpoints.chat.listMembers(
        alice.client,
        chatId: group.chat.id!,
      );
      expect(members, hasLength(1));
      expect(await endpoints.chat.listMine(bob.client), isEmpty);
    });

    test('when inviting an existing member then it is rejected', () async {
      await expectLater(
        () => endpoints.chatInvitation.inviteToGroup(
          alice.client,
          chatId: group.chat.id!,
          username: 'alice_g',
        ),
        throwsA(isA<MessengerSelfInvitationException>()),
      );
    });
  });

  withServerpod('Given a chat participant', (sessionBuilder, endpoints) {
    late Session session;
    late _User alice;
    late _User bob;
    late ChatSummary chat;

    setUp(() async {
      session = sessionBuilder.build();
      alice = await _createUser(session, sessionBuilder, username: 'alice_p');
      bob = await _createUser(session, sessionBuilder, username: 'bob_p');
      chat = await endpoints.chat.createGroup(alice.client, name: 'Team');
    });

    test(
      'when inserting the same participant twice then uniqueness holds',
      () async {
        await expectLater(
          () => ChatParticipant.db.insertRow(
            session,
            ChatParticipant(
              chatId: chat.chat.id!,
              userId: alice.user.id!,
              role: ChatParticipantRole.member,
            ),
          ),
          throwsA(isA<DatabaseQueryException>()),
        );
      },
    );

    test(
      'when Alice archives and mutes then only her membership changes',
      () async {
        final invite = await endpoints.chatInvitation.inviteToGroup(
          alice.client,
          chatId: chat.chat.id!,
          username: 'bob_p',
        );
        await endpoints.chatInvitation.accept(
          bob.client,
          invitationId: invite.invitation.id!,
        );

        await endpoints.chat.setArchived(
          alice.client,
          chatId: chat.chat.id!,
          archived: true,
        );
        await endpoints.chat.setMuted(
          alice.client,
          chatId: chat.chat.id!,
          notificationsMuted: true,
        );

        final aliceChat = (await endpoints.chat.listMine(alice.client)).single;
        final bobChat = (await endpoints.chat.listMine(bob.client)).single;
        expect(aliceChat.membership.archived, isTrue);
        expect(aliceChat.membership.notificationsMuted, isTrue);
        expect(bobChat.membership.archived, isFalse);
        expect(bobChat.membership.notificationsMuted, isFalse);

        await endpoints.chat.setArchived(
          alice.client,
          chatId: chat.chat.id!,
          archived: false,
        );
        expect(
          (await endpoints.chat.listMine(
            alice.client,
          )).single.membership.archived,
          isFalse,
        );
      },
    );

    test('when Bob archives a chat he is not in then it is rejected', () async {
      await expectLater(
        () => endpoints.chat.setArchived(
          bob.client,
          chatId: chat.chat.id!,
          archived: true,
        ),
        throwsA(isA<MessengerNotChatMemberException>()),
      );
    });
  });

  withServerpod('Given chats for two users', (sessionBuilder, endpoints) {
    late Session session;
    late _User alice;
    late _User bob;

    setUp(() async {
      session = sessionBuilder.build();
      alice = await _createUser(session, sessionBuilder, username: 'alice_l');
      bob = await _createUser(session, sessionBuilder, username: 'bob_l');
    });

    test(
      'when listing chats then only the current user\'s chats are returned',
      () async {
        await endpoints.chat.createGroup(alice.client, name: 'Alice only');
        await endpoints.chat.createGroup(bob.client, name: 'Bob only');

        final aliceChats = await endpoints.chat.listMine(alice.client);
        final bobChats = await endpoints.chat.listMine(bob.client);
        expect(aliceChats.map((item) => item.chat.name), ['Alice only']);
        expect(bobChats.map((item) => item.chat.name), ['Bob only']);
      },
    );

    test('when lastMessageAt is set then chats are ordered by it', () async {
      final older = await endpoints.chat.createGroup(
        alice.client,
        name: 'Older',
      );
      final newer = await endpoints.chat.createGroup(
        alice.client,
        name: 'Newer',
      );

      final olderStored = await Chat.db.findById(session, older.chat.id!);
      final newerStored = await Chat.db.findById(session, newer.chat.id!);
      await Chat.db.updateRow(
        session,
        olderStored!.copyWith(
          lastMessageAt: DateTime.utc(2026, 1, 1),
        ),
      );
      await Chat.db.updateRow(
        session,
        newerStored!.copyWith(
          lastMessageAt: DateTime.utc(2026, 6, 1),
        ),
      );

      final chats = await endpoints.chat.listMine(alice.client);
      expect(chats.map((item) => item.chat.name), ['Newer', 'Older']);
    });
  });
}

class _User {
  const _User({required this.user, required this.client});

  final MessengerUser user;
  final TestSessionBuilder client;
}

Future<_User> _createUser(
  Session session,
  TestSessionBuilder sessionBuilder, {
  required String username,
}) async {
  final authUser = await const AuthUsers().create(session);
  final user = await const MessengerUsers().create(
    session,
    authUserId: authUser.id,
    username: username,
  );
  return _User(
    user: user,
    client: sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        authUser.id.toString(),
        {},
      ),
    ),
  );
}
