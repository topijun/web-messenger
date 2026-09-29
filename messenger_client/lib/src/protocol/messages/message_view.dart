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
import '../messages/message.dart' as _i2;
import '../messages/message_receipt.dart' as _i3;
import '../messages/poll_view.dart' as _i4;
import 'package:messenger_client/src/protocol/protocol.dart' as _i5;

/// A [Message] plus sender and receipt data for the current caller.
abstract class MessageView implements _i1.SerializableModel {
  MessageView._({
    required this.message,
    required this.senderUsername,
    this.senderProfileImageId,
    required this.isMine,
    required this.receipts,
    this.thumbnailMediaId,
    this.poll,
  });

  factory MessageView({
    required _i2.Message message,
    required String senderUsername,
    int? senderProfileImageId,
    required bool isMine,
    required List<_i3.MessageReceipt> receipts,
    int? thumbnailMediaId,
    _i4.PollView? poll,
  }) = _MessageViewImpl;

  factory MessageView.fromJson(Map<String, dynamic> jsonSerialization) {
    return MessageView(
      message: _i5.Protocol().deserialize<_i2.Message>(
        jsonSerialization['message'],
      ),
      senderUsername: jsonSerialization['senderUsername'] as String,
      senderProfileImageId: jsonSerialization['senderProfileImageId'] as int?,
      isMine: _i1.BoolJsonExtension.fromJson(jsonSerialization['isMine']),
      receipts: _i5.Protocol().deserialize<List<_i3.MessageReceipt>>(
        jsonSerialization['receipts'],
      ),
      thumbnailMediaId: jsonSerialization['thumbnailMediaId'] as int?,
      poll: jsonSerialization['poll'] == null
          ? null
          : _i5.Protocol().deserialize<_i4.PollView>(jsonSerialization['poll']),
    );
  }

  _i2.Message message;

  String senderUsername;

  int? senderProfileImageId;

  bool isMine;

  List<_i3.MessageReceipt> receipts;

  /// Encrypted JPEG poster for a video message. Null for other types.
  int? thumbnailMediaId;

  /// Decrypted poll. Null unless [Message.type] is poll and the message
  /// has not been deleted.
  _i4.PollView? poll;

  /// Returns a shallow copy of this [MessageView]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MessageView copyWith({
    _i2.Message? message,
    String? senderUsername,
    int? senderProfileImageId,
    bool? isMine,
    List<_i3.MessageReceipt>? receipts,
    int? thumbnailMediaId,
    _i4.PollView? poll,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MessageView',
      'message': message.toJson(),
      'senderUsername': senderUsername,
      if (senderProfileImageId != null)
        'senderProfileImageId': senderProfileImageId,
      'isMine': isMine,
      'receipts': receipts.toJson(valueToJson: (v) => v.toJson()),
      if (thumbnailMediaId != null) 'thumbnailMediaId': thumbnailMediaId,
      if (poll != null) 'poll': poll?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MessageViewImpl extends MessageView {
  _MessageViewImpl({
    required _i2.Message message,
    required String senderUsername,
    int? senderProfileImageId,
    required bool isMine,
    required List<_i3.MessageReceipt> receipts,
    int? thumbnailMediaId,
    _i4.PollView? poll,
  }) : super._(
         message: message,
         senderUsername: senderUsername,
         senderProfileImageId: senderProfileImageId,
         isMine: isMine,
         receipts: receipts,
         thumbnailMediaId: thumbnailMediaId,
         poll: poll,
       );

  /// Returns a shallow copy of this [MessageView]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MessageView copyWith({
    _i2.Message? message,
    String? senderUsername,
    Object? senderProfileImageId = _Undefined,
    bool? isMine,
    List<_i3.MessageReceipt>? receipts,
    Object? thumbnailMediaId = _Undefined,
    Object? poll = _Undefined,
  }) {
    return MessageView(
      message: message ?? this.message.copyWith(),
      senderUsername: senderUsername ?? this.senderUsername,
      senderProfileImageId: senderProfileImageId is int?
          ? senderProfileImageId
          : this.senderProfileImageId,
      isMine: isMine ?? this.isMine,
      receipts: receipts ?? this.receipts.map((e0) => e0.copyWith()).toList(),
      thumbnailMediaId: thumbnailMediaId is int?
          ? thumbnailMediaId
          : this.thumbnailMediaId,
      poll: poll is _i4.PollView? ? poll : this.poll?.copyWith(),
    );
  }
}
