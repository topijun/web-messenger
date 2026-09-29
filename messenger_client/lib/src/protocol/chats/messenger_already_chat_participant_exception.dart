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

/// Thrown when the invited user is already a participant.
abstract class MessengerAlreadyChatParticipantException
    implements _i1.SerializableException, _i1.SerializableModel {
  MessengerAlreadyChatParticipantException._({required this.username});

  factory MessengerAlreadyChatParticipantException({required String username}) =
      _MessengerAlreadyChatParticipantExceptionImpl;

  factory MessengerAlreadyChatParticipantException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return MessengerAlreadyChatParticipantException(
      username: jsonSerialization['username'] as String,
    );
  }

  String username;

  /// Returns a shallow copy of this [MessengerAlreadyChatParticipantException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MessengerAlreadyChatParticipantException copyWith({String? username});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MessengerAlreadyChatParticipantException',
      'username': username,
    };
  }

  @override
  String toString() {
    return 'MessengerAlreadyChatParticipantException(username: $username)';
  }
}

class _MessengerAlreadyChatParticipantExceptionImpl
    extends MessengerAlreadyChatParticipantException {
  _MessengerAlreadyChatParticipantExceptionImpl({required String username})
    : super._(username: username);

  /// Returns a shallow copy of this [MessengerAlreadyChatParticipantException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MessengerAlreadyChatParticipantException copyWith({String? username}) {
    return MessengerAlreadyChatParticipantException(
      username: username ?? this.username,
    );
  }
}
