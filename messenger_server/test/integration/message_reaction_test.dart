import 'dart:async';

import 'package:messenger_server/src/generated/protocol.dart';
import 'package:messenger_server/src/messages/messages.dart';
import 'package:messenger_server/src/users/messenger_users.dart';
import 'package:serverpod/serverpod.dart' hide Message;
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given a direct chat with a message', (
    sessionBuilder,
    endpoints,
  ) {
    late Session session;
    late _User alice;
    late _User bob;
    late _User carol;
    late int chatId;
    late int messageId;

    setUp(() async {
      session = sessionBuilder.build();
      alice = await _createUser(
        session,
        sessionBuilder,
        username: 'alice_react',
      );
      bob = await _createUser(session, sessionBuilder, username: 'bob_react');
      carol = await _createUser(
        session,
        sessionBuilder,
        username: 'carol_react',
      );
      chatId = await _directChat(endpoints, alice, bob);
      final sent = await endpoints.message.sendText(
        alice.client,
        chatId: chatId,
        encryptedText: 'Thanks',
      );
      messageId = sent.message.id!;
    });

    test('when a member reacts then the reaction is stored', () async {
      final view = await endpoints.message.react(
        alice.client,
        messageId: messageId,
        emoji: '❤️',
      );

      expect(view.reactions, hasLength(1));
      expect(view.reactions!.single.emoji, '❤️');
      expect(view.reactions!.single.count, 1);
      expect(view.reactions!.single.mine, isTrue);

      final stored = await MessageReaction.db.find(session);
      expect(stored, hasLength(1));
      expect(stored.single.emoji, '❤️');
      expect(stored.single.emoji.startsWith('v1:'), isFalse);
      expect(stored.single.messageId, messageId);
      expect(stored.single.userId, alice.user.id);
    });

    test(
      'when the same reaction is sent twice then it does not duplicate',
      () async {
        await endpoints.message.react(
          alice.client,
          messageId: messageId,
          emoji: '👍',
        );
        final removed = await endpoints.message.react(
          alice.client,
          messageId: messageId,
          emoji: '👍',
        );

        expect(removed.reactions, isEmpty);
        expect(await MessageReaction.db.find(session), isEmpty);
      },
    );

    test(
      'when the same reaction is selected again then it is removed',
      () async {
        await endpoints.message.react(
          bob.client,
          messageId: messageId,
          emoji: '😂',
        );
        final removed = await endpoints.message.react(
          bob.client,
          messageId: messageId,
          emoji: '😂',
        );

        expect(removed.reactions, isEmpty);
        expect(
          await MessageReaction.db.count(session),
          0,
        );
      },
    );

    test('when different users react then both are counted', () async {
      await endpoints.message.react(
        alice.client,
        messageId: messageId,
        emoji: '😮',
      );
      final bobView = await endpoints.message.react(
        bob.client,
        messageId: messageId,
        emoji: '😮',
      );

      expect(bobView.reactions!.single.count, 2);
      expect(bobView.reactions!.single.mine, isTrue);

      final alicePage = await endpoints.message.listHistory(
        alice.client,
        chatId: chatId,
      );
      final aliceReaction = alicePage.messages.single.reactions!.single;
      expect(aliceReaction.count, 2);
      expect(aliceReaction.mine, isTrue);
      expect(await MessageReaction.db.count(session), 2);
    });

    test('when different emoji are used then they coexist', () async {
      await endpoints.message.react(
        alice.client,
        messageId: messageId,
        emoji: '❤️',
      );
      final view = await endpoints.message.react(
        alice.client,
        messageId: messageId,
        emoji: '😡',
      );

      expect(view.reactions!.map((reaction) => reaction.emoji), ['❤️', '😡']);
      expect(view.reactions!.map((reaction) => reaction.count), [1, 1]);
      expect(view.reactions!.every((reaction) => reaction.mine), isTrue);
      expect(await MessageReaction.db.count(session), 2);
    });

    test(
      'when several people use several emoji then counts stay separate',
      () async {
        await endpoints.message.react(
          alice.client,
          messageId: messageId,
          emoji: '❤️',
        );
        await endpoints.message.react(
          bob.client,
          messageId: messageId,
          emoji: '❤️',
        );
        final view = await endpoints.message.react(
          bob.client,
          messageId: messageId,
          emoji: '😢',
        );

        expect(view.reactions!.map((reaction) => reaction.emoji), ['❤️', '😢']);
        expect(
          view.reactions!
              .singleWhere((reaction) => reaction.emoji == '❤️')
              .count,
          2,
        );
        expect(
          view.reactions!
              .singleWhere((reaction) => reaction.emoji == '😢')
              .count,
          1,
        );
        expect(
          view.reactions!
              .singleWhere((reaction) => reaction.emoji == '❤️')
              .mine,
          isTrue,
        );
      },
    );

    test(
      'when a non-member reacts or reads history then it is rejected',
      () async {
        await endpoints.message.react(
          alice.client,
          messageId: messageId,
          emoji: '👍',
        );

        await expectLater(
          () => endpoints.message.react(
            carol.client,
            messageId: messageId,
            emoji: '👍',
          ),
          throwsA(isA<MessengerNotChatMemberException>()),
        );
        await expectLater(
          () => endpoints.message.react(
            carol.client,
            messageId: messageId,
            emoji: '👍',
          ),
          throwsA(isA<MessengerNotChatMemberException>()),
        );
        await expectLater(
          () => endpoints.message.listHistory(carol.client, chatId: chatId),
          throwsA(isA<MessengerNotChatMemberException>()),
        );
        expect(await MessageReaction.db.count(session), 1);
      },
    );

    test('when a message is deleted then new reactions are rejected', () async {
      await endpoints.message.react(
        alice.client,
        messageId: messageId,
        emoji: '😂',
      );
      await endpoints.message.deleteMessage(alice.client, messageId: messageId);

      await expectLater(
        () => endpoints.message.react(
          bob.client,
          messageId: messageId,
          emoji: '😂',
        ),
        throwsA(
          isA<MessengerInvalidChatInputException>().having(
            (error) => error.field,
            'field',
            'deletedAt',
          ),
        ),
      );

      final page = await endpoints.message.listHistory(
        bob.client,
        chatId: chatId,
      );
      expect(page.messages.single.message.deletedAt, isNotNull);
      expect(page.messages.single.reactions, isEmpty);
      expect(await MessageReaction.db.count(session), 1);
    });

    test(
      'when history is loaded then reactions belong to that message',
      () async {
        await endpoints.message.react(
          alice.client,
          messageId: messageId,
          emoji: '👍',
        );
        final page = await endpoints.message.listHistory(
          bob.client,
          chatId: chatId,
        );

        expect(page.messages, hasLength(1));
        expect(page.messages.single.reactions!.single.emoji, '👍');
        expect(page.messages.single.reactions!.single.count, 1);
        expect(page.messages.single.reactions!.single.mine, isFalse);
      },
    );

    test(
      'when a reaction changes then it is published on the message channel',
      () async {
        final events = <ChatEvent>[];
        final stream = session.messages.createStream<ChatEvent>(
          Messages.channelForUser(bob.user.id!),
        );
        final subscription = stream.listen(events.add);

        await endpoints.message.react(
          alice.client,
          messageId: messageId,
          emoji: '❤️',
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final updates = events.where(
          (event) => event.kind == ChatEventKind.messageReactionUpdated,
        );
        expect(updates, hasLength(1));
        expect(updates.single.chatId, chatId);
        expect(updates.single.message?.message.id, messageId);
        expect(updates.single.message?.reactions!.single.emoji, '❤️');
        expect(updates.single.message?.reactions!.single.count, 1);
        expect(updates.single.message?.reactions!.single.mine, isFalse);
        expect(updates.single.message?.isMine, isFalse);
        await subscription.cancel();
      },
    );

    test(
      'when the same reaction row is inserted twice then the database rejects it',
      () async {
        await endpoints.message.react(
          alice.client,
          messageId: messageId,
          emoji: '😢',
        );
        Object? failure;
        try {
          await MessageReaction.db.insertRow(
            session,
            MessageReaction(
              messageId: messageId,
              userId: alice.user.id!,
              emoji: '😢',
              createdAt: DateTime.now().toUtc(),
            ),
          );
        } catch (error) {
          failure = error;
        }

        expect(failure, isNotNull);
        expect(await MessageReaction.db.count(session), 1);
      },
    );

    test('when the emoji is empty or unknown then it is rejected', () async {
      await expectLater(
        () => endpoints.message.react(
          alice.client,
          messageId: messageId,
          emoji: '   ',
        ),
        throwsA(
          isA<MessengerInvalidChatInputException>().having(
            (error) => error.field,
            'field',
            'emoji',
          ),
        ),
      );
      await expectLater(
        () => endpoints.message.react(
          alice.client,
          messageId: messageId,
          emoji: 'nope',
        ),
        throwsA(isA<MessengerInvalidChatInputException>()),
      );
      expect(await MessageReaction.db.find(session), isEmpty);
    });

    test(
      'when a poll message is reacted to then the poll stays intact',
      () async {
        final groupId = await _groupChat(endpoints, alice, [bob]);
        final poll = await endpoints.message.createPoll(
          alice.client,
          chatId: groupId,
          question: 'Where should we go?',
          options: ['Helsinki', 'Tampere'],
          anonymous: true,
        );
        final view = await endpoints.message.react(
          bob.client,
          messageId: poll.message.id!,
          emoji: '👍',
        );

        expect(view.message.type, MessageType.poll);
        expect(view.poll?.question, 'Where should we go?');
        expect(view.reactions!.single.emoji, '👍');
        expect(view.reactions!.single.mine, isTrue);
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
