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
import '../messages/message.dart' as _i2;
import '../users/messenger_user.dart' as _i3;
import 'package:messenger_server/src/generated/protocol.dart' as _i4;

/// One user's emoji on a message.
///
/// One row per (message, user, emoji). Counts are derived from these rows.
/// The emoji is metadata, not message text, and is not encrypted.
abstract class MessageReaction
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  MessageReaction._({
    this.id,
    required this.messageId,
    this.message,
    required this.userId,
    this.user,
    required this.emoji,
    required this.createdAt,
  });

  factory MessageReaction({
    int? id,
    required int messageId,
    _i2.Message? message,
    required int userId,
    _i3.MessengerUser? user,
    required String emoji,
    required DateTime createdAt,
  }) = _MessageReactionImpl;

  factory MessageReaction.fromJson(Map<String, dynamic> jsonSerialization) {
    return MessageReaction(
      id: jsonSerialization['id'] as int?,
      messageId: jsonSerialization['messageId'] as int,
      message: jsonSerialization['message'] == null
          ? null
          : _i4.Protocol().deserialize<_i2.Message>(
              jsonSerialization['message'],
            ),
      userId: jsonSerialization['userId'] as int,
      user: jsonSerialization['user'] == null
          ? null
          : _i4.Protocol().deserialize<_i3.MessengerUser>(
              jsonSerialization['user'],
            ),
      emoji: jsonSerialization['emoji'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = MessageReactionTable();

  static const db = MessageReactionRepository._();

  @override
  int? id;

  int messageId;

  _i2.Message? message;

  int userId;

  _i3.MessengerUser? user;

  String emoji;

  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [MessageReaction]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MessageReaction copyWith({
    int? id,
    int? messageId,
    _i2.Message? message,
    int? userId,
    _i3.MessengerUser? user,
    String? emoji,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MessageReaction',
      if (id != null) 'id': id,
      'messageId': messageId,
      if (message != null) 'message': message?.toJson(),
      'userId': userId,
      if (user != null) 'user': user?.toJson(),
      'emoji': emoji,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MessageReaction',
      if (id != null) 'id': id,
      'messageId': messageId,
      if (message != null) 'message': message?.toJsonForProtocol(),
      'userId': userId,
      if (user != null) 'user': user?.toJsonForProtocol(),
      'emoji': emoji,
      'createdAt': createdAt.toJson(),
    };
  }

  static MessageReactionInclude include({
    _i2.MessageInclude? message,
    _i3.MessengerUserInclude? user,
  }) {
    return MessageReactionInclude._(
      message: message,
      user: user,
    );
  }

  static MessageReactionIncludeList includeList({
    _i1.WhereExpressionBuilder<MessageReactionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MessageReactionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MessageReactionTable>? orderByList,
    MessageReactionInclude? include,
  }) {
    return MessageReactionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MessageReaction.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(MessageReaction.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MessageReactionImpl extends MessageReaction {
  _MessageReactionImpl({
    int? id,
    required int messageId,
    _i2.Message? message,
    required int userId,
    _i3.MessengerUser? user,
    required String emoji,
    required DateTime createdAt,
  }) : super._(
         id: id,
         messageId: messageId,
         message: message,
         userId: userId,
         user: user,
         emoji: emoji,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [MessageReaction]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MessageReaction copyWith({
    Object? id = _Undefined,
    int? messageId,
    Object? message = _Undefined,
    int? userId,
    Object? user = _Undefined,
    String? emoji,
    DateTime? createdAt,
  }) {
    return MessageReaction(
      id: id is int? ? id : this.id,
      messageId: messageId ?? this.messageId,
      message: message is _i2.Message? ? message : this.message?.copyWith(),
      userId: userId ?? this.userId,
      user: user is _i3.MessengerUser? ? user : this.user?.copyWith(),
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MessageReactionUpdateTable extends _i1.UpdateTable<MessageReactionTable> {
  MessageReactionUpdateTable(super.table);

  _i1.ColumnValue<int, int> messageId(int value) => _i1.ColumnValue(
    table.messageId,
    value,
  );

  _i1.ColumnValue<int, int> userId(int value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<String, String> emoji(String value) => _i1.ColumnValue(
    table.emoji,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class MessageReactionTable extends _i1.Table<int?> {
  MessageReactionTable({super.tableRelation})
    : super(tableName: 'messenger_message_reaction') {
    updateTable = MessageReactionUpdateTable(this);
    messageId = _i1.ColumnInt(
      'messageId',
      this,
    );
    userId = _i1.ColumnInt(
      'userId',
      this,
    );
    emoji = _i1.ColumnString(
      'emoji',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final MessageReactionUpdateTable updateTable;

  late final _i1.ColumnInt messageId;

  _i2.MessageTable? _message;

  late final _i1.ColumnInt userId;

  _i3.MessengerUserTable? _user;

  late final _i1.ColumnString emoji;

  late final _i1.ColumnDateTime createdAt;

  _i2.MessageTable get message {
    if (_message != null) return _message!;
    _message = _i1.createRelationTable(
      relationFieldName: 'message',
      field: MessageReaction.t.messageId,
      foreignField: _i2.Message.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.MessageTable(tableRelation: foreignTableRelation),
    );
    return _message!;
  }

  _i3.MessengerUserTable get user {
    if (_user != null) return _user!;
    _user = _i1.createRelationTable(
      relationFieldName: 'user',
      field: MessageReaction.t.userId,
      foreignField: _i3.MessengerUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i3.MessengerUserTable(tableRelation: foreignTableRelation),
    );
    return _user!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    messageId,
    userId,
    emoji,
    createdAt,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'message') {
      return message;
    }
    if (relationField == 'user') {
      return user;
    }
    return null;
  }
}

class MessageReactionInclude extends _i1.IncludeObject {
  MessageReactionInclude._({
    _i2.MessageInclude? message,
    _i3.MessengerUserInclude? user,
  }) {
    _message = message;
    _user = user;
  }

  _i2.MessageInclude? _message;

  _i3.MessengerUserInclude? _user;

  @override
  Map<String, _i1.Include?> get includes => {
    'message': _message,
    'user': _user,
  };

  @override
  _i1.Table<int?> get table => MessageReaction.t;
}

class MessageReactionIncludeList extends _i1.IncludeList {
  MessageReactionIncludeList._({
    _i1.WhereExpressionBuilder<MessageReactionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MessageReaction.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => MessageReaction.t;
}

class MessageReactionRepository {
  const MessageReactionRepository._();

  final attachRow = const MessageReactionAttachRowRepository._();

  /// Returns a list of [MessageReaction]s matching the given query parameters.
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
  Future<List<MessageReaction>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MessageReactionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MessageReactionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MessageReactionTable>? orderByList,
    _i1.Transaction? transaction,
    MessageReactionInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MessageReaction>(
      where: where?.call(MessageReaction.t),
      orderBy: orderBy?.call(MessageReaction.t),
      orderByList: orderByList?.call(MessageReaction.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MessageReaction] matching the given query parameters.
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
  Future<MessageReaction?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MessageReactionTable>? where,
    int? offset,
    _i1.OrderByBuilder<MessageReactionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MessageReactionTable>? orderByList,
    _i1.Transaction? transaction,
    MessageReactionInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MessageReaction>(
      where: where?.call(MessageReaction.t),
      orderBy: orderBy?.call(MessageReaction.t),
      orderByList: orderByList?.call(MessageReaction.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MessageReaction] by its [id] or null if no such row exists.
  Future<MessageReaction?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    MessageReactionInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MessageReaction>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MessageReaction]s in the list and returns the inserted rows.
  ///
  /// The returned [MessageReaction]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<MessageReaction>> insert(
    _i1.DatabaseSession session,
    List<MessageReaction> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<MessageReaction>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [MessageReaction] and returns the inserted row.
  ///
  /// The returned [MessageReaction] will have its `id` field set.
  Future<MessageReaction> insertRow(
    _i1.DatabaseSession session,
    MessageReaction row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<MessageReaction>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [MessageReaction]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<MessageReaction>> update(
    _i1.DatabaseSession session,
    List<MessageReaction> rows, {
    _i1.ColumnSelections<MessageReactionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<MessageReaction>(
      rows,
      columns: columns?.call(MessageReaction.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MessageReaction]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MessageReaction> updateRow(
    _i1.DatabaseSession session,
    MessageReaction row, {
    _i1.ColumnSelections<MessageReactionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<MessageReaction>(
      row,
      columns: columns?.call(MessageReaction.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MessageReaction] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MessageReaction?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<MessageReactionUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<MessageReaction>(
      id,
      columnValues: columnValues(MessageReaction.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MessageReaction]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<MessageReaction>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<MessageReactionUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<MessageReactionTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MessageReactionTable>? orderBy,
    _i1.OrderByListBuilder<MessageReactionTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<MessageReaction>(
      columnValues: columnValues(MessageReaction.t.updateTable),
      where: where(MessageReaction.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MessageReaction.t),
      orderByList: orderByList?.call(MessageReaction.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [MessageReaction]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<MessageReaction>> delete(
    _i1.DatabaseSession session,
    List<MessageReaction> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<MessageReaction>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [MessageReaction].
  Future<MessageReaction> deleteRow(
    _i1.DatabaseSession session,
    MessageReaction row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MessageReaction>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<MessageReaction>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MessageReactionTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<MessageReaction>(
      where: where(MessageReaction.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MessageReactionTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<MessageReaction>(
      where: where?.call(MessageReaction.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MessageReaction] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MessageReactionTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MessageReaction>(
      where: where(MessageReaction.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class MessageReactionAttachRowRepository {
  const MessageReactionAttachRowRepository._();

  /// Creates a relation between the given [MessageReaction] and [Message]
  /// by setting the [MessageReaction]'s foreign key `messageId` to refer to the [Message].
  Future<void> message(
    _i1.DatabaseSession session,
    MessageReaction messageReaction,
    _i2.Message message, {
    _i1.Transaction? transaction,
  }) async {
    if (messageReaction.id == null) {
      throw ArgumentError.notNull('messageReaction.id');
    }
    if (message.id == null) {
      throw ArgumentError.notNull('message.id');
    }

    var $messageReaction = messageReaction.copyWith(messageId: message.id);
    await session.db.updateRow<MessageReaction>(
      $messageReaction,
      columns: [MessageReaction.t.messageId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [MessageReaction] and [MessengerUser]
  /// by setting the [MessageReaction]'s foreign key `userId` to refer to the [MessengerUser].
  Future<void> user(
    _i1.DatabaseSession session,
    MessageReaction messageReaction,
    _i3.MessengerUser user, {
    _i1.Transaction? transaction,
  }) async {
    if (messageReaction.id == null) {
      throw ArgumentError.notNull('messageReaction.id');
    }
    if (user.id == null) {
      throw ArgumentError.notNull('user.id');
    }

    var $messageReaction = messageReaction.copyWith(userId: user.id);
    await session.db.updateRow<MessageReaction>(
      $messageReaction,
      columns: [MessageReaction.t.userId],
      transaction: transaction,
    );
  }
}
