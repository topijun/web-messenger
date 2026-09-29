import 'package:messenger_server/src/generated/protocol.dart';
import 'package:messenger_server/src/users/messenger_users.dart';
import 'package:serverpod/serverpod.dart' hide Message;
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given an authenticated MessengerUser', (
    sessionBuilder,
    endpoints,
  ) {
    late Session session;
    late _User alice;
    late _User bob;

    setUp(() async {
      session = sessionBuilder.build();
      alice = await _createUser(session, sessionBuilder, username: 'alice_enc');
      bob = await _createUser(session, sessionBuilder, username: 'bob_enc');
    });

    test(
      'when sending a message then PostgreSQL stores ciphertext',
      () async {
        final invitation = await endpoints.chatInvitation.inviteDirect(
          alice.client,
          username: bob.user.username,
        );
        final chat = await endpoints.chatInvitation.accept(
          bob.client,
          invitationId: invitation.invitation.id!,
        );

        const plaintext = 'SECRET_MESSAGE_PHASE7';
        final view = await endpoints.message.sendText(
          alice.client,
          chatId: chat.chat.id!,
          encryptedText: plaintext,
        );

        final stored = await Message.db.findById(session, view.message.id!);
        expect(stored, isNotNull);
        expect(stored!.encryptedText, isNot(plaintext));
        expect(stored.encryptedText, startsWith('v1:'));
        expect(view.message.encryptedText, plaintext);

        final page = await endpoints.message.listHistory(
          bob.client,
          chatId: chat.chat.id!,
        );
        expect(page.messages.single.message.encryptedText, plaintext);
      },
    );

    test(
      'when updating About Me then PostgreSQL stores ciphertext',
      () async {
        const plaintext = 'SECRET_PROFILE_PHASE7';
        final updated = await endpoints.profile.updateMine(
          alice.client,
          aboutMe: plaintext,
        );

        final stored = await Profile.db.findFirstRow(
          session,
          where: (t) => t.userId.equals(alice.user.id),
        );
        expect(stored, isNotNull);
        expect(stored!.aboutMe, isNot(plaintext));
        expect(stored.aboutMe, startsWith('v1:'));
        expect(updated.aboutMe, plaintext);

        final fetched = await endpoints.profile.getMine(alice.client);
        expect(fetched.aboutMe, plaintext);
      },
    );

    test(
      'when creating a group then PostgreSQL stores an encrypted name',
      () async {
        const plaintext = 'SECRET_GROUP_PHASE7';
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
        expect(listed.single.chat.name, plaintext);
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
