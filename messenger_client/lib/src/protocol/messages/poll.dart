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
import '../users/messenger_user.dart' as _i2;
import 'package:messenger_client/src/protocol/protocol.dart' as _i3;

/// A single-choice poll attached to one [Message] through [Message.pollId].
///
/// [question] is AES-256-GCM ciphertext. Clients send and receive plaintext.
abstract class Poll implements _i1.SerializableModel {
  Poll._({
    this.id,
    required this.question,
    bool? anonymous,
    required this.createdById,
    this.createdBy,
    required this.createdAt,
  }) : anonymous = anonymous ?? false;

  factory Poll({
    int? id,
    required String question,
    bool? anonymous,
    required int createdById,
    _i2.MessengerUser? createdBy,
    required DateTime createdAt,
  }) = _PollImpl;

  factory Poll.fromJson(Map<String, dynamic> jsonSerialization) {
    return Poll(
      id: jsonSerialization['id'] as int?,
      question: jsonSerialization['question'] as String,
      anonymous: jsonSerialization['anonymous'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['anonymous']),
      createdById: jsonSerialization['createdById'] as int,
      createdBy: jsonSerialization['createdBy'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.MessengerUser>(
              jsonSerialization['createdBy'],
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

  /// Ciphertext of the poll question.
  String question;

  bool anonymous;

  int createdById;

  _i2.MessengerUser? createdBy;

  DateTime createdAt;

  /// Returns a shallow copy of this [Poll]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Poll copyWith({
    int? id,
    String? question,
    bool? anonymous,
    int? createdById,
    _i2.MessengerUser? createdBy,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Poll',
      if (id != null) 'id': id,
      'question': question,
      'anonymous': anonymous,
      'createdById': createdById,
      if (createdBy != null) 'createdBy': createdBy?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PollImpl extends Poll {
  _PollImpl({
    int? id,
    required String question,
    bool? anonymous,
    required int createdById,
    _i2.MessengerUser? createdBy,
    required DateTime createdAt,
  }) : super._(
         id: id,
         question: question,
         anonymous: anonymous,
         createdById: createdById,
         createdBy: createdBy,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Poll]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Poll copyWith({
    Object? id = _Undefined,
    String? question,
    bool? anonymous,
    int? createdById,
    Object? createdBy = _Undefined,
    DateTime? createdAt,
  }) {
    return Poll(
      id: id is int? ? id : this.id,
      question: question ?? this.question,
      anonymous: anonymous ?? this.anonymous,
      createdById: createdById ?? this.createdById,
      createdBy: createdBy is _i2.MessengerUser?
          ? createdBy
          : this.createdBy?.copyWith(),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
