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

enum ChatEventKind implements _i1.SerializableModel {
  message,
  receipt,
  typingStarted,
  typingStopped,
  messageEdited,
  messageDeleted,
  invitation,
  pollUpdated,
  messageReactionUpdated;

  static ChatEventKind fromJson(String name) {
    switch (name) {
      case 'message':
        return ChatEventKind.message;
      case 'receipt':
        return ChatEventKind.receipt;
      case 'typingStarted':
        return ChatEventKind.typingStarted;
      case 'typingStopped':
        return ChatEventKind.typingStopped;
      case 'messageEdited':
        return ChatEventKind.messageEdited;
      case 'messageDeleted':
        return ChatEventKind.messageDeleted;
      case 'invitation':
        return ChatEventKind.invitation;
      case 'pollUpdated':
        return ChatEventKind.pollUpdated;
      case 'messageReactionUpdated':
        return ChatEventKind.messageReactionUpdated;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "ChatEventKind"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
