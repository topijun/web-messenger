import 'package:messenger_server/src/generated/protocol.dart';
import 'package:messenger_server/src/users/messenger_users.dart';
import 'package:serverpod/serverpod.dart' hide Message;
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given a fresh Phase 7 database', (
    sessionBuilder,
    endpoints,
  ) {
    late Session session;
    late _User alice;
    late _User bob;

    setUp(() async {
      session = sessionBuilder.build();
      alice = await _createUser(session, sessionBuilder, username: 'alice_r');
      bob = await _createUser(session, sessionBuilder, username: 'bob_r');
    });

    test('when creating a direct chat then it appears in listMine', () async {
      final invitation = await endpoints.chatInvitation.inviteDirect(
        alice.client,
        username: bob.user.username,
      );
      await endpoints.chatInvitation.accept(
        bob.client,
        invitationId: invitation.invitation.id!,
      );

      final listed = await endpoints.chat.listMine(alice.client);
      expect(listed, hasLength(1));
      expect(listed.single.chat.type, ChatType.direct);
      expect(listed.single.chat.name, isNull);
      expect(listed.single.otherUsernames, [bob.user.username]);
    });

    test(
      'when listing a direct chat then null Chat.name is not decrypted',
      () async {
        final invitation = await endpoints.chatInvitation.inviteDirect(
          alice.client,
          username: bob.user.username,
        );
        final accepted = await endpoints.chatInvitation.accept(
          bob.client,
          invitationId: invitation.invitation.id!,
        );

        final stored = await Chat.db.findById(session, accepted.chat.id!);
        expect(stored, isNotNull);
        expect(stored!.type, ChatType.direct);
        expect(stored.name, isNull);

        final listed = await endpoints.chat.listMine(bob.client);
        expect(listed, hasLength(1));
        expect(listed.single.chat.id, stored.id);
        expect(listed.single.chat.name, isNull);
      },
    );

    test(
      'when creating PHASE7_GROUP_REGRESSION then it lists with plaintext',
      () async {
        const plaintext = 'PHASE7_GROUP_REGRESSION';
        final created = await endpoints.chat.createGroup(
          alice.client,
          name: plaintext,
        );

        final stored = await Chat.db.findById(session, created.chat.id!);
        expect(stored, isNotNull);
        expect(stored!.name, isNot(plaintext));
        expect(stored.name, startsWith('v1:'));
        expect(created.chat.name, plaintext);

        final listed = await endpoints.chat.listMine(alice.client);
        expect(listed, hasLength(1));
        expect(listed.single.chat.name, plaintext);
      },
    );

    test(
      'when sending a direct invitation then the receiver can list it',
      () async {
        await endpoints.chatInvitation.inviteDirect(
          alice.client,
          username: bob.user.username,
        );

        final pending = await endpoints.chatInvitation.listPendingMine(
          bob.client,
        );
        expect(pending, hasLength(1));
        expect(pending.single.isGroup, isFalse);
        expect(pending.single.chatName, isNull);
        expect(pending.single.senderUsername, alice.user.username);
        expect(pending.single.invitation.chatId, isNull);

        final accepted = await endpoints.chatInvitation.accept(
          bob.client,
          invitationId: pending.single.invitation.id!,
        );
        expect(accepted.chat.type, ChatType.direct);

        final aliceChats = await endpoints.chat.listMine(alice.client);
        final bobChats = await endpoints.chat.listMine(bob.client);
        expect(aliceChats, hasLength(1));
        expect(bobChats, hasLength(1));
        expect(aliceChats.single.chat.id, bobChats.single.chat.id);
      },
    );

    test(
      'when inviting to a group then the receiver sees the decrypted name',
      () async {
        const plaintext = 'PHASE7_GROUP_REGRESSION';
        final group = await endpoints.chat.createGroup(
          alice.client,
          name: plaintext,
        );
        final invite = await endpoints.chatInvitation.inviteToGroup(
          alice.client,
          chatId: group.chat.id!,
          username: bob.user.username,
        );
        expect(invite.chatName, plaintext);
        expect(invite.isGroup, isTrue);

        final pending = await endpoints.chatInvitation.listPendingMine(
          bob.client,
        );
        expect(pending, hasLength(1));
        expect(pending.single.isGroup, isTrue);
        expect(pending.single.chatName, plaintext);

        final accepted = await endpoints.chatInvitation.accept(
          bob.client,
          invitationId: pending.single.invitation.id!,
        );
        expect(accepted.chat.id, group.chat.id);
        expect(accepted.membership.userId, bob.user.id);

        final bobChats = await endpoints.chat.listMine(bob.client);
        expect(bobChats.single.chat.name, plaintext);
      },
    );

    test(
      'when one group name is leftover plaintext then other chats still list',
      () async {
        const leftover = 'LEGACY_PLAINTEXT_GROUP';
        const freshName = 'PHASE7_GROUP_REGRESSION';

        final invitation = await endpoints.chatInvitation.inviteDirect(
          alice.client,
          username: bob.user.username,
        );
        final direct = await endpoints.chatInvitation.accept(
          bob.client,
          invitationId: invitation.invitation.id!,
        );
        final fresh = await endpoints.chat.createGroup(
          alice.client,
          name: freshName,
        );
        final leftoverChat = await Chat.db.insertRow(
          session,
          Chat(type: ChatType.group, name: leftover),
        );
        await ChatParticipant.db.insertRow(
          session,
          ChatParticipant(
            chatId: leftoverChat.id!,
            userId: alice.user.id!,
            role: ChatParticipantRole.admin,
          ),
        );

        final listed = await endpoints.chat.listMine(alice.client);
        expect(
          listed.map((item) => item.chat.id),
          containsAll([direct.chat.id, fresh.chat.id, leftoverChat.id]),
        );

        final leftoverListed = listed.firstWhere(
          (item) => item.chat.id == leftoverChat.id,
        );
        expect(leftoverListed.chat.name, isNot(leftover));
        expect(leftoverListed.chat.name, isNull);

        final freshListed = listed.firstWhere(
          (item) => item.chat.id == fresh.chat.id,
        );
        expect(freshListed.chat.name, freshName);

        final directListed = listed.firstWhere(
          (item) => item.chat.id == direct.chat.id,
        );
        expect(directListed.chat.name, isNull);
        expect(directListed.chat.type, ChatType.direct);
      },
    );

    test(
      'when a leftover plaintext group exists then direct invitations still list',
      () async {
        final leftoverChat = await Chat.db.insertRow(
          session,
          Chat(type: ChatType.group, name: 'LEGACY_PLAINTEXT_GROUP'),
        );
        await ChatParticipant.db.insertRow(
          session,
          ChatParticipant(
            chatId: leftoverChat.id!,
            userId: bob.user.id!,
            role: ChatParticipantRole.member,
          ),
        );

        await endpoints.chatInvitation.inviteDirect(
          alice.client,
          username: bob.user.username,
        );

        final pending = await endpoints.chatInvitation.listPendingMine(
          bob.client,
        );
        expect(pending, hasLength(1));
        expect(pending.single.isGroup, isFalse);
        expect(pending.single.invitation.chatId, isNull);
        expect(pending.single.senderUsername, alice.user.username);
      },
    );

    test(
      'when inviting to a leftover plaintext group then the invitation still lists',
      () async {
        const leftover = 'LEGACY_PLAINTEXT_GROUP';
        final leftoverChat = await Chat.db.insertRow(
          session,
          Chat(type: ChatType.group, name: leftover),
        );
        await ChatParticipant.db.insertRow(
          session,
          ChatParticipant(
            chatId: leftoverChat.id!,
            userId: alice.user.id!,
            role: ChatParticipantRole.admin,
          ),
        );

        final invite = await endpoints.chatInvitation.inviteToGroup(
          alice.client,
          chatId: leftoverChat.id!,
          username: bob.user.username,
        );
        expect(invite.isGroup, isTrue);
        expect(invite.chatName, isNot(leftover));
        expect(invite.chatName, isNull);

        final pending = await endpoints.chatInvitation.listPendingMine(
          bob.client,
        );
        expect(pending, hasLength(1));
        expect(pending.single.isGroup, isTrue);
        expect(pending.single.invitation.chatId, leftoverChat.id);
        expect(pending.single.chatName, isNot(leftover));
        expect(pending.single.chatName, isNull);
      },
    );
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
