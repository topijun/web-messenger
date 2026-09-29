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
import '../media/media_type.dart' as _i2;
import 'dart:typed_data' as _i3;

/// Decrypted chat image or video returned to an authorized chat member.
abstract class ChatMedia
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ChatMedia._({
    required this.mediaId,
    required this.type,
    required this.mimeType,
    required this.size,
    required this.bytes,
    this.thumbnailMediaId,
  });

  factory ChatMedia({
    required int mediaId,
    required _i2.MediaType type,
    required String mimeType,
    required int size,
    required _i3.ByteData bytes,
    int? thumbnailMediaId,
  }) = _ChatMediaImpl;

  factory ChatMedia.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatMedia(
      mediaId: jsonSerialization['mediaId'] as int,
      type: _i2.MediaType.fromJson((jsonSerialization['type'] as String)),
      mimeType: jsonSerialization['mimeType'] as String,
      size: jsonSerialization['size'] as int,
      bytes: _i1.ByteDataJsonExtension.fromJson(jsonSerialization['bytes']),
      thumbnailMediaId: jsonSerialization['thumbnailMediaId'] as int?,
    );
  }

  int mediaId;

  _i2.MediaType type;

  String mimeType;

  int size;

  _i3.ByteData bytes;

  int? thumbnailMediaId;

  /// Returns a shallow copy of this [ChatMedia]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatMedia copyWith({
    int? mediaId,
    _i2.MediaType? type,
    String? mimeType,
    int? size,
    _i3.ByteData? bytes,
    int? thumbnailMediaId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatMedia',
      'mediaId': mediaId,
      'type': type.toJson(),
      'mimeType': mimeType,
      'size': size,
      'bytes': bytes.toJson(),
      if (thumbnailMediaId != null) 'thumbnailMediaId': thumbnailMediaId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ChatMedia',
      'mediaId': mediaId,
      'type': type.toJson(),
      'mimeType': mimeType,
      'size': size,
      'bytes': bytes.toJson(),
      if (thumbnailMediaId != null) 'thumbnailMediaId': thumbnailMediaId,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatMediaImpl extends ChatMedia {
  _ChatMediaImpl({
    required int mediaId,
    required _i2.MediaType type,
    required String mimeType,
    required int size,
    required _i3.ByteData bytes,
    int? thumbnailMediaId,
  }) : super._(
         mediaId: mediaId,
         type: type,
         mimeType: mimeType,
         size: size,
         bytes: bytes,
         thumbnailMediaId: thumbnailMediaId,
       );

  /// Returns a shallow copy of this [ChatMedia]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatMedia copyWith({
    int? mediaId,
    _i2.MediaType? type,
    String? mimeType,
    int? size,
    _i3.ByteData? bytes,
    Object? thumbnailMediaId = _Undefined,
  }) {
    return ChatMedia(
      mediaId: mediaId ?? this.mediaId,
      type: type ?? this.type,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      bytes: bytes ?? this.bytes.clone(),
      thumbnailMediaId: thumbnailMediaId is int?
          ? thumbnailMediaId
          : this.thumbnailMediaId,
    );
  }
}
