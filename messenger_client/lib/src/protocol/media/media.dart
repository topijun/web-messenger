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
import '../media/media_type.dart' as _i3;
import 'dart:typed_data' as _i4;
import 'package:messenger_client/src/protocol/protocol.dart' as _i5;

/// Encrypted media blob and metadata. Used for profile pictures and
/// chat image/video/audio messages.
///
/// [encryptedData] is AES-256-GCM ciphertext (version byte + nonce +
/// ciphertext + tag). Original media bytes are never stored.
abstract class Media implements _i1.SerializableModel {
  Media._({
    this.id,
    required this.userId,
    this.user,
    required this.type,
    required this.mimeType,
    required this.size,
    required this.encryptedData,
    this.thumbnailMediaId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Media({
    int? id,
    required int userId,
    _i2.MessengerUser? user,
    required _i3.MediaType type,
    required String mimeType,
    required int size,
    required _i4.ByteData encryptedData,
    int? thumbnailMediaId,
    DateTime? createdAt,
  }) = _MediaImpl;

  factory Media.fromJson(Map<String, dynamic> jsonSerialization) {
    return Media(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      user: jsonSerialization['user'] == null
          ? null
          : _i5.Protocol().deserialize<_i2.MessengerUser>(
              jsonSerialization['user'],
            ),
      type: _i3.MediaType.fromJson((jsonSerialization['type'] as String)),
      mimeType: jsonSerialization['mimeType'] as String,
      size: jsonSerialization['size'] as int,
      encryptedData: _i1.ByteDataJsonExtension.fromJson(
        jsonSerialization['encryptedData'],
      ),
      thumbnailMediaId: jsonSerialization['thumbnailMediaId'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int userId;

  /// Owner. Profile pictures are only readable/replaceable by this user.
  _i2.MessengerUser? user;

  _i3.MediaType type;

  String mimeType;

  /// Original plaintext size in bytes, before encryption.
  int size;

  /// AES-256-GCM packed ciphertext. Not the original file bytes.
  _i4.ByteData encryptedData;

  /// Optional encrypted JPEG poster media id for a video row.
  int? thumbnailMediaId;

  DateTime createdAt;

  /// Returns a shallow copy of this [Media]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Media copyWith({
    int? id,
    int? userId,
    _i2.MessengerUser? user,
    _i3.MediaType? type,
    String? mimeType,
    int? size,
    _i4.ByteData? encryptedData,
    int? thumbnailMediaId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Media',
      if (id != null) 'id': id,
      'userId': userId,
      if (user != null) 'user': user?.toJson(),
      'type': type.toJson(),
      'mimeType': mimeType,
      'size': size,
      'encryptedData': encryptedData.toJson(),
      if (thumbnailMediaId != null) 'thumbnailMediaId': thumbnailMediaId,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MediaImpl extends Media {
  _MediaImpl({
    int? id,
    required int userId,
    _i2.MessengerUser? user,
    required _i3.MediaType type,
    required String mimeType,
    required int size,
    required _i4.ByteData encryptedData,
    int? thumbnailMediaId,
    DateTime? createdAt,
  }) : super._(
         id: id,
         userId: userId,
         user: user,
         type: type,
         mimeType: mimeType,
         size: size,
         encryptedData: encryptedData,
         thumbnailMediaId: thumbnailMediaId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Media]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Media copyWith({
    Object? id = _Undefined,
    int? userId,
    Object? user = _Undefined,
    _i3.MediaType? type,
    String? mimeType,
    int? size,
    _i4.ByteData? encryptedData,
    Object? thumbnailMediaId = _Undefined,
    DateTime? createdAt,
  }) {
    return Media(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      user: user is _i2.MessengerUser? ? user : this.user?.copyWith(),
      type: type ?? this.type,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      encryptedData: encryptedData ?? this.encryptedData.clone(),
      thumbnailMediaId: thumbnailMediaId is int?
          ? thumbnailMediaId
          : this.thumbnailMediaId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
