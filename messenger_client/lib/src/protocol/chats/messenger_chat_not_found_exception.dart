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

/// Thrown when a chat does not exist or is not visible to the caller.
abstract class MessengerChatNotFoundException
    implements _i1.SerializableException, _i1.SerializableModel {
  MessengerChatNotFoundException._({required this.chatId});

  factory MessengerChatNotFoundException({required int chatId}) =
      _MessengerChatNotFoundExceptionImpl;

  factory MessengerChatNotFoundException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return MessengerChatNotFoundException(
      chatId: jsonSerialization['chatId'] as int,
    );
  }

  int chatId;

  /// Returns a shallow copy of this [MessengerChatNotFoundException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MessengerChatNotFoundException copyWith({int? chatId});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MessengerChatNotFoundException',
      'chatId': chatId,
    };
  }

  @override
  String toString() {
    return 'MessengerChatNotFoundException(chatId: $chatId)';
  }
}

class _MessengerChatNotFoundExceptionImpl
    extends MessengerChatNotFoundException {
  _MessengerChatNotFoundExceptionImpl({required int chatId})
    : super._(chatId: chatId);

  /// Returns a shallow copy of this [MessengerChatNotFoundException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MessengerChatNotFoundException copyWith({int? chatId}) {
    return MessengerChatNotFoundException(chatId: chatId ?? this.chatId);
  }
}
