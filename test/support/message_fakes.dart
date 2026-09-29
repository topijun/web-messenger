import 'dart:async';
import 'dart:typed_data';

import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/features/messaging/data/message_repository.dart';

MessageView testMessageView({
  int id = 1,
  int chatId = 1,
  int senderId = 2,
  String text = 'Hello Bob',
  bool isMine = false,
  String senderUsername = 'Alice',
  int? senderProfileImageId,
  DateTime? createdAt,
  DateTime? editedAt,
  DateTime? deletedAt,
  List<MessageReceipt>? receipts,
  MessageType type = MessageType.text,
  int? mediaId,
  int? thumbnailMediaId,
  PollView? poll,
}) {
  return MessageView(
    message: Message(
      id: id,
      chatId: chatId,
      senderId: senderId,
      type: type,
      encryptedText: text,
      mediaId: mediaId,
      createdAt: createdAt ?? DateTime.utc(2026, 9, 20, 12, id),
      editedAt: editedAt,
      deletedAt: deletedAt,
      pollId: poll?.id,
    ),
    senderUsername: senderUsername,
    senderProfileImageId: senderProfileImageId,
    isMine: isMine,
    receipts: receipts ?? const [],
    thumbnailMediaId: thumbnailMediaId,
    poll: deletedAt == null ? poll : null,
  );
}

MessageReceipt testReceipt({
  int id = 1,
  int messageId = 1,
  int userId = 1,
  DateTime? deliveredAt,
  DateTime? readAt,
}) {
  return MessageReceipt(
    id: id,
    messageId: messageId,
    userId: userId,
    deliveredAt: deliveredAt,
    readAt: readAt,
  );
}

ChatMedia testChatMedia({
  int mediaId = 9,
  MediaType type = MediaType.image,
  String mimeType = 'image/png',
  Uint8List? bytes,
  int? thumbnailMediaId,
}) {
  final payload = bytes ?? Uint8List.fromList([0xFF, 0xD8, 0xFF, 1, 2, 3]);
  return ChatMedia(
    mediaId: mediaId,
    type: type,
    mimeType: mimeType,
    size: payload.length,
    bytes: ByteData.sublistView(payload),
    thumbnailMediaId: thumbnailMediaId,
  );
}

class FakeMessageRepository implements MessageRepository {
  FakeMessageRepository({
    List<MessageView>? history,
    this.sendError,
    this.loadError,
    this.mediaError,
    this.typingError,
    this.editError,
    this.deleteError,
    this.pageSize = 30,
  }) : history = List<MessageView>.from(history ?? const []);

  List<MessageView> history;
  Object? sendError;
  Object? loadError;
  Object? mediaError;
  int pageSize;
  int nextId = 100;
  int nextMediaId = 500;
  final _events = StreamController<ChatEvent>.broadcast();
  final sentTexts = <String>[];
  final sentMedia = <Uint8List>[];
  final sentThumbnails = <Uint8List>[];
  final mediaRequests = <int>[];
  final sentAudio = <Uint8List>[];
  final deliveredIds = <int>[];
  final readIds = <int>[];
  final mediaById = <int, ChatMedia>{};
  final typingUpdates = <({int chatId, bool isTyping})>[];
  final editedTexts = <({int messageId, String text})>[];
  final deletedIds = <int>[];
  final searchQueries = <({int chatId, String query})>[];
  final createdPolls = <({int chatId, String question, bool anonymous})>[];
  Object? searchError;
  Object? pollError;
  int listHistoryCalls = 0;
  int watchCalls = 0;
  Object? typingError;
  Object? editError;
  Object? deleteError;

  /// Test handle for injecting realtime events.
  StreamController<ChatEvent> get events => _events;

  @override
  Future<MessageView> sendText({
    required int chatId,
    required String encryptedText,
  }) async {
    sentTexts.add(encryptedText);
    if (sendError != null) {
      throw sendError!;
    }
    nextId += 1;
    final view = testMessageView(
      id: nextId,
      chatId: chatId,
      senderId: 1,
      text: encryptedText,
      isMine: true,
      senderUsername: 'Topi.J',
      createdAt: DateTime.now().toUtc(),
    );
    history.insert(0, view);
    return view;
  }

  @override
  Future<MessageView> sendMedia({
    required int chatId,
    required ByteData bytes,
    ByteData? thumbnailBytes,
  }) async {
    final payload = Uint8List.sublistView(bytes);
    sentMedia.add(payload);
    if (thumbnailBytes != null) {
      sentThumbnails.add(Uint8List.sublistView(thumbnailBytes));
    }
    if (sendError != null) {
      throw sendError!;
    }
    nextId += 1;
    final isVideo =
        payload.length >= 8 &&
        payload[4] == 0x66 &&
        payload[5] == 0x74 &&
        payload[6] == 0x79 &&
        payload[7] == 0x70;
    int? thumbnailId;
    if (isVideo && thumbnailBytes != null) {
      nextMediaId += 1;
      thumbnailId = nextMediaId;
      mediaById[thumbnailId] = testChatMedia(
        mediaId: thumbnailId,
        type: MediaType.image,
        mimeType: 'image/jpeg',
        bytes: Uint8List.sublistView(thumbnailBytes),
      );
    }
    nextMediaId += 1;
    final view = testMessageView(
      id: nextId,
      chatId: chatId,
      senderId: 1,
      text: '',
      isMine: true,
      senderUsername: 'Topi.J',
      createdAt: DateTime.now().toUtc(),
      type: isVideo ? MessageType.video : MessageType.image,
      mediaId: nextMediaId,
      thumbnailMediaId: thumbnailId,
    );
    mediaById[nextMediaId] = testChatMedia(
      mediaId: nextMediaId,
      type: isVideo ? MediaType.video : MediaType.image,
      mimeType: isVideo ? 'video/mp4' : 'image/png',
      bytes: payload,
      thumbnailMediaId: thumbnailId,
    );
    history.insert(0, view);
    return view;
  }

  @override
  Future<MessageView> sendAudio({
    required int chatId,
    required ByteData bytes,
  }) async {
    final payload = Uint8List.sublistView(bytes);
    sentAudio.add(payload);
    if (sendError != null) {
      throw sendError!;
    }
    nextId += 1;
    nextMediaId += 1;
    final view = testMessageView(
      id: nextId,
      chatId: chatId,
      senderId: 1,
      text: '',
      isMine: true,
      senderUsername: 'Topi.J',
      createdAt: DateTime.now().toUtc(),
      type: MessageType.audio,
      mediaId: nextMediaId,
    );
    mediaById[nextMediaId] = testChatMedia(
      mediaId: nextMediaId,
      type: MediaType.audio,
      mimeType: 'audio/wav',
      bytes: payload,
    );
    history.insert(0, view);
    return view;
  }

  @override
  Future<ChatMedia> getChatMedia({required int mediaId}) async {
    mediaRequests.add(mediaId);
    if (mediaError != null) {
      throw mediaError!;
    }
    final owner = history.cast<MessageView?>().firstWhere(
      (view) =>
          view?.message.mediaId == mediaId || view?.thumbnailMediaId == mediaId,
      orElse: () => null,
    );
    if (owner?.message.deletedAt != null) {
      throw MessengerMediaNotFoundException(mediaId: mediaId);
    }
    final stored = mediaById[mediaId];
    if (stored == null) {
      throw MessengerMediaNotFoundException(mediaId: mediaId);
    }
    return stored;
  }

  @override
  Future<List<MessageView>> searchText({
    required int chatId,
    required String query,
  }) async {
    searchQueries.add((chatId: chatId, query: query));
    if (searchError != null) {
      throw searchError!;
    }
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) {
      return const [];
    }
    return [
      for (final view in history)
        if (view.message.chatId == chatId &&
            view.message.deletedAt == null &&
            view.message.type == MessageType.text &&
            view.message.encryptedText.toLowerCase().contains(needle))
          view,
    ];
  }

  @override
  Future<MessageHistoryPage> listHistory({
    required int chatId,
    DateTime? beforeCreatedAt,
    int? beforeId,
    int? limit,
  }) async {
    listHistoryCalls += 1;
    if (loadError != null) {
      throw loadError!;
    }
    final all = [
      for (final view in history)
        if (view.message.chatId == chatId) view,
    ];
    var start = 0;
    if (beforeId != null) {
      final index = all.indexWhere((view) => view.message.id == beforeId);
      start = index < 0 ? all.length : index + 1;
    }
    final size = limit ?? pageSize;
    final slice = all.skip(start).take(size).toList();
    final hasMore = start + slice.length < all.length;
    return MessageHistoryPage(
      messages: slice,
      hasMore: hasMore,
      nextCreatedAt: slice.isEmpty ? null : slice.last.message.createdAt,
      nextId: slice.isEmpty ? null : slice.last.message.id,
    );
  }

  @override
  Future<List<MessageReceipt>> markDelivered({
    required List<int> messageIds,
  }) async {
    deliveredIds.addAll(messageIds);
    return [
      for (final id in messageIds)
        testReceipt(messageId: id, deliveredAt: DateTime.utc(2026, 9, 20, 12)),
    ];
  }

  @override
  Future<List<MessageReceipt>> markRead({required List<int> messageIds}) async {
    readIds.addAll(messageIds);
    return [
      for (final id in messageIds)
        testReceipt(
          messageId: id,
          deliveredAt: DateTime.utc(2026, 9, 20, 12),
          readAt: DateTime.utc(2026, 9, 20, 12, 1),
        ),
    ];
  }

  @override
  Stream<ChatEvent> watch() {
    watchCalls += 1;
    return _events.stream;
  }

  @override
  Future<void> setTyping({required int chatId, required bool isTyping}) async {
    typingUpdates.add((chatId: chatId, isTyping: isTyping));
    if (typingError != null) {
      throw typingError!;
    }
  }

  @override
  Future<MessageView> editText({
    required int messageId,
    required String encryptedText,
  }) async {
    editedTexts.add((messageId: messageId, text: encryptedText));
    if (editError != null) {
      throw editError!;
    }
    final index = history.indexWhere((view) => view.message.id == messageId);
    if (index < 0) {
      throw MessengerMessageNotFoundException(messageId: messageId);
    }
    final previous = history[index];
    final updated = MessageView(
      message: previous.message.copyWith(
        encryptedText: encryptedText,
        editedAt: DateTime.now().toUtc(),
      ),
      senderUsername: previous.senderUsername,
      senderProfileImageId: previous.senderProfileImageId,
      isMine: previous.isMine,
      receipts: previous.receipts,
      thumbnailMediaId: previous.thumbnailMediaId,
    );
    history[index] = updated;
    return updated;
  }

  @override
  Future<MessageView> deleteMessage({required int messageId}) async {
    deletedIds.add(messageId);
    if (deleteError != null) {
      throw deleteError!;
    }
    final index = history.indexWhere((view) => view.message.id == messageId);
    if (index < 0) {
      throw MessengerMessageNotFoundException(messageId: messageId);
    }
    final previous = history[index];
    final updated = MessageView(
      message: previous.message.copyWith(
        encryptedText: '',
        deletedAt: DateTime.now().toUtc(),
      ),
      senderUsername: previous.senderUsername,
      senderProfileImageId: previous.senderProfileImageId,
      isMine: previous.isMine,
      receipts: previous.receipts,
      thumbnailMediaId: previous.thumbnailMediaId,
    );
    history[index] = updated;
    return updated;
  }

  @override
  Future<MessageView> createPoll({
    required int chatId,
    required String question,
    required List<String> options,
    required bool anonymous,
  }) async {
    createdPolls.add((
      chatId: chatId,
      question: question,
      anonymous: anonymous,
    ));
    if (pollError != null) {
      throw pollError!;
    }
    final prompt = question.trim();
    final choices = [for (final option in options) option.trim()];
    if (prompt.isEmpty) {
      throw MessengerInvalidChatInputException(
        field: 'question',
        message: 'Poll question cannot be empty.',
      );
    }
    if (choices.length < 2 || choices.any((choice) => choice.isEmpty)) {
      throw MessengerInvalidChatInputException(
        field: 'options',
        message: 'A poll needs between 2 and 6 options.',
      );
    }
    nextId += 1;
    final pollId = nextId;
    final view = testMessageView(
      id: nextId,
      chatId: chatId,
      senderId: 1,
      text: '',
      isMine: true,
      senderUsername: 'Topi.J',
      type: MessageType.poll,
      createdAt: DateTime.now().toUtc(),
      poll: PollView(
        id: pollId,
        question: prompt,
        anonymous: anonymous,
        totalVotes: 0,
        options: [
          for (var index = 0; index < choices.length; index++)
            PollOptionView(
              id: pollId * 10 + index,
              text: choices[index],
              position: index,
              voteCount: 0,
              voters: const [],
            ),
        ],
      ),
    );
    history.insert(0, view);
    return view;
  }

  @override
  Future<MessageView> vote({required int pollId, required int optionId}) async {
    if (pollError != null) {
      throw pollError!;
    }
    final index = history.indexWhere((view) => view.poll?.id == pollId);
    if (index < 0 || history[index].poll == null) {
      throw MessengerPollNotFoundException(pollId: pollId);
    }
    final previous = history[index];
    final poll = previous.poll!;
    final current = poll.myOptionId;
    final nextOptionId = current == optionId ? null : optionId;
    final options = [
      for (final option in poll.options)
        PollOptionView(
          id: option.id,
          text: option.text,
          position: option.position,
          voteCount:
              option.voteCount +
              (option.id == nextOptionId ? 1 : 0) -
              (option.id == current ? 1 : 0),
          voters: poll.anonymous ? const <String>[] : option.voters,
        ),
    ];
    final total =
        poll.totalVotes +
        (current == null && nextOptionId != null ? 1 : 0) -
        (current != null && nextOptionId == null ? 1 : 0);
    final updated = MessageView(
      message: previous.message,
      senderUsername: previous.senderUsername,
      senderProfileImageId: previous.senderProfileImageId,
      isMine: previous.isMine,
      receipts: previous.receipts,
      thumbnailMediaId: previous.thumbnailMediaId,
      poll: poll.copyWith(
        myOptionId: nextOptionId,
        totalVotes: total,
        options: options,
      ),
    );
    history[index] = updated;
    return updated;
  }

  void dispose() {
    _events.close();
  }
}

/// Minimal RIFF/WAVE payload accepted by client and server validation.
Uint8List testWavBytes({int extraBytes = 4}) {
  final bytes = Uint8List(44 + extraBytes);
  bytes[0] = 0x52;
  bytes[1] = 0x49;
  bytes[2] = 0x46;
  bytes[3] = 0x46;
  bytes[8] = 0x57;
  bytes[9] = 0x41;
  bytes[10] = 0x56;
  bytes[11] = 0x45;
  return bytes;
}
