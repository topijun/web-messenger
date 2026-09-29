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
import 'package:messenger_server/src/generated/protocol.dart' as _i2;

/// One decrypted poll option for the caller.
abstract class PollOptionView
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  PollOptionView._({
    required this.id,
    required this.text,
    required this.position,
    required this.voteCount,
    required this.voters,
  });

  factory PollOptionView({
    required int id,
    required String text,
    required int position,
    required int voteCount,
    required List<String> voters,
  }) = _PollOptionViewImpl;

  factory PollOptionView.fromJson(Map<String, dynamic> jsonSerialization) {
    return PollOptionView(
      id: jsonSerialization['id'] as int,
      text: jsonSerialization['text'] as String,
      position: jsonSerialization['position'] as int,
      voteCount: jsonSerialization['voteCount'] as int,
      voters: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['voters'],
      ),
    );
  }

  int id;

  String text;

  int position;

  int voteCount;

  /// Usernames who voted for this option. Empty when the poll is anonymous.
  List<String> voters;

  /// Returns a shallow copy of this [PollOptionView]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PollOptionView copyWith({
    int? id,
    String? text,
    int? position,
    int? voteCount,
    List<String>? voters,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PollOptionView',
      'id': id,
      'text': text,
      'position': position,
      'voteCount': voteCount,
      'voters': voters.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PollOptionView',
      'id': id,
      'text': text,
      'position': position,
      'voteCount': voteCount,
      'voters': voters.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PollOptionViewImpl extends PollOptionView {
  _PollOptionViewImpl({
    required int id,
    required String text,
    required int position,
    required int voteCount,
    required List<String> voters,
  }) : super._(
         id: id,
         text: text,
         position: position,
         voteCount: voteCount,
         voters: voters,
       );

  /// Returns a shallow copy of this [PollOptionView]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PollOptionView copyWith({
    int? id,
    String? text,
    int? position,
    int? voteCount,
    List<String>? voters,
  }) {
    return PollOptionView(
      id: id ?? this.id,
      text: text ?? this.text,
      position: position ?? this.position,
      voteCount: voteCount ?? this.voteCount,
      voters: voters ?? this.voters.map((e0) => e0).toList(),
    );
  }
}
