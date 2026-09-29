import 'dart:async';
import 'dart:typed_data';

import 'package:messenger_client/messenger_client.dart';

/// Server-backed messages, history, receipts, realtime events, and chat media.
abstract class MessageRepository {
  /// Sends a text message. [encryptedText] is plaintext in Phase 6+.
  Future<MessageView> sendText({
    required int chatId,
    required String encryptedText,
  });

  /// Sends supported image or video bytes as a chat message.
  Future<MessageView> sendMedia({
    required int chatId,
    required ByteData bytes,
    ByteData? thumbnailBytes,
  });

  /// Sends WAV audio bytes as a chat message.
  Future<MessageView> sendAudio({required int chatId, required ByteData bytes});

  /// Decrypts chat media the signed-in user is allowed to access.
  Future<ChatMedia> getChatMedia({required int mediaId});

  /// Newest-first history page for [chatId].
  Future<MessageHistoryPage> listHistory({
    required int chatId,
    DateTime? beforeCreatedAt,
    int? beforeId,
    int? limit,
  });

  /// Marks [messageIds] delivered for the signed-in recipient.
  Future<List<MessageReceipt>> markDelivered({required List<int> messageIds});

  /// Marks [messageIds] read for the signed-in recipient.
  Future<List<MessageReceipt>> markRead({required List<int> messageIds});

  /// Live message, receipt, and typing events for the signed-in user.
  Stream<ChatEvent> watch();

  /// Emits a transient typing start/stop event for [chatId].
  Future<void> setTyping({required int chatId, required bool isTyping});

  /// Replaces the body of the caller's own text message.
  Future<MessageView> editText({
    required int messageId,
    required String encryptedText,
  });

  /// Soft-deletes the caller's own message.
  Future<MessageView> deleteMessage({required int messageId});
}

/// [MessageRepository] that talks to the generated Serverpod client.
class ServerpodMessageRepository implements MessageRepository {
  /// Creates a [ServerpodMessageRepository].
  ServerpodMessageRepository(this._client);

  final Client _client;
  Stream<ChatEvent>? _watch;

  @override
  Future<MessageView> sendText({
    required int chatId,
    required String encryptedText,
  }) {
    return _client.message.sendText(
      chatId: chatId,
      encryptedText: encryptedText,
    );
  }

  @override
  Future<MessageView> sendMedia({
    required int chatId,
    required ByteData bytes,
    ByteData? thumbnailBytes,
  }) {
    return _client.message.sendMedia(
      chatId: chatId,
      bytes: bytes,
      thumbnailBytes: thumbnailBytes,
    );
  }

  @override
  Future<MessageView> sendAudio({
    required int chatId,
    required ByteData bytes,
  }) {
    return _client.message.sendAudio(chatId: chatId, bytes: bytes);
  }

  @override
  Future<ChatMedia> getChatMedia({required int mediaId}) {
    return _client.message.getChatMedia(mediaId: mediaId);
  }

  @override
  Future<MessageHistoryPage> listHistory({
    required int chatId,
    DateTime? beforeCreatedAt,
    int? beforeId,
    int? limit,
  }) {
    return _client.message.listHistory(
      chatId: chatId,
      beforeCreatedAt: beforeCreatedAt,
      beforeId: beforeId,
      limit: limit,
    );
  }

  @override
  Future<List<MessageReceipt>> markDelivered({required List<int> messageIds}) {
    return _client.message.markDelivered(messageIds: messageIds);
  }

  @override
  Future<List<MessageReceipt>> markRead({required List<int> messageIds}) {
    return _client.message.markRead(messageIds: messageIds);
  }

  @override
  Stream<ChatEvent> watch() {
    return _watch ??= _client.message.watch().asBroadcastStream(
      onCancel: (_) {
        _watch = null;
      },
    );
  }

  @override
  Future<void> setTyping({required int chatId, required bool isTyping}) {
    return _client.message.setTyping(chatId: chatId, isTyping: isTyping);
  }

  @override
  Future<MessageView> editText({
    required int messageId,
    required String encryptedText,
  }) {
    return _client.message.editText(
      messageId: messageId,
      encryptedText: encryptedText,
    );
  }

  @override
  Future<MessageView> deleteMessage({required int messageId}) {
    return _client.message.deleteMessage(messageId: messageId);
  }
}
