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
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i2;
import '../chats/chat_invitation.dart' as _i3;
import 'package:messenger_client/src/protocol/protocol.dart' as _i4;

/// Messenger domain identity linked to a Serverpod [AuthUser].
///
/// Authentication credentials stay in Serverpod Auth. This table only stores
/// Messenger-specific data such as the unique username.
abstract class MessengerUser implements _i1.SerializableModel {
  MessengerUser._({
    this.id,
    required this.authUserId,
    this.authUser,
    required this.username,
    required this.usernameNormalized,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.sentInvitations,
    this.receivedInvitations,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory MessengerUser({
    int? id,
    required _i1.UuidValue authUserId,
    _i2.AuthUser? authUser,
    required String username,
    required String usernameNormalized,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<_i3.ChatInvitation>? sentInvitations,
    List<_i3.ChatInvitation>? receivedInvitations,
  }) = _MessengerUserImpl;

  factory MessengerUser.fromJson(Map<String, dynamic> jsonSerialization) {
    return MessengerUser(
      id: jsonSerialization['id'] as int?,
      authUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _i4.Protocol().deserialize<_i2.AuthUser>(
              jsonSerialization['authUser'],
            ),
      username: jsonSerialization['username'] as String,
      usernameNormalized: jsonSerialization['usernameNormalized'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      sentInvitations: jsonSerialization['sentInvitations'] == null
          ? null
          : _i4.Protocol().deserialize<List<_i3.ChatInvitation>>(
              jsonSerialization['sentInvitations'],
            ),
      receivedInvitations: jsonSerialization['receivedInvitations'] == null
          ? null
          : _i4.Protocol().deserialize<List<_i3.ChatInvitation>>(
              jsonSerialization['receivedInvitations'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _i1.UuidValue authUserId;

  /// The [AuthUser] this Messenger user belongs to.
  _i2.AuthUser? authUser;

  /// Public Messenger username. Original casing is preserved for display.
  String username;

  /// Lower-cased username used for case-insensitive uniqueness.
  String usernameNormalized;

  DateTime createdAt;

  DateTime updatedAt;

  /// Invitations this user sent.
  List<_i3.ChatInvitation>? sentInvitations;

  /// Invitations this user received.
  List<_i3.ChatInvitation>? receivedInvitations;

  /// Returns a shallow copy of this [MessengerUser]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MessengerUser copyWith({
    int? id,
    _i1.UuidValue? authUserId,
    _i2.AuthUser? authUser,
    String? username,
    String? usernameNormalized,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<_i3.ChatInvitation>? sentInvitations,
    List<_i3.ChatInvitation>? receivedInvitations,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MessengerUser',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'username': username,
      'usernameNormalized': usernameNormalized,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (sentInvitations != null)
        'sentInvitations': sentInvitations?.toJson(
          valueToJson: (v) => v.toJson(),
        ),
      if (receivedInvitations != null)
        'receivedInvitations': receivedInvitations?.toJson(
          valueToJson: (v) => v.toJson(),
        ),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MessengerUserImpl extends MessengerUser {
  _MessengerUserImpl({
    int? id,
    required _i1.UuidValue authUserId,
    _i2.AuthUser? authUser,
    required String username,
    required String usernameNormalized,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<_i3.ChatInvitation>? sentInvitations,
    List<_i3.ChatInvitation>? receivedInvitations,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         username: username,
         usernameNormalized: usernameNormalized,
         createdAt: createdAt,
         updatedAt: updatedAt,
         sentInvitations: sentInvitations,
         receivedInvitations: receivedInvitations,
       );

  /// Returns a shallow copy of this [MessengerUser]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MessengerUser copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? authUserId,
    Object? authUser = _Undefined,
    String? username,
    String? usernameNormalized,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? sentInvitations = _Undefined,
    Object? receivedInvitations = _Undefined,
  }) {
    return MessengerUser(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _i2.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      username: username ?? this.username,
      usernameNormalized: usernameNormalized ?? this.usernameNormalized,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sentInvitations: sentInvitations is List<_i3.ChatInvitation>?
          ? sentInvitations
          : this.sentInvitations?.map((e0) => e0.copyWith()).toList(),
      receivedInvitations: receivedInvitations is List<_i3.ChatInvitation>?
          ? receivedInvitations
          : this.receivedInvitations?.map((e0) => e0.copyWith()).toList(),
    );
  }
}
