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
import '../messages/chat_event_kind.dart' as _i2;
import '../messages/message_view.dart' as _i3;
import '../messages/message_receipt.dart' as _i4;
import '../chats/chat_invitation_view.dart' as _i5;
import 'package:messenger_client/src/protocol/protocol.dart' as _i6;

/// Realtime notification for a new message, receipt, typing, edit, delete,
/// or incoming invitation.
///
/// Realtime is an optimization. The database remains the source of truth.
/// Typing fields are transient; they are never persisted.
/// Edit and delete events carry a MessageView keyed by stable message id.
/// Invitation events reuse this user's existing MessageCentral channel.
/// Pending direct invitations have no chat yet; [chatId] is 0 in that case.
abstract class ChatEvent implements _i1.SerializableModel {
  ChatEvent._({
    required this.kind,
    required this.chatId,
    this.message,
    this.receipt,
    this.typingUserId,
    this.typingUsername,
    this.invitation,
  });

  factory ChatEvent({
    required _i2.ChatEventKind kind,
    required int chatId,
    _i3.MessageView? message,
    _i4.MessageReceipt? receipt,
    int? typingUserId,
    String? typingUsername,
    _i5.ChatInvitationView? invitation,
  }) = _ChatEventImpl;

  factory ChatEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatEvent(
      kind: _i2.ChatEventKind.fromJson((jsonSerialization['kind'] as String)),
      chatId: jsonSerialization['chatId'] as int,
      message: jsonSerialization['message'] == null
          ? null
          : _i6.Protocol().deserialize<_i3.MessageView>(
              jsonSerialization['message'],
            ),
      receipt: jsonSerialization['receipt'] == null
          ? null
          : _i6.Protocol().deserialize<_i4.MessageReceipt>(
              jsonSerialization['receipt'],
            ),
      typingUserId: jsonSerialization['typingUserId'] as int?,
      typingUsername: jsonSerialization['typingUsername'] as String?,
      invitation: jsonSerialization['invitation'] == null
          ? null
          : _i6.Protocol().deserialize<_i5.ChatInvitationView>(
              jsonSerialization['invitation'],
            ),
    );
  }

  _i2.ChatEventKind kind;

  int chatId;

  _i3.MessageView? message;

  _i4.MessageReceipt? receipt;

  /// Set on typingStarted / typingStopped. Never includes draft text.
  int? typingUserId;

  String? typingUsername;

  /// Set on invitation. Posted only to the invitation receiver.
  _i5.ChatInvitationView? invitation;

  /// Returns a shallow copy of this [ChatEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatEvent copyWith({
    _i2.ChatEventKind? kind,
    int? chatId,
    _i3.MessageView? message,
    _i4.MessageReceipt? receipt,
    int? typingUserId,
    String? typingUsername,
    _i5.ChatInvitationView? invitation,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatEvent',
      'kind': kind.toJson(),
      'chatId': chatId,
      if (message != null) 'message': message?.toJson(),
      if (receipt != null) 'receipt': receipt?.toJson(),
      if (typingUserId != null) 'typingUserId': typingUserId,
      if (typingUsername != null) 'typingUsername': typingUsername,
      if (invitation != null) 'invitation': invitation?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatEventImpl extends ChatEvent {
  _ChatEventImpl({
    required _i2.ChatEventKind kind,
    required int chatId,
    _i3.MessageView? message,
    _i4.MessageReceipt? receipt,
    int? typingUserId,
    String? typingUsername,
    _i5.ChatInvitationView? invitation,
  }) : super._(
         kind: kind,
         chatId: chatId,
         message: message,
         receipt: receipt,
         typingUserId: typingUserId,
         typingUsername: typingUsername,
         invitation: invitation,
       );

  /// Returns a shallow copy of this [ChatEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatEvent copyWith({
    _i2.ChatEventKind? kind,
    int? chatId,
    Object? message = _Undefined,
    Object? receipt = _Undefined,
    Object? typingUserId = _Undefined,
    Object? typingUsername = _Undefined,
    Object? invitation = _Undefined,
  }) {
    return ChatEvent(
      kind: kind ?? this.kind,
      chatId: chatId ?? this.chatId,
      message: message is _i3.MessageView? ? message : this.message?.copyWith(),
      receipt: receipt is _i4.MessageReceipt?
          ? receipt
          : this.receipt?.copyWith(),
      typingUserId: typingUserId is int? ? typingUserId : this.typingUserId,
      typingUsername: typingUsername is String?
          ? typingUsername
          : this.typingUsername,
      invitation: invitation is _i5.ChatInvitationView?
          ? invitation
          : this.invitation?.copyWith(),
    );
  }
}
