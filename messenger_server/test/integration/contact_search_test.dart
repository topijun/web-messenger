import 'package:messenger_server/src/generated/protocol.dart';
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
    test('when searching for a contact then it is rejected', () async {
      await expectLater(
        () => endpoints.messengerUser.searchContact(
          sessionBuilder,
          query: 'bob',
        ),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });
  });

  withServerpod('Given Alice and Bob with email accounts', (
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
        username: 'alice_s',
        email: 'alice@example.com',
      );
      bob = await _createUser(
        session,
        sessionBuilder,
        username: 'bob_s',
        email: 'bob@example.com',
      );
    });

    test('when searching by username then the contact is returned', () async {
      final found = await endpoints.messengerUser.searchContact(
        alice.client,
        query: 'Bob_S',
      );

      expect(found?.username, 'bob_s');
      expect(found?.relation, ContactSearchRelation.none);
    });

    test('when searching by email then the contact is returned', () async {
      final found = await endpoints.messengerUser.searchContact(
        alice.client,
        query: 'BOB@example.com',
      );

      expect(found?.username, 'bob_s');
      expect(found?.relation, ContactSearchRelation.none);
    });

    test('when no user matches then the result is null', () async {
      expect(
        await endpoints.messengerUser.searchContact(
          alice.client,
          query: 'carol_s',
        ),
        isNull,
      );
      expect(
        await endpoints.messengerUser.searchContact(
          alice.client,
          query: 'carol@example.com',
        ),
        isNull,
      );
    });

    test('when searching for self by username then relation is self', () async {
      final found = await endpoints.messengerUser.searchContact(
        alice.client,
        query: 'alice_s',
      );

      expect(found?.username, 'alice_s');
      expect(found?.relation, ContactSearchRelation.self);
    });

    test('when searching for self by email then relation is self', () async {
      final found = await endpoints.messengerUser.searchContact(
        alice.client,
        query: 'alice@example.com',
      );

      expect(found?.username, 'alice_s');
      expect(found?.relation, ContactSearchRelation.self);
    });

    test('when a match is returned then it omits sensitive fields', () async {
      final found = await endpoints.messengerUser.searchContact(
        alice.client,
        query: 'bob@example.com',
      );

      expect(found, isNotNull);
      final json = found!.toJson();
      expect(json.keys, containsAll(<String>['username', 'relation']));
      expect(json.containsKey('authUserId'), isFalse);
      expect(json.containsKey('email'), isFalse);
      expect(json.containsKey('passwordHash'), isFalse);
      expect(json['username'], 'bob_s');
    });

    test('when a direct chat exists then relation is chatting', () async {
      final invitation = await endpoints.chatInvitation.inviteDirect(
        alice.client,
        username: 'bob_s',
      );
      await endpoints.chatInvitation.accept(
        bob.client,
        invitationId: invitation.invitation.id!,
      );

      final found = await endpoints.messengerUser.searchContact(
        alice.client,
        query: 'bob@example.com',
      );

      expect(found?.relation, ContactSearchRelation.chatting);
      await expectLater(
        () => endpoints.chatInvitation.inviteDirect(
          alice.client,
          username: 'bob_s',
        ),
        throwsA(isA<MessengerDirectChatAlreadyExistsException>()),
      );
    });

    test('when Alice has a pending invite then both sides see it', () async {
      await endpoints.chatInvitation.inviteDirect(
        alice.client,
        username: 'bob_s',
      );

      expect(
        (await endpoints.messengerUser.searchContact(
          alice.client,
          query: 'bob_s',
        ))?.relation,
        ContactSearchRelation.invitationSent,
      );
      expect(
        (await endpoints.messengerUser.searchContact(
          bob.client,
          query: 'alice_s',
        ))?.relation,
        ContactSearchRelation.invitationReceived,
      );
    });

    test(
      'when a pending invite exists then a second invite is rejected',
      () async {
        await endpoints.chatInvitation.inviteDirect(
          alice.client,
          username: 'bob_s',
        );

        await expectLater(
          () => endpoints.chatInvitation.inviteDirect(
            alice.client,
            username: 'bob_s',
          ),
          throwsA(isA<MessengerDuplicateInvitationException>()),
        );
      },
    );

    test('when inviting self then it is rejected', () async {
      await expectLater(
        () => endpoints.chatInvitation.inviteDirect(
          alice.client,
          username: 'alice_s',
        ),
        throwsA(isA<MessengerSelfInvitationException>()),
      );
    });
  });

  withServerpod('Given a group admin and contacts with email accounts', (
    sessionBuilder,
    endpoints,
  ) {
    late Session session;
    late _User alice;
    late _User bob;
    late _User carol;
    late ChatSummary group;

    setUp(() async {
      session = sessionBuilder.build();
      alice = await _createUser(
        session,
        sessionBuilder,
        username: 'alice_g',
        email: 'alice.g@example.com',
      );
      bob = await _createUser(
        session,
        sessionBuilder,
        username: 'bob_g',
        email: 'bob.g@example.com',
      );
      carol = await _createUser(
        session,
        sessionBuilder,
        username: 'carol_g',
        email: 'carol.g@example.com',
      );
      group = await endpoints.chat.createGroup(alice.client, name: 'Weekend');
    });

    test('when searching by username then the admin can invite', () async {
      final found = await endpoints.messengerUser.searchContact(
        alice.client,
        query: 'Carol_G',
      );
      expect(found?.username, 'carol_g');
      expect(found!.toJson().containsKey('email'), isFalse);

      final invite = await endpoints.chatInvitation.inviteToGroup(
        alice.client,
        chatId: group.chat.id!,
        username: found.username,
      );
      expect(invite.receiverUsername, 'carol_g');
      expect(invite.isGroup, isTrue);
    });

    test(
      'when searching by email then invite uses the resolved username',
      () async {
        final found = await endpoints.messengerUser.searchContact(
          alice.client,
          query: 'CAROL.G@example.com',
        );
        expect(found?.username, 'carol_g');
        expect(found!.toJson().containsKey('email'), isFalse);
        expect(found.toJson().containsKey('authUserId'), isFalse);

        await endpoints.chatInvitation.inviteToGroup(
          alice.client,
          chatId: group.chat.id!,
          username: found.username,
        );
        final pending = await endpoints.chatInvitation.listPendingMine(
          carol.client,
        );
        expect(pending.single.receiverUsername, 'carol_g');
      },
    );

    test('when the invitee accepts then membership is updated', () async {
      final found = await endpoints.messengerUser.searchContact(
        alice.client,
        query: 'bob.g@example.com',
      );
      final invite = await endpoints.chatInvitation.inviteToGroup(
        alice.client,
        chatId: group.chat.id!,
        username: found!.username,
      );
      await endpoints.chatInvitation.accept(
        bob.client,
        invitationId: invite.invitation.id!,
      );

      final members = await endpoints.chat.listMembers(
        alice.client,
        chatId: group.chat.id!,
      );
      expect(members.map((member) => member.username).toSet(), {
        'alice_g',
        'bob_g',
      });
    });

    test('when inviting an existing member then it is rejected', () async {
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
          alice.client,
          chatId: group.chat.id!,
          username: 'bob_g',
        ),
        throwsA(isA<MessengerAlreadyChatParticipantException>()),
      );
    });

    test('when the admin invites themselves then it is rejected', () async {
      final found = await endpoints.messengerUser.searchContact(
        alice.client,
        query: 'alice.g@example.com',
      );
      expect(found?.relation, ContactSearchRelation.self);

      await expectLater(
        () => endpoints.chatInvitation.inviteToGroup(
          alice.client,
          chatId: group.chat.id!,
          username: found!.username,
        ),
        throwsA(isA<MessengerSelfInvitationException>()),
      );
    });

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

    test('when the query matches nobody then search returns null', () async {
      expect(
        await endpoints.messengerUser.searchContact(
          alice.client,
          query: 'missing_g',
        ),
        isNull,
      );
      expect(
        await endpoints.messengerUser.searchContact(
          alice.client,
          query: 'missing@example.com',
        ),
        isNull,
      );
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
  String? email,
}) async {
  final authUser = await const AuthUsers().create(session);
  final user = await const MessengerUsers().create(
    session,
    authUserId: authUser.id,
    username: username,
  );
  if (email != null) {
    await EmailAccount.db.insertRow(
      session,
      EmailAccount(
        authUserId: authUser.id,
        email: email.toLowerCase(),
        passwordHash: 'unused-for-contact-search',
      ),
    );
  }
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
