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
import '../users/messenger_user.dart' as _i2;
import '../media/media.dart' as _i3;
import 'package:messenger_client/src/protocol/protocol.dart' as _i4;

/// Messenger presentation identity. 1:1 with [MessengerUser].
///
/// [profileImage] is null when the user has no uploaded picture; Flutter then
/// shows the default avatar.
abstract class Profile implements _i1.SerializableModel {
  Profile._({
    this.id,
    required this.userId,
    this.user,
    required this.aboutMe,
    this.profileImageId,
    this.profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Profile({
    int? id,
    required int userId,
    _i2.MessengerUser? user,
    required String aboutMe,
    int? profileImageId,
    _i3.Media? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProfileImpl;

  factory Profile.fromJson(Map<String, dynamic> jsonSerialization) {
    return Profile(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      user: jsonSerialization['user'] == null
          ? null
          : _i4.Protocol().deserialize<_i2.MessengerUser>(
              jsonSerialization['user'],
            ),
      aboutMe: jsonSerialization['aboutMe'] as String,
      profileImageId: jsonSerialization['profileImageId'] as int?,
      profileImage: jsonSerialization['profileImage'] == null
          ? null
          : _i4.Protocol().deserialize<_i3.Media>(
              jsonSerialization['profileImage'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int userId;

  /// The [MessengerUser] this profile belongs to.
  _i2.MessengerUser? user;

  /// Encrypted about-me text (AES-256-GCM). Empty until the user writes one.
  String aboutMe;

  int? profileImageId;

  /// Optional encrypted profile picture. Null shows the default avatar.
  _i3.Media? profileImage;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [Profile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Profile copyWith({
    int? id,
    int? userId,
    _i2.MessengerUser? user,
    String? aboutMe,
    int? profileImageId,
    _i3.Media? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Profile',
      if (id != null) 'id': id,
      'userId': userId,
      if (user != null) 'user': user?.toJson(),
      'aboutMe': aboutMe,
      if (profileImageId != null) 'profileImageId': profileImageId,
      if (profileImage != null) 'profileImage': profileImage?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProfileImpl extends Profile {
  _ProfileImpl({
    int? id,
    required int userId,
    _i2.MessengerUser? user,
    required String aboutMe,
    int? profileImageId,
    _i3.Media? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         userId: userId,
         user: user,
         aboutMe: aboutMe,
         profileImageId: profileImageId,
         profileImage: profileImage,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Profile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Profile copyWith({
    Object? id = _Undefined,
    int? userId,
    Object? user = _Undefined,
    String? aboutMe,
    Object? profileImageId = _Undefined,
    Object? profileImage = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      user: user is _i2.MessengerUser? ? user : this.user?.copyWith(),
      aboutMe: aboutMe ?? this.aboutMe,
      profileImageId: profileImageId is int?
          ? profileImageId
          : this.profileImageId,
      profileImage: profileImage is _i3.Media?
          ? profileImage
          : this.profileImage?.copyWith(),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
