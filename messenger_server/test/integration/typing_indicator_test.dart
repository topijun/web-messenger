import 'package:messenger_server/src/generated/protocol.dart';
import 'package:messenger_server/src/messages/messages.dart';
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
    test('when emitting typing then it is rejected', () async {
      await expectLater(
        () => endpoints.message.setTyping(
          sessionBuilder,
          chatId: 1,
          isTyping: true,
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
      alice = await _createUser(session, sessionBuilder, username: 'alice_typ');
      bob = await _createUser(session, sessionBuilder, username: 'bob_typ');
      carol = await _createUser(session, sessionBuilder, username: 'carol_typ');
      chatId = await _directChat(endpoints, alice, bob);
    });

    test('when a non-member emits typing then it is rejected', () async {
      await expectLater(
        () => endpoints.message.setTyping(
          carol.client,
          chatId: chatId,
          isTyping: true,
        ),
        throwsA(isA<MessengerNotChatMemberException>()),
      );
    });

    test(
      'when Alice types then Bob receives start/stop without message text',
      () async {
        final events = <ChatEvent>[];
        final stream = session.messages.createStream<ChatEvent>(
          Messages.channelForUser(bob.user.id!),
        );
        final subscription = stream.listen(events.add);

        await endpoints.message.setTyping(
          alice.client,
          chatId: chatId,
          isTyping: true,
        );
        await endpoints.message.setTyping(
          alice.client,
          chatId: chatId,
          isTyping: false,
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final typing = events
            .where(
              (event) =>
                  event.kind == ChatEventKind.typingStarted ||
                  event.kind == ChatEventKind.typingStopped,
            )
            .toList();
        expect(typing, hasLength(2));
        expect(typing.first.kind, ChatEventKind.typingStarted);
        expect(typing.last.kind, ChatEventKind.typingStopped);
        for (final event in typing) {
          expect(event.chatId, chatId);
          expect(event.typingUserId, alice.user.id);
          expect(event.typingUsername, 'alice_typ');
          expect(event.message, isNull);
          expect(event.receipt, isNull);
        }
        await subscription.cancel();
      },
    );

    test('when Alice types then she does not receive her own event', () async {
      final events = <ChatEvent>[];
      final stream = session.messages.createStream<ChatEvent>(
        Messages.channelForUser(alice.user.id!),
      );
      final subscription = stream.listen(events.add);

      await endpoints.message.setTyping(
        alice.client,
        chatId: chatId,
        isTyping: true,
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(events, isEmpty);
      await subscription.cancel();
    });

    test('when Alice types then Carol does not receive the event', () async {
      final events = <ChatEvent>[];
      final stream = session.messages.createStream<ChatEvent>(
        Messages.channelForUser(carol.user.id!),
      );
      final subscription = stream.listen(events.add);

      await endpoints.message.setTyping(
        alice.client,
        chatId: chatId,
        isTyping: true,
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(events, isEmpty);
      await subscription.cancel();
    });

    test('when emitting typing then nothing is persisted', () async {
      final before = await Chat.db.findById(session, chatId);
      final messagesBefore = await Message.db.count(session);
      final receiptsBefore = await MessageReceipt.db.count(session);

      await endpoints.message.setTyping(
        alice.client,
        chatId: chatId,
        isTyping: true,
      );

      final after = await Chat.db.findById(session, chatId);
      expect(await Message.db.count(session), messagesBefore);
      expect(await MessageReceipt.db.count(session), receiptsBefore);
      expect(after?.lastMessageAt, before?.lastMessageAt);
      expect(after?.updatedAt, before?.updatedAt);

      final history = await endpoints.message.listHistory(
        bob.client,
        chatId: chatId,
      );
      expect(history.messages, isEmpty);
    });
  });

  withServerpod('Given a group chat and an unrelated direct chat', (
    sessionBuilder,
    endpoints,
  ) {
    late Session session;
    late _User alice;
    late _User bob;
    late _User carol;
    late _User dave;
    late int groupId;
    late int daveChatId;

    setUp(() async {
      session = sessionBuilder.build();
      alice = await _createUser(session, sessionBuilder, username: 'alice_grp');
      bob = await _createUser(session, sessionBuilder, username: 'bob_grp');
      carol = await _createUser(session, sessionBuilder, username: 'carol_grp');
      dave = await _createUser(session, sessionBuilder, username: 'dave_grp');
      groupId = await _groupChat(endpoints, alice, [bob, carol]);
      daveChatId = await _directChat(endpoints, alice, dave);
    });

    test('when Alice types in the group then members receive it', () async {
      final bobEvents = <ChatEvent>[];
      final carolEvents = <ChatEvent>[];
      final daveEvents = <ChatEvent>[];
      final bobSub = session.messages
          .createStream<ChatEvent>(Messages.channelForUser(bob.user.id!))
          .listen(bobEvents.add);
      final carolSub = session.messages
          .createStream<ChatEvent>(Messages.channelForUser(carol.user.id!))
          .listen(carolEvents.add);
      final daveSub = session.messages
          .createStream<ChatEvent>(Messages.channelForUser(dave.user.id!))
          .listen(daveEvents.add);

      await endpoints.message.setTyping(
        alice.client,
        chatId: groupId,
        isTyping: true,
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(
        bobEvents.single.kind,
        ChatEventKind.typingStarted,
      );
      expect(bobEvents.single.chatId, groupId);
      expect(carolEvents.single.chatId, groupId);
      expect(daveEvents, isEmpty);

      await endpoints.message.setTyping(
        alice.client,
        chatId: daveChatId,
        isTyping: true,
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(daveEvents, hasLength(1));
      expect(daveEvents.single.chatId, daveChatId);
      expect(bobEvents, hasLength(1));

      await bobSub.cancel();
      await carolSub.cancel();
      await daveSub.cancel();
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
    name: 'Typing group',
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
