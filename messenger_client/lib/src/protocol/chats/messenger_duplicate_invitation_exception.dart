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

/// Thrown when a pending invitation already exists.
abstract class MessengerDuplicateInvitationException
    implements _i1.SerializableException, _i1.SerializableModel {
  MessengerDuplicateInvitationException._({required this.username});

  factory MessengerDuplicateInvitationException({required String username}) =
      _MessengerDuplicateInvitationExceptionImpl;

  factory MessengerDuplicateInvitationException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return MessengerDuplicateInvitationException(
      username: jsonSerialization['username'] as String,
    );
  }

  String username;

  /// Returns a shallow copy of this [MessengerDuplicateInvitationException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MessengerDuplicateInvitationException copyWith({String? username});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MessengerDuplicateInvitationException',
      'username': username,
    };
  }

  @override
  String toString() {
    return 'MessengerDuplicateInvitationException(username: $username)';
  }
}

class _MessengerDuplicateInvitationExceptionImpl
    extends MessengerDuplicateInvitationException {
  _MessengerDuplicateInvitationExceptionImpl({required String username})
    : super._(username: username);

  /// Returns a shallow copy of this [MessengerDuplicateInvitationException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MessengerDuplicateInvitationException copyWith({String? username}) {
    return MessengerDuplicateInvitationException(
      username: username ?? this.username,
    );
  }
}
