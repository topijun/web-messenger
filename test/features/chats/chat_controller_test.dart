import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/features/chats/application/chat_controller.dart';

import '../../support/chat_fakes.dart';
import '../../support/message_fakes.dart';

void main() {
  test('load puts chats and invitations into the ready state', () async {
    final controller = ChatController(
      repository: FakeChatRepository(
        chats: [testDirectChat()],
        invitations: [testInvitation()],
      ),
    );

    await controller.load();

    expect(controller.status, ChatStatus.ready);
    expect(controller.chats, hasLength(1));
    expect(controller.invitations, hasLength(1));
    expect(controller.errorMessage, isNull);
  });

  test('load failure is an error state', () async {
    final controller = ChatController(
      repository: FakeChatRepository(loadError: Exception('down')),
    );

    await controller.load();

    expect(controller.status, ChatStatus.error);
    expect(controller.errorMessage, contains('Could not load chats'));
  });

  test('chat list failure still loads invitations', () async {
    final controller = ChatController(
      repository: FakeChatRepository(
        chatsLoadError: Exception('chats down'),
        invitations: [testInvitation(senderUsername: 'Alice')],
      ),
    );

    await controller.load();

    expect(controller.status, ChatStatus.error);
    expect(controller.errorMessage, contains('Could not load chats'));
    expect(controller.chats, isEmpty);
    expect(controller.invitations, hasLength(1));
    expect(controller.invitations.single.senderUsername, 'Alice');
  });

  test('invitation list failure still loads chats', () async {
    final controller = ChatController(
      repository: FakeChatRepository(
        chats: [testDirectChat(otherUsername: 'Bob')],
        invitationsLoadError: Exception('invites down'),
      ),
    );

    await controller.load();

    expect(controller.status, ChatStatus.error);
    expect(controller.errorMessage, contains('Could not load invitations'));
    expect(controller.chats, hasLength(1));
    expect(controller.invitations, isEmpty);
  });

  test('accept moves an invitation into the chat list', () async {
    final repository = FakeChatRepository(
      invitations: [testInvitation(id: 10, senderUsername: 'Alice')],
    );
    final controller = ChatController(repository: repository);
    await controller.load();

    final accepted = await controller.accept(10);

    expect(accepted, isTrue);
    expect(repository.lastAcceptedId, 10);
    expect(controller.invitations, isEmpty);
    expect(controller.chats.single.otherUsernames, ['Alice']);
  });

  test('decline removes the invitation without adding a chat', () async {
    final repository = FakeChatRepository(
      invitations: [testInvitation(id: 11)],
    );
    final controller = ChatController(repository: repository);
    await controller.load();

    final declined = await controller.decline(11);

    expect(declined, isTrue);
    expect(repository.lastDeclinedId, 11);
    expect(controller.invitations, isEmpty);
    expect(controller.chats, isEmpty);
  });

  test('setArchived and setMuted update membership', () async {
    final repository = FakeChatRepository(chats: [testDirectChat(id: 3)]);
    final controller = ChatController(repository: repository);
    await controller.load();

    expect(await controller.setArchived(chatId: 3, archived: true), isTrue);
    expect(controller.chats.single.membership.archived, isTrue);
    expect(controller.activeChats, isEmpty);
    expect(controller.archivedChats, hasLength(1));
    expect(repository.lastArchivedValue, isTrue);

    expect(await controller.setArchived(chatId: 3, archived: false), isTrue);
    expect(controller.activeChats, hasLength(1));
    expect(controller.archivedChats, isEmpty);

    expect(
      await controller.setMuted(chatId: 3, notificationsMuted: true),
      isTrue,
    );
    expect(controller.chats.single.membership.notificationsMuted, isTrue);
    expect(repository.lastMutedValue, isTrue);
  });

  test('inviteDirect failure maps a domain error', () async {
    final controller = ChatController(
      repository: FakeChatRepository(
        actionError: MessengerSelfInvitationException(),
      ),
    );
    await controller.load();

    final sent = await controller.inviteDirect('Topi.J');

    expect(sent, isFalse);
    expect(controller.errorMessage, 'You cannot invite yourself.');
  });

  test('existing direct chat maps to a user-facing error', () async {
    final controller = ChatController(
      repository: FakeChatRepository(
        actionError: MessengerDirectChatAlreadyExistsException(username: 'Bob'),
      ),
    );
    await controller.load();

    final sent = await controller.inviteDirect('Bob');

    expect(sent, isFalse);
    expect(controller.errorMessage, 'You already have a direct chat with Bob.');
  });

  test('searchContact stores a username match', () async {
    final repository = FakeChatRepository(
      searchResult: testContact(username: 'Bob'),
    );
    final controller = ChatController(repository: repository);
    await controller.load();

    await controller.searchContact(' Bob ');

    expect(repository.lastSearchQuery, 'Bob');
    expect(controller.contact?.username, 'Bob');
    expect(controller.contact?.relation, ContactSearchRelation.none);
    expect(controller.contactFeedback, isNull);
    expect(controller.searching, isFalse);
    controller.dispose();
  });

  test('searchContact stores an email match', () async {
    final repository = FakeChatRepository(
      searchResult: testContact(username: 'Bob'),
    );
    final controller = ChatController(repository: repository);
    await controller.load();

    await controller.searchContact('bob@example.com');

    expect(repository.lastSearchQuery, 'bob@example.com');
    expect(controller.contact?.username, 'Bob');
    controller.dispose();
  });

  test('searchContact empty query does not call the repository', () async {
    final repository = FakeChatRepository(searchResult: testContact());
    final controller = ChatController(repository: repository);
    await controller.load();

    await controller.searchContact('   ');

    expect(repository.lastSearchQuery, isNull);
    expect(controller.contact, isNull);
    expect(controller.contactFeedback, 'Enter a username or email.');
    expect(controller.searching, isFalse);
    controller.dispose();
  });

  test('searchContact no match shows feedback', () async {
    final repository = FakeChatRepository();
    final controller = ChatController(repository: repository);
    await controller.load();

    await controller.searchContact('nobody');

    expect(controller.contact, isNull);
    expect(controller.contactFeedback, 'No matching user was found.');
    controller.dispose();
  });

  test('searchContact failure maps a connection error', () async {
    final repository = FakeChatRepository(
      searchError: ServerpodClientException('down', 503),
    );
    final controller = ChatController(repository: repository);
    await controller.load();

    await controller.searchContact('Bob');

    expect(controller.contact, isNull);
    expect(controller.contactFeedback, contains('connection'));
    expect(controller.searching, isFalse);
    controller.dispose();
  });

  test('overlapping load joins the in-flight request', () async {
    final load = Completer<List<ChatSummary>>();
    final repository = FakeChatRepository(chatsCompleter: load);
    final controller = ChatController(repository: repository);

    final first = controller.load();
    final second = controller.load();
    load.complete([testDirectChat()]);
    await Future.wait([first, second]);

    expect(repository.listMineCalls, 1);
    expect(controller.status, ChatStatus.ready);
    expect(controller.isBusy, isFalse);
    controller.dispose();
  });

  test(
    'silent refresh keeps existing chats and reports a recoverable error',
    () async {
      final repository = FakeChatRepository(chats: [testDirectChat()]);
      final controller = ChatController(repository: repository);
      await controller.load();
      repository.loadError = ServerpodClientException('down', 503);

      await controller.load(silent: true);

      expect(controller.status, ChatStatus.error);
      expect(controller.chats, hasLength(1));
      expect(controller.errorMessage, contains('Could not load chats'));
      expect(controller.isBusy, isFalse);
      controller.dispose();
    },
  );

  test(
    'a second invitation action is ignored while the first is running',
    () async {
      final accepted = Completer<void>();
      final repository = FakeChatRepository(
        invitations: [testInvitation(id: 10, senderUsername: 'Alice')],
      );
      repository.acceptCompleter = accepted;
      final controller = ChatController(repository: repository);
      await controller.load();

      final first = controller.accept(10);
      final second = controller.accept(10);
      accepted.complete();
      expect(await first, isTrue);
      expect(await second, isFalse);
      expect(repository.lastAcceptedId, 10);
      controller.dispose();
    },
  );

  test('createGroup adds the group to the chat list', () async {
    final repository = FakeChatRepository();
    final controller = ChatController(repository: repository);
    await controller.load();

    final created = await controller.createGroup('Weekend trip');

    expect(created, isTrue);
    expect(repository.lastCreatedGroupName, 'Weekend trip');
    expect(controller.chats.single.chat.name, 'Weekend trip');
  });

  test('server unreadCount is shown after load', () async {
    final controller = ChatController(
      repository: FakeChatRepository(chats: [testDirectChat(unreadCount: 3)]),
    );

    await controller.load();

    expect(controller.unreadCountFor(controller.chats.single), 3);
    controller.dispose();
  });

  test('incoming unread message creates an indicator', () async {
    final controller = ChatController(
      repository: FakeChatRepository(chats: [testDirectChat()]),
    );
    await controller.load();

    controller.applyEvent(
      ChatEvent(
        kind: ChatEventKind.message,
        chatId: 1,
        message: testMessageView(id: 21, chatId: 1, isMine: false),
      ),
    );

    expect(controller.unreadCountFor(controller.chats.single), 1);
    controller.dispose();
  });

  test('own message does not create an unread indicator', () async {
    final controller = ChatController(
      repository: FakeChatRepository(chats: [testDirectChat()]),
    );
    await controller.load();

    controller.applyEvent(
      ChatEvent(
        kind: ChatEventKind.message,
        chatId: 1,
        message: testMessageView(id: 22, chatId: 1, isMine: true, senderId: 1),
      ),
    );

    expect(controller.unreadCountFor(controller.chats.single), 0);
    controller.dispose();
  });

  test('duplicate realtime message does not increment twice', () async {
    final controller = ChatController(
      repository: FakeChatRepository(chats: [testDirectChat()]),
    );
    await controller.load();
    final event = ChatEvent(
      kind: ChatEventKind.message,
      chatId: 1,
      message: testMessageView(id: 23, chatId: 1),
    );

    controller.applyEvent(event);
    controller.applyEvent(event);

    expect(controller.unreadCountFor(controller.chats.single), 1);
    controller.dispose();
  });

  test('multiple unread messages produce a count', () async {
    final controller = ChatController(
      repository: FakeChatRepository(chats: [testDirectChat()]),
    );
    await controller.load();

    controller.applyEvent(
      ChatEvent(
        kind: ChatEventKind.message,
        chatId: 1,
        message: testMessageView(id: 31, chatId: 1),
      ),
    );
    controller.applyEvent(
      ChatEvent(
        kind: ChatEventKind.message,
        chatId: 1,
        message: testMessageView(id: 32, chatId: 1),
      ),
    );

    expect(controller.unreadCountFor(controller.chats.single), 2);
    controller.dispose();
  });

  test('opening a conversation clears the chat-list indicator', () async {
    final controller = ChatController(
      repository: FakeChatRepository(chats: [testDirectChat(unreadCount: 2)]),
    );
    await controller.load();

    controller.setActiveChat(1);

    expect(controller.unreadCountFor(controller.chats.single), 0);
    controller.dispose();
  });

  test(
    'active conversation does not create a chat-list notification',
    () async {
      final controller = ChatController(
        repository: FakeChatRepository(chats: [testDirectChat()]),
      );
      await controller.load();
      controller.setActiveChat(1);

      controller.applyEvent(
        ChatEvent(
          kind: ChatEventKind.message,
          chatId: 1,
          message: testMessageView(id: 41, chatId: 1),
        ),
      );

      expect(controller.unreadCountFor(controller.chats.single), 0);
      expect(controller.chats.single.unreadCount, 0);
      controller.dispose();
    },
  );

  test('read receipt for the current user clears that unread', () async {
    final controller = ChatController(
      repository: FakeChatRepository(chats: [testDirectChat(unreadCount: 1)]),
    );
    await controller.load();

    controller.applyEvent(
      ChatEvent(
        kind: ChatEventKind.receipt,
        chatId: 1,
        receipt: testReceipt(
          messageId: 51,
          userId: 1,
          readAt: DateTime.utc(2026, 9, 24),
        ),
      ),
    );

    expect(controller.unreadCountFor(controller.chats.single), 0);
    controller.dispose();
  });

  test('pending invitation creates and updates the indicator', () async {
    final events = StreamController<ChatEvent>.broadcast();
    final repository = FakeChatRepository();
    final controller = ChatController(
      repository: repository,
      events: events.stream,
    );
    await controller.load();
    expect(controller.pendingInvitationCount, 0);

    final invitation = testInvitation(id: 70, senderUsername: 'Alice');
    events.add(
      ChatEvent(
        kind: ChatEventKind.invitation,
        chatId: 0,
        invitation: invitation,
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(controller.pendingInvitationCount, 1);

    events.add(
      ChatEvent(
        kind: ChatEventKind.invitation,
        chatId: 0,
        invitation: invitation,
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(controller.pendingInvitationCount, 1);

    repository.invitations = [invitation];
    expect(await controller.accept(70), isTrue);
    expect(controller.pendingInvitationCount, 0);

    await events.close();
    controller.dispose();
  });

  test('decline and resume refresh reconcile invitation state', () async {
    final repository = FakeChatRepository(
      invitations: [
        testInvitation(id: 80),
        testInvitation(id: 81, senderUsername: 'Carol'),
      ],
    );
    final controller = ChatController(repository: repository);
    await controller.load();
    expect(controller.pendingInvitationCount, 2);

    expect(await controller.decline(80), isTrue);
    expect(controller.pendingInvitationCount, 1);

    repository.invitations = const [];
    await controller.load(silent: true);
    expect(controller.pendingInvitationCount, 0);
    controller.dispose();
  });

  test(
    'muted and archived chats still store unread without unarchiving',
    () async {
      final controller = ChatController(
        repository: FakeChatRepository(
          chats: [
            testDirectChat(id: 3, archived: true, notificationsMuted: true),
          ],
        ),
      );
      await controller.load();

      controller.applyEvent(
        ChatEvent(
          kind: ChatEventKind.message,
          chatId: 3,
          message: testMessageView(id: 61, chatId: 3),
        ),
      );

      final summary = controller.chats.single;
      expect(controller.unreadCountFor(summary), 1);
      expect(summary.membership.archived, isTrue);
      expect(summary.membership.notificationsMuted, isTrue);
      expect(controller.activeChats, isEmpty);
      expect(controller.archivedChats.single.chat.id, 3);
      controller.dispose();
    },
  );

  test('refresh keeps archived chats archived', () async {
    final repository = FakeChatRepository(
      chats: [testDirectChat(id: 3, archived: true, otherUsername: 'Bob')],
    );
    final controller = ChatController(repository: repository);
    await controller.load();
    expect(controller.archivedChats, hasLength(1));

    await controller.load(silent: true);

    expect(controller.chats.single.membership.archived, isTrue);
    expect(controller.activeChats, isEmpty);
    expect(controller.archivedChats.single.otherUsernames, ['Bob']);
    controller.dispose();
  });

  test('poll reconciles a missed invitation without duplicating', () async {
    final repository = FakeChatRepository();
    final controller = ChatController(repository: repository);
    await controller.load();
    expect(controller.pendingInvitationCount, 0);

    final invitation = testInvitation(id: 91, senderUsername: 'Alice');
    repository.invitations = [invitation];
    await controller.poll();

    expect(controller.pendingInvitationCount, 1);
    expect(controller.status, ChatStatus.ready);
    expect(controller.errorMessage, isNull);

    await controller.poll();
    expect(controller.pendingInvitationCount, 1);
    expect(controller.invitations.single.invitation.id, 91);
    controller.dispose();
  });

  test('poll plus a duplicate realtime event does not double-count', () async {
    final events = StreamController<ChatEvent>.broadcast();
    final invitation = testInvitation(id: 92, senderUsername: 'Alice');
    final repository = FakeChatRepository(invitations: [invitation]);
    final controller = ChatController(
      repository: repository,
      events: events.stream,
    );
    await controller.load();
    expect(controller.pendingInvitationCount, 1);

    events.add(
      ChatEvent(
        kind: ChatEventKind.invitation,
        chatId: 0,
        invitation: invitation,
      ),
    );
    await Future<void>.delayed(Duration.zero);
    await controller.poll();

    expect(controller.pendingInvitationCount, 1);

    await events.close();
    controller.dispose();
  });

  test(
    'background poll failure keeps visible state and hides the error',
    () async {
      final repository = FakeChatRepository(
        chats: [testDirectChat(otherUsername: 'Bob')],
        invitations: [testInvitation(id: 93)],
      );
      final controller = ChatController(repository: repository);
      await controller.load();
      repository.loadError = Exception('down');

      await controller.poll();

      expect(controller.status, ChatStatus.ready);
      expect(controller.errorMessage, isNull);
      expect(controller.chats.single.otherUsernames, ['Bob']);
      expect(controller.pendingInvitationCount, 1);
      expect(controller.isBusy, isFalse);
      controller.dispose();
    },
  );

  test('poll joins an in-flight load instead of overlapping', () async {
    final load = Completer<List<ChatSummary>>();
    final repository = FakeChatRepository(chatsCompleter: load);
    final controller = ChatController(repository: repository);

    final first = controller.load();
    final polled = controller.poll();
    load.complete([testDirectChat()]);
    await Future.wait([first, polled]);

    expect(repository.listMineCalls, 1);
    expect(controller.status, ChatStatus.ready);
    controller.dispose();
  });

  test('watch is restored after the realtime stream ends', () async {
    final events = StreamController<ChatEvent>.broadcast();
    final repository = FakeChatRepository();
    final controller = ChatController(
      repository: repository,
      events: events.stream,
    );
    await controller.load();

    events.addError(Exception('dropped'));
    await Future<void>.delayed(Duration.zero);

    controller.resubscribeWatch();
    events.add(
      ChatEvent(
        kind: ChatEventKind.invitation,
        chatId: 0,
        invitation: testInvitation(id: 94, senderUsername: 'Alice'),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(controller.pendingInvitationCount, 1);
    await events.close();
    controller.dispose();
  });

  test('a new message reorders the chat list by lastMessageAt', () async {
    final older = DateTime.utc(2026, 1, 1);
    final newer = DateTime.utc(2026, 6, 1);
    final controller = ChatController(
      repository: FakeChatRepository(
        chats: [
          testDirectChat(id: 1, otherUsername: 'Alice', lastMessageAt: newer),
          testDirectChat(id: 2, otherUsername: 'Bob', lastMessageAt: older),
        ],
      ),
    );
    await controller.load();
    expect(controller.chats.map((chat) => chat.chat.id), [1, 2]);

    controller.applyEvent(
      ChatEvent(
        kind: ChatEventKind.message,
        chatId: 2,
        message: testMessageView(
          id: 90,
          chatId: 2,
          createdAt: DateTime.utc(2026, 9, 24),
        ),
      ),
    );

    expect(controller.chats.map((chat) => chat.chat.id), [2, 1]);
    controller.dispose();
  });
}
