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
import '../chats/chat_participant_role.dart' as _i4;
import 'package:messenger_client/src/protocol/protocol.dart' as _i5;

/// Membership of a [MessengerUser] in a [Chat]. Settings are per user.
abstract class ChatParticipant implements _i1.SerializableModel {
  ChatParticipant._({
    this.id,
    required this.chatId,
    this.chat,
    required this.userId,
    this.user,
    required this.role,
    DateTime? joinedAt,
    bool? archived,
    bool? notificationsMuted,
  }) : joinedAt = joinedAt ?? DateTime.now(),
       archived = archived ?? false,
       notificationsMuted = notificationsMuted ?? false;

  factory ChatParticipant({
    int? id,
    required int chatId,
    _i2.Chat? chat,
    required int userId,
    _i3.MessengerUser? user,
    required _i4.ChatParticipantRole role,
    DateTime? joinedAt,
    bool? archived,
    bool? notificationsMuted,
  }) = _ChatParticipantImpl;

  factory ChatParticipant.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatParticipant(
      id: jsonSerialization['id'] as int?,
      chatId: jsonSerialization['chatId'] as int,
      chat: jsonSerialization['chat'] == null
          ? null
          : _i5.Protocol().deserialize<_i2.Chat>(jsonSerialization['chat']),
      userId: jsonSerialization['userId'] as int,
      user: jsonSerialization['user'] == null
          ? null
          : _i5.Protocol().deserialize<_i3.MessengerUser>(
              jsonSerialization['user'],
            ),
      role: _i4.ChatParticipantRole.fromJson(
        (jsonSerialization['role'] as String),
      ),
      joinedAt: jsonSerialization['joinedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['joinedAt']),
      archived: jsonSerialization['archived'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['archived']),
      notificationsMuted: jsonSerialization['notificationsMuted'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(
              jsonSerialization['notificationsMuted'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int chatId;

  _i2.Chat? chat;

  int userId;

  _i3.MessengerUser? user;

  _i4.ChatParticipantRole role;

  DateTime joinedAt;

  bool archived;

  bool notificationsMuted;

  /// Returns a shallow copy of this [ChatParticipant]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatParticipant copyWith({
    int? id,
    int? chatId,
    _i2.Chat? chat,
    int? userId,
    _i3.MessengerUser? user,
    _i4.ChatParticipantRole? role,
    DateTime? joinedAt,
    bool? archived,
    bool? notificationsMuted,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatParticipant',
      if (id != null) 'id': id,
      'chatId': chatId,
      if (chat != null) 'chat': chat?.toJson(),
      'userId': userId,
      if (user != null) 'user': user?.toJson(),
      'role': role.toJson(),
      'joinedAt': joinedAt.toJson(),
      'archived': archived,
      'notificationsMuted': notificationsMuted,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatParticipantImpl extends ChatParticipant {
  _ChatParticipantImpl({
    int? id,
    required int chatId,
    _i2.Chat? chat,
    required int userId,
    _i3.MessengerUser? user,
    required _i4.ChatParticipantRole role,
    DateTime? joinedAt,
    bool? archived,
    bool? notificationsMuted,
  }) : super._(
         id: id,
         chatId: chatId,
         chat: chat,
         userId: userId,
         user: user,
         role: role,
         joinedAt: joinedAt,
         archived: archived,
         notificationsMuted: notificationsMuted,
       );

  /// Returns a shallow copy of this [ChatParticipant]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatParticipant copyWith({
    Object? id = _Undefined,
    int? chatId,
    Object? chat = _Undefined,
    int? userId,
    Object? user = _Undefined,
    _i4.ChatParticipantRole? role,
    DateTime? joinedAt,
    bool? archived,
    bool? notificationsMuted,
  }) {
    return ChatParticipant(
      id: id is int? ? id : this.id,
      chatId: chatId ?? this.chatId,
      chat: chat is _i2.Chat? ? chat : this.chat?.copyWith(),
      userId: userId ?? this.userId,
      user: user is _i3.MessengerUser? ? user : this.user?.copyWith(),
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      archived: archived ?? this.archived,
      notificationsMuted: notificationsMuted ?? this.notificationsMuted,
    );
  }
}
