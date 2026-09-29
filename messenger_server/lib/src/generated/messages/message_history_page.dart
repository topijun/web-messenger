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
import '../messages/message_view.dart' as _i2;
import 'package:messenger_server/src/generated/protocol.dart' as _i3;

/// A newest-first page of chat history with a cursor for older messages.
abstract class MessageHistoryPage
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  MessageHistoryPage._({
    required this.messages,
    required this.hasMore,
    this.nextCreatedAt,
    this.nextId,
  });

  factory MessageHistoryPage({
    required List<_i2.MessageView> messages,
    required bool hasMore,
    DateTime? nextCreatedAt,
    int? nextId,
  }) = _MessageHistoryPageImpl;

  factory MessageHistoryPage.fromJson(Map<String, dynamic> jsonSerialization) {
    return MessageHistoryPage(
      messages: _i3.Protocol().deserialize<List<_i2.MessageView>>(
        jsonSerialization['messages'],
      ),
      hasMore: _i1.BoolJsonExtension.fromJson(jsonSerialization['hasMore']),
      nextCreatedAt: jsonSerialization['nextCreatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['nextCreatedAt'],
            ),
      nextId: jsonSerialization['nextId'] as int?,
    );
  }

  List<_i2.MessageView> messages;

  bool hasMore;

  DateTime? nextCreatedAt;

  int? nextId;

  /// Returns a shallow copy of this [MessageHistoryPage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MessageHistoryPage copyWith({
    List<_i2.MessageView>? messages,
    bool? hasMore,
    DateTime? nextCreatedAt,
    int? nextId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MessageHistoryPage',
      'messages': messages.toJson(valueToJson: (v) => v.toJson()),
      'hasMore': hasMore,
      if (nextCreatedAt != null) 'nextCreatedAt': nextCreatedAt?.toJson(),
      if (nextId != null) 'nextId': nextId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MessageHistoryPage',
      'messages': messages.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'hasMore': hasMore,
      if (nextCreatedAt != null) 'nextCreatedAt': nextCreatedAt?.toJson(),
      if (nextId != null) 'nextId': nextId,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MessageHistoryPageImpl extends MessageHistoryPage {
  _MessageHistoryPageImpl({
    required List<_i2.MessageView> messages,
    required bool hasMore,
    DateTime? nextCreatedAt,
    int? nextId,
  }) : super._(
         messages: messages,
         hasMore: hasMore,
         nextCreatedAt: nextCreatedAt,
         nextId: nextId,
       );

  /// Returns a shallow copy of this [MessageHistoryPage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MessageHistoryPage copyWith({
    List<_i2.MessageView>? messages,
    bool? hasMore,
    Object? nextCreatedAt = _Undefined,
    Object? nextId = _Undefined,
  }) {
    return MessageHistoryPage(
      messages: messages ?? this.messages.map((e0) => e0.copyWith()).toList(),
      hasMore: hasMore ?? this.hasMore,
      nextCreatedAt: nextCreatedAt is DateTime?
          ? nextCreatedAt
          : this.nextCreatedAt,
      nextId: nextId is int? ? nextId : this.nextId,
    );
  }
}
