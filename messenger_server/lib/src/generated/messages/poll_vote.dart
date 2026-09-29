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
// ignore_for_file: unnecessary_null_comparison

import 'package:serverpod/serverpod.dart' as _i1;
import '../messages/poll.dart' as _i2;
import '../messages/poll_option.dart' as _i3;
import '../users/messenger_user.dart' as _i4;
import 'package:messenger_server/src/generated/protocol.dart' as _i5;

/// One user's active vote. Absence of a row means the user has not voted.
///
/// [userId] is stored for anonymous polls too, so the voter can change or
/// retract. Anonymous polls omit voter names from client views.
abstract class PollVote
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = PollVoteTable();

  static const db = PollVoteRepository._();

  @override
  int? id;

  int pollId;

  _i2.Poll? poll;

  int optionId;

  _i3.PollOption? option;

  int userId;

  _i4.MessengerUser? user;

  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PollVote',
      if (id != null) 'id': id,
      'pollId': pollId,
      if (poll != null) 'poll': poll?.toJsonForProtocol(),
      'optionId': optionId,
      if (option != null) 'option': option?.toJsonForProtocol(),
      'userId': userId,
      if (user != null) 'user': user?.toJsonForProtocol(),
      'createdAt': createdAt.toJson(),
    };
  }

  static PollVoteInclude include({
    _i2.PollInclude? poll,
    _i3.PollOptionInclude? option,
    _i4.MessengerUserInclude? user,
  }) {
    return PollVoteInclude._(
      poll: poll,
      option: option,
      user: user,
    );
  }

  static PollVoteIncludeList includeList({
    _i1.WhereExpressionBuilder<PollVoteTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PollVoteTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PollVoteTable>? orderByList,
    PollVoteInclude? include,
  }) {
    return PollVoteIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PollVote.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(PollVote.t),
      include: include,
    );
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

class PollVoteUpdateTable extends _i1.UpdateTable<PollVoteTable> {
  PollVoteUpdateTable(super.table);

  _i1.ColumnValue<int, int> pollId(int value) => _i1.ColumnValue(
    table.pollId,
    value,
  );

  _i1.ColumnValue<int, int> optionId(int value) => _i1.ColumnValue(
    table.optionId,
    value,
  );

  _i1.ColumnValue<int, int> userId(int value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class PollVoteTable extends _i1.Table<int?> {
  PollVoteTable({super.tableRelation})
    : super(tableName: 'messenger_poll_vote') {
    updateTable = PollVoteUpdateTable(this);
    pollId = _i1.ColumnInt(
      'pollId',
      this,
    );
    optionId = _i1.ColumnInt(
      'optionId',
      this,
    );
    userId = _i1.ColumnInt(
      'userId',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final PollVoteUpdateTable updateTable;

  late final _i1.ColumnInt pollId;

  _i2.PollTable? _poll;

  late final _i1.ColumnInt optionId;

  _i3.PollOptionTable? _option;

  late final _i1.ColumnInt userId;

  _i4.MessengerUserTable? _user;

  late final _i1.ColumnDateTime createdAt;

  _i2.PollTable get poll {
    if (_poll != null) return _poll!;
    _poll = _i1.createRelationTable(
      relationFieldName: 'poll',
      field: PollVote.t.pollId,
      foreignField: _i2.Poll.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.PollTable(tableRelation: foreignTableRelation),
    );
    return _poll!;
  }

  _i3.PollOptionTable get option {
    if (_option != null) return _option!;
    _option = _i1.createRelationTable(
      relationFieldName: 'option',
      field: PollVote.t.optionId,
      foreignField: _i3.PollOption.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i3.PollOptionTable(tableRelation: foreignTableRelation),
    );
    return _option!;
  }

  _i4.MessengerUserTable get user {
    if (_user != null) return _user!;
    _user = _i1.createRelationTable(
      relationFieldName: 'user',
      field: PollVote.t.userId,
      foreignField: _i4.MessengerUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i4.MessengerUserTable(tableRelation: foreignTableRelation),
    );
    return _user!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    pollId,
    optionId,
    userId,
    createdAt,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'poll') {
      return poll;
    }
    if (relationField == 'option') {
      return option;
    }
    if (relationField == 'user') {
      return user;
    }
    return null;
  }
}

class PollVoteInclude extends _i1.IncludeObject {
  PollVoteInclude._({
    _i2.PollInclude? poll,
    _i3.PollOptionInclude? option,
    _i4.MessengerUserInclude? user,
  }) {
    _poll = poll;
    _option = option;
    _user = user;
  }

  _i2.PollInclude? _poll;

  _i3.PollOptionInclude? _option;

  _i4.MessengerUserInclude? _user;

  @override
  Map<String, _i1.Include?> get includes => {
    'poll': _poll,
    'option': _option,
    'user': _user,
  };

  @override
  _i1.Table<int?> get table => PollVote.t;
}

class PollVoteIncludeList extends _i1.IncludeList {
  PollVoteIncludeList._({
    _i1.WhereExpressionBuilder<PollVoteTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PollVote.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => PollVote.t;
}

class PollVoteRepository {
  const PollVoteRepository._();

  final attachRow = const PollVoteAttachRowRepository._();

  /// Returns a list of [PollVote]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<PollVote>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PollVoteTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PollVoteTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PollVoteTable>? orderByList,
    _i1.Transaction? transaction,
    PollVoteInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PollVote>(
      where: where?.call(PollVote.t),
      orderBy: orderBy?.call(PollVote.t),
      orderByList: orderByList?.call(PollVote.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PollVote] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<PollVote?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PollVoteTable>? where,
    int? offset,
    _i1.OrderByBuilder<PollVoteTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PollVoteTable>? orderByList,
    _i1.Transaction? transaction,
    PollVoteInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PollVote>(
      where: where?.call(PollVote.t),
      orderBy: orderBy?.call(PollVote.t),
      orderByList: orderByList?.call(PollVote.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PollVote] by its [id] or null if no such row exists.
  Future<PollVote?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    PollVoteInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PollVote>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PollVote]s in the list and returns the inserted rows.
  ///
  /// The returned [PollVote]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<PollVote>> insert(
    _i1.DatabaseSession session,
    List<PollVote> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<PollVote>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [PollVote] and returns the inserted row.
  ///
  /// The returned [PollVote] will have its `id` field set.
  Future<PollVote> insertRow(
    _i1.DatabaseSession session,
    PollVote row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PollVote>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PollVote]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PollVote>> update(
    _i1.DatabaseSession session,
    List<PollVote> rows, {
    _i1.ColumnSelections<PollVoteTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PollVote>(
      rows,
      columns: columns?.call(PollVote.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PollVote]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PollVote> updateRow(
    _i1.DatabaseSession session,
    PollVote row, {
    _i1.ColumnSelections<PollVoteTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<PollVote>(
      row,
      columns: columns?.call(PollVote.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PollVote] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PollVote?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<PollVoteUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<PollVote>(
      id,
      columnValues: columnValues(PollVote.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PollVote]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<PollVote>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<PollVoteUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<PollVoteTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PollVoteTable>? orderBy,
    _i1.OrderByListBuilder<PollVoteTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<PollVote>(
      columnValues: columnValues(PollVote.t.updateTable),
      where: where(PollVote.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PollVote.t),
      orderByList: orderByList?.call(PollVote.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [PollVote]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PollVote>> delete(
    _i1.DatabaseSession session,
    List<PollVote> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PollVote>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [PollVote].
  Future<PollVote> deleteRow(
    _i1.DatabaseSession session,
    PollVote row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PollVote>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<PollVote>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PollVoteTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PollVote>(
      where: where(PollVote.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PollVoteTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PollVote>(
      where: where?.call(PollVote.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PollVote] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PollVoteTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PollVote>(
      where: where(PollVote.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class PollVoteAttachRowRepository {
  const PollVoteAttachRowRepository._();

  /// Creates a relation between the given [PollVote] and [Poll]
  /// by setting the [PollVote]'s foreign key `pollId` to refer to the [Poll].
  Future<void> poll(
    _i1.DatabaseSession session,
    PollVote pollVote,
    _i2.Poll poll, {
    _i1.Transaction? transaction,
  }) async {
    if (pollVote.id == null) {
      throw ArgumentError.notNull('pollVote.id');
    }
    if (poll.id == null) {
      throw ArgumentError.notNull('poll.id');
    }

    var $pollVote = pollVote.copyWith(pollId: poll.id);
    await session.db.updateRow<PollVote>(
      $pollVote,
      columns: [PollVote.t.pollId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [PollVote] and [PollOption]
  /// by setting the [PollVote]'s foreign key `optionId` to refer to the [PollOption].
  Future<void> option(
    _i1.DatabaseSession session,
    PollVote pollVote,
    _i3.PollOption option, {
    _i1.Transaction? transaction,
  }) async {
    if (pollVote.id == null) {
      throw ArgumentError.notNull('pollVote.id');
    }
    if (option.id == null) {
      throw ArgumentError.notNull('option.id');
    }

    var $pollVote = pollVote.copyWith(optionId: option.id);
    await session.db.updateRow<PollVote>(
      $pollVote,
      columns: [PollVote.t.optionId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [PollVote] and [MessengerUser]
  /// by setting the [PollVote]'s foreign key `userId` to refer to the [MessengerUser].
  Future<void> user(
    _i1.DatabaseSession session,
    PollVote pollVote,
    _i4.MessengerUser user, {
    _i1.Transaction? transaction,
  }) async {
    if (pollVote.id == null) {
      throw ArgumentError.notNull('pollVote.id');
    }
    if (user.id == null) {
      throw ArgumentError.notNull('user.id');
    }

    var $pollVote = pollVote.copyWith(userId: user.id);
    await session.db.updateRow<PollVote>(
      $pollVote,
      columns: [PollVote.t.userId],
      transaction: transaction,
    );
  }
}
