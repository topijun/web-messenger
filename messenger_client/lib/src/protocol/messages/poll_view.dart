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
import '../messages/poll_option_view.dart' as _i2;
import 'package:messenger_client/src/protocol/protocol.dart' as _i3;

/// Decrypted poll attached to a [MessageView].
///
/// [myOptionId] is the caller's own vote. Other voters' identities are
/// included only when [anonymous] is false.
abstract class PollView implements _i1.SerializableModel {
  PollView._({
    required this.id,
    required this.question,
    required this.anonymous,
    required this.options,
    required this.totalVotes,
    this.myOptionId,
  });

  factory PollView({
    required int id,
    required String question,
    required bool anonymous,
    required List<_i2.PollOptionView> options,
    required int totalVotes,
    int? myOptionId,
  }) = _PollViewImpl;

  factory PollView.fromJson(Map<String, dynamic> jsonSerialization) {
    return PollView(
      id: jsonSerialization['id'] as int,
      question: jsonSerialization['question'] as String,
      anonymous: _i1.BoolJsonExtension.fromJson(jsonSerialization['anonymous']),
      options: _i3.Protocol().deserialize<List<_i2.PollOptionView>>(
        jsonSerialization['options'],
      ),
      totalVotes: jsonSerialization['totalVotes'] as int,
      myOptionId: jsonSerialization['myOptionId'] as int?,
    );
  }

  int id;

  String question;

  bool anonymous;

  List<_i2.PollOptionView> options;

  int totalVotes;

  int? myOptionId;

  /// Returns a shallow copy of this [PollView]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PollView copyWith({
    int? id,
    String? question,
    bool? anonymous,
    List<_i2.PollOptionView>? options,
    int? totalVotes,
    int? myOptionId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PollView',
      'id': id,
      'question': question,
      'anonymous': anonymous,
      'options': options.toJson(valueToJson: (v) => v.toJson()),
      'totalVotes': totalVotes,
      if (myOptionId != null) 'myOptionId': myOptionId,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PollViewImpl extends PollView {
  _PollViewImpl({
    required int id,
    required String question,
    required bool anonymous,
    required List<_i2.PollOptionView> options,
    required int totalVotes,
    int? myOptionId,
  }) : super._(
         id: id,
         question: question,
         anonymous: anonymous,
         options: options,
         totalVotes: totalVotes,
         myOptionId: myOptionId,
       );

  /// Returns a shallow copy of this [PollView]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PollView copyWith({
    int? id,
    String? question,
    bool? anonymous,
    List<_i2.PollOptionView>? options,
    int? totalVotes,
    Object? myOptionId = _Undefined,
  }) {
    return PollView(
      id: id ?? this.id,
      question: question ?? this.question,
      anonymous: anonymous ?? this.anonymous,
      options: options ?? this.options.map((e0) => e0.copyWith()).toList(),
      totalVotes: totalVotes ?? this.totalVotes,
      myOptionId: myOptionId is int? ? myOptionId : this.myOptionId,
    );
  }
}
