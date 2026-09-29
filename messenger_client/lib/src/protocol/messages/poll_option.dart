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
import '../messages/poll.dart' as _i2;
import 'package:messenger_client/src/protocol/protocol.dart' as _i3;

/// One answer on a [Poll]. [text] is AES-256-GCM ciphertext.
abstract class PollOption implements _i1.SerializableModel {
  PollOption._({
    this.id,
    required this.pollId,
    this.poll,
    required this.text,
    required this.position,
  });

  factory PollOption({
    int? id,
    required int pollId,
    _i2.Poll? poll,
    required String text,
    required int position,
  }) = _PollOptionImpl;

  factory PollOption.fromJson(Map<String, dynamic> jsonSerialization) {
    return PollOption(
      id: jsonSerialization['id'] as int?,
      pollId: jsonSerialization['pollId'] as int,
      poll: jsonSerialization['poll'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.Poll>(jsonSerialization['poll']),
      text: jsonSerialization['text'] as String,
      position: jsonSerialization['position'] as int,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int pollId;

  _i2.Poll? poll;

  /// Ciphertext of the option label.
  String text;

  int position;

  /// Returns a shallow copy of this [PollOption]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PollOption copyWith({
    int? id,
    int? pollId,
    _i2.Poll? poll,
    String? text,
    int? position,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PollOption',
      if (id != null) 'id': id,
      'pollId': pollId,
      if (poll != null) 'poll': poll?.toJson(),
      'text': text,
      'position': position,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PollOptionImpl extends PollOption {
  _PollOptionImpl({
    int? id,
    required int pollId,
    _i2.Poll? poll,
    required String text,
    required int position,
  }) : super._(
         id: id,
         pollId: pollId,
         poll: poll,
         text: text,
         position: position,
       );

  /// Returns a shallow copy of this [PollOption]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PollOption copyWith({
    Object? id = _Undefined,
    int? pollId,
    Object? poll = _Undefined,
    String? text,
    int? position,
  }) {
    return PollOption(
      id: id is int? ? id : this.id,
      pollId: pollId ?? this.pollId,
      poll: poll is _i2.Poll? ? poll : this.poll?.copyWith(),
      text: text ?? this.text,
      position: position ?? this.position,
    );
  }
}
