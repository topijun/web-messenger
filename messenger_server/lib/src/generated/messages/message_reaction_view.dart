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

/// Aggregated emoji reactions for one message, as seen by the caller.
abstract class MessageReactionView
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  MessageReactionView._({
    required this.emoji,
    required this.count,
    required this.mine,
  });

  factory MessageReactionView({
    required String emoji,
    required int count,
    required bool mine,
  }) = _MessageReactionViewImpl;

  factory MessageReactionView.fromJson(Map<String, dynamic> jsonSerialization) {
    return MessageReactionView(
      emoji: jsonSerialization['emoji'] as String,
      count: jsonSerialization['count'] as int,
      mine: _i1.BoolJsonExtension.fromJson(jsonSerialization['mine']),
    );
  }

  String emoji;

  int count;

  /// True when the caller has this emoji on the message.
  bool mine;

  /// Returns a shallow copy of this [MessageReactionView]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MessageReactionView copyWith({
    String? emoji,
    int? count,
    bool? mine,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MessageReactionView',
      'emoji': emoji,
      'count': count,
      'mine': mine,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MessageReactionView',
      'emoji': emoji,
      'count': count,
      'mine': mine,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _MessageReactionViewImpl extends MessageReactionView {
  _MessageReactionViewImpl({
    required String emoji,
    required int count,
    required bool mine,
  }) : super._(
         emoji: emoji,
         count: count,
         mine: mine,
       );

  /// Returns a shallow copy of this [MessageReactionView]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MessageReactionView copyWith({
    String? emoji,
    int? count,
    bool? mine,
  }) {
    return MessageReactionView(
      emoji: emoji ?? this.emoji,
      count: count ?? this.count,
      mine: mine ?? this.mine,
    );
  }
}
