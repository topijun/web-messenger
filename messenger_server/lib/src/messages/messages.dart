import 'dart:typed_data';

import 'package:serverpod/serverpod.dart' hide Message;

import '../encryption/encryption_service.dart';
import '../generated/protocol.dart';
import '../media/media_bytes.dart';
import '../profiles/profiles.dart';
import '../users/current_messenger_user.dart';

/// Text, image, video, and audio messages, receipts, history, and realtime fan-out.
class Messages {
  static const _profiles = Profiles();
  static const maxTextLength = 4000;
  static const defaultPageSize = 30;
  static const maxPageSize = 100;

  /// Newest messages inspected for one search. Ciphertext is not queried.
  static const maxSearchScan = 300;

  /// Matching messages returned from one search.
  static const maxSearchResults = 50;

  /// Maximum trimmed search query length.
  static const maxSearchQueryLength = 200;

  /// Maximum trimmed poll question length.
  static const maxPollQuestionLength = 200;

  /// Maximum trimmed poll option length.
  static const maxPollOptionLength = 100;

  /// Minimum options on a poll.
  static const minPollOptions = 2;

  /// Maximum options on a poll.
  static const maxPollOptions = 6;

  /// Emoji the reaction chooser offers. Anything else is rejected.
  static const reactionEmojis = ['❤️', '👍', '😂', '😮', '😢', '😡'];

  /// Maximum original chat image/video size (20 MiB), before encryption.
  static const maxChatMediaBytes = 20 * 1024 * 1024;

  /// Maximum original chat audio size (10 MiB), before encryption.
  static const maxAudioBytes = 10 * 1024 * 1024;

  /// Maximum JPEG poster size stored beside a video (512 KiB).
  static const maxThumbnailBytes = 512 * 1024;

  /// Creates a [Messages] instance.
  const Messages();

  /// MessageCentral channel for one Messenger user on this server process.
  ///
  /// Redis is not required. Local [postMessage] delivers to listeners on the
  /// same Serverpod instance, which is enough for development and tests.
  static String channelForUser(int userId) => 'messenger_user_$userId';

  /// Posts [event] on [userId]'s existing MessageCentral channel.
  static Future<void> publishUserEvent(
    Session session, {
    required int userId,
    required ChatEvent event,
  }) async {
    try {
      await session.messages.postMessage(channelForUser(userId), event);
    } catch (_, stackTrace) {
      session.log(
        'Failed to publish chat event to user $userId',
        stackTrace: stackTrace,
      );
    }
  }

  /// Creates a text message for the authenticated chat participant.
  ///
  /// [encryptedText] is the client-supplied plaintext. The server encrypts it
  /// with AES-256-GCM before PostgreSQL insert and decrypts it again in the
  /// returned [MessageView] and realtime event.
  Future<MessageView> sendText(
    Session session, {
    required int chatId,
    required String encryptedText,
  }) async {
    final text = _validatedText(encryptedText);
    final cipherText = await EncryptionService.of(session).encrypt(text);
    return _sendPersisted(
      session,
      chatId: chatId,
      type: MessageType.text,
      cipherText: cipherText,
    );
  }

  /// Creates a single-choice poll message in a group chat.
  ///
  /// [question] and [options] are plaintext. The server encrypts them before
  /// insert. The poll is a normal [Message] with [MessageType.poll].
  Future<MessageView> createPoll(
    Session session, {
    required int chatId,
    required String question,
    required List<String> options,
    required bool anonymous,
  }) async {
    final prompt = _validatedPollQuestion(question);
    final choices = _validatedPollOptions(options);
    final encryption = EncryptionService.of(session);
    final questionCipher = await encryption.encrypt(prompt);
    final optionCiphers = <String>[
      for (final choice in choices) await encryption.encrypt(choice),
    ];
    final cipherText = await encryption.encrypt('');
    return _sendPersisted(
      session,
      chatId: chatId,
      type: MessageType.poll,
      cipherText: cipherText,
      poll: (
        question: prompt,
        options: choices,
        anonymous: anonymous,
        questionCipher: questionCipher,
        optionCiphers: optionCiphers,
      ),
    );
  }

  /// Casts, changes, or retracts the caller's vote on [pollId].
  ///
  /// Selecting the option the caller already voted for deletes that vote.
  Future<MessageView> vote(
    Session session, {
    required int pollId,
    required int optionId,
  }) async {
    final me = await CurrentMessengerUser.require(session);
    final message = await Message.db.findFirstRow(
      session,
      where: (t) => t.pollId.equals(pollId) & t.deletedAt.equals(null),
    );
    if (message == null || message.type != MessageType.poll) {
      throw MessengerPollNotFoundException(pollId: pollId);
    }
    final memberships = await _requireMemberships(
      session,
      chatId: message.chatId,
      userId: me.id!,
    );

    await DatabaseUtil.runInTransactionOrSavepoint(
      session.db,
      null,
      (transaction) async {
        final option = await PollOption.db.findById(
          session,
          optionId,
          transaction: transaction,
        );
        if (option == null || option.pollId != pollId) {
          throw MessengerInvalidChatInputException(
            field: 'optionId',
            message: 'That option is not part of this poll.',
          );
        }
        final existing = await PollVote.db.findFirstRow(
          session,
          where: (t) => t.pollId.equals(pollId) & t.userId.equals(me.id!),
          transaction: transaction,
        );
        if (existing == null) {
          try {
            await PollVote.db.insertRow(
              session,
              PollVote(
                pollId: pollId,
                optionId: optionId,
                userId: me.id!,
                createdAt: DateTime.now().toUtc(),
              ),
              transaction: transaction,
            );
          } catch (_) {
            final raced = await PollVote.db.findFirstRow(
              session,
              where: (t) => t.pollId.equals(pollId) & t.userId.equals(me.id!),
              transaction: transaction,
            );
            if (raced == null) {
              rethrow;
            }
            await _storeVoteChange(
              session,
              vote: raced,
              optionId: optionId,
              transaction: transaction,
            );
          }
        } else {
          await _storeVoteChange(
            session,
            vote: existing,
            optionId: optionId,
            transaction: transaction,
          );
        }
      },
    );

    return _publishMessageView(
      session,
      me: me,
      stored: message,
      memberships: memberships,
      kind: ChatEventKind.pollUpdated,
    );
  }

  Future<void> _storeVoteChange(
    Session session, {
    required PollVote vote,
    required int optionId,
    required Transaction transaction,
  }) async {
    if (vote.optionId == optionId) {
      await PollVote.db.deleteRow(session, vote, transaction: transaction);
      return;
    }
    await PollVote.db.updateRow(
      session,
      vote.copyWith(optionId: optionId),
      transaction: transaction,
    );
  }

  /// Adds [emoji] for the caller, or removes it when it is already selected.
  ///
  /// One user may keep several emoji on the same message. The same emoji
  /// toggles off. Deleted messages are rejected.
  Future<MessageView> react(
    Session session, {
    required int messageId,
    required String emoji,
  }) async {
    final value = _validatedEmoji(emoji);
    final me = await CurrentMessengerUser.require(session);
    final message = await Message.db.findById(session, messageId);
    if (message == null) {
      throw MessengerMessageNotFoundException(messageId: messageId);
    }
    if (message.deletedAt != null) {
      throw MessengerInvalidChatInputException(
        field: 'deletedAt',
        message: 'Deleted messages cannot be reacted to.',
      );
    }
    final memberships = await _requireMemberships(
      session,
      chatId: message.chatId,
      userId: me.id!,
    );

    await DatabaseUtil.runInTransactionOrSavepoint(
      session.db,
      null,
      (transaction) async {
        final existing = await MessageReaction.db.findFirstRow(
          session,
          where: (t) =>
              t.messageId.equals(messageId) &
              t.userId.equals(me.id!) &
              t.emoji.equals(value),
          transaction: transaction,
        );
        if (existing != null) {
          await MessageReaction.db.deleteRow(
            session,
            existing,
            transaction: transaction,
          );
          return;
        }
        try {
          await MessageReaction.db.insertRow(
            session,
            MessageReaction(
              messageId: messageId,
              userId: me.id!,
              emoji: value,
              createdAt: DateTime.now().toUtc(),
            ),
            transaction: transaction,
          );
        } catch (_) {
          final raced = await MessageReaction.db.findFirstRow(
            session,
            where: (t) =>
                t.messageId.equals(messageId) &
                t.userId.equals(me.id!) &
                t.emoji.equals(value),
            transaction: transaction,
          );
          if (raced == null) {
            rethrow;
          }
        }
      },
    );

    return _publishMessageView(
      session,
      me: me,
      stored: message,
      memberships: memberships,
      kind: ChatEventKind.messageReactionUpdated,
    );
  }

  /// Replaces the ciphertext of the caller's own text message.
  ///
  /// Does not change the message id, receipts, or [Chat.lastMessageAt].
  Future<MessageView> editText(
    Session session, {
    required int messageId,
    required String encryptedText,
  }) async {
    final text = _validatedText(encryptedText);
    final me = await CurrentMessengerUser.require(session);
    final loaded = await _requireOwnMessage(
      session,
      messageId: messageId,
      userId: me.id!,
    );
    final message = loaded.message;
    if (message.deletedAt != null) {
      throw MessengerInvalidChatInputException(
        field: 'deletedAt',
        message: 'Deleted messages cannot be edited.',
      );
    }
    if (message.type != MessageType.text) {
      throw MessengerInvalidChatInputException(
        field: 'type',
        message: 'Only text messages can be edited.',
      );
    }

    final cipherText = await EncryptionService.of(session).encrypt(text);
    final updated = await Message.db.updateRow(
      session,
      message.copyWith(
        encryptedText: cipherText,
        editedAt: DateTime.now().toUtc(),
      ),
    );
    return _publishMessageView(
      session,
      me: me,
      stored: updated,
      memberships: loaded.memberships,
      kind: ChatEventKind.messageEdited,
    );
  }

  /// Soft-deletes the caller's own message. The row and Media stay in place.
  ///
  /// Does not change receipts or [Chat.lastMessageAt].
  Future<MessageView> deleteMessage(
    Session session, {
    required int messageId,
  }) async {
    final me = await CurrentMessengerUser.require(session);
    final loaded = await _requireOwnMessage(
      session,
      messageId: messageId,
      userId: me.id!,
    );
    final message = loaded.message;
    if (message.deletedAt != null) {
      throw MessengerInvalidChatInputException(
        field: 'deletedAt',
        message: 'Message is already deleted.',
      );
    }

    final updated = await Message.db.updateRow(
      session,
      message.copyWith(deletedAt: DateTime.now().toUtc()),
    );
    return _publishMessageView(
      session,
      me: me,
      stored: updated,
      memberships: loaded.memberships,
      kind: ChatEventKind.messageDeleted,
    );
  }

  /// Encrypts and stores supported image or video bytes as a chat message.
  ///
  /// [bytes] are plaintext. The server encrypts them before PostgreSQL insert.
  /// The returned [MessageView] and realtime event include [Message.mediaId]
  /// but not the media bytes.
  Future<MessageView> sendMedia(
    Session session, {
    required int chatId,
    required ByteData bytes,
    ByteData? thumbnailBytes,
  }) async {
    final plaintext = uint8ListFromByteData(bytes);
    if (plaintext.length > maxChatMediaBytes) {
      throw MessengerInvalidMediaException(
        code: 'tooLarge',
        message: 'Images and videos must be at most 20 MB before encryption.',
      );
    }
    final format = ChatMediaFormat.detect(plaintext);
    if (format == null) {
      throw MessengerInvalidMediaException(
        code: 'unsupportedFormat',
        message: 'Chat media must be JPEG, PNG, MP4, WebM, MOV, or 3GP.',
      );
    }

    final me = await CurrentMessengerUser.require(session);
    await _requireMemberships(session, chatId: chatId, userId: me.id!);

    final encryption = EncryptionService.of(session);
    final cipherBytes = await encryption.encryptBytes(plaintext);
    final cipherText = await encryption.encrypt('');
    final messageType = format.type == MediaType.video
        ? MessageType.video
        : MessageType.image;

    Media? thumbnail;
    if (messageType == MessageType.video) {
      final poster = _validatedThumbnail(thumbnailBytes);
      if (poster != null) {
        final thumbCipher = await encryption.encryptBytes(poster);
        thumbnail = Media(
          userId: me.id!,
          type: MediaType.image,
          mimeType: ChatMediaFormat.jpegMime,
          size: poster.length,
          encryptedData: byteDataFromBytes(thumbCipher),
        );
      }
    }

    return _sendPersisted(
      session,
      chatId: chatId,
      type: messageType,
      cipherText: cipherText,
      media: Media(
        userId: me.id!,
        type: format.type,
        mimeType: format.mimeType,
        size: plaintext.length,
        encryptedData: byteDataFromBytes(cipherBytes),
      ),
      thumbnail: thumbnail,
    );
  }

  Uint8List? _validatedThumbnail(ByteData? bytes) {
    if (bytes == null) {
      return null;
    }
    final plaintext = uint8ListFromByteData(bytes);
    if (plaintext.length > maxThumbnailBytes ||
        !ChatMediaFormat.isJpeg(plaintext)) {
      return null;
    }
    return plaintext;
  }

  /// Encrypts and stores a WAV recording as a chat message.
  ///
  /// [bytes] are plaintext. The server encrypts them before PostgreSQL insert.
  /// History and realtime include [Message.mediaId] only, not audio bytes.
  Future<MessageView> sendAudio(
    Session session, {
    required int chatId,
    required ByteData bytes,
  }) async {
    final plaintext = uint8ListFromByteData(bytes);
    if (plaintext.isEmpty ||
        plaintext.length <= ChatMediaFormat.wavHeaderBytes) {
      throw MessengerInvalidMediaException(
        code: 'empty',
        message: 'Audio cannot be empty.',
      );
    }
    if (plaintext.length > maxAudioBytes) {
      throw MessengerInvalidMediaException(
        code: 'tooLarge',
        message: 'Audio must be at most 10 MB before encryption.',
      );
    }
    final format = ChatMediaFormat.detectAudio(plaintext);
    if (format == null) {
      throw MessengerInvalidMediaException(
        code: 'unsupportedFormat',
        message: 'Audio must be WAV.',
      );
    }

    final me = await CurrentMessengerUser.require(session);
    await _requireMemberships(session, chatId: chatId, userId: me.id!);

    final encryption = EncryptionService.of(session);
    final cipherBytes = await encryption.encryptBytes(plaintext);
    final cipherText = await encryption.encrypt('');

    return _sendPersisted(
      session,
      chatId: chatId,
      type: MessageType.audio,
      cipherText: cipherText,
      media: Media(
        userId: me.id!,
        type: MediaType.audio,
        mimeType: format.mimeType,
        size: plaintext.length,
        encryptedData: byteDataFromBytes(cipherBytes),
      ),
    );
  }

  /// Decrypts chat media for a member of the chat that owns the message.
  Future<ChatMedia> getChatMedia(
    Session session, {
    required int mediaId,
  }) async {
    final me = await CurrentMessengerUser.require(session);
    final media = await Media.db.findById(session, mediaId);
    if (media == null) {
      throw MessengerMediaNotFoundException(mediaId: mediaId);
    }

    var message = await Message.db.findFirstRow(
      session,
      where: (t) => t.mediaId.equals(mediaId),
    );
    if (message == null) {
      final owner = await Media.db.findFirstRow(
        session,
        where: (t) => t.thumbnailMediaId.equals(mediaId),
      );
      if (owner != null) {
        message = await Message.db.findFirstRow(
          session,
          where: (t) => t.mediaId.equals(owner.id),
        );
      }
    }
    if (message == null) {
      throw MessengerMediaNotFoundException(mediaId: mediaId);
    }

    await _requireMemberships(
      session,
      chatId: message.chatId,
      userId: me.id!,
    );
    if (message.deletedAt != null) {
      throw MessengerMediaNotFoundException(mediaId: mediaId);
    }

    final clear = await EncryptionService.of(session).decryptBytes(
      uint8ListFromByteData(media.encryptedData),
    );
    return ChatMedia(
      mediaId: media.id!,
      type: media.type,
      mimeType: media.mimeType,
      size: media.size,
      bytes: byteDataFromBytes(clear),
      thumbnailMediaId: media.thumbnailMediaId,
    );
  }

  /// Newest-first history for a chat the caller belongs to.
  ///
  /// Pass both [beforeCreatedAt] and [beforeId] from the previous page's
  /// cursor to load older messages. Ordering is [createdAt] descending, then
  /// message id descending so equal timestamps stay stable.
  Future<MessageHistoryPage> listHistory(
    Session session, {
    required int chatId,
    DateTime? beforeCreatedAt,
    int? beforeId,
    int? limit,
  }) async {
    final me = await CurrentMessengerUser.require(session);
    await _requireMemberships(session, chatId: chatId, userId: me.id!);

    final pageSize = _pageSize(limit);
    final rows = await _historyRows(
      session,
      chatId: chatId,
      beforeCreatedAt: beforeCreatedAt,
      beforeId: beforeId,
      limit: pageSize + 1,
    );

    final hasMore = rows.length > pageSize;
    final page = hasMore ? rows.sublist(0, pageSize) : rows;
    final views = await _viewsFor(session, me: me, messages: page);
    final oldest = page.isEmpty ? null : page.last;
    return MessageHistoryPage(
      messages: views,
      hasMore: hasMore,
      nextCreatedAt: oldest?.createdAt,
      nextId: oldest?.id,
    );
  }

  /// Case-insensitive text search in a chat the caller belongs to.
  ///
  /// Loads at most [maxSearchScan] newest messages, decrypts text messages
  /// with [EncryptionService], and returns at most [maxSearchResults] matches,
  /// newest first. An empty query returns no rows and does not scan messages.
  /// Deleted messages and non-text messages are skipped. Ciphertext is never
  /// matched in SQL.
  Future<List<MessageView>> searchText(
    Session session, {
    required int chatId,
    required String query,
  }) async {
    final me = await CurrentMessengerUser.require(session);
    await _requireMemberships(session, chatId: chatId, userId: me.id!);

    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const [];
    }
    if (trimmed.length > maxSearchQueryLength) {
      throw MessengerInvalidChatInputException(
        field: 'query',
        message:
            'Search text must be at most $maxSearchQueryLength characters.',
      );
    }
    final needle = trimmed.toLowerCase();

    final matched = <Message>[];
    DateTime? beforeCreatedAt;
    int? beforeId;
    var scanned = 0;
    while (scanned < maxSearchScan && matched.length < maxSearchResults) {
      final batchSize = maxSearchScan - scanned < maxPageSize
          ? maxSearchScan - scanned
          : maxPageSize;
      final rows = await _historyRows(
        session,
        chatId: chatId,
        beforeCreatedAt: beforeCreatedAt,
        beforeId: beforeId,
        limit: batchSize,
      );
      if (rows.isEmpty) {
        break;
      }
      scanned += rows.length;
      for (final row in rows) {
        if (matched.length >= maxSearchResults) {
          break;
        }
        if (!_searchableText(row)) {
          continue;
        }
        final String plaintext;
        try {
          plaintext = await EncryptionService.of(
            session,
          ).decrypt(row.encryptedText);
        } on MessengerEncryptedDataException {
          continue;
        }
        if (plaintext.toLowerCase().contains(needle)) {
          matched.add(row);
        }
      }
      if (rows.length < batchSize) {
        break;
      }
      final oldest = rows.last;
      beforeCreatedAt = oldest.createdAt;
      beforeId = oldest.id;
    }

    return _viewsFor(session, me: me, messages: matched);
  }

  bool _searchableText(Message row) {
    return row.deletedAt == null &&
        row.type == MessageType.text &&
        row.encryptedText.isNotEmpty;
  }

  Future<List<Message>> _historyRows(
    Session session, {
    required int chatId,
    DateTime? beforeCreatedAt,
    int? beforeId,
    required int limit,
  }) {
    final createdAtCursor = beforeCreatedAt;
    final idCursor = beforeId;
    return Message.db.find(
      session,
      where: (t) {
        var filter = t.chatId.equals(chatId);
        if (createdAtCursor != null && idCursor != null) {
          filter =
              filter &
              ((t.createdAt < createdAtCursor) |
                  (t.createdAt.equals(createdAtCursor) & (t.id < idCursor)));
        }
        return filter;
      },
      orderByList: (t) => [
        Order(column: t.createdAt, orderDescending: true),
        Order(column: t.id, orderDescending: true),
      ],
      limit: limit,
    );
  }

  /// Marks messages as delivered for the authenticated recipient.
  Future<List<MessageReceipt>> markDelivered(
    Session session, {
    required List<int> messageIds,
  }) {
    return _markReceipts(
      session,
      messageIds: messageIds,
      delivered: true,
      read: false,
    );
  }

  /// Marks messages as read for the authenticated recipient.
  ///
  /// Read also implies delivered when [deliveredAt] is still null.
  Future<List<MessageReceipt>> markRead(
    Session session, {
    required List<int> messageIds,
  }) {
    return _markReceipts(
      session,
      messageIds: messageIds,
      delivered: true,
      read: true,
    );
  }

  /// Live message, receipt, and typing events for the authenticated user.
  ///
  /// Realtime is not the source of truth. Missed events are recovered by
  /// loading history and reconciling on stable message ids. Typing state is
  /// not recovered from PostgreSQL.
  Stream<ChatEvent> watch(Session session) async* {
    final me = await CurrentMessengerUser.require(session);
    yield* session.messages.createStream<ChatEvent>(
      channelForUser(me.id!),
    );
  }

  /// Publishes a transient typing start/stop event to other chat members.
  ///
  /// Does not write to PostgreSQL. The sender is excluded from fan-out.
  Future<void> setTyping(
    Session session, {
    required int chatId,
    required bool isTyping,
  }) async {
    final me = await CurrentMessengerUser.require(session);
    final memberships = await _requireMemberships(
      session,
      chatId: chatId,
      userId: me.id!,
    );
    final recipientIds = [
      for (final membership in memberships)
        if (membership.userId != me.id) membership.userId,
    ];
    if (recipientIds.isEmpty) {
      return;
    }

    await _publish(
      session,
      ChatEvent(
        kind: isTyping
            ? ChatEventKind.typingStarted
            : ChatEventKind.typingStopped,
        chatId: chatId,
        typingUserId: me.id,
        typingUsername: me.username,
      ),
      userIds: recipientIds,
    );
  }

  Future<List<MessageReceipt>> _markReceipts(
    Session session, {
    required List<int> messageIds,
    required bool delivered,
    required bool read,
  }) async {
    if (messageIds.isEmpty) {
      return const [];
    }

    final me = await CurrentMessengerUser.require(session);
    final uniqueIds = messageIds.toSet().toList();
    final now = DateTime.now().toUtc();
    final updated = <MessageReceipt>[];
    final events = <ChatEvent>[];
    final recipientFanout = <int, Set<int>>{};

    await DatabaseUtil.runInTransactionOrSavepoint(session.db, null, (
      transaction,
    ) async {
      for (final messageId in uniqueIds) {
        final message = await Message.db.findById(
          session,
          messageId,
          transaction: transaction,
        );
        if (message == null) {
          throw MessengerMessageNotFoundException(messageId: messageId);
        }

        final memberships = await _requireMemberships(
          session,
          chatId: message.chatId,
          userId: me.id!,
          transaction: transaction,
        );
        if (message.senderId == me.id) {
          throw MessengerNotMessageRecipientException(messageId: messageId);
        }

        var receipt = await MessageReceipt.db.findFirstRow(
          session,
          where: (t) => t.messageId.equals(messageId) & t.userId.equals(me.id),
          transaction: transaction,
        );
        receipt ??= await _insertReceipt(
          session,
          messageId: messageId,
          userId: me.id!,
          transaction: transaction,
        );

        var changed = false;
        if (delivered && receipt.deliveredAt == null) {
          receipt = receipt.copyWith(deliveredAt: now);
          changed = true;
        }
        if (read && receipt.readAt == null) {
          receipt = receipt.copyWith(readAt: now);
          if (receipt.deliveredAt == null) {
            receipt = receipt.copyWith(deliveredAt: now);
          }
          changed = true;
        }

        if (changed) {
          receipt = await MessageReceipt.db.updateRow(
            session,
            receipt,
            transaction: transaction,
          );
        }

        updated.add(receipt);
        events.add(
          ChatEvent(
            kind: ChatEventKind.receipt,
            chatId: message.chatId,
            receipt: receipt,
          ),
        );
        recipientFanout[message.chatId] = {
          for (final membership in memberships) membership.userId,
        };
      }
    });

    for (final event in events) {
      await _publish(
        session,
        event,
        userIds: recipientFanout[event.chatId] ?? const {},
      );
    }
    return updated;
  }

  Future<List<MessageView>> _viewsFor(
    Session session, {
    required MessengerUser me,
    required List<Message> messages,
    Transaction? transaction,
  }) async {
    if (messages.isEmpty) {
      return const [];
    }

    final senderIds = {for (final message in messages) message.senderId};
    final senders = await MessengerUser.db.find(
      session,
      where: (t) => t.id.inSet(senderIds),
      transaction: transaction,
    );
    final usernameById = {
      for (final user in senders) user.id!: user.username,
    };
    final imageIdByUserId = await _profiles.imageIdsByUserIds(
      session,
      senderIds,
      transaction: transaction,
    );

    final messageIds = {for (final message in messages) message.id!};
    final receipts = await MessageReceipt.db.find(
      session,
      where: (t) => t.messageId.inSet(messageIds),
      transaction: transaction,
    );
    final receiptsByMessageId = <int, List<MessageReceipt>>{};
    for (final receipt in receipts) {
      receiptsByMessageId.putIfAbsent(receipt.messageId, () => []).add(receipt);
    }

    final mediaIds = {
      for (final message in messages)
        if (message.mediaId != null) message.mediaId!,
    };
    final mediaRows = mediaIds.isEmpty
        ? const <Media>[]
        : await Media.db.find(
            session,
            where: (t) => t.id.inSet(mediaIds),
            transaction: transaction,
          );
    final thumbnailByMediaId = {
      for (final row in mediaRows)
        if (row.thumbnailMediaId != null) row.id!: row.thumbnailMediaId!,
    };
    final pollsById = await _pollViewsById(
      session,
      me: me,
      messages: messages,
      transaction: transaction,
    );
    final reactionsByMessageId = await _reactionRowsByMessageId(
      session,
      messages: messages,
      transaction: transaction,
    );

    return [
      for (final message in messages)
        MessageView(
          message: await _messageForClient(session, message),
          senderUsername: usernameById[message.senderId] ?? 'Unknown',
          senderProfileImageId: imageIdByUserId[message.senderId],
          isMine: message.senderId == me.id,
          receipts: receiptsByMessageId[message.id] ?? const [],
          thumbnailMediaId: message.mediaId == null
              ? null
              : thumbnailByMediaId[message.mediaId!],
          poll: message.deletedAt == null && message.pollId != null
              ? pollsById[message.pollId!]
              : null,
          reactions: message.deletedAt == null
              ? _reactionViews(
                  reactionsByMessageId[message.id] ?? const [],
                  me.id!,
                )
              : const [],
        ),
    ];
  }

  Future<MessageView> _sendPersisted(
    Session session, {
    required int chatId,
    required MessageType type,
    required String cipherText,
    Media? media,
    Media? thumbnail,
    ({
      String question,
      List<String> options,
      bool anonymous,
      String questionCipher,
      List<String> optionCiphers,
    })?
    poll,
  }) async {
    final me = await CurrentMessengerUser.require(session);
    final createdAt = DateTime.now().toUtc();

    final result = await DatabaseUtil.runInTransactionOrSavepoint(
      session.db,
      null,
      (transaction) async {
        final memberships = await _requireMemberships(
          session,
          chatId: chatId,
          userId: me.id!,
          transaction: transaction,
        );
        final participantIds = [
          for (final membership in memberships) membership.userId,
        ];

        final chat = await Chat.db.findById(
          session,
          chatId,
          transaction: transaction,
        );
        if (chat == null) {
          throw MessengerChatNotFoundException(chatId: chatId);
        }

        var storedMedia = media;
        if (thumbnail != null && thumbnail.id == null) {
          final storedThumb = await Media.db.insertRow(
            session,
            thumbnail,
            transaction: transaction,
          );
          storedMedia = media?.copyWith(thumbnailMediaId: storedThumb.id);
        }
        var mediaId = storedMedia?.id;
        if (storedMedia != null && mediaId == null) {
          final inserted = await Media.db.insertRow(
            session,
            storedMedia,
            transaction: transaction,
          );
          mediaId = inserted.id;
          storedMedia = inserted;
        }

        final pollView = await _insertPoll(
          session,
          me: me,
          chat: chat,
          createdAt: createdAt,
          poll: poll,
          transaction: transaction,
        );

        final message = await Message.db.insertRow(
          session,
          Message(
            chatId: chatId,
            senderId: me.id!,
            type: type,
            encryptedText: cipherText,
            mediaId: mediaId,
            pollId: pollView?.id,
            createdAt: createdAt,
          ),
          transaction: transaction,
        );

        final recipientIds = [
          for (final userId in participantIds)
            if (userId != me.id) userId,
        ];
        final receipts = recipientIds.isEmpty
            ? const <MessageReceipt>[]
            : await MessageReceipt.db.insert(
                session,
                [
                  for (final userId in recipientIds)
                    MessageReceipt(messageId: message.id!, userId: userId),
                ],
                transaction: transaction,
              );

        await Chat.db.updateRow(
          session,
          chat.copyWith(lastMessageAt: createdAt, updatedAt: createdAt),
          transaction: transaction,
        );

        return (
          MessageView(
            message: await _messageForClient(session, message),
            senderUsername: me.username,
            senderProfileImageId: (await _profiles.imageIdsByUserIds(
              session,
              [me.id!],
              transaction: transaction,
            ))[me.id!],
            isMine: true,
            receipts: receipts,
            thumbnailMediaId: storedMedia?.thumbnailMediaId,
            poll: pollView,
          ),
          participantIds,
        );
      },
    );

    await _publish(
      session,
      ChatEvent(
        kind: ChatEventKind.message,
        chatId: chatId,
        message: result.$1,
      ),
      userIds: result.$2,
      senderView: result.$1,
    );
    return result.$1;
  }

  Future<Message> _messageForClient(Session session, Message stored) async {
    if (stored.deletedAt != null) {
      return stored.copyWith(encryptedText: '');
    }
    final plaintext = await EncryptionService.of(
      session,
    ).decrypt(stored.encryptedText);
    return stored.copyWith(encryptedText: plaintext);
  }

  String _validatedPollQuestion(String question) {
    final text = question.trim();
    if (text.isEmpty) {
      throw MessengerInvalidChatInputException(
        field: 'question',
        message: 'Poll question cannot be empty.',
      );
    }
    if (text.length > maxPollQuestionLength) {
      throw MessengerInvalidChatInputException(
        field: 'question',
        message:
            'Poll question must be at most $maxPollQuestionLength characters.',
      );
    }
    return text;
  }

  List<String> _validatedPollOptions(List<String> options) {
    final choices = [for (final option in options) option.trim()];
    if (choices.length < minPollOptions || choices.length > maxPollOptions) {
      throw MessengerInvalidChatInputException(
        field: 'options',
        message:
            'A poll needs between $minPollOptions and $maxPollOptions options.',
      );
    }
    if (choices.any((choice) => choice.isEmpty)) {
      throw MessengerInvalidChatInputException(
        field: 'options',
        message: 'Poll options cannot be empty.',
      );
    }
    if (choices.any((choice) => choice.length > maxPollOptionLength)) {
      throw MessengerInvalidChatInputException(
        field: 'options',
        message:
            'Poll options must be at most $maxPollOptionLength characters.',
      );
    }
    return choices;
  }

  Future<PollView?> _insertPoll(
    Session session, {
    required MessengerUser me,
    required Chat chat,
    required DateTime createdAt,
    required ({
      String question,
      List<String> options,
      bool anonymous,
      String questionCipher,
      List<String> optionCiphers,
    })?
    poll,
    required Transaction transaction,
  }) async {
    if (poll == null) {
      return null;
    }
    if (chat.type != ChatType.group) {
      throw MessengerInvalidChatInputException(
        field: 'chatType',
        message: 'Polls can only be created in group chats.',
      );
    }
    final stored = await Poll.db.insertRow(
      session,
      Poll(
        question: poll.questionCipher,
        anonymous: poll.anonymous,
        createdById: me.id!,
        createdAt: createdAt,
      ),
      transaction: transaction,
    );
    final storedOptions = await PollOption.db.insert(
      session,
      [
        for (var index = 0; index < poll.optionCiphers.length; index++)
          PollOption(
            pollId: stored.id!,
            text: poll.optionCiphers[index],
            position: index,
          ),
      ],
      transaction: transaction,
    );
    return PollView(
      id: stored.id!,
      question: poll.question,
      anonymous: poll.anonymous,
      totalVotes: 0,
      options: [
        for (var index = 0; index < storedOptions.length; index++)
          PollOptionView(
            id: storedOptions[index].id!,
            text: poll.options[index],
            position: index,
            voteCount: 0,
            voters: const [],
          ),
      ],
    );
  }

  Future<Map<int, PollView>> _pollViewsById(
    Session session, {
    required MessengerUser me,
    required List<Message> messages,
    Transaction? transaction,
  }) async {
    final pollIds = {
      for (final message in messages)
        if (message.deletedAt == null && message.pollId != null)
          message.pollId!,
    };
    if (pollIds.isEmpty) {
      return const {};
    }

    final polls = await Poll.db.find(
      session,
      where: (t) => t.id.inSet(pollIds),
      transaction: transaction,
    );
    final options = await PollOption.db.find(
      session,
      where: (t) => t.pollId.inSet(pollIds),
      transaction: transaction,
    );
    final votes = await PollVote.db.find(
      session,
      where: (t) => t.pollId.inSet(pollIds),
      transaction: transaction,
    );
    final publicVoterIds = {
      for (final poll in polls)
        if (!poll.anonymous)
          for (final vote in votes)
            if (vote.pollId == poll.id) vote.userId,
    };
    final voters = publicVoterIds.isEmpty
        ? const <MessengerUser>[]
        : await MessengerUser.db.find(
            session,
            where: (t) => t.id.inSet(publicVoterIds),
            transaction: transaction,
          );
    final usernameById = {
      for (final user in voters) user.id!: user.username,
    };
    final encryption = EncryptionService.of(session);

    final views = <int, PollView>{};
    for (final poll in polls) {
      final pollOptions =
          [
            for (final option in options)
              if (option.pollId == poll.id) option,
          ]..sort((a, b) {
            final byPosition = a.position.compareTo(b.position);
            if (byPosition != 0) {
              return byPosition;
            }
            return (a.id ?? 0).compareTo(b.id ?? 0);
          });
      final pollVotes = [
        for (final vote in votes)
          if (vote.pollId == poll.id) vote,
      ];
      final myVote = pollVotes.where((vote) => vote.userId == me.id);
      views[poll.id!] = PollView(
        id: poll.id!,
        question: await encryption.decrypt(poll.question),
        anonymous: poll.anonymous,
        totalVotes: pollVotes.length,
        myOptionId: myVote.isEmpty ? null : myVote.first.optionId,
        options: [
          for (final option in pollOptions)
            PollOptionView(
              id: option.id!,
              text: await encryption.decrypt(option.text),
              position: option.position,
              voteCount: pollVotes
                  .where((vote) => vote.optionId == option.id)
                  .length,
              voters: poll.anonymous
                  ? const <String>[]
                  : ([
                      for (final vote in pollVotes)
                        if (vote.optionId == option.id)
                          usernameById[vote.userId] ?? 'Unknown',
                    ]..sort()),
            ),
        ],
      );
    }
    return views;
  }

  String _validatedText(String encryptedText) {
    final text = encryptedText.trim();
    if (text.isEmpty) {
      throw MessengerInvalidChatInputException(
        field: 'encryptedText',
        message: 'Message text cannot be empty.',
      );
    }
    if (text.length > maxTextLength) {
      throw MessengerInvalidChatInputException(
        field: 'encryptedText',
        message: 'Message text must be at most $maxTextLength characters.',
      );
    }
    return text;
  }

  Future<({Message message, List<ChatParticipant> memberships})>
  _requireOwnMessage(
    Session session, {
    required int messageId,
    required int userId,
  }) async {
    final message = await Message.db.findById(session, messageId);
    if (message == null) {
      throw MessengerMessageNotFoundException(messageId: messageId);
    }
    final memberships = await _requireMemberships(
      session,
      chatId: message.chatId,
      userId: userId,
    );
    if (message.senderId != userId) {
      throw MessengerNotMessageOwnerException(messageId: messageId);
    }
    return (message: message, memberships: memberships);
  }

  Future<MessageView> _publishMessageView(
    Session session, {
    required MessengerUser me,
    required Message stored,
    required List<ChatParticipant> memberships,
    required ChatEventKind kind,
  }) async {
    final views = await _viewsFor(session, me: me, messages: [stored]);
    final view = views.single;
    await _publish(
      session,
      ChatEvent(kind: kind, chatId: stored.chatId, message: view),
      userIds: [for (final membership in memberships) membership.userId],
      senderView: view,
    );
    return view;
  }

  Future<List<ChatParticipant>> _requireMemberships(
    Session session, {
    required int chatId,
    required int userId,
    Transaction? transaction,
  }) async {
    final chat = await Chat.db.findById(
      session,
      chatId,
      transaction: transaction,
    );
    if (chat == null) {
      throw MessengerChatNotFoundException(chatId: chatId);
    }
    final memberships = await ChatParticipant.db.find(
      session,
      where: (t) => t.chatId.equals(chatId),
      transaction: transaction,
    );
    if (!memberships.any((row) => row.userId == userId)) {
      throw MessengerNotChatMemberException(chatId: chatId);
    }
    return memberships;
  }

  Future<MessageReceipt> _insertReceipt(
    Session session, {
    required int messageId,
    required int userId,
    Transaction? transaction,
  }) async {
    try {
      return await MessageReceipt.db.insertRow(
        session,
        MessageReceipt(messageId: messageId, userId: userId),
        transaction: transaction,
      );
    } catch (_) {
      final existing = await MessageReceipt.db.findFirstRow(
        session,
        where: (t) => t.messageId.equals(messageId) & t.userId.equals(userId),
        transaction: transaction,
      );
      if (existing == null) {
        rethrow;
      }
      return existing;
    }
  }

  Future<Map<int, List<MessageReaction>>> _reactionRowsByMessageId(
    Session session, {
    required List<Message> messages,
    Transaction? transaction,
  }) async {
    final ids = {
      for (final message in messages)
        if (message.deletedAt == null && message.id != null) message.id!,
    };
    if (ids.isEmpty) {
      return const {};
    }
    final rows = await MessageReaction.db.find(
      session,
      where: (t) => t.messageId.inSet(ids),
      transaction: transaction,
    );
    final grouped = <int, List<MessageReaction>>{};
    for (final row in rows) {
      grouped.putIfAbsent(row.messageId, () => []).add(row);
    }
    return grouped;
  }

  List<MessageReactionView> _reactionViews(
    List<MessageReaction> rows,
    int viewerId,
  ) {
    if (rows.isEmpty) {
      return const [];
    }
    return [
      for (final emoji in reactionEmojis)
        if (rows.any((row) => row.emoji == emoji))
          MessageReactionView(
            emoji: emoji,
            count: rows.where((row) => row.emoji == emoji).length,
            mine: rows.any(
              (row) => row.emoji == emoji && row.userId == viewerId,
            ),
          ),
    ];
  }

  String _validatedEmoji(String emoji) {
    final value = emoji.trim();
    if (!reactionEmojis.contains(value)) {
      throw MessengerInvalidChatInputException(
        field: 'emoji',
        message: 'Choose one of the available reactions.',
      );
    }
    return value;
  }

  Future<void> _publish(
    Session session,
    ChatEvent event, {
    required Iterable<int> userIds,
    MessageView? senderView,
  }) async {
    final messageId = senderView?.message.id;
    final reactionRows =
        senderView == null ||
            messageId == null ||
            senderView.message.deletedAt != null
        ? const <MessageReaction>[]
        : await MessageReaction.db.find(
            session,
            where: (t) => t.messageId.equals(messageId),
          );
    final pollId = senderView?.poll?.id;
    final pollVotes = pollId == null
        ? const <PollVote>[]
        : await PollVote.db.find(
            session,
            where: (t) => t.pollId.equals(pollId),
          );
    for (final userId in userIds.toSet()) {
      final payload = senderView == null
          ? event
          : ChatEvent(
              kind: event.kind,
              chatId: event.chatId,
              message: MessageView(
                message: senderView.message,
                senderUsername: senderView.senderUsername,
                senderProfileImageId: senderView.senderProfileImageId,
                isMine: userId == senderView.message.senderId,
                receipts: senderView.receipts,
                thumbnailMediaId: senderView.thumbnailMediaId,
                poll: senderView.poll?.copyWith(
                  myOptionId: _votedOptionId(pollVotes, userId),
                ),
                reactions: senderView.message.deletedAt == null
                    ? _reactionViews(reactionRows, userId)
                    : const [],
              ),
              receipt: event.receipt,
              typingUserId: event.typingUserId,
              typingUsername: event.typingUsername,
              invitation: event.invitation,
            );
      try {
        await session.messages.postMessage(channelForUser(userId), payload);
      } catch (_, stackTrace) {
        session.log(
          'Failed to publish chat event to user $userId',
          stackTrace: stackTrace,
        );
      }
    }
  }

  /// The recipient's own vote. Counts on the poll stay shared.
  int? _votedOptionId(List<PollVote> votes, int userId) {
    for (final vote in votes) {
      if (vote.userId == userId) {
        return vote.optionId;
      }
    }
    return null;
  }

  int _pageSize(int? limit) {
    final requested = limit ?? defaultPageSize;
    if (requested < 1) {
      return 1;
    }
    if (requested > maxPageSize) {
      return maxPageSize;
    }
    return requested;
  }
}
