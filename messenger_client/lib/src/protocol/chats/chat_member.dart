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
import '../chats/chat_participant_role.dart' as _i2;

/// A participant with a display username.
abstract class ChatMember implements _i1.SerializableModel {
  ChatMember._({
    required this.userId,
    required this.username,
    this.profileImageId,
    required this.role,
    required this.joinedAt,
  });

  factory ChatMember({
    required int userId,
    required String username,
    int? profileImageId,
    required _i2.ChatParticipantRole role,
    required DateTime joinedAt,
  }) = _ChatMemberImpl;

  factory ChatMember.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatMember(
      userId: jsonSerialization['userId'] as int,
      username: jsonSerialization['username'] as String,
      profileImageId: jsonSerialization['profileImageId'] as int?,
      role: _i2.ChatParticipantRole.fromJson(
        (jsonSerialization['role'] as String),
      ),
      joinedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['joinedAt'],
      ),
    );
  }

  int userId;

  String username;

  int? profileImageId;

  _i2.ChatParticipantRole role;

  DateTime joinedAt;

  /// Returns a shallow copy of this [ChatMember]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatMember copyWith({
    int? userId,
    String? username,
    int? profileImageId,
    _i2.ChatParticipantRole? role,
    DateTime? joinedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatMember',
      'userId': userId,
      'username': username,
      if (profileImageId != null) 'profileImageId': profileImageId,
      'role': role.toJson(),
      'joinedAt': joinedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatMemberImpl extends ChatMember {
  _ChatMemberImpl({
    required int userId,
    required String username,
    int? profileImageId,
    required _i2.ChatParticipantRole role,
    required DateTime joinedAt,
  }) : super._(
         userId: userId,
         username: username,
         profileImageId: profileImageId,
         role: role,
         joinedAt: joinedAt,
       );

  /// Returns a shallow copy of this [ChatMember]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatMember copyWith({
    int? userId,
    String? username,
    Object? profileImageId = _Undefined,
    _i2.ChatParticipantRole? role,
    DateTime? joinedAt,
  }) {
    return ChatMember(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      profileImageId: profileImageId is int?
          ? profileImageId
          : this.profileImageId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
