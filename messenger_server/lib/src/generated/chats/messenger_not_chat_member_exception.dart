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

/// Thrown when the caller is not a participant of the chat.
abstract class MessengerNotChatMemberException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  MessengerNotChatMemberException._({required this.chatId});

  factory MessengerNotChatMemberException({required int chatId}) =
      _MessengerNotChatMemberExceptionImpl;

  factory MessengerNotChatMemberException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return MessengerNotChatMemberException(
      chatId: jsonSerialization['chatId'] as int,
    );
  }

  int chatId;

  /// Returns a shallow copy of this [MessengerNotChatMemberException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MessengerNotChatMemberException copyWith({int? chatId});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MessengerNotChatMemberException',
      'chatId': chatId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MessengerNotChatMemberException',
      'chatId': chatId,
    };
  }

  @override
  String toString() {
    return 'MessengerNotChatMemberException(chatId: $chatId)';
  }
}

class _MessengerNotChatMemberExceptionImpl
    extends MessengerNotChatMemberException {
  _MessengerNotChatMemberExceptionImpl({required int chatId})
    : super._(chatId: chatId);

  /// Returns a shallow copy of this [MessengerNotChatMemberException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MessengerNotChatMemberException copyWith({int? chatId}) {
    return MessengerNotChatMemberException(chatId: chatId ?? this.chatId);
  }
}
