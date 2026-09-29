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
import 'dart:typed_data' as _i2;

/// Decrypted profile picture returned to the authenticated owner.
abstract class ProfileImage
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ProfileImage._({
    required this.mediaId,
    required this.mimeType,
    required this.size,
    required this.bytes,
  });

  factory ProfileImage({
    required int mediaId,
    required String mimeType,
    required int size,
    required _i2.ByteData bytes,
  }) = _ProfileImageImpl;

  factory ProfileImage.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProfileImage(
      mediaId: jsonSerialization['mediaId'] as int,
      mimeType: jsonSerialization['mimeType'] as String,
      size: jsonSerialization['size'] as int,
      bytes: _i1.ByteDataJsonExtension.fromJson(jsonSerialization['bytes']),
    );
  }

  int mediaId;

  String mimeType;

  int size;

  _i2.ByteData bytes;

  /// Returns a shallow copy of this [ProfileImage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProfileImage copyWith({
    int? mediaId,
    String? mimeType,
    int? size,
    _i2.ByteData? bytes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProfileImage',
      'mediaId': mediaId,
      'mimeType': mimeType,
      'size': size,
      'bytes': bytes.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ProfileImage',
      'mediaId': mediaId,
      'mimeType': mimeType,
      'size': size,
      'bytes': bytes.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ProfileImageImpl extends ProfileImage {
  _ProfileImageImpl({
    required int mediaId,
    required String mimeType,
    required int size,
    required _i2.ByteData bytes,
  }) : super._(
         mediaId: mediaId,
         mimeType: mimeType,
         size: size,
         bytes: bytes,
       );

  /// Returns a shallow copy of this [ProfileImage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProfileImage copyWith({
    int? mediaId,
    String? mimeType,
    int? size,
    _i2.ByteData? bytes,
  }) {
    return ProfileImage(
      mediaId: mediaId ?? this.mediaId,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      bytes: bytes ?? this.bytes.clone(),
    );
  }
}
