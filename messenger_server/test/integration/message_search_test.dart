import 'package:messenger_server/src/generated/protocol.dart';
import 'package:messenger_server/src/users/messenger_users.dart';
import 'package:serverpod/serverpod.dart' hide Message;
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given an unauthenticated session', (
    sessionBuilder,
    endpoints,
  ) {
    test('when searching messages then it is rejected', () async {
      await expectLater(
        () => endpoints.message.searchText(
          sessionBuilder,
          chatId: 1,
          query: 'hello',
        ),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });
  });

  withServerpod('Given a direct chat between Alice and Bob', (
    sessionBuilder,
    endpoints,
  ) {
    late Session session;
    late _User alice;
    late _User bob;
    late _User carol;
    late int chatId;

    setUp(() async {
      session = sessionBuilder.build();
      alice = await _createUser(
        session,
        sessionBuilder,
        username: 'alice_search',
      );
      bob = await _createUser(session, sessionBuilder, username: 'bob_search');
      carol = await _createUser(
        session,
        sessionBuilder,
        username: 'carol_search',
      );
      chatId = await _directChat(endpoints, alice, bob);
    });

    test('when searching hello then only matching text is returned', () async {
      await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'Hello Bob',
      );
      await endpoints.message.sendText(
        bob.client,
        chatId: chatId,
        encryptedText: 'How are you?',
      );
      await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'hello again',
      );

      final results = await endpoints.message.searchText(
        bob.client,
        chatId: chatId,
        query: 'hello',
      );

      expect(
        results.map((view) => view.message.encryptedText),
        ['hello again', 'Hello Bob'],
      );
      expect(results.map((view) => view.message.chatId), everyElement(chatId));
      expect(results.every((view) => view.message.id != null), isTrue);
    });

    test(
      'when the query case differs then matches are still returned',
      () async {
        await endpoints.message.sendText(
          alice.client,
          chatId: chatId,
          encryptedText: 'Hello',
        );
        await endpoints.message.sendText(
          bob.client,
          chatId: chatId,
          encryptedText: 'hello',
        );
        await endpoints.message.sendText(
          alice.client,
          chatId: chatId,
          encryptedText: 'HELLO',
        );

        final results = await endpoints.message.searchText(
          alice.client,
          chatId: chatId,
          query: 'HELLO',
        );

        expect(
          results.map((view) => view.message.encryptedText),
          ['HELLO', 'hello', 'Hello'],
        );
      },
    );

    test('when nothing matches then the result is empty', () async {
      await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'Hello Bob',
      );

      final results = await endpoints.message.searchText(
        alice.client,
        chatId: chatId,
        query: 'missing',
      );

      expect(results, isEmpty);
    });

    test('when the query is blank then no messages are returned', () async {
      await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'Hello Bob',
      );

      final results = await endpoints.message.searchText(
        alice.client,
        chatId: chatId,
        query: '   ',
      );

      expect(results, isEmpty);
    });

    test(
      'when the caller is not a participant then search is rejected',
      () async {
        await endpoints.message.sendText(
          alice.client,
          chatId: chatId,
          encryptedText: 'Hello Bob',
        );

        await expectLater(
          () => endpoints.message.searchText(
            carol.client,
            chatId: chatId,
            query: 'hello',
          ),
          throwsA(isA<MessengerNotChatMemberException>()),
        );
        await expectLater(
          () => endpoints.message.searchText(
            carol.client,
            chatId: chatId,
            query: '   ',
          ),
          throwsA(isA<MessengerNotChatMemberException>()),
        );
      },
    );

    test('when searching then stored message text stays encrypted', () async {
      final view = await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'Hello Bob',
      );

      final results = await endpoints.message.searchText(
        bob.client,
        chatId: chatId,
        query: 'hello',
      );

      expect(results.single.message.encryptedText, 'Hello Bob');
      final stored = await Message.db.findById(session, view.message.id!);
      expect(stored?.encryptedText, isNot('Hello Bob'));
      expect(stored?.encryptedText, startsWith('v1:'));
    });

    test('when a group member searches then that chat is matched', () async {
      final groupId = await _groupChat(endpoints, alice, [bob]);
      await endpoints.message.sendText(
        bob.client,
        chatId: groupId,
        encryptedText: 'Hello group',
      );
      await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'Hello direct',
      );

      final results = await endpoints.message.searchText(
        alice.client,
        chatId: groupId,
        query: 'hello',
      );

      expect(results.single.message.encryptedText, 'Hello group');
      expect(results.single.message.chatId, groupId);
      await expectLater(
        () => endpoints.message.searchText(
          carol.client,
          chatId: groupId,
          query: 'hello',
        ),
        throwsA(isA<MessengerNotChatMemberException>()),
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

Future<int> _directChat(
  TestEndpoints endpoints,
  _User alice,
  _User bob,
) async {
  final invitation = await endpoints.chatInvitation.inviteDirect(
    alice.client,
    username: bob.user.username,
  );
  final summary = await endpoints.chatInvitation.accept(
    bob.client,
    invitationId: invitation.invitation.id!,
  );
  return summary.chat.id as int;
}

Future<int> _groupChat(
  TestEndpoints endpoints,
  _User admin,
  List<_User> members,
) async {
  final created = await endpoints.chat.createGroup(
    admin.client,
    name: 'Weekend',
  );
  final chatId = created.chat.id as int;
  for (final member in members) {
    await endpoints.chatInvitation.inviteToGroup(
      admin.client,
      chatId: chatId,
      username: member.user.username,
    );
    final pending = await endpoints.chatInvitation.listPendingMine(
      member.client,
    );
    await endpoints.chatInvitation.accept(
      member.client,
      invitationId: pending.single.invitation.id!,
    );
  }
  return chatId;
}
