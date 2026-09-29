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

/// Thrown when profile input is missing or too long.
abstract class MessengerInvalidProfileInputException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  MessengerInvalidProfileInputException._({
    required this.field,
    required this.message,
  });

  factory MessengerInvalidProfileInputException({
    required String field,
    required String message,
  }) = _MessengerInvalidProfileInputExceptionImpl;

  factory MessengerInvalidProfileInputException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return MessengerInvalidProfileInputException(
      field: jsonSerialization['field'] as String,
      message: jsonSerialization['message'] as String,
    );
  }

  String field;

  String message;

  /// Returns a shallow copy of this [MessengerInvalidProfileInputException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MessengerInvalidProfileInputException copyWith({
    String? field,
    String? message,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MessengerInvalidProfileInputException',
      'field': field,
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MessengerInvalidProfileInputException',
      'field': field,
      'message': message,
    };
  }

  @override
  String toString() {
    return 'MessengerInvalidProfileInputException(field: $field, message: $message)';
  }
}

class _MessengerInvalidProfileInputExceptionImpl
    extends MessengerInvalidProfileInputException {
  _MessengerInvalidProfileInputExceptionImpl({
    required String field,
    required String message,
  }) : super._(
         field: field,
         message: message,
       );

  /// Returns a shallow copy of this [MessengerInvalidProfileInputException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MessengerInvalidProfileInputException copyWith({
    String? field,
    String? message,
  }) {
    return MessengerInvalidProfileInputException(
      field: field ?? this.field,
      message: message ?? this.message,
    );
  }
}
