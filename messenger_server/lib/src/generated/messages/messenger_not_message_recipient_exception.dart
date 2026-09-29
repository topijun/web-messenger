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

/// Thrown when the caller is not a recipient of the message.
abstract class MessengerNotMessageRecipientException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  MessengerNotMessageRecipientException._({required this.messageId});

  factory MessengerNotMessageRecipientException({required int messageId}) =
      _MessengerNotMessageRecipientExceptionImpl;

  factory MessengerNotMessageRecipientException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return MessengerNotMessageRecipientException(
      messageId: jsonSerialization['messageId'] as int,
    );
  }

  int messageId;

  /// Returns a shallow copy of this [MessengerNotMessageRecipientException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MessengerNotMessageRecipientException copyWith({int? messageId});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MessengerNotMessageRecipientException',
      'messageId': messageId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MessengerNotMessageRecipientException',
      'messageId': messageId,
    };
  }

  @override
  String toString() {
    return 'MessengerNotMessageRecipientException(messageId: $messageId)';
  }
}

class _MessengerNotMessageRecipientExceptionImpl
    extends MessengerNotMessageRecipientException {
  _MessengerNotMessageRecipientExceptionImpl({required int messageId})
    : super._(messageId: messageId);

  /// Returns a shallow copy of this [MessengerNotMessageRecipientException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MessengerNotMessageRecipientException copyWith({int? messageId}) {
    return MessengerNotMessageRecipientException(
      messageId: messageId ?? this.messageId,
    );
  }
}
