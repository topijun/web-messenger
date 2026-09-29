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

/// Thrown when the requested media does not exist or the caller cannot access it.
abstract class MessengerMediaNotFoundException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  MessengerMediaNotFoundException._({required this.mediaId});

  factory MessengerMediaNotFoundException({required int mediaId}) =
      _MessengerMediaNotFoundExceptionImpl;

  factory MessengerMediaNotFoundException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return MessengerMediaNotFoundException(
      mediaId: jsonSerialization['mediaId'] as int,
    );
  }

  int mediaId;

  /// Returns a shallow copy of this [MessengerMediaNotFoundException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MessengerMediaNotFoundException copyWith({int? mediaId});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MessengerMediaNotFoundException',
      'mediaId': mediaId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MessengerMediaNotFoundException',
      'mediaId': mediaId,
    };
  }

  @override
  String toString() {
    return 'MessengerMediaNotFoundException(mediaId: $mediaId)';
  }
}

class _MessengerMediaNotFoundExceptionImpl
    extends MessengerMediaNotFoundException {
  _MessengerMediaNotFoundExceptionImpl({required int mediaId})
    : super._(mediaId: mediaId);

  /// Returns a shallow copy of this [MessengerMediaNotFoundException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MessengerMediaNotFoundException copyWith({int? mediaId}) {
    return MessengerMediaNotFoundException(mediaId: mediaId ?? this.mediaId);
  }
}
