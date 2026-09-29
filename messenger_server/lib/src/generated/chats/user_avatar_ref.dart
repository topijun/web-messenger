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

import 'package:serverpod/serverpod.dart' as _i1;

/// Username plus optional profile-picture media id for list rows.
abstract class UserAvatarRef
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  UserAvatarRef._({
    required this.username,
    this.profileImageId,
  });

  factory UserAvatarRef({
    required String username,
    int? profileImageId,
  }) = _UserAvatarRefImpl;

  factory UserAvatarRef.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserAvatarRef(
      username: jsonSerialization['username'] as String,
      profileImageId: jsonSerialization['profileImageId'] as int?,
    );
  }

  String username;

  int? profileImageId;

  /// Returns a shallow copy of this [UserAvatarRef]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserAvatarRef copyWith({
    String? username,
    int? profileImageId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserAvatarRef',
      'username': username,
      if (profileImageId != null) 'profileImageId': profileImageId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserAvatarRef',
      'username': username,
      if (profileImageId != null) 'profileImageId': profileImageId,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserAvatarRefImpl extends UserAvatarRef {
  _UserAvatarRefImpl({
    required String username,
    int? profileImageId,
  }) : super._(
         username: username,
         profileImageId: profileImageId,
       );

  /// Returns a shallow copy of this [UserAvatarRef]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserAvatarRef copyWith({
    String? username,
    Object? profileImageId = _Undefined,
  }) {
    return UserAvatarRef(
      username: username ?? this.username,
      profileImageId: profileImageId is int?
          ? profileImageId
          : this.profileImageId,
    );
  }
}
