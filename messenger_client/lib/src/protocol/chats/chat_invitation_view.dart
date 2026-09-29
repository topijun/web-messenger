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
import '../chats/chat_invitation.dart' as _i2;
import 'package:messenger_client/src/protocol/protocol.dart' as _i3;

/// Pending or handled invitation with usernames for the client.
abstract class ChatInvitationView implements _i1.SerializableModel {
  ChatInvitationView._({
    required this.invitation,
    required this.senderUsername,
    this.senderProfileImageId,
    required this.receiverUsername,
    this.chatName,
    required this.isGroup,
  });

  factory ChatInvitationView({
    required _i2.ChatInvitation invitation,
    required String senderUsername,
    int? senderProfileImageId,
    required String receiverUsername,
    String? chatName,
    required bool isGroup,
  }) = _ChatInvitationViewImpl;

  factory ChatInvitationView.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatInvitationView(
      invitation: _i3.Protocol().deserialize<_i2.ChatInvitation>(
        jsonSerialization['invitation'],
      ),
      senderUsername: jsonSerialization['senderUsername'] as String,
      senderProfileImageId: jsonSerialization['senderProfileImageId'] as int?,
      receiverUsername: jsonSerialization['receiverUsername'] as String,
      chatName: jsonSerialization['chatName'] as String?,
      isGroup: _i1.BoolJsonExtension.fromJson(jsonSerialization['isGroup']),
    );
  }

  _i2.ChatInvitation invitation;

  String senderUsername;

  int? senderProfileImageId;

  String receiverUsername;

  String? chatName;

  bool isGroup;

  /// Returns a shallow copy of this [ChatInvitationView]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatInvitationView copyWith({
    _i2.ChatInvitation? invitation,
    String? senderUsername,
    int? senderProfileImageId,
    String? receiverUsername,
    String? chatName,
    bool? isGroup,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatInvitationView',
      'invitation': invitation.toJson(),
      'senderUsername': senderUsername,
      if (senderProfileImageId != null)
        'senderProfileImageId': senderProfileImageId,
      'receiverUsername': receiverUsername,
      if (chatName != null) 'chatName': chatName,
      'isGroup': isGroup,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatInvitationViewImpl extends ChatInvitationView {
  _ChatInvitationViewImpl({
    required _i2.ChatInvitation invitation,
    required String senderUsername,
    int? senderProfileImageId,
    required String receiverUsername,
    String? chatName,
    required bool isGroup,
  }) : super._(
         invitation: invitation,
         senderUsername: senderUsername,
         senderProfileImageId: senderProfileImageId,
         receiverUsername: receiverUsername,
         chatName: chatName,
         isGroup: isGroup,
       );

  /// Returns a shallow copy of this [ChatInvitationView]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatInvitationView copyWith({
    _i2.ChatInvitation? invitation,
    String? senderUsername,
    Object? senderProfileImageId = _Undefined,
    String? receiverUsername,
    Object? chatName = _Undefined,
    bool? isGroup,
  }) {
    return ChatInvitationView(
      invitation: invitation ?? this.invitation.copyWith(),
      senderUsername: senderUsername ?? this.senderUsername,
      senderProfileImageId: senderProfileImageId is int?
          ? senderProfileImageId
          : this.senderProfileImageId,
      receiverUsername: receiverUsername ?? this.receiverUsername,
      chatName: chatName is String? ? chatName : this.chatName,
      isGroup: isGroup ?? this.isGroup,
    );
  }
}
