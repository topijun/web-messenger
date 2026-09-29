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

/// Thrown when an [AuthUser] already has a [MessengerUser].
abstract class MessengerUserAlreadyExistsException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  MessengerUserAlreadyExistsException._({required this.authUserId});

  factory MessengerUserAlreadyExistsException({
    required _i1.UuidValue authUserId,
  }) = _MessengerUserAlreadyExistsExceptionImpl;

  factory MessengerUserAlreadyExistsException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return MessengerUserAlreadyExistsException(
      authUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
    );
  }

  _i1.UuidValue authUserId;

  /// Returns a shallow copy of this [MessengerUserAlreadyExistsException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MessengerUserAlreadyExistsException copyWith({_i1.UuidValue? authUserId});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MessengerUserAlreadyExistsException',
      'authUserId': authUserId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MessengerUserAlreadyExistsException',
      'authUserId': authUserId.toJson(),
    };
  }

  @override
  String toString() {
    return 'MessengerUserAlreadyExistsException(authUserId: $authUserId)';
  }
}

class _MessengerUserAlreadyExistsExceptionImpl
    extends MessengerUserAlreadyExistsException {
  _MessengerUserAlreadyExistsExceptionImpl({required _i1.UuidValue authUserId})
    : super._(authUserId: authUserId);

  /// Returns a shallow copy of this [MessengerUserAlreadyExistsException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MessengerUserAlreadyExistsException copyWith({_i1.UuidValue? authUserId}) {
    return MessengerUserAlreadyExistsException(
      authUserId: authUserId ?? this.authUserId,
    );
  }
}
