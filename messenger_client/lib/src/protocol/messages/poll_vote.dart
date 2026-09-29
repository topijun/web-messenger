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
import '../messages/poll_option.dart' as _i3;
import '../users/messenger_user.dart' as _i4;
import 'package:messenger_client/src/protocol/protocol.dart' as _i5;

/// One user's active vote. Absence of a row means the user has not voted.
///
/// [userId] is stored for anonymous polls too, so the voter can change or
/// retract. Anonymous polls omit voter names from client views.
abstract class PollVote implements _i1.SerializableModel {
  PollVote._({
    this.id,
    required this.pollId,
    this.poll,
    required this.optionId,
    this.option,
    required this.userId,
    this.user,
    required this.createdAt,
  });

  factory PollVote({
    int? id,
    required int pollId,
    _i2.Poll? poll,
    required int optionId,
    _i3.PollOption? option,
    required int userId,
    _i4.MessengerUser? user,
    required DateTime createdAt,
  }) = _PollVoteImpl;

  factory PollVote.fromJson(Map<String, dynamic> jsonSerialization) {
    return PollVote(
      id: jsonSerialization['id'] as int?,
      pollId: jsonSerialization['pollId'] as int,
      poll: jsonSerialization['poll'] == null
          ? null
          : _i5.Protocol().deserialize<_i2.Poll>(jsonSerialization['poll']),
      optionId: jsonSerialization['optionId'] as int,
      option: jsonSerialization['option'] == null
          ? null
          : _i5.Protocol().deserialize<_i3.PollOption>(
              jsonSerialization['option'],
            ),
      userId: jsonSerialization['userId'] as int,
      user: jsonSerialization['user'] == null
          ? null
          : _i5.Protocol().deserialize<_i4.MessengerUser>(
              jsonSerialization['user'],
            ),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int pollId;

  _i2.Poll? poll;

  int optionId;

  _i3.PollOption? option;

  int userId;

  _i4.MessengerUser? user;

  DateTime createdAt;

  /// Returns a shallow copy of this [PollVote]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PollVote copyWith({
    int? id,
    int? pollId,
    _i2.Poll? poll,
    int? optionId,
    _i3.PollOption? option,
    int? userId,
    _i4.MessengerUser? user,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PollVote',
      if (id != null) 'id': id,
      'pollId': pollId,
      if (poll != null) 'poll': poll?.toJson(),
      'optionId': optionId,
      if (option != null) 'option': option?.toJson(),
      'userId': userId,
      if (user != null) 'user': user?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PollVoteImpl extends PollVote {
  _PollVoteImpl({
    int? id,
    required int pollId,
    _i2.Poll? poll,
    required int optionId,
    _i3.PollOption? option,
    required int userId,
    _i4.MessengerUser? user,
    required DateTime createdAt,
  }) : super._(
         id: id,
         pollId: pollId,
         poll: poll,
         optionId: optionId,
         option: option,
         userId: userId,
         user: user,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [PollVote]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PollVote copyWith({
    Object? id = _Undefined,
    int? pollId,
    Object? poll = _Undefined,
    int? optionId,
    Object? option = _Undefined,
    int? userId,
    Object? user = _Undefined,
    DateTime? createdAt,
  }) {
    return PollVote(
      id: id is int? ? id : this.id,
      pollId: pollId ?? this.pollId,
      poll: poll is _i2.Poll? ? poll : this.poll?.copyWith(),
      optionId: optionId ?? this.optionId,
      option: option is _i3.PollOption? ? option : this.option?.copyWith(),
      userId: userId ?? this.userId,
      user: user is _i4.MessengerUser? ? user : this.user?.copyWith(),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
