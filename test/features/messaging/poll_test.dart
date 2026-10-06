import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/features/chats/application/chat_controller.dart';
import 'package:mobile_messenger/features/messaging/presentation/conversation_screen.dart';
import 'package:mobile_messenger/features/profile/data/profile_image_store.dart';
import 'package:mobile_messenger/features/profile/presentation/profile_scope.dart';

import '../../support/chat_fakes.dart';
import '../../support/message_fakes.dart';
import '../../support/profile_fakes.dart';
import '../../support/video_poster_fakes.dart';

void main() {
  testWidgets('a group conversation can open the poll composer', (
    tester,
  ) async {
    final messages = FakeMessageRepository();
    await _pump(tester, messages, testGroupChat());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('openPollComposer')), findsOneWidget);
    await tester.tap(find.byKey(const Key('openPollComposer')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('pollQuestionField')), findsOneWidget);
    expect(find.byKey(const Key('pollOptionField-0')), findsOneWidget);
    expect(find.byKey(const Key('pollOptionField-1')), findsOneWidget);
    expect(find.byKey(const Key('pollAnonymous')), findsOneWidget);
    final submit = tester.widget<FilledButton>(
      find.byKey(const Key('submitPoll')),
    );
    expect(submit.onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('pollQuestionField')),
      'Where should we go?',
    );
    await tester.enterText(
      find.byKey(const Key('pollOptionField-0')),
      'Helsinki',
    );
    await tester.enterText(
      find.byKey(const Key('pollOptionField-1')),
      'Tampere',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('submitPoll')));
    await tester.pumpAndSettle();

    expect(find.text('Where should we go?'), findsOneWidget);
    expect(find.text('Helsinki'), findsOneWidget);
    expect(find.text('Tampere'), findsOneWidget);
    expect(find.text('0 votes'), findsOneWidget);
    expect(messages.createdPolls, hasLength(1));
  });

  testWidgets('a direct conversation does not offer poll creation', (
    tester,
  ) async {
    final messages = FakeMessageRepository();
    await _pump(tester, messages, testDirectChat());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('openPollComposer')), findsNothing);
  });

  testWidgets('selecting options votes, changes, and retracts', (tester) async {
    final messages = FakeMessageRepository(
      history: [
        testMessageView(
          id: 4,
          chatId: 2,
          type: MessageType.poll,
          text: '',
          senderUsername: 'Alice',
          poll: _poll(),
        ),
      ],
    );
    await _pump(tester, messages, testGroupChat());
    await tester.pumpAndSettle();

    expect(find.text('Where should we go?'), findsOneWidget);
    expect(find.text('Helsinki'), findsOneWidget);
    expect(find.text('Tampere'), findsOneWidget);
    expect(find.text('Turku'), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_checked), findsNothing);

    await tester.tap(find.byKey(const Key('pollOption-101')));
    await tester.pumpAndSettle();
    expect(find.text('1 vote'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('pollOption-101')),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('pollOption-102')));
    await tester.pumpAndSettle();
    expect(find.text('1 vote'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('pollOption-101')),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('pollOption-102')),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('pollOption-102')));
    await tester.pumpAndSettle();
    expect(find.text('0 votes'), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_checked), findsNothing);
  });

  testWidgets('another voter updates counts without moving this selection', (
    tester,
  ) async {
    final messages = FakeMessageRepository(
      history: [
        testMessageView(
          id: 4,
          chatId: 2,
          type: MessageType.poll,
          text: '',
          senderUsername: 'Alice',
          poll: _poll(
            myOptionId: 101,
            options: [
              PollOptionView(
                id: 101,
                text: 'Helsinki',
                position: 0,
                voteCount: 1,
                voters: const ['Alice'],
              ),
              PollOptionView(
                id: 102,
                text: 'Tampere',
                position: 1,
                voteCount: 0,
                voters: const [],
              ),
              PollOptionView(
                id: 103,
                text: 'Turku',
                position: 2,
                voteCount: 0,
                voters: const [],
              ),
            ],
          ),
        ),
      ],
    );
    await _pump(tester, messages, testGroupChat());
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('pollOption-101')),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );

    messages.events.add(
      ChatEvent(
        kind: ChatEventKind.pollUpdated,
        chatId: 2,
        message: testMessageView(
          id: 4,
          chatId: 2,
          type: MessageType.poll,
          text: '',
          senderUsername: 'Alice',
          poll: _poll(
            myOptionId: 102,
            options: [
              PollOptionView(
                id: 101,
                text: 'Helsinki',
                position: 0,
                voteCount: 1,
                voters: const ['Alice'],
              ),
              PollOptionView(
                id: 102,
                text: 'Tampere',
                position: 1,
                voteCount: 1,
                voters: const ['Bob'],
              ),
              PollOptionView(
                id: 103,
                text: 'Turku',
                position: 2,
                voteCount: 0,
                voters: const [],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('2 votes'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('pollVoters-102'))).data,
      'Bob',
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('pollOption-101')),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('pollOption-102')),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsNothing,
    );

    await tester.tap(find.byKey(const Key('pollOption-102')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('pollOption-102')),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('pollOption-101')),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsNothing,
    );

    messages.events.add(
      ChatEvent(
        kind: ChatEventKind.pollUpdated,
        chatId: 2,
        message: testMessageView(
          id: 4,
          chatId: 2,
          type: MessageType.poll,
          text: '',
          senderUsername: 'Alice',
          poll: _poll(
            myOptionId: 103,
            options: [
              PollOptionView(
                id: 101,
                text: 'Helsinki',
                position: 0,
                voteCount: 0,
                voters: const [],
              ),
              PollOptionView(
                id: 102,
                text: 'Tampere',
                position: 1,
                voteCount: 1,
                voters: const ['Alice'],
              ),
              PollOptionView(
                id: 103,
                text: 'Turku',
                position: 2,
                voteCount: 1,
                voters: const ['Carol'],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Carol'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('pollOption-102')),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('pollOption-103')),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsNothing,
    );
  });

  testWidgets('an anonymous poll does not show voter names', (tester) async {
    final messages = FakeMessageRepository(
      history: [
        testMessageView(
          id: 4,
          chatId: 2,
          type: MessageType.poll,
          text: '',
          senderUsername: 'Alice',
          poll: _poll(
            anonymous: true,
            options: [
              PollOptionView(
                id: 101,
                text: 'Helsinki',
                position: 0,
                voteCount: 1,
                voters: const ['carol_poll'],
              ),
              PollOptionView(
                id: 102,
                text: 'Tampere',
                position: 1,
                voteCount: 0,
                voters: const [],
              ),
            ],
          ),
        ),
      ],
    );
    await _pump(tester, messages, testGroupChat());
    await tester.pumpAndSettle();

    expect(find.text('1 vote'), findsOneWidget);
    expect(find.text('carol_poll'), findsNothing);
    expect(find.byKey(const Key('pollVoters-101')), findsNothing);
  });
}

PollView _poll({
  bool anonymous = false,
  int? myOptionId,
  List<PollOptionView>? options,
}) {
  return PollView(
    id: 4,
    question: 'Where should we go?',
    anonymous: anonymous,
    myOptionId: myOptionId,
    totalVotes: options == null
        ? 0
        : options.fold(0, (sum, option) => sum + option.voteCount),
    options:
        options ??
        [
          PollOptionView(
            id: 101,
            text: 'Helsinki',
            position: 0,
            voteCount: 0,
            voters: const [],
          ),
          PollOptionView(
            id: 102,
            text: 'Tampere',
            position: 1,
            voteCount: 0,
            voters: const [],
          ),
          PollOptionView(
            id: 103,
            text: 'Turku',
            position: 2,
            voteCount: 0,
            voters: const [],
          ),
        ],
  );
}

Future<void> _pump(
  WidgetTester tester,
  FakeMessageRepository messages,
  ChatSummary summary,
) async {
  final chats = FakeChatRepository(chats: [summary]);
  final chatController = ChatController(repository: chats);
  await chatController.load();
  addTearDown(chatController.dispose);
  addTearDown(messages.dispose);
  final profiles = FakeProfileRepository();
  await tester.pumpWidget(
    ProfileScope(
      repository: profiles,
      images: ProfileImageStore(profiles),
      child: MaterialApp(
        home: ConversationScreen(
          chatController: chatController,
          summary: summary,
          messages: messages,
          poster: FakeVideoPoster(),
        ),
      ),
    ),
  );
}
