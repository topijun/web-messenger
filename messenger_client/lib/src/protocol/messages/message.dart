/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod_client/serverpod_client.dart' as _i1;
import '../chats/chat.dart' as _i2;
import '../users/messenger_user.dart' as _i3;
import '../messages/message_type.dart' as _i4;
import '../media/media.dart' as _i5;
import '../messages/poll.dart' as _i6;
import '../messages/message_receipt.dart' as _i7;
import 'package:messenger_client/src/protocol/protocol.dart' as _i8;

/// A chat message. One row for every type of content.
///
/// [encryptedText] is AES-256-GCM ciphertext produced by EncryptionService.
/// Do not add a separate plaintext text column.
abstract class Message implements _i1.SerializableModel {
  Message._({
    this.id,
    required this.chatId,
    this.chat,
    required this.senderId,
    this.sender,
    required this.type,
    required this.encryptedText,
    this.mediaId,
    this.media,
    this.pollId,
    this.poll,
    required this.createdAt,
    this.editedAt,
    this.deletedAt,
    this.receipts,
  });

  factory Message({
    int? id,
    required int chatId,
    _i2.Chat? chat,
    required int senderId,
    _i3.MessengerUser? sender,
    required _i4.MessageType type,
    required String encryptedText,
    int? mediaId,
    _i5.Media? media,
    int? pollId,
    _i6.Poll? poll,
    required DateTime createdAt,
    DateTime? editedAt,
    DateTime? deletedAt,
    List<_i7.MessageReceipt>? receipts,
  }) = _MessageImpl;

  factory Message.fromJson(Map<String, dynamic> jsonSerialization) {
    return Message(
      id: jsonSerialization['id'] as int?,
      chatId: jsonSerialization['chatId'] as int,
      chat: jsonSerialization['chat'] == null
          ? null
          : _i8.Protocol().deserialize<_i2.Chat>(jsonSerialization['chat']),
      senderId: jsonSerialization['senderId'] as int,
      sender: jsonSerialization['sender'] == null
          ? null
          : _i8.Protocol().deserialize<_i3.MessengerUser>(
              jsonSerialization['sender'],
            ),
      type: _i4.MessageType.fromJson((jsonSerialization['type'] as String)),
      encryptedText: jsonSerialization['encryptedText'] as String,
      mediaId: jsonSerialization['mediaId'] as int?,
      media: jsonSerialization['media'] == null
          ? null
          : _i8.Protocol().deserialize<_i5.Media>(jsonSerialization['media']),
      pollId: jsonSerialization['pollId'] as int?,
      poll: jsonSerialization['poll'] == null
          ? null
          : _i8.Protocol().deserialize<_i6.Poll>(jsonSerialization['poll']),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      editedAt: jsonSerialization['editedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['editedAt']),
      deletedAt: jsonSerialization['deletedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['deletedAt']),
      receipts: jsonSerialization['receipts'] == null
          ? null
          : _i8.Protocol().deserialize<List<_i7.MessageReceipt>>(
              jsonSerialization['receipts'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int chatId;

  _i2.Chat? chat;

  int senderId;

  _i3.MessengerUser? sender;

  _i4.MessageType type;

  /// Ciphertext of the message body (AES-256-GCM, server-side).
  /// Clients send and receive plaintext through the API; PostgreSQL stores
  /// only the versioned ciphertext from EncryptionService.
  String encryptedText;

  int? mediaId;

  /// Optional encrypted image/video. Null for text messages.
  _i5.Media? media;

  int? pollId;

  /// Optional poll. Question and options live on [Poll], encrypted at rest.
  _i6.Poll? poll;

  DateTime createdAt;

  DateTime? editedAt;

  DateTime? deletedAt;

  List<_i7.MessageReceipt>? receipts;

  /// Returns a shallow copy of this [Message]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Message copyWith({
    int? id,
    int? chatId,
    _i2.Chat? chat,
    int? senderId,
    _i3.MessengerUser? sender,
    _i4.MessageType? type,
    String? encryptedText,
    int? mediaId,
    _i5.Media? media,
    int? pollId,
    _i6.Poll? poll,
    DateTime? createdAt,
    DateTime? editedAt,
    DateTime? deletedAt,
    List<_i7.MessageReceipt>? receipts,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Message',
      if (id != null) 'id': id,
      'chatId': chatId,
      if (chat != null) 'chat': chat?.toJson(),
      'senderId': senderId,
      if (sender != null) 'sender': sender?.toJson(),
      'type': type.toJson(),
      'encryptedText': encryptedText,
      if (mediaId != null) 'mediaId': mediaId,
      if (media != null) 'media': media?.toJson(),
      if (pollId != null) 'pollId': pollId,
      if (poll != null) 'poll': poll?.toJson(),
      'createdAt': createdAt.toJson(),
      if (editedAt != null) 'editedAt': editedAt?.toJson(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      if (receipts != null)
        'receipts': receipts?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MessageImpl extends Message {
  _MessageImpl({
    int? id,
    required int chatId,
    _i2.Chat? chat,
    required int senderId,
    _i3.MessengerUser? sender,
    required _i4.MessageType type,
    required String encryptedText,
    int? mediaId,
    _i5.Media? media,
    int? pollId,
    _i6.Poll? poll,
    required DateTime createdAt,
    DateTime? editedAt,
    DateTime? deletedAt,
    List<_i7.MessageReceipt>? receipts,
  }) : super._(
         id: id,
         chatId: chatId,
         chat: chat,
         senderId: senderId,
         sender: sender,
         type: type,
         encryptedText: encryptedText,
         mediaId: mediaId,
         media: media,
         pollId: pollId,
         poll: poll,
         createdAt: createdAt,
         editedAt: editedAt,
         deletedAt: deletedAt,
         receipts: receipts,
       );

  /// Returns a shallow copy of this [Message]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Message copyWith({
    Object? id = _Undefined,
    int? chatId,
    Object? chat = _Undefined,
    int? senderId,
    Object? sender = _Undefined,
    _i4.MessageType? type,
    String? encryptedText,
    Object? mediaId = _Undefined,
    Object? media = _Undefined,
    Object? pollId = _Undefined,
    Object? poll = _Undefined,
    DateTime? createdAt,
    Object? editedAt = _Undefined,
    Object? deletedAt = _Undefined,
    Object? receipts = _Undefined,
  }) {
    return Message(
      id: id is int? ? id : this.id,
      chatId: chatId ?? this.chatId,
      chat: chat is _i2.Chat? ? chat : this.chat?.copyWith(),
      senderId: senderId ?? this.senderId,
      sender: sender is _i3.MessengerUser? ? sender : this.sender?.copyWith(),
      type: type ?? this.type,
      encryptedText: encryptedText ?? this.encryptedText,
      mediaId: mediaId is int? ? mediaId : this.mediaId,
      media: media is _i5.Media? ? media : this.media?.copyWith(),
      pollId: pollId is int? ? pollId : this.pollId,
      poll: poll is _i6.Poll? ? poll : this.poll?.copyWith(),
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt is DateTime? ? editedAt : this.editedAt,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
      receipts: receipts is List<_i7.MessageReceipt>?
          ? receipts
          : this.receipts?.map((e0) => e0.copyWith()).toList(),
    );
  }
}
