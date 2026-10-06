import 'dart:async';

import 'package:messenger_server/src/generated/protocol.dart';
import 'package:messenger_server/src/messages/messages.dart';
import 'package:messenger_server/src/users/messenger_users.dart';
import 'package:serverpod/serverpod.dart' hide Message;
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given a group chat and a direct chat', (
    sessionBuilder,
    endpoints,
  ) {
    late Session session;
    late _User alice;
    late _User bob;
    late _User carol;
    late int groupId;
    late int directId;

    setUp(() async {
      session = sessionBuilder.build();
      alice = await _createUser(
        session,
        sessionBuilder,
        username: 'alice_poll',
      );
      bob = await _createUser(session, sessionBuilder, username: 'bob_poll');
      carol = await _createUser(
        session,
        sessionBuilder,
        username: 'carol_poll',
      );
      groupId = await _groupChat(endpoints, alice, [bob]);
      directId = await _directChat(endpoints, alice, bob);
    });

    test('when a member creates a poll then it is a normal message', () async {
      final events = <ChatEvent>[];
      final stream = session.messages.createStream<ChatEvent>(
        Messages.channelForUser(bob.user.id!),
      );
      final subscription = stream.listen(events.add);

      final view = await endpoints.message.createPoll(
        alice.client,
        chatId: groupId,
        question: 'Where should we go?',
        options: ['Helsinki', 'Tampere', 'Turku'],
        anonymous: false,
      );

      expect(view.message.type, MessageType.poll);
      expect(view.message.pollId, isNotNull);
      expect(view.poll?.id, view.message.pollId);
      expect(view.poll?.question, 'Where should we go?');
      expect(view.poll?.options.map((option) => option.text), [
        'Helsinki',
        'Tampere',
        'Turku',
      ]);
      expect(view.poll?.totalVotes, 0);
      expect(view.poll?.myOptionId, isNull);

      final page = await endpoints.message.listHistory(
        bob.client,
        chatId: groupId,
      );
      expect(page.messages.single.message.type, MessageType.poll);
      expect(page.messages.single.message.pollId, view.message.pollId);
      expect(page.messages.single.poll?.question, 'Where should we go?');

      final matches = await endpoints.message.searchText(
        bob.client,
        chatId: groupId,
        query: 'Helsinki',
      );
      expect(matches, isEmpty);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      final created = events.where(
        (event) => event.kind == ChatEventKind.message,
      );
      expect(created, isNotEmpty);
      expect(created.single.message?.message.type, MessageType.poll);
      expect(created.single.message?.poll?.question, 'Where should we go?');
      await subscription.cancel();
    });

    test('when creating a poll in a direct chat then it is rejected', () async {
      await expectLater(
        () => endpoints.message.createPoll(
          alice.client,
          chatId: directId,
          question: 'Where should we go?',
          options: ['Helsinki', 'Tampere'],
          anonymous: false,
        ),
        throwsA(
          isA<MessengerInvalidChatInputException>().having(
            (error) => error.field,
            'field',
            'chatType',
          ),
        ),
      );
      expect(await Poll.db.find(session), isEmpty);
    });

    test('when a non-member creates or votes then it is rejected', () async {
      final view = await endpoints.message.createPoll(
        alice.client,
        chatId: groupId,
        question: 'Where should we go?',
        options: ['Helsinki', 'Tampere'],
        anonymous: false,
      );

      await expectLater(
        () => endpoints.message.createPoll(
          carol.client,
          chatId: groupId,
          question: 'Another poll?',
          options: ['Yes', 'No'],
          anonymous: false,
        ),
        throwsA(isA<MessengerNotChatMemberException>()),
      );
      await expectLater(
        () => endpoints.message.vote(
          carol.client,
          pollId: view.poll!.id,
          optionId: view.poll!.options.first.id,
        ),
        throwsA(isA<MessengerNotChatMemberException>()),
      );
      expect(await PollVote.db.find(session), isEmpty);
    });

    test(
      'when a poll is stored then question and options stay encrypted',
      () async {
        final view = await endpoints.message.createPoll(
          alice.client,
          chatId: groupId,
          question: 'Where should we go?',
          options: ['Helsinki', 'Tampere'],
          anonymous: true,
        );

        final stored = await Poll.db.findById(session, view.poll!.id);
        expect(stored?.question, isNot('Where should we go?'));
        expect(stored?.question, startsWith('v1:'));
        final options = await PollOption.db.find(
          session,
          where: (t) => t.pollId.equals(view.poll!.id),
        );
        expect(options, hasLength(2));
        expect(
          options.map((option) => option.text),
          everyElement(startsWith('v1:')),
        );
        expect(
          options.map((option) => option.text),
          isNot(contains('Helsinki')),
        );
      },
    );

    test(
      'when a member votes, changes, and retracts then one vote remains consistent',
      () async {
        final created = await endpoints.message.createPoll(
          alice.client,
          chatId: groupId,
          question: 'Where should we go?',
          options: ['Helsinki', 'Tampere'],
          anonymous: false,
        );
        final helsinki = created.poll!.options[0].id;
        final tampere = created.poll!.options[1].id;

        final first = await endpoints.message.vote(
          alice.client,
          pollId: created.poll!.id,
          optionId: helsinki,
        );
        expect(first.poll?.myOptionId, helsinki);
        expect(first.poll?.totalVotes, 1);
        expect(first.poll?.options[0].voteCount, 1);
        expect(first.poll?.options[0].voters, ['alice_poll']);
        expect(await PollVote.db.find(session), hasLength(1));

        final changed = await endpoints.message.vote(
          alice.client,
          pollId: created.poll!.id,
          optionId: tampere,
        );
        expect(changed.poll?.myOptionId, tampere);
        expect(changed.poll?.totalVotes, 1);
        expect(changed.poll?.options[0].voteCount, 0);
        expect(changed.poll?.options[1].voteCount, 1);
        expect(changed.poll?.options[1].voters, ['alice_poll']);
        expect(await PollVote.db.find(session), hasLength(1));

        final retracted = await endpoints.message.vote(
          alice.client,
          pollId: created.poll!.id,
          optionId: tampere,
        );
        expect(retracted.poll?.myOptionId, isNull);
        expect(retracted.poll?.totalVotes, 0);
        expect(
          retracted.poll?.options.every((option) => option.voteCount == 0),
          isTrue,
        );
        expect(await PollVote.db.find(session), isEmpty);
      },
    );

    test(
      'when the poll is anonymous then other clients do not see voters',
      () async {
        final events = <ChatEvent>[];
        final stream = session.messages.createStream<ChatEvent>(
          Messages.channelForUser(bob.user.id!),
        );
        final subscription = stream.listen(events.add);
        final created = await endpoints.message.createPoll(
          alice.client,
          chatId: groupId,
          question: 'Where should we go?',
          options: ['Helsinki', 'Tampere'],
          anonymous: true,
        );

        await endpoints.message.vote(
          alice.client,
          pollId: created.poll!.id,
          optionId: created.poll!.options.first.id,
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final bobView = await endpoints.message.listHistory(
          bob.client,
          chatId: groupId,
        );
        final poll = bobView.messages.single.poll!;
        expect(poll.anonymous, isTrue);
        expect(poll.totalVotes, 1);
        expect(poll.myOptionId, isNull);
        expect(poll.options.first.voteCount, 1);
        expect(
          poll.options.expand((option) => option.voters),
          isEmpty,
        );

        final update = events.where(
          (event) => event.kind == ChatEventKind.pollUpdated,
        );
        expect(update, isNotEmpty);
        expect(
          update.single.message?.poll?.options.expand(
            (option) => option.voters,
          ),
          isEmpty,
        );
        await subscription.cancel();

        final storedVote = await PollVote.db.find(session);
        expect(storedVote.single.userId, alice.user.id);
      },
    );

    test(
      'when another member votes then each client keeps its own selection',
      () async {
        final aliceEvents = <ChatEvent>[];
        final bobEvents = <ChatEvent>[];
        final aliceSubscription = session.messages
            .createStream<ChatEvent>(
              Messages.channelForUser(alice.user.id!),
            )
            .listen(aliceEvents.add);
        final bobSubscription = session.messages
            .createStream<ChatEvent>(Messages.channelForUser(bob.user.id!))
            .listen(bobEvents.add);

        final created = await endpoints.message.createPoll(
          alice.client,
          chatId: groupId,
          question: 'Where should we go?',
          options: ['Helsinki', 'Tampere'],
          anonymous: false,
        );
        final pollId = created.poll!.id;
        final helsinki = created.poll!.options[0].id;
        final tampere = created.poll!.options[1].id;

        final aliceVote = await endpoints.message.vote(
          alice.client,
          pollId: pollId,
          optionId: helsinki,
        );
        expect(aliceVote.poll?.myOptionId, helsinki);
        expect(aliceVote.poll?.totalVotes, 1);
        expect(aliceVote.poll?.options[0].voteCount, 1);

        await Future<void>.delayed(const Duration(milliseconds: 50));
        final bobSawAlice = bobEvents.lastWhere(
          (event) => event.kind == ChatEventKind.pollUpdated,
        );
        expect(bobSawAlice.message?.poll?.myOptionId, isNull);
        expect(bobSawAlice.message?.poll?.totalVotes, 1);
        expect(bobSawAlice.message?.poll?.options[0].voteCount, 1);

        aliceEvents.clear();
        final bobVote = await endpoints.message.vote(
          bob.client,
          pollId: pollId,
          optionId: tampere,
        );
        expect(bobVote.poll?.myOptionId, tampere);
        expect(bobVote.poll?.totalVotes, 2);
        expect(bobVote.poll?.options[0].voteCount, 1);
        expect(bobVote.poll?.options[1].voteCount, 1);

        await Future<void>.delayed(const Duration(milliseconds: 50));
        final aliceSawBob = aliceEvents.lastWhere(
          (event) => event.kind == ChatEventKind.pollUpdated,
        );
        expect(aliceSawBob.message?.poll?.myOptionId, helsinki);
        expect(aliceSawBob.message?.poll?.totalVotes, 2);
        expect(aliceSawBob.message?.poll?.options[0].voteCount, 1);
        expect(aliceSawBob.message?.poll?.options[1].voteCount, 1);
        expect(
          bobEvents
              .lastWhere((event) => event.kind == ChatEventKind.pollUpdated)
              .message
              ?.poll
              ?.myOptionId,
          tampere,
        );

        bobEvents.clear();
        final changed = await endpoints.message.vote(
          alice.client,
          pollId: pollId,
          optionId: tampere,
        );
        expect(changed.poll?.myOptionId, tampere);
        expect(changed.poll?.totalVotes, 2);
        expect(changed.poll?.options[0].voteCount, 0);
        expect(changed.poll?.options[1].voteCount, 2);

        await Future<void>.delayed(const Duration(milliseconds: 50));
        final bobSawChange = bobEvents.lastWhere(
          (event) => event.kind == ChatEventKind.pollUpdated,
        );
        expect(bobSawChange.message?.poll?.myOptionId, tampere);
        expect(bobSawChange.message?.poll?.options[1].voteCount, 2);
        expect(bobSawChange.message?.poll?.totalVotes, 2);

        await aliceSubscription.cancel();
        await bobSubscription.cancel();
      },
    );

    test('when poll input is invalid then it is rejected', () async {
      await expectLater(
        () => endpoints.message.createPoll(
          alice.client,
          chatId: groupId,
          question: '   ',
          options: ['Helsinki', 'Tampere'],
          anonymous: false,
        ),
        throwsA(
          isA<MessengerInvalidChatInputException>().having(
            (error) => error.field,
            'field',
            'question',
          ),
        ),
      );
      await expectLater(
        () => endpoints.message.createPoll(
          alice.client,
          chatId: groupId,
          question: 'Where?',
          options: ['Helsinki'],
          anonymous: false,
        ),
        throwsA(
          isA<MessengerInvalidChatInputException>().having(
            (error) => error.field,
            'field',
            'options',
          ),
        ),
      );
      await expectLater(
        () => endpoints.message.createPoll(
          alice.client,
          chatId: groupId,
          question: 'Where?',
          options: ['Helsinki', '   '],
          anonymous: false,
        ),
        throwsA(isA<MessengerInvalidChatInputException>()),
      );
      expect(await Poll.db.find(session), isEmpty);
    });

    test(
      'when the option is not on the poll then the vote is rejected',
      () async {
        final created = await endpoints.message.createPoll(
          alice.client,
          chatId: groupId,
          question: 'Where should we go?',
          options: ['Helsinki', 'Tampere'],
          anonymous: false,
        );
        await expectLater(
          () => endpoints.message.vote(
            alice.client,
            pollId: created.poll!.id,
            optionId: 999999,
          ),
          throwsA(
            isA<MessengerInvalidChatInputException>().having(
              (error) => error.field,
              'field',
              'optionId',
            ),
          ),
        );
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
