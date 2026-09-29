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

/// Thrown when a message does not exist.
abstract class MessengerMessageNotFoundException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  MessengerMessageNotFoundException._({required this.messageId});

  factory MessengerMessageNotFoundException({required int messageId}) =
      _MessengerMessageNotFoundExceptionImpl;

  factory MessengerMessageNotFoundException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return MessengerMessageNotFoundException(
      messageId: jsonSerialization['messageId'] as int,
    );
  }

  int messageId;

  /// Returns a shallow copy of this [MessengerMessageNotFoundException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MessengerMessageNotFoundException copyWith({int? messageId});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MessengerMessageNotFoundException',
      'messageId': messageId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MessengerMessageNotFoundException',
      'messageId': messageId,
    };
  }

  @override
  String toString() {
    return 'MessengerMessageNotFoundException(messageId: $messageId)';
  }
}

class _MessengerMessageNotFoundExceptionImpl
    extends MessengerMessageNotFoundException {
  _MessengerMessageNotFoundExceptionImpl({required int messageId})
    : super._(messageId: messageId);

  /// Returns a shallow copy of this [MessengerMessageNotFoundException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MessengerMessageNotFoundException copyWith({int? messageId}) {
    return MessengerMessageNotFoundException(
      messageId: messageId ?? this.messageId,
    );
  }
}
