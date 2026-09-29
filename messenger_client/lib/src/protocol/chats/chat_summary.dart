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
import '../chats/chat.dart' as _i2;
import '../chats/chat_participant.dart' as _i3;
import '../chats/user_avatar_ref.dart' as _i4;
import 'package:messenger_client/src/protocol/protocol.dart' as _i5;

/// Chat row plus the current user's membership, for the chat list.
abstract class ChatSummary implements _i1.SerializableModel {
  ChatSummary._({
    required this.chat,
    required this.membership,
    required this.otherUsernames,
    required this.otherAvatars,
    required this.unreadCount,
  });

  factory ChatSummary({
    required _i2.Chat chat,
    required _i3.ChatParticipant membership,
    required List<String> otherUsernames,
    required List<_i4.UserAvatarRef> otherAvatars,
    required int unreadCount,
  }) = _ChatSummaryImpl;

  factory ChatSummary.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatSummary(
      chat: _i5.Protocol().deserialize<_i2.Chat>(jsonSerialization['chat']),
      membership: _i5.Protocol().deserialize<_i3.ChatParticipant>(
        jsonSerialization['membership'],
      ),
      otherUsernames: _i5.Protocol().deserialize<List<String>>(
        jsonSerialization['otherUsernames'],
      ),
      otherAvatars: _i5.Protocol().deserialize<List<_i4.UserAvatarRef>>(
        jsonSerialization['otherAvatars'],
      ),
      unreadCount: jsonSerialization['unreadCount'] as int,
    );
  }

  _i2.Chat chat;

  _i3.ChatParticipant membership;

  List<String> otherUsernames;

  /// Other participants in the same order as [otherUsernames], with ids only.
  List<_i4.UserAvatarRef> otherAvatars;

  /// Incoming messages in this chat whose recipient receipt has no readAt.
  /// The signed-in user's own messages are never included.
  int unreadCount;

  /// Returns a shallow copy of this [ChatSummary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatSummary copyWith({
    _i2.Chat? chat,
    _i3.ChatParticipant? membership,
    List<String>? otherUsernames,
    List<_i4.UserAvatarRef>? otherAvatars,
    int? unreadCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatSummary',
      'chat': chat.toJson(),
      'membership': membership.toJson(),
      'otherUsernames': otherUsernames.toJson(),
      'otherAvatars': otherAvatars.toJson(valueToJson: (v) => v.toJson()),
      'unreadCount': unreadCount,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ChatSummaryImpl extends ChatSummary {
  _ChatSummaryImpl({
    required _i2.Chat chat,
    required _i3.ChatParticipant membership,
    required List<String> otherUsernames,
    required List<_i4.UserAvatarRef> otherAvatars,
    required int unreadCount,
  }) : super._(
         chat: chat,
         membership: membership,
         otherUsernames: otherUsernames,
         otherAvatars: otherAvatars,
         unreadCount: unreadCount,
       );

  /// Returns a shallow copy of this [ChatSummary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatSummary copyWith({
    _i2.Chat? chat,
    _i3.ChatParticipant? membership,
    List<String>? otherUsernames,
    List<_i4.UserAvatarRef>? otherAvatars,
    int? unreadCount,
  }) {
    return ChatSummary(
      chat: chat ?? this.chat.copyWith(),
      membership: membership ?? this.membership.copyWith(),
      otherUsernames:
          otherUsernames ?? this.otherUsernames.map((e0) => e0).toList(),
      otherAvatars:
          otherAvatars ?? this.otherAvatars.map((e0) => e0.copyWith()).toList(),
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
