import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/features/messaging/application/conversation_controller.dart';
import 'package:mobile_messenger/features/messaging/domain/chat_media_format.dart';

import '../../support/message_fakes.dart';
import '../../support/profile_fakes.dart';
import '../../support/video_poster_fakes.dart';

void main() {
  test('load shows history in newest-first order', () async {
    final repository = FakeMessageRepository(
      history: [
        testMessageView(
          id: 2,
          text: 'newer',
          isMine: true,
          senderUsername: 'Me',
        ),
        testMessageView(id: 1, text: 'older'),
      ],
    );
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );

    await controller.load();

    expect(controller.status, ConversationStatus.ready);
    expect(controller.items.map((item) => item.text), ['newer', 'older']);
    expect(controller.items.first.status, ConversationItemStatus.sent);
    expect(controller.items.last.status, ConversationItemStatus.received);
    expect(repository.deliveredIds, [1]);
    expect(repository.readIds, [1]);
    controller.dispose();
    repository.dispose();
  });

  test('overlapping load joins the in-flight history request', () async {
    final repository = FakeMessageRepository();
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );

    final first = controller.load();
    final second = controller.load();
    await Future.wait([first, second]);

    expect(repository.listHistoryCalls, 1);
    expect(controller.status, ConversationStatus.ready);
    expect(controller.isBusy, isFalse);
    controller.dispose();
    repository.dispose();
  });

  test('refreshOnResume reloads history without leaving a spinner', () async {
    final repository = FakeMessageRepository(
      history: [testMessageView(id: 1, text: 'first')],
    );
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );
    await controller.load();
    repository.history = [testMessageView(id: 2, text: 'after resume')];

    await controller.refreshOnResume();

    expect(repository.listHistoryCalls, 2);
    expect(controller.status, ConversationStatus.ready);
    expect(controller.isBusy, isFalse);
    expect(controller.items.single.text, 'after resume');
    controller.dispose();
    repository.dispose();
  });

  test('a dropped realtime stream is resubscribed on resume', () async {
    final repository = FakeMessageRepository();
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );
    await controller.load();
    expect(repository.watchCalls, 1);

    repository.events.addError(Exception('socket closed'));
    await Future<void>.delayed(Duration.zero);

    await controller.refreshOnResume();

    expect(repository.watchCalls, 2);
    controller.applyEvent(
      ChatEvent(
        kind: ChatEventKind.message,
        chatId: 1,
        message: testMessageView(id: 8, text: 'reconnected'),
      ),
    );
    expect(controller.items.single.text, 'reconnected');
    controller.dispose();
    repository.dispose();
  });

  test('send then failure leaves a retryable item', () async {
    final repository = FakeMessageRepository(sendError: Exception('down'));
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );
    await controller.load();

    await controller.send('Hello Bob');

    expect(controller.items, hasLength(1));
    expect(controller.items.single.status, ConversationItemStatus.failed);
    expect(controller.items.single.text, 'Hello Bob');
    expect(controller.errorMessage, isNotNull);
    expect(repository.sentTexts, ['Hello Bob']);

    repository.sendError = null;
    await controller.retry(controller.items.single.localKey);

    expect(controller.items, hasLength(1));
    expect(controller.items.single.status, ConversationItemStatus.sent);
    expect(controller.items.single.serverId, isNotNull);
    expect(repository.sentTexts, ['Hello Bob', 'Hello Bob']);
    controller.dispose();
    repository.dispose();
  });

  test('realtime insert and history do not duplicate the same id', () async {
    final view = testMessageView(id: 7, text: 'Hello Bob');
    final repository = FakeMessageRepository();
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );
    await controller.load();

    controller.applyEvent(
      ChatEvent(kind: ChatEventKind.message, chatId: 1, message: view),
    );
    repository.history = [view];
    await controller.loadOlder();
    controller.applyEvent(
      ChatEvent(kind: ChatEventKind.message, chatId: 1, message: view),
    );

    expect(controller.items.where((item) => item.serverId == 7), hasLength(1));
    controller.dispose();
    repository.dispose();
  });

  test('receipt events update delivered and read state', () async {
    final view = testMessageView(
      id: 3,
      text: 'Hi',
      isMine: true,
      senderUsername: 'Me',
      receipts: [testReceipt(messageId: 3, userId: 2)],
    );
    final repository = FakeMessageRepository(history: [view]);
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );
    await controller.load();
    expect(controller.items.single.status, ConversationItemStatus.sent);

    controller.applyEvent(
      ChatEvent(
        kind: ChatEventKind.receipt,
        chatId: 1,
        receipt: testReceipt(
          messageId: 3,
          userId: 2,
          deliveredAt: DateTime.utc(2026, 9, 20, 12),
        ),
      ),
    );
    expect(controller.items.single.status, ConversationItemStatus.delivered);

    controller.applyEvent(
      ChatEvent(
        kind: ChatEventKind.receipt,
        chatId: 1,
        receipt: testReceipt(
          messageId: 3,
          userId: 2,
          deliveredAt: DateTime.utc(2026, 9, 20, 12),
          readAt: DateTime.utc(2026, 9, 20, 12, 1),
        ),
      ),
    );
    expect(controller.items.single.status, ConversationItemStatus.read);
    controller.dispose();
    repository.dispose();
  });

  test('load older appends without duplicating', () async {
    final repository = FakeMessageRepository(
      pageSize: 2,
      history: [
        testMessageView(id: 5, text: 'e', isMine: true, senderUsername: 'Me'),
        testMessageView(id: 4, text: 'd', isMine: true, senderUsername: 'Me'),
        testMessageView(id: 3, text: 'c'),
        testMessageView(id: 2, text: 'b'),
        testMessageView(id: 1, text: 'a'),
      ],
    );
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );
    await controller.load();
    expect(controller.items.map((item) => item.text), ['e', 'd']);
    expect(controller.hasMore, isTrue);

    await controller.loadOlder();
    expect(controller.items.map((item) => item.text), ['e', 'd', 'c', 'b']);
    expect(controller.items.map((item) => item.serverId).toSet(), {5, 4, 3, 2});

    await controller.loadOlder();
    expect(controller.items.map((item) => item.text), [
      'e',
      'd',
      'c',
      'b',
      'a',
    ]);
    expect(controller.hasMore, isFalse);
    controller.dispose();
    repository.dispose();
  });

  test('successful image upload updates conversation state', () async {
    final repository = FakeMessageRepository();
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );
    await controller.load();

    await controller.sendMedia(testPngBytes);

    expect(controller.items, hasLength(1));
    expect(controller.items.single.type, MessageType.image);
    expect(controller.items.single.status, ConversationItemStatus.sent);
    expect(controller.items.single.mediaId, isNotNull);
    expect(repository.sentMedia, hasLength(1));
    expect(
      controller.mediaBytes(controller.items.single.mediaId!),
      testPngBytes,
    );
    controller.dispose();
    repository.dispose();
  });

  test('video upload success then failure can be retried', () async {
    final repository = FakeMessageRepository(sendError: Exception('down'));
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );
    await controller.load();

    await controller.sendMedia(_mp4Bytes());

    expect(controller.items.single.status, ConversationItemStatus.failed);
    expect(controller.items.single.type, MessageType.video);
    expect(controller.errorMessage, isNotNull);

    repository.sendError = null;
    await controller.retry(controller.items.single.localKey);

    expect(controller.items, hasLength(1));
    expect(controller.items.single.status, ConversationItemStatus.sent);
    expect(controller.items.single.type, MessageType.video);
    expect(repository.sentMedia, hasLength(2));
    controller.dispose();
    repository.dispose();
  });

  test('MOV container is sent as a video message', () async {
    final repository = FakeMessageRepository();
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );
    await controller.load();

    final mov = _ftypBrand('qt  ');
    expect(ChatMediaFormat.detect(mov)?.mimeType, 'video/quicktime');

    await controller.sendMedia(mov);

    expect(controller.items.single.type, MessageType.video);
    expect(controller.items.single.status, ConversationItemStatus.sent);
    expect(repository.sentMedia, [mov]);
    controller.dispose();
    repository.dispose();
  });

  test('oversized media is rejected before the server is called', () async {
    final repository = FakeMessageRepository();
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );
    await controller.load();

    final tooLarge = Uint8List(ChatMediaFormat.maxBytes + 1);
    tooLarge[0] = 0xFF;
    tooLarge[1] = 0xD8;
    tooLarge[2] = 0xFF;
    await controller.sendMedia(tooLarge);

    expect(controller.items, isEmpty);
    expect(repository.sentMedia, isEmpty);
    expect(controller.errorMessage, contains('20 MB'));
    controller.dispose();
    repository.dispose();
  });

  test('unsupported media is rejected before the server is called', () async {
    final repository = FakeMessageRepository();
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );
    await controller.load();

    await controller.sendMedia(
      Uint8List.fromList([0x47, 0x49, 0x46, 0x38, 0x39, 0x61]),
    );

    expect(controller.items, isEmpty);
    expect(repository.sentMedia, isEmpty);
    expect(controller.errorMessage, contains('JPEG'));
    controller.dispose();
    repository.dispose();
  });

  test('history load does not fetch video bytes', () async {
    final repository = FakeMessageRepository(
      history: [
        testMessageView(
          id: 8,
          text: '',
          type: MessageType.video,
          mediaId: 12,
          thumbnailMediaId: 21,
        ),
        testMessageView(
          id: 9,
          text: '',
          type: MessageType.video,
          mediaId: 13,
          thumbnailMediaId: 22,
        ),
      ],
    );
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );
    await controller.load();

    expect(controller.items, hasLength(2));
    expect(repository.mediaRequests, isEmpty);
    controller.dispose();
    repository.dispose();
  });

  test(
    'video send stores a generated poster without extra full fetch',
    () async {
      final repository = FakeMessageRepository();
      final poster = FakeVideoPoster(bytes: testJpegBytes);
      final controller = ConversationController(
        repository: repository,
        chatId: 1,
        poster: poster,
      );
      await controller.load();
      await controller.sendMedia(_mp4Bytes());

      expect(poster.extractCalls, 1);
      expect(repository.sentThumbnails, [testJpegBytes]);
      expect(controller.items.single.thumbnailMediaId, isNotNull);
      expect(repository.mediaRequests, isEmpty);
      controller.dispose();
      repository.dispose();
    },
  );

  test('ensureMedia loads bytes for an image message', () async {
    final png = testPngBytes;
    final repository = FakeMessageRepository(
      history: [
        testMessageView(id: 4, text: '', type: MessageType.image, mediaId: 9),
      ],
    );
    repository.mediaById[9] = testChatMedia(
      mediaId: 9,
      mimeType: 'image/png',
      bytes: png,
    );
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );
    await controller.load();
    await controller.ensureMedia(9);

    expect(controller.mediaStatus(9), ConversationMediaStatus.loaded);
    expect(controller.mediaBytes(9), png);
    controller.dispose();
    repository.dispose();
  });

  test('ensureMedia failure is an error state', () async {
    final repository = FakeMessageRepository(
      history: [
        testMessageView(id: 5, text: '', type: MessageType.video, mediaId: 11),
      ],
      mediaError: Exception('down'),
    );
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );
    await controller.load();
    await controller.ensureMedia(11);

    expect(controller.mediaStatus(11), ConversationMediaStatus.failed);
    expect(controller.errorMessage, isNotNull);
    controller.dispose();
    repository.dispose();
  });

  test('composer typing starts once and stops after idle', () {
    fakeAsync((async) {
      final repository = FakeMessageRepository();
      final controller = ConversationController(
        repository: repository,
        chatId: 1,
        selfUserId: 1,
      );

      controller.onComposerTextChanged('Hello');
      async.flushMicrotasks();
      expect(repository.typingUpdates, [(chatId: 1, isTyping: true)]);

      controller.onComposerTextChanged('Hello world');
      async.flushMicrotasks();
      expect(repository.typingUpdates, hasLength(1));

      async.elapse(const Duration(milliseconds: 1500));
      async.flushMicrotasks();
      expect(repository.typingUpdates.last.isTyping, isFalse);

      controller.dispose();
      async.flushMicrotasks();
      repository.dispose();
    });
  });

  test('clearing text and sending both stop typing', () {
    fakeAsync((async) {
      final repository = FakeMessageRepository();
      final controller = ConversationController(
        repository: repository,
        chatId: 1,
        selfUserId: 1,
      );

      controller.onComposerTextChanged('Hi');
      async.flushMicrotasks();
      controller.onComposerTextChanged('');
      async.flushMicrotasks();
      expect(repository.typingUpdates.last.isTyping, isFalse);

      controller.onComposerTextChanged('Ping');
      async.flushMicrotasks();
      controller.send('Ping');
      async.flushMicrotasks();
      expect(repository.typingUpdates.last.isTyping, isFalse);
      expect(repository.sentTexts, ['Ping']);

      controller.dispose();
      async.flushMicrotasks();
      repository.dispose();
    });
  });

  test('disposal stops typing', () {
    fakeAsync((async) {
      final repository = FakeMessageRepository();
      final controller = ConversationController(
        repository: repository,
        chatId: 1,
        selfUserId: 1,
      );
      controller.onComposerTextChanged('Hi');
      async.flushMicrotasks();
      controller.dispose();
      async.flushMicrotasks();
      expect(repository.typingUpdates.last.isTyping, isFalse);
      repository.dispose();
    });
  });

  test('own typing event is ignored and unrelated chats are ignored', () {
    final repository = FakeMessageRepository();
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
      selfUserId: 1,
    );

    controller.applyEvent(
      ChatEvent(
        kind: ChatEventKind.typingStarted,
        chatId: 1,
        typingUserId: 1,
        typingUsername: 'Me',
      ),
    );
    expect(controller.typingLabel, isNull);

    controller.applyEvent(
      ChatEvent(
        kind: ChatEventKind.typingStarted,
        chatId: 99,
        typingUserId: 2,
        typingUsername: 'Alice',
      ),
    );
    expect(controller.typingLabel, isNull);

    controller.dispose();
    repository.dispose();
  });

  test('remote typing start, stop, stale expiry, and group labels', () {
    fakeAsync((async) {
      final repository = FakeMessageRepository();
      final controller = ConversationController(
        repository: repository,
        chatId: 1,
        selfUserId: 1,
      );

      controller.applyEvent(
        ChatEvent(
          kind: ChatEventKind.typingStarted,
          chatId: 1,
          typingUserId: 2,
          typingUsername: 'Anna',
        ),
      );
      expect(controller.typingLabel, 'Anna is typing…');

      controller.applyEvent(
        ChatEvent(
          kind: ChatEventKind.typingStarted,
          chatId: 1,
          typingUserId: 3,
          typingUsername: 'Mikko',
        ),
      );
      expect(controller.typingLabel, 'Anna and Mikko are typing…');

      controller.applyEvent(
        ChatEvent(
          kind: ChatEventKind.typingStarted,
          chatId: 1,
          typingUserId: 4,
          typingUsername: 'Topi',
        ),
      );
      expect(controller.typingLabel, 'Anna, Mikko and 1 other are typing…');

      controller.applyEvent(
        ChatEvent(
          kind: ChatEventKind.typingStopped,
          chatId: 1,
          typingUserId: 3,
          typingUsername: 'Mikko',
        ),
      );
      expect(controller.typingLabel, 'Anna and Topi are typing…');

      async.elapse(const Duration(milliseconds: 5000));
      expect(controller.typingLabel, isNull);

      controller.dispose();
      async.flushMicrotasks();
      repository.dispose();
    });
  });

  test('watch disconnect clears remote typing', () async {
    final repository = FakeMessageRepository();
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
      selfUserId: 1,
    );
    await controller.load();
    controller.applyEvent(
      ChatEvent(
        kind: ChatEventKind.typingStarted,
        chatId: 1,
        typingUserId: 2,
        typingUsername: 'Alice',
      ),
    );
    expect(controller.typingLabel, 'Alice is typing…');

    repository.events.addError(Exception('disconnected'));
    await Future<void>.delayed(Duration.zero);
    expect(controller.typingLabel, isNull);

    controller.dispose();
    repository.dispose();
  });

  test('typing failure does not prevent message sending', () async {
    final repository = FakeMessageRepository(typingError: Exception('down'));
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
      selfUserId: 1,
    );
    await controller.load();
    controller.onComposerTextChanged('Hello');
    await controller.send('Hello');

    expect(repository.sentTexts, ['Hello']);
    expect(controller.items.single.status, ConversationItemStatus.sent);
    expect(controller.status, ConversationStatus.ready);
    controller.dispose();
    repository.dispose();
  });

  test('history reconstructs edited and deleted state', () async {
    final repository = FakeMessageRepository(
      history: [
        testMessageView(
          id: 2,
          text: '',
          isMine: true,
          senderUsername: 'Me',
          deletedAt: DateTime.utc(2026, 9, 21, 12),
        ),
        testMessageView(
          id: 1,
          text: 'Updated',
          isMine: true,
          senderUsername: 'Me',
          editedAt: DateTime.utc(2026, 9, 21, 11),
        ),
      ],
    );
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
      selfUserId: 1,
    );
    await controller.load();

    expect(controller.items.first.isDeleted, isTrue);
    expect(controller.items.first.canEdit, isFalse);
    expect(controller.items.first.canDelete, isFalse);
    expect(controller.items.last.isEdited, isTrue);
    expect(controller.items.last.canEdit, isTrue);
    controller.dispose();
    repository.dispose();
  });

  test('saveEdit updates text and cancel leaves the original', () async {
    final repository = FakeMessageRepository(
      history: [
        testMessageView(
          id: 4,
          text: 'Original',
          isMine: true,
          senderUsername: 'Me',
          senderId: 1,
        ),
      ],
    );
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
      selfUserId: 1,
    );
    await controller.load();
    final item = controller.items.single;

    controller.beginEdit(item);
    expect(controller.isEditing, isTrue);
    controller.cancelEdit();
    expect(controller.isEditing, isFalse);
    expect(controller.items.single.text, 'Original');

    controller.beginEdit(item);
    await controller.saveEdit('Changed');
    expect(controller.isEditing, isFalse);
    expect(controller.items.single.text, 'Changed');
    expect(controller.items.single.isEdited, isTrue);
    expect(repository.editedTexts.single.text, 'Changed');
    expect(controller.items, hasLength(1));
    controller.dispose();
    repository.dispose();
  });

  test('edit failure preserves original message', () async {
    final repository = FakeMessageRepository(
      history: [
        testMessageView(
          id: 5,
          text: 'Stay',
          isMine: true,
          senderUsername: 'Me',
          senderId: 1,
        ),
      ],
      editError: Exception('down'),
    );
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
      selfUserId: 1,
    );
    await controller.load();
    controller.beginEdit(controller.items.single);
    await controller.saveEdit('New');
    expect(controller.items.single.text, 'Stay');
    expect(controller.items.single.isEdited, isFalse);
    expect(controller.errorMessage, isNotNull);
    expect(controller.status, ConversationStatus.ready);
    controller.dispose();
    repository.dispose();
  });

  test('delete failure preserves original message', () async {
    final repository = FakeMessageRepository(
      history: [
        testMessageView(
          id: 6,
          text: 'Keep',
          isMine: true,
          senderUsername: 'Me',
          senderId: 1,
        ),
      ],
      deleteError: Exception('down'),
    );
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
      selfUserId: 1,
    );
    await controller.load();
    await controller.deleteMessage(controller.items.single);
    expect(controller.items.single.text, 'Keep');
    expect(controller.items.single.isDeleted, isFalse);
    expect(controller.errorMessage, isNotNull);
    controller.dispose();
    repository.dispose();
  });

  test('delete succeeds and realtime edit/delete upsert by id', () async {
    final repository = FakeMessageRepository(
      history: [
        testMessageView(
          id: 7,
          text: 'Mine',
          isMine: true,
          senderUsername: 'Me',
          senderId: 1,
        ),
      ],
    );
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
      selfUserId: 1,
    );
    await controller.load();
    await controller.deleteMessage(controller.items.single);
    expect(controller.items, hasLength(1));
    expect(controller.items.single.isDeleted, isTrue);
    expect(controller.items.single.text, isEmpty);

    controller.applyEvent(
      ChatEvent(
        kind: ChatEventKind.messageEdited,
        chatId: 1,
        message: testMessageView(
          id: 7,
          text: 'From stream',
          isMine: true,
          senderUsername: 'Me',
          senderId: 1,
          editedAt: DateTime.utc(2026, 9, 21, 13),
        ),
      ),
    );
    expect(controller.items, hasLength(1));
    expect(controller.items.single.text, 'From stream');

    controller.applyEvent(
      ChatEvent(
        kind: ChatEventKind.messageDeleted,
        chatId: 1,
        message: testMessageView(
          id: 7,
          text: '',
          isMine: true,
          senderUsername: 'Me',
          senderId: 1,
          deletedAt: DateTime.utc(2026, 9, 21, 14),
        ),
      ),
    );
    expect(controller.items, hasLength(1));
    expect(controller.items.single.isDeleted, isTrue);
    controller.dispose();
    repository.dispose();
  });

  test('successful audio upload updates conversation state', () async {
    final repository = FakeMessageRepository();
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );
    await controller.load();

    await controller.sendAudio(testWavBytes());

    expect(controller.items, hasLength(1));
    expect(controller.items.single.type, MessageType.audio);
    expect(controller.items.single.status, ConversationItemStatus.sent);
    expect(controller.items.single.mediaId, isNotNull);
    expect(controller.items.single.canEdit, isFalse);
    expect(controller.items.single.canDelete, isTrue);
    expect(repository.sentAudio, hasLength(1));
    expect(
      controller.mediaBytes(controller.items.single.mediaId!),
      testWavBytes(),
    );
    controller.dispose();
    repository.dispose();
  });

  test(
    'failed audio send can be retried and does not look successful',
    () async {
      final repository = FakeMessageRepository(sendError: Exception('down'));
      final controller = ConversationController(
        repository: repository,
        chatId: 1,
      );
      await controller.load();

      await controller.sendAudio(testWavBytes());

      expect(controller.items, hasLength(1));
      expect(controller.items.single.status, ConversationItemStatus.failed);
      expect(controller.items.single.type, MessageType.audio);
      expect(controller.items.single.serverId, isNull);
      expect(controller.errorMessage, isNotNull);

      repository.sendError = null;
      await controller.retry(controller.items.single.localKey);

      expect(controller.items, hasLength(1));
      expect(controller.items.single.status, ConversationItemStatus.sent);
      expect(controller.items.single.type, MessageType.audio);
      expect(repository.sentAudio, hasLength(2));
      expect(repository.sentMedia, isEmpty);
      controller.dispose();
      repository.dispose();
    },
  );

  test('oversized audio is rejected before the server is called', () async {
    final repository = FakeMessageRepository();
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );
    await controller.load();

    final tooLarge = testWavBytes(
      extraBytes: ChatMediaFormat.maxAudioBytes - 43,
    );
    await controller.sendAudio(tooLarge);

    expect(controller.items, isEmpty);
    expect(repository.sentAudio, isEmpty);
    expect(controller.errorMessage, contains('10 MB'));
    controller.dispose();
    repository.dispose();
  });

  test('unsupported audio is rejected before the server is called', () async {
    final repository = FakeMessageRepository();
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );
    await controller.load();

    await controller.sendAudio(
      Uint8List.fromList([0xFF, 0xD8, 0xFF, ...List.filled(50, 1)]),
    );

    expect(controller.items, isEmpty);
    expect(repository.sentAudio, isEmpty);
    expect(controller.errorMessage, contains('WAV'));
    controller.dispose();
    repository.dispose();
  });

  test('empty audio is rejected before the server is called', () async {
    final repository = FakeMessageRepository();
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );
    await controller.load();

    await controller.sendAudio(Uint8List(0));

    expect(controller.items, isEmpty);
    expect(repository.sentAudio, isEmpty);
    expect(controller.errorMessage, contains('empty'));
    controller.dispose();
    repository.dispose();
  });

  test('incoming audio realtime is inserted once', () async {
    final view = testMessageView(
      id: 21,
      text: '',
      type: MessageType.audio,
      mediaId: 44,
    );
    final repository = FakeMessageRepository();
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );
    await controller.load();

    controller.applyEvent(
      ChatEvent(kind: ChatEventKind.message, chatId: 1, message: view),
    );
    controller.applyEvent(
      ChatEvent(kind: ChatEventKind.message, chatId: 1, message: view),
    );

    expect(controller.items.where((item) => item.serverId == 21), hasLength(1));
    expect(controller.items.single.type, MessageType.audio);
    expect(controller.mediaStatus(44), ConversationMediaStatus.idle);
    controller.dispose();
    repository.dispose();
  });

  test('deleted audio drops cached bytes and cannot be fetched', () async {
    final wav = testWavBytes();
    final repository =
        FakeMessageRepository(
            history: [
              testMessageView(
                id: 8,
                text: '',
                isMine: true,
                senderUsername: 'Me',
                senderId: 1,
                type: MessageType.audio,
                mediaId: 33,
              ),
            ],
          )
          ..mediaById[33] = testChatMedia(
            mediaId: 33,
            type: MediaType.audio,
            mimeType: 'audio/wav',
            bytes: wav,
          );
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );
    await controller.load();
    await controller.ensureMedia(33);
    expect(controller.mediaBytes(33), wav);

    await controller.deleteMessage(controller.items.single);
    expect(controller.items.single.isDeleted, isTrue);
    expect(controller.mediaBytes(33), isNull);
    await controller.ensureMedia(33);
    expect(controller.mediaStatus(33), ConversationMediaStatus.idle);
    controller.dispose();
    repository.dispose();
  });

  test('text sending still works after audio', () async {
    final repository = FakeMessageRepository();
    final controller = ConversationController(
      repository: repository,
      chatId: 1,
    );
    await controller.load();
    await controller.sendAudio(testWavBytes());
    await controller.send('hello');
    expect(repository.sentTexts, ['hello']);
    expect(controller.items.map((item) => item.type), [
      MessageType.text,
      MessageType.audio,
    ]);
    controller.dispose();
    repository.dispose();
  });
}

Uint8List _mp4Bytes() => Uint8List.fromList([
  0x00,
  0x00,
  0x00,
  0x18,
  0x66,
  0x74,
  0x79,
  0x70,
  0x69,
  0x73,
  0x6F,
  0x6D,
  0x00,
  0x00,
  0x00,
  0x00,
  0x69,
  0x73,
  0x6F,
  0x6D,
  0x6D,
  0x70,
  0x34,
  0x31,
]);

Uint8List _ftypBrand(String brand) {
  return Uint8List.fromList([
    0x00,
    0x00,
    0x00,
    0x18,
    0x66,
    0x74,
    0x79,
    0x70,
    ...brand.codeUnits,
  ]);
}
