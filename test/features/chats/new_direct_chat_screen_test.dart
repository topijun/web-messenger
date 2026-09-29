import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/features/chats/application/chat_controller.dart';
import 'package:mobile_messenger/features/chats/presentation/new_direct_chat_screen.dart';

import '../../support/chat_fakes.dart';

void main() {
  testWidgets('search by username shows the result and Invite', (tester) async {
    final repository = FakeChatRepository(
      searchResult: testContact(username: 'Bob'),
    );
    final controller = ChatController(repository: repository);
    await tester.pumpWidget(_screen(controller));

    await tester.enterText(find.byKey(const Key('directInviteUsername')), 'Bob');
    await tester.tap(find.byKey(const Key('lookupUsername')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('contactSearchResult')), findsOneWidget);
    expect(find.byKey(const Key('contactSearchUsername')), findsOneWidget);
    expect(find.text('Invite'), findsWidgets);
    expect(find.byKey(const Key('sendDirectInvitation')), findsOneWidget);
    expect(repository.lastSearchQuery, 'Bob');

    controller.dispose();
  });

  testWidgets('search by email shows the same contact result', (tester) async {
    final repository = FakeChatRepository(
      searchResult: testContact(username: 'Bob'),
    );
    final controller = ChatController(repository: repository);
    await tester.pumpWidget(_screen(controller));

    await tester.enterText(
      find.byKey(const Key('directInviteUsername')),
      'bob@example.com',
    );
    await tester.tap(find.byKey(const Key('lookupUsername')));
    await tester.pumpAndSettle();

    expect(find.text('Bob'), findsOneWidget);
    expect(repository.lastSearchQuery, 'bob@example.com');

    controller.dispose();
  });

  testWidgets('empty query shows visible feedback', (tester) async {
    final repository = FakeChatRepository(searchResult: testContact());
    final controller = ChatController(repository: repository);
    await tester.pumpWidget(_screen(controller));

    await tester.tap(find.byKey(const Key('lookupUsername')));
    await tester.pumpAndSettle();

    expect(find.text('Enter a username or email.'), findsOneWidget);
    expect(find.byKey(const Key('contactSearchResult')), findsNothing);
    expect(repository.lastSearchQuery, isNull);

    controller.dispose();
  });

  testWidgets('no results shows visible feedback', (tester) async {
    final repository = FakeChatRepository();
    final controller = ChatController(repository: repository);
    await tester.pumpWidget(_screen(controller));

    await tester.enterText(
      find.byKey(const Key('directInviteUsername')),
      'nobody',
    );
    await tester.tap(find.byKey(const Key('lookupUsername')));
    await tester.pumpAndSettle();

    expect(find.text('No matching user was found.'), findsOneWidget);
    expect(find.byKey(const Key('sendDirectInvitation')), findsNothing);

    controller.dispose();
  });

  testWidgets('search shows a loading indicator then clears it', (tester) async {
    final pending = Completer<ContactSearchResult?>();
    final repository = FakeChatRepository(searchCompleter: pending);
    final controller = ChatController(repository: repository);
    await tester.pumpWidget(_screen(controller));

    await tester.enterText(find.byKey(const Key('directInviteUsername')), 'Bob');
    await tester.tap(find.byKey(const Key('lookupUsername')));
    await tester.pump();

    expect(find.byKey(const Key('contactSearchLoading')), findsOneWidget);

    pending.complete(testContact(username: 'Bob'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('contactSearchLoading')), findsNothing);
    expect(find.byKey(const Key('contactSearchResult')), findsOneWidget);

    controller.dispose();
  });

  testWidgets('search error shows visible feedback', (tester) async {
    final repository = FakeChatRepository(
      searchError: ServerpodClientException('down', 503),
    );
    final controller = ChatController(repository: repository);
    await tester.pumpWidget(_screen(controller));

    await tester.enterText(find.byKey(const Key('directInviteUsername')), 'Bob');
    await tester.tap(find.byKey(const Key('lookupUsername')));
    await tester.pumpAndSettle();

    expect(find.textContaining('connection'), findsOneWidget);
    expect(find.byKey(const Key('contactSearchResult')), findsNothing);
    expect(find.byKey(const Key('contactSearchLoading')), findsNothing);

    controller.dispose();
  });

  testWidgets('pending invitation hides Invite', (tester) async {
    final repository = FakeChatRepository(
      searchResult: testContact(
        username: 'Bob',
        relation: ContactSearchRelation.invitationSent,
      ),
    );
    final controller = ChatController(repository: repository);
    await tester.pumpWidget(_screen(controller));

    await tester.enterText(find.byKey(const Key('directInviteUsername')), 'Bob');
    await tester.tap(find.byKey(const Key('lookupUsername')));
    await tester.pumpAndSettle();

    expect(find.text('Invitation pending'), findsOneWidget);
    expect(find.byKey(const Key('sendDirectInvitation')), findsNothing);

    controller.dispose();
  });

  testWidgets('existing chat hides Invite', (tester) async {
    final repository = FakeChatRepository(
      searchResult: testContact(
        username: 'Bob',
        relation: ContactSearchRelation.chatting,
      ),
    );
    final controller = ChatController(repository: repository);
    await tester.pumpWidget(_screen(controller));

    await tester.enterText(find.byKey(const Key('directInviteUsername')), 'Bob');
    await tester.tap(find.byKey(const Key('lookupUsername')));
    await tester.pumpAndSettle();

    expect(find.text('Already chatting'), findsOneWidget);
    expect(find.byKey(const Key('sendDirectInvitation')), findsNothing);

    controller.dispose();
  });

  testWidgets('self search hides Invite', (tester) async {
    final repository = FakeChatRepository(
      searchResult: testContact(
        username: 'Topi.J',
        relation: ContactSearchRelation.self,
      ),
    );
    final controller = ChatController(repository: repository);
    await tester.pumpWidget(_screen(controller));

    await tester.enterText(
      find.byKey(const Key('directInviteUsername')),
      'Topi.J',
    );
    await tester.tap(find.byKey(const Key('lookupUsername')));
    await tester.pumpAndSettle();

    expect(find.text('You cannot invite yourself'), findsOneWidget);
    expect(find.byKey(const Key('sendDirectInvitation')), findsNothing);

    controller.dispose();
  });

  testWidgets('Invite uses the existing invitation flow', (tester) async {
    final repository = FakeChatRepository(
      searchResult: testContact(username: 'Bob'),
    );
    final controller = ChatController(repository: repository);
    await tester.pumpWidget(_screen(controller));

    await tester.enterText(find.byKey(const Key('directInviteUsername')), 'Bob');
    await tester.tap(find.byKey(const Key('lookupUsername')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sendDirectInvitation')));
    await tester.pumpAndSettle();

    expect(repository.lastInvitedUsername, 'Bob');

    controller.dispose();
  });

  testWidgets('invitation failure shows a snackbar', (tester) async {
    final repository = FakeChatRepository(
      searchResult: testContact(username: 'Bob'),
      actionError: MessengerDuplicateInvitationException(username: 'Bob'),
    );
    final controller = ChatController(repository: repository);
    await tester.pumpWidget(_screen(controller));

    await tester.enterText(find.byKey(const Key('directInviteUsername')), 'Bob');
    await tester.tap(find.byKey(const Key('lookupUsername')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sendDirectInvitation')));
    await tester.pump();

    expect(
      find.text('An invitation is already pending with Bob.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('contactSearchResult')), findsOneWidget);

    controller.dispose();
  });
}

Widget _screen(ChatController controller) {
  return MaterialApp(home: NewDirectChatScreen(controller: controller));
}
