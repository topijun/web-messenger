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

/// Thrown when a Messenger username cannot be found.
abstract class MessengerUserNotFoundException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  MessengerUserNotFoundException._({required this.username});

  factory MessengerUserNotFoundException({required String username}) =
      _MessengerUserNotFoundExceptionImpl;

  factory MessengerUserNotFoundException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return MessengerUserNotFoundException(
      username: jsonSerialization['username'] as String,
    );
  }

  String username;

  /// Returns a shallow copy of this [MessengerUserNotFoundException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MessengerUserNotFoundException copyWith({String? username});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MessengerUserNotFoundException',
      'username': username,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MessengerUserNotFoundException',
      'username': username,
    };
  }

  @override
  String toString() {
    return 'MessengerUserNotFoundException(username: $username)';
  }
}

class _MessengerUserNotFoundExceptionImpl
    extends MessengerUserNotFoundException {
  _MessengerUserNotFoundExceptionImpl({required String username})
    : super._(username: username);

  /// Returns a shallow copy of this [MessengerUserNotFoundException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MessengerUserNotFoundException copyWith({String? username}) {
    return MessengerUserNotFoundException(username: username ?? this.username);
  }
}
