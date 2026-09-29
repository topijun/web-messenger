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

/// Thrown when an authenticated AuthUser has no MessengerUser.
abstract class MessengerAccountRequiredException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  MessengerAccountRequiredException._({required this.authUserId});

  factory MessengerAccountRequiredException({
    required _i1.UuidValue authUserId,
  }) = _MessengerAccountRequiredExceptionImpl;

  factory MessengerAccountRequiredException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return MessengerAccountRequiredException(
      authUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
    );
  }

  _i1.UuidValue authUserId;

  /// Returns a shallow copy of this [MessengerAccountRequiredException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MessengerAccountRequiredException copyWith({_i1.UuidValue? authUserId});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MessengerAccountRequiredException',
      'authUserId': authUserId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MessengerAccountRequiredException',
      'authUserId': authUserId.toJson(),
    };
  }

  @override
  String toString() {
    return 'MessengerAccountRequiredException(authUserId: $authUserId)';
  }
}

class _MessengerAccountRequiredExceptionImpl
    extends MessengerAccountRequiredException {
  _MessengerAccountRequiredExceptionImpl({required _i1.UuidValue authUserId})
    : super._(authUserId: authUserId);

  /// Returns a shallow copy of this [MessengerAccountRequiredException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MessengerAccountRequiredException copyWith({_i1.UuidValue? authUserId}) {
    return MessengerAccountRequiredException(
      authUserId: authUserId ?? this.authUserId,
    );
  }
}
