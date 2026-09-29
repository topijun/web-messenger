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

/// Thrown when account completion has no reserved Messenger username.
abstract class MessengerRegistrationIncompleteException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  MessengerRegistrationIncompleteException._();

  factory MessengerRegistrationIncompleteException() =
      _MessengerRegistrationIncompleteExceptionImpl;

  factory MessengerRegistrationIncompleteException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return MessengerRegistrationIncompleteException();
  }

  /// Returns a shallow copy of this [MessengerRegistrationIncompleteException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MessengerRegistrationIncompleteException copyWith();
  @override
  Map<String, dynamic> toJson() {
    return {'__className__': 'MessengerRegistrationIncompleteException'};
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {'__className__': 'MessengerRegistrationIncompleteException'};
  }

  @override
  String toString() {
    return 'MessengerRegistrationIncompleteException';
  }
}

class _MessengerRegistrationIncompleteExceptionImpl
    extends MessengerRegistrationIncompleteException {
  _MessengerRegistrationIncompleteExceptionImpl() : super._();

  /// Returns a shallow copy of this [MessengerRegistrationIncompleteException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MessengerRegistrationIncompleteException copyWith() {
    return MessengerRegistrationIncompleteException();
  }
}
