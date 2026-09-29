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

/// Thrown when a Messenger username does not match the server validation rules.
abstract class MessengerInvalidUsernameException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  MessengerInvalidUsernameException._({required this.username});

  factory MessengerInvalidUsernameException({required String username}) =
      _MessengerInvalidUsernameExceptionImpl;

  factory MessengerInvalidUsernameException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return MessengerInvalidUsernameException(
      username: jsonSerialization['username'] as String,
    );
  }

  String username;

  /// Returns a shallow copy of this [MessengerInvalidUsernameException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MessengerInvalidUsernameException copyWith({String? username});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MessengerInvalidUsernameException',
      'username': username,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MessengerInvalidUsernameException',
      'username': username,
    };
  }

  @override
  String toString() {
    return 'MessengerInvalidUsernameException(username: $username)';
  }
}

class _MessengerInvalidUsernameExceptionImpl
    extends MessengerInvalidUsernameException {
  _MessengerInvalidUsernameExceptionImpl({required String username})
    : super._(username: username);

  /// Returns a shallow copy of this [MessengerInvalidUsernameException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MessengerInvalidUsernameException copyWith({String? username}) {
    return MessengerInvalidUsernameException(
      username: username ?? this.username,
    );
  }
}
