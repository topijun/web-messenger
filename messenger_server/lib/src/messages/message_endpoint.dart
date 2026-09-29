import 'dart:typed_data';

import 'package:serverpod/serverpod.dart' hide Message;

import '../generated/protocol.dart';
import 'messages.dart';

/// Authenticated text/image/video/audio messages, history, receipts, and realtime.
class MessageEndpoint extends Endpoint {
  static const _messages = Messages();

  @override
  bool get requireLogin => true;

  /// Sends a text message in a chat the caller belongs to.
  ///
  /// [encryptedText] is plaintext from the client. The server encrypts it
  /// before PostgreSQL persistence.
  Future<MessageView> sendText(
    Session session, {
    required int chatId,
    required String encryptedText,
  }) {
    return _messages.sendText(
      session,
      chatId: chatId,
      encryptedText: encryptedText,
    );
  }

  /// Sends a JPEG, PNG, MP4, or WebM message in a chat the caller belongs to.
  ///
  /// [bytes] are plaintext. The server encrypts them before persistence.
  /// The returned view includes [Message.mediaId]; media bytes are retrieved
  /// separately with [getChatMedia].
  Future<MessageView> sendMedia(
    Session session, {
    required int chatId,
    required ByteData bytes,
    ByteData? thumbnailBytes,
  }) {
    return _messages.sendMedia(
      session,
      chatId: chatId,
      bytes: bytes,
      thumbnailBytes: thumbnailBytes,
    );
  }

  /// Sends a WAV audio message in a chat the caller belongs to.
  ///
  /// [bytes] are plaintext. The server encrypts them before persistence.
  /// The returned view includes [Message.mediaId]; audio bytes are retrieved
  /// separately with [getChatMedia].
  Future<MessageView> sendAudio(
    Session session, {
    required int chatId,
    required ByteData bytes,
  }) {
    return _messages.sendAudio(session, chatId: chatId, bytes: bytes);
  }

  /// Decrypts chat media for a member of the chat that owns the message.
  Future<ChatMedia> getChatMedia(Session session, {required int mediaId}) {
    return _messages.getChatMedia(session, mediaId: mediaId);
  }

  /// Case-insensitive text search in a chat the caller belongs to.
  ///
  /// [query] is plaintext. The server decrypts stored message text and
  /// matches it in memory. PostgreSQL is not asked to search ciphertext.
  Future<List<MessageView>> searchText(
    Session session, {
    required int chatId,
    required String query,
  }) {
    return _messages.searchText(session, chatId: chatId, query: query);
  }

  /// Newest-first history for a chat the caller belongs to.
  Future<MessageHistoryPage> listHistory(
    Session session, {
    required int chatId,
    DateTime? beforeCreatedAt,
    int? beforeId,
    int? limit,
  }) {
    return _messages.listHistory(
      session,
      chatId: chatId,
      beforeCreatedAt: beforeCreatedAt,
      beforeId: beforeId,
      limit: limit,
    );
  }

  /// Creates a poll message in a group chat the caller belongs to.
  ///
  /// [question] and [options] are plaintext. The server encrypts them.
  Future<MessageView> createPoll(
    Session session, {
    required int chatId,
    required String question,
    required List<String> options,
    required bool anonymous,
  }) {
    return _messages.createPoll(
      session,
      chatId: chatId,
      question: question,
      options: options,
      anonymous: anonymous,
    );
  }

  /// Selects [optionId] for the caller.
  ///
  /// Choosing the current option retracts the vote. Choosing a different
  /// option replaces it.
  Future<MessageView> vote(
    Session session, {
    required int pollId,
    required int optionId,
  }) {
    return _messages.vote(session, pollId: pollId, optionId: optionId);
  }

  /// Marks messages as delivered for the authenticated recipient.
  Future<List<MessageReceipt>> markDelivered(
    Session session, {
    required List<int> messageIds,
  }) {
    return _messages.markDelivered(session, messageIds: messageIds);
  }

  /// Marks messages as read for the authenticated recipient.
  Future<List<MessageReceipt>> markRead(
    Session session, {
    required List<int> messageIds,
  }) {
    return _messages.markRead(session, messageIds: messageIds);
  }

  /// Serverpod streaming method for new messages, receipts, and typing.
  ///
  /// Uses [MessageCentral], not a custom WebSocket. The database remains
  /// authoritative if the client misses message events. Typing is transient.
  Stream<ChatEvent> watch(Session session) {
    return _messages.watch(session);
  }

  /// Emits a transient typing start/stop event to other members of [chatId].
  ///
  /// Does not persist anything. Draft text is never included.
  Future<void> setTyping(
    Session session, {
    required int chatId,
    required bool isTyping,
  }) {
    return _messages.setTyping(session, chatId: chatId, isTyping: isTyping);
  }

  /// Replaces the body of the caller's own text message.
  ///
  /// [encryptedText] is plaintext from the client. The server encrypts it
  /// before PostgreSQL update. Receipts and [Chat.lastMessageAt] are unchanged.
  Future<MessageView> editText(
    Session session, {
    required int messageId,
    required String encryptedText,
  }) {
    return _messages.editText(
      session,
      messageId: messageId,
      encryptedText: encryptedText,
    );
  }

  /// Soft-deletes the caller's own message. The row is kept.
  Future<MessageView> deleteMessage(
    Session session, {
    required int messageId,
  }) {
    return _messages.deleteMessage(session, messageId: messageId);
  }
}
