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

/// Thrown when uploaded media is the wrong type or too large.
abstract class MessengerInvalidMediaException
    implements _i1.SerializableException, _i1.SerializableModel {
  MessengerInvalidMediaException._({
    required this.code,
    required this.message,
  });

  factory MessengerInvalidMediaException({
    required String code,
    required String message,
  }) = _MessengerInvalidMediaExceptionImpl;

  factory MessengerInvalidMediaException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return MessengerInvalidMediaException(
      code: jsonSerialization['code'] as String,
      message: jsonSerialization['message'] as String,
    );
  }

  /// `unsupportedFormat` or `tooLarge`.
  String code;

  String message;

  /// Returns a shallow copy of this [MessengerInvalidMediaException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MessengerInvalidMediaException copyWith({
    String? code,
    String? message,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MessengerInvalidMediaException',
      'code': code,
      'message': message,
    };
  }

  @override
  String toString() {
    return 'MessengerInvalidMediaException(code: $code, message: $message)';
  }
}

class _MessengerInvalidMediaExceptionImpl
    extends MessengerInvalidMediaException {
  _MessengerInvalidMediaExceptionImpl({
    required String code,
    required String message,
  }) : super._(
         code: code,
         message: message,
       );

  /// Returns a shallow copy of this [MessengerInvalidMediaException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MessengerInvalidMediaException copyWith({
    String? code,
    String? message,
  }) {
    return MessengerInvalidMediaException(
      code: code ?? this.code,
      message: message ?? this.message,
    );
  }
}
