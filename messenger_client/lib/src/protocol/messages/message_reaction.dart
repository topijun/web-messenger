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
import '../messages/message.dart' as _i2;
import '../users/messenger_user.dart' as _i3;
import 'package:messenger_client/src/protocol/protocol.dart' as _i4;

/// One user's emoji on a message.
///
/// One row per (message, user, emoji). Counts are derived from these rows.
/// The emoji is metadata, not message text, and is not encrypted.
abstract class MessageReaction implements _i1.SerializableModel {
  MessageReaction._({
    this.id,
    required this.messageId,
    this.message,
    required this.userId,
    this.user,
    required this.emoji,
    required this.createdAt,
  });

  factory MessageReaction({
    int? id,
    required int messageId,
    _i2.Message? message,
    required int userId,
    _i3.MessengerUser? user,
    required String emoji,
    required DateTime createdAt,
  }) = _MessageReactionImpl;

  factory MessageReaction.fromJson(Map<String, dynamic> jsonSerialization) {
    return MessageReaction(
      id: jsonSerialization['id'] as int?,
      messageId: jsonSerialization['messageId'] as int,
      message: jsonSerialization['message'] == null
          ? null
          : _i4.Protocol().deserialize<_i2.Message>(
              jsonSerialization['message'],
            ),
      userId: jsonSerialization['userId'] as int,
      user: jsonSerialization['user'] == null
          ? null
          : _i4.Protocol().deserialize<_i3.MessengerUser>(
              jsonSerialization['user'],
            ),
      emoji: jsonSerialization['emoji'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int messageId;

  _i2.Message? message;

  int userId;

  _i3.MessengerUser? user;

  String emoji;

  DateTime createdAt;

  /// Returns a shallow copy of this [MessageReaction]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MessageReaction copyWith({
    int? id,
    int? messageId,
    _i2.Message? message,
    int? userId,
    _i3.MessengerUser? user,
    String? emoji,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MessageReaction',
      if (id != null) 'id': id,
      'messageId': messageId,
      if (message != null) 'message': message?.toJson(),
      'userId': userId,
      if (user != null) 'user': user?.toJson(),
      'emoji': emoji,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MessageReactionImpl extends MessageReaction {
  _MessageReactionImpl({
    int? id,
    required int messageId,
    _i2.Message? message,
    required int userId,
    _i3.MessengerUser? user,
    required String emoji,
    required DateTime createdAt,
  }) : super._(
         id: id,
         messageId: messageId,
         message: message,
         userId: userId,
         user: user,
         emoji: emoji,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [MessageReaction]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MessageReaction copyWith({
    Object? id = _Undefined,
    int? messageId,
    Object? message = _Undefined,
    int? userId,
    Object? user = _Undefined,
    String? emoji,
    DateTime? createdAt,
  }) {
    return MessageReaction(
      id: id is int? ? id : this.id,
      messageId: messageId ?? this.messageId,
      message: message is _i2.Message? ? message : this.message?.copyWith(),
      userId: userId ?? this.userId,
      user: user is _i3.MessengerUser? ? user : this.user?.copyWith(),
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
