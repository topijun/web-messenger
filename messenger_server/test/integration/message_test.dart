import 'dart:async';

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
    test('when sending a message then it is rejected', () async {
      await expectLater(
        () => endpoints.message.sendText(
          sessionBuilder,
          chatId: 1,
          encryptedText: 'Hello',
        ),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });

    test('when listing history then it is rejected', () async {
      await expectLater(
        () => endpoints.message.listHistory(sessionBuilder, chatId: 1),
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
      alice = await _createUser(session, sessionBuilder, username: 'alice_msg');
      bob = await _createUser(session, sessionBuilder, username: 'bob_msg');
      carol = await _createUser(session, sessionBuilder, username: 'carol_msg');
      chatId = await _directChat(endpoints, alice, bob);
    });

    test('when a participant sends then the message is stored', () async {
      final before = DateTime.now().toUtc().subtract(
        const Duration(seconds: 2),
      );
      final view = await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'Hello Bob',
      );

      expect(view.message.senderId, alice.user.id);
      expect(view.message.chatId, chatId);
      expect(view.message.type, MessageType.text);
      expect(view.message.encryptedText, 'Hello Bob');
      expect(view.isMine, isTrue);
      expect(view.senderUsername, 'alice_msg');
      expect(view.message.createdAt.isAfter(before), isTrue);
      expect(
        view.message.createdAt.isBefore(
          DateTime.now().toUtc().add(const Duration(seconds: 2)),
        ),
        isTrue,
      );
      expect(view.receipts, hasLength(1));
      expect(view.receipts.single.userId, bob.user.id);
      expect(view.receipts.single.deliveredAt, isNull);
      expect(view.receipts.single.readAt, isNull);

      final stored = await Message.db.findById(session, view.message.id!);
      expect(stored?.encryptedText, isNot('Hello Bob'));
      expect(stored?.encryptedText, startsWith('v1:'));
      expect(stored?.senderId, alice.user.id);

      final chat = await Chat.db.findById(session, chatId);
      expect(chat?.lastMessageAt, view.message.createdAt);
    });

    test('when text is empty then it is rejected', () async {
      await expectLater(
        () => endpoints.message.sendText(
          alice.client,
          chatId: chatId,
          encryptedText: '   ',
        ),
        throwsA(
          isA<MessengerInvalidChatInputException>().having(
            (error) => error.field,
            'field',
            'encryptedText',
          ),
        ),
      );
      expect(await Message.db.find(session), isEmpty);
    });

    test('when the chat does not exist then it is rejected', () async {
      await expectLater(
        () => endpoints.message.sendText(
          alice.client,
          chatId: 999999,
          encryptedText: 'Hello',
        ),
        throwsA(isA<MessengerChatNotFoundException>()),
      );
    });

    test('when a non-participant sends then it is rejected', () async {
      await expectLater(
        () => endpoints.message.sendText(
          carol.client,
          chatId: chatId,
          encryptedText: 'Intruder',
        ),
        throwsA(isA<MessengerNotChatMemberException>()),
      );
    });

    test('when Bob lists history then he sees Alice\'s message', () async {
      await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'Hello Bob',
      );

      final page = await endpoints.message.listHistory(
        bob.client,
        chatId: chatId,
      );
      expect(page.messages, hasLength(1));
      expect(page.messages.single.message.encryptedText, 'Hello Bob');
      expect(page.messages.single.isMine, isFalse);
      expect(page.messages.single.senderUsername, 'alice_msg');
      expect(page.hasMore, isFalse);
    });

    test('when a non-participant lists history then it is rejected', () async {
      await expectLater(
        () => endpoints.message.listHistory(carol.client, chatId: chatId),
        throwsA(isA<MessengerNotChatMemberException>()),
      );
    });

    test('when messages share a timestamp then id breaks the tie', () async {
      final first = await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'first',
      );
      final second = await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'second',
      );
      final tied = DateTime.utc(2026, 9, 20, 10);
      final firstStored = await Message.db.findById(session, first.message.id!);
      final secondStored = await Message.db.findById(
        session,
        second.message.id!,
      );
      await Message.db.updateRow(
        session,
        firstStored!.copyWith(createdAt: tied),
      );
      await Message.db.updateRow(
        session,
        secondStored!.copyWith(createdAt: tied),
      );

      final page = await endpoints.message.listHistory(
        alice.client,
        chatId: chatId,
      );
      expect(
        page.messages.map((item) => item.message.encryptedText),
        ['second', 'first'],
      );
    });

    test(
      'when paging then older messages are returned without duplicates',
      () async {
        for (var i = 1; i <= 5; i++) {
          await endpoints.message.sendText(
            alice.client,
            chatId: chatId,
            encryptedText: 'm$i',
          );
        }

        final firstPage = await endpoints.message.listHistory(
          bob.client,
          chatId: chatId,
          limit: 2,
        );
        expect(
          firstPage.messages.map((item) => item.message.encryptedText),
          ['m5', 'm4'],
        );
        expect(firstPage.hasMore, isTrue);
        expect(firstPage.nextCreatedAt, isNotNull);
        expect(firstPage.nextId, firstPage.messages.last.message.id);

        final secondPage = await endpoints.message.listHistory(
          bob.client,
          chatId: chatId,
          beforeCreatedAt: firstPage.nextCreatedAt,
          beforeId: firstPage.nextId,
          limit: 2,
        );
        expect(
          secondPage.messages.map((item) => item.message.encryptedText),
          ['m3', 'm2'],
        );

        final firstIds = firstPage.messages
            .map((item) => item.message.id)
            .toSet();
        final secondIds = secondPage.messages
            .map((item) => item.message.id)
            .toSet();
        expect(firstIds.intersection(secondIds), isEmpty);

        final thirdPage = await endpoints.message.listHistory(
          bob.client,
          chatId: chatId,
          beforeCreatedAt: secondPage.nextCreatedAt,
          beforeId: secondPage.nextId,
          limit: 2,
        );
        expect(
          thirdPage.messages.map((item) => item.message.encryptedText),
          ['m1'],
        );
        expect(thirdPage.hasMore, isFalse);
      },
    );

    test(
      'when Bob marks delivered and read then Alice sees the receipt',
      () async {
        final sent = await endpoints.message.sendText(
          alice.client,
          chatId: chatId,
          encryptedText: 'Hello Bob',
        );

        final delivered = await endpoints.message.markDelivered(
          bob.client,
          messageIds: [sent.message.id!],
        );
        expect(delivered, hasLength(1));
        expect(delivered.single.userId, bob.user.id);
        expect(delivered.single.deliveredAt, isNotNull);
        expect(delivered.single.readAt, isNull);

        final read = await endpoints.message.markRead(
          bob.client,
          messageIds: [sent.message.id!],
        );
        expect(read.single.readAt, isNotNull);
        expect(read.single.deliveredAt, isNotNull);

        final alicePage = await endpoints.message.listHistory(
          alice.client,
          chatId: chatId,
        );
        expect(alicePage.messages.single.receipts.single.readAt, isNotNull);
      },
    );

    test(
      'when Alice marks her own message delivered then it is rejected',
      () async {
        final sent = await endpoints.message.sendText(
          alice.client,
          chatId: chatId,
          encryptedText: 'Hello Bob',
        );

        await expectLater(
          () => endpoints.message.markDelivered(
            alice.client,
            messageIds: [sent.message.id!],
          ),
          throwsA(isA<MessengerNotMessageRecipientException>()),
        );
        await expectLater(
          () => endpoints.message.markRead(
            alice.client,
            messageIds: [sent.message.id!],
          ),
          throwsA(isA<MessengerNotMessageRecipientException>()),
        );
        expect(await MessageReceipt.db.find(session), hasLength(1));
        expect(
          (await MessageReceipt.db.find(session)).single.userId,
          bob.user.id,
        );
      },
    );

    test(
      'when Carol marks a message she cannot see then it is rejected',
      () async {
        final sent = await endpoints.message.sendText(
          alice.client,
          chatId: chatId,
          encryptedText: 'Hello Bob',
        );

        await expectLater(
          () => endpoints.message.markDelivered(
            carol.client,
            messageIds: [sent.message.id!],
          ),
          throwsA(isA<MessengerNotChatMemberException>()),
        );
        await expectLater(
          () => endpoints.message.markRead(
            carol.client,
            messageIds: [sent.message.id!],
          ),
          throwsA(isA<MessengerNotChatMemberException>()),
        );
      },
    );

    test(
      'when delivered is marked twice then the timestamp does not move',
      () async {
        final sent = await endpoints.message.sendText(
          alice.client,
          chatId: chatId,
          encryptedText: 'Hello Bob',
        );
        final first = await endpoints.message.markDelivered(
          bob.client,
          messageIds: [sent.message.id!],
        );
        final second = await endpoints.message.markDelivered(
          bob.client,
          messageIds: [sent.message.id!],
        );
        expect(second.single.id, first.single.id);
        expect(second.single.deliveredAt, first.single.deliveredAt);

        final afterRead = await endpoints.message.markRead(
          bob.client,
          messageIds: [sent.message.id!],
        );
        final again = await endpoints.message.markRead(
          bob.client,
          messageIds: [sent.message.id!],
        );
        expect(again.single.readAt, afterRead.single.readAt);
        expect(again.single.deliveredAt, afterRead.single.deliveredAt);
        expect(await MessageReceipt.db.find(session), hasLength(1));
      },
    );

    test('when read is marked first then deliveredAt is also set', () async {
      final sent = await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'Hello Bob',
      );
      final read = await endpoints.message.markRead(
        bob.client,
        messageIds: [sent.message.id!],
      );
      expect(read.single.readAt, isNotNull);
      expect(read.single.deliveredAt, isNotNull);
    });

    test(
      'when Alice sends then Bob receives a MessageCentral event',
      () async {
        final events = <ChatEvent>[];
        final stream = session.messages.createStream<ChatEvent>(
          Messages.channelForUser(bob.user.id!),
        );
        final subscription = stream.listen(events.add);

        await endpoints.message.sendText(
          alice.client,
          chatId: chatId,
          encryptedText: 'Hello Bob',
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(
          events
              .where((event) => event.kind == ChatEventKind.message)
              .map((event) => event.message?.message.encryptedText),
          contains('Hello Bob'),
        );
        await subscription.cancel();
      },
    );

    test('when Alice sends then only Bob has an unread count', () async {
      await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'Hello Bob',
      );
      await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'Second',
      );

      final bobChats = await endpoints.chat.listMine(bob.client);
      final aliceChats = await endpoints.chat.listMine(alice.client);
      expect(bobChats.single.unreadCount, 2);
      expect(aliceChats.single.unreadCount, 0);
    });

    test('when Bob marks read then his unread count is cleared', () async {
      final sent = await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'Hello Bob',
      );
      expect((await endpoints.chat.listMine(bob.client)).single.unreadCount, 1);

      await endpoints.message.markRead(
        bob.client,
        messageIds: [sent.message.id!],
      );
      expect((await endpoints.chat.listMine(bob.client)).single.unreadCount, 0);
    });

    test(
      'when Bob archives or mutes then unread state is still stored',
      () async {
        await endpoints.chat.setArchived(
          bob.client,
          chatId: chatId,
          archived: true,
        );
        await endpoints.chat.setMuted(
          bob.client,
          chatId: chatId,
          notificationsMuted: true,
        );
        await endpoints.message.sendText(
          alice.client,
          chatId: chatId,
          encryptedText: 'Hello muted archive',
        );

        final bobChat = (await endpoints.chat.listMine(bob.client)).single;
        expect(bobChat.unreadCount, 1);
        expect(bobChat.membership.archived, isTrue);
        expect(bobChat.membership.notificationsMuted, isTrue);
      },
    );
  });

  withServerpod('Given a group chat with Alice, Bob, and Carol', (
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
      alice = await _createUser(session, sessionBuilder, username: 'alice_grp');
      bob = await _createUser(session, sessionBuilder, username: 'bob_grp');
      carol = await _createUser(session, sessionBuilder, username: 'carol_grp');
      chatId = await _groupChat(endpoints, alice, [bob, carol]);
    });

    test('when Alice sends then every member can read history', () async {
      await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'Hello group',
      );

      for (final member in [alice, bob, carol]) {
        final page = await endpoints.message.listHistory(
          member.client,
          chatId: chatId,
        );
        expect(page.messages, hasLength(1));
        expect(page.messages.single.message.encryptedText, 'Hello group');
        expect(page.messages.single.message.senderId, alice.user.id);
        expect(page.messages.single.isMine, member.user.id == alice.user.id);
      }
    });

    test('when Bob marks read then Carol\'s receipt is unchanged', () async {
      final sent = await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'Hello group',
      );
      expect(sent.receipts, hasLength(2));

      await endpoints.message.markRead(
        bob.client,
        messageIds: [sent.message.id!],
      );

      final receipts = await MessageReceipt.db.find(
        session,
        where: (t) => t.messageId.equals(sent.message.id),
      );
      expect(receipts, hasLength(2));
      final bobReceipt = receipts.singleWhere(
        (row) => row.userId == bob.user.id,
      );
      final carolReceipt = receipts.singleWhere(
        (row) => row.userId == carol.user.id,
      );
      expect(bobReceipt.readAt, isNotNull);
      expect(bobReceipt.deliveredAt, isNotNull);
      expect(carolReceipt.readAt, isNull);
      expect(carolReceipt.deliveredAt, isNull);
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
