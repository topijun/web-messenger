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
import '../chats/chat_type.dart' as _i2;

/// A direct or group conversation.
abstract class Chat implements _i1.SerializableModel {
  Chat._({
    this.id,
    required this.type,
    this.name,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.lastMessageAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Chat({
    int? id,
    required _i2.ChatType type,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastMessageAt,
  }) = _ChatImpl;

  factory Chat.fromJson(Map<String, dynamic> jsonSerialization) {
    return Chat(
      id: jsonSerialization['id'] as int?,
      type: _i2.ChatType.fromJson((jsonSerialization['type'] as String)),
      name: jsonSerialization['name'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      lastMessageAt: jsonSerialization['lastMessageAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastMessageAt'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// Direct chats have two participants. Group chats can have more.
  _i2.ChatType type;

  /// Encrypted display name for group chats (AES-256-GCM). Null for direct chats.
  String? name;

  DateTime createdAt;

  DateTime updatedAt;

  /// Denormalized timestamp for chat-list sorting. Null until messages exist.
  DateTime? lastMessageAt;

  /// Returns a shallow copy of this [Chat]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Chat copyWith({
    int? id,
    _i2.ChatType? type,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastMessageAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Chat',
      if (id != null) 'id': id,
      'type': type.toJson(),
      if (name != null) 'name': name,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (lastMessageAt != null) 'lastMessageAt': lastMessageAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatImpl extends Chat {
  _ChatImpl({
    int? id,
    required _i2.ChatType type,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastMessageAt,
  }) : super._(
         id: id,
         type: type,
         name: name,
         createdAt: createdAt,
         updatedAt: updatedAt,
         lastMessageAt: lastMessageAt,
       );

  /// Returns a shallow copy of this [Chat]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Chat copyWith({
    Object? id = _Undefined,
    _i2.ChatType? type,
    Object? name = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? lastMessageAt = _Undefined,
  }) {
    return Chat(
      id: id is int? ? id : this.id,
      type: type ?? this.type,
      name: name is String? ? name : this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessageAt: lastMessageAt is DateTime?
          ? lastMessageAt
          : this.lastMessageAt,
    );
  }
}
