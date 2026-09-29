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
import '../chats/chat_invitation_status.dart' as _i4;
import 'package:messenger_client/src/protocol/protocol.dart' as _i5;

/// Invitation to a direct or group [Chat]. Direct invitations have no chat
/// until they are accepted.
abstract class ChatInvitation implements _i1.SerializableModel {
  ChatInvitation._({
    this.id,
    this.chatId,
    this.chat,
    required this.senderId,
    this.sender,
    required this.receiverId,
    this.receiver,
    required this.status,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ChatInvitation({
    int? id,
    int? chatId,
    _i2.Chat? chat,
    required int senderId,
    _i3.MessengerUser? sender,
    required int receiverId,
    _i3.MessengerUser? receiver,
    required _i4.ChatInvitationStatus status,
    DateTime? createdAt,
  }) = _ChatInvitationImpl;

  factory ChatInvitation.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatInvitation(
      id: jsonSerialization['id'] as int?,
      chatId: jsonSerialization['chatId'] as int?,
      chat: jsonSerialization['chat'] == null
          ? null
          : _i5.Protocol().deserialize<_i2.Chat>(jsonSerialization['chat']),
      senderId: jsonSerialization['senderId'] as int,
      sender: jsonSerialization['sender'] == null
          ? null
          : _i5.Protocol().deserialize<_i3.MessengerUser>(
              jsonSerialization['sender'],
            ),
      receiverId: jsonSerialization['receiverId'] as int,
      receiver: jsonSerialization['receiver'] == null
          ? null
          : _i5.Protocol().deserialize<_i3.MessengerUser>(
              jsonSerialization['receiver'],
            ),
      status: _i4.ChatInvitationStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int? chatId;

  _i2.Chat? chat;

  int senderId;

  _i3.MessengerUser? sender;

  int receiverId;

  _i3.MessengerUser? receiver;

  _i4.ChatInvitationStatus status;

  DateTime createdAt;

  /// Returns a shallow copy of this [ChatInvitation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatInvitation copyWith({
    int? id,
    int? chatId,
    _i2.Chat? chat,
    int? senderId,
    _i3.MessengerUser? sender,
    int? receiverId,
    _i3.MessengerUser? receiver,
    _i4.ChatInvitationStatus? status,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatInvitation',
      if (id != null) 'id': id,
      if (chatId != null) 'chatId': chatId,
      if (chat != null) 'chat': chat?.toJson(),
      'senderId': senderId,
      if (sender != null) 'sender': sender?.toJson(),
      'receiverId': receiverId,
      if (receiver != null) 'receiver': receiver?.toJson(),
      'status': status.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatInvitationImpl extends ChatInvitation {
  _ChatInvitationImpl({
    int? id,
    int? chatId,
    _i2.Chat? chat,
    required int senderId,
    _i3.MessengerUser? sender,
    required int receiverId,
    _i3.MessengerUser? receiver,
    required _i4.ChatInvitationStatus status,
    DateTime? createdAt,
  }) : super._(
         id: id,
         chatId: chatId,
         chat: chat,
         senderId: senderId,
         sender: sender,
         receiverId: receiverId,
         receiver: receiver,
         status: status,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ChatInvitation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatInvitation copyWith({
    Object? id = _Undefined,
    Object? chatId = _Undefined,
    Object? chat = _Undefined,
    int? senderId,
    Object? sender = _Undefined,
    int? receiverId,
    Object? receiver = _Undefined,
    _i4.ChatInvitationStatus? status,
    DateTime? createdAt,
  }) {
    return ChatInvitation(
      id: id is int? ? id : this.id,
      chatId: chatId is int? ? chatId : this.chatId,
      chat: chat is _i2.Chat? ? chat : this.chat?.copyWith(),
      senderId: senderId ?? this.senderId,
      sender: sender is _i3.MessengerUser? ? sender : this.sender?.copyWith(),
      receiverId: receiverId ?? this.receiverId,
      receiver: receiver is _i3.MessengerUser?
          ? receiver
          : this.receiver?.copyWith(),
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
