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

/// Per-recipient delivery and read timestamps for a [Message].
///
/// One row per (message, recipient). The sender does not get a receipt.
abstract class MessageReceipt
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  MessageReceipt._({
    this.id,
    required this.messageId,
    this.message,
    required this.userId,
    this.user,
    this.deliveredAt,
    this.readAt,
  });

  factory MessageReceipt({
    int? id,
    required int messageId,
    _i2.Message? message,
    required int userId,
    _i3.MessengerUser? user,
    DateTime? deliveredAt,
    DateTime? readAt,
  }) = _MessageReceiptImpl;

  factory MessageReceipt.fromJson(Map<String, dynamic> jsonSerialization) {
    return MessageReceipt(
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
      deliveredAt: jsonSerialization['deliveredAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['deliveredAt'],
            ),
      readAt: jsonSerialization['readAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['readAt']),
    );
  }

  static final t = MessageReceiptTable();

  static const db = MessageReceiptRepository._();

  @override
  int? id;

  int messageId;

  _i2.Message? message;

  int userId;

  _i3.MessengerUser? user;

  DateTime? deliveredAt;

  DateTime? readAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [MessageReceipt]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MessageReceipt copyWith({
    int? id,
    int? messageId,
    _i2.Message? message,
    int? userId,
    _i3.MessengerUser? user,
    DateTime? deliveredAt,
    DateTime? readAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MessageReceipt',
      if (id != null) 'id': id,
      'messageId': messageId,
      if (message != null) 'message': message?.toJson(),
      'userId': userId,
      if (user != null) 'user': user?.toJson(),
      if (deliveredAt != null) 'deliveredAt': deliveredAt?.toJson(),
      if (readAt != null) 'readAt': readAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MessageReceipt',
      if (id != null) 'id': id,
      'messageId': messageId,
      if (message != null) 'message': message?.toJsonForProtocol(),
      'userId': userId,
      if (user != null) 'user': user?.toJsonForProtocol(),
      if (deliveredAt != null) 'deliveredAt': deliveredAt?.toJson(),
      if (readAt != null) 'readAt': readAt?.toJson(),
    };
  }

  static MessageReceiptInclude include({
    _i2.MessageInclude? message,
    _i3.MessengerUserInclude? user,
  }) {
    return MessageReceiptInclude._(
      message: message,
      user: user,
    );
  }

  static MessageReceiptIncludeList includeList({
    _i1.WhereExpressionBuilder<MessageReceiptTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MessageReceiptTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MessageReceiptTable>? orderByList,
    MessageReceiptInclude? include,
  }) {
    return MessageReceiptIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MessageReceipt.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(MessageReceipt.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MessageReceiptImpl extends MessageReceipt {
  _MessageReceiptImpl({
    int? id,
    required int messageId,
    _i2.Message? message,
    required int userId,
    _i3.MessengerUser? user,
    DateTime? deliveredAt,
    DateTime? readAt,
  }) : super._(
         id: id,
         messageId: messageId,
         message: message,
         userId: userId,
         user: user,
         deliveredAt: deliveredAt,
         readAt: readAt,
       );

  /// Returns a shallow copy of this [MessageReceipt]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MessageReceipt copyWith({
    Object? id = _Undefined,
    int? messageId,
    Object? message = _Undefined,
    int? userId,
    Object? user = _Undefined,
    Object? deliveredAt = _Undefined,
    Object? readAt = _Undefined,
  }) {
    return MessageReceipt(
      id: id is int? ? id : this.id,
      messageId: messageId ?? this.messageId,
      message: message is _i2.Message? ? message : this.message?.copyWith(),
      userId: userId ?? this.userId,
      user: user is _i3.MessengerUser? ? user : this.user?.copyWith(),
      deliveredAt: deliveredAt is DateTime? ? deliveredAt : this.deliveredAt,
      readAt: readAt is DateTime? ? readAt : this.readAt,
    );
  }
}

class MessageReceiptUpdateTable extends _i1.UpdateTable<MessageReceiptTable> {
  MessageReceiptUpdateTable(super.table);

  _i1.ColumnValue<int, int> messageId(int value) => _i1.ColumnValue(
    table.messageId,
    value,
  );

  _i1.ColumnValue<int, int> userId(int value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> deliveredAt(DateTime? value) =>
      _i1.ColumnValue(
        table.deliveredAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> readAt(DateTime? value) =>
      _i1.ColumnValue(
        table.readAt,
        value,
      );
}

class MessageReceiptTable extends _i1.Table<int?> {
  MessageReceiptTable({super.tableRelation})
    : super(tableName: 'messenger_message_receipt') {
    updateTable = MessageReceiptUpdateTable(this);
    messageId = _i1.ColumnInt(
      'messageId',
      this,
    );
    userId = _i1.ColumnInt(
      'userId',
      this,
    );
    deliveredAt = _i1.ColumnDateTime(
      'deliveredAt',
      this,
    );
    readAt = _i1.ColumnDateTime(
      'readAt',
      this,
    );
  }

  late final MessageReceiptUpdateTable updateTable;

  late final _i1.ColumnInt messageId;

  _i2.MessageTable? _message;

  late final _i1.ColumnInt userId;

  _i3.MessengerUserTable? _user;

  late final _i1.ColumnDateTime deliveredAt;

  late final _i1.ColumnDateTime readAt;

  _i2.MessageTable get message {
    if (_message != null) return _message!;
    _message = _i1.createRelationTable(
      relationFieldName: 'message',
      field: MessageReceipt.t.messageId,
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
      field: MessageReceipt.t.userId,
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
    deliveredAt,
    readAt,
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

class MessageReceiptInclude extends _i1.IncludeObject {
  MessageReceiptInclude._({
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
  _i1.Table<int?> get table => MessageReceipt.t;
}

class MessageReceiptIncludeList extends _i1.IncludeList {
  MessageReceiptIncludeList._({
    _i1.WhereExpressionBuilder<MessageReceiptTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MessageReceipt.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => MessageReceipt.t;
}

class MessageReceiptRepository {
  const MessageReceiptRepository._();

  final attachRow = const MessageReceiptAttachRowRepository._();

  /// Returns a list of [MessageReceipt]s matching the given query parameters.
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
  Future<List<MessageReceipt>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MessageReceiptTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MessageReceiptTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MessageReceiptTable>? orderByList,
    _i1.Transaction? transaction,
    MessageReceiptInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MessageReceipt>(
      where: where?.call(MessageReceipt.t),
      orderBy: orderBy?.call(MessageReceipt.t),
      orderByList: orderByList?.call(MessageReceipt.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MessageReceipt] matching the given query parameters.
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
  Future<MessageReceipt?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MessageReceiptTable>? where,
    int? offset,
    _i1.OrderByBuilder<MessageReceiptTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MessageReceiptTable>? orderByList,
    _i1.Transaction? transaction,
    MessageReceiptInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MessageReceipt>(
      where: where?.call(MessageReceipt.t),
      orderBy: orderBy?.call(MessageReceipt.t),
      orderByList: orderByList?.call(MessageReceipt.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MessageReceipt] by its [id] or null if no such row exists.
  Future<MessageReceipt?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    MessageReceiptInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MessageReceipt>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MessageReceipt]s in the list and returns the inserted rows.
  ///
  /// The returned [MessageReceipt]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<MessageReceipt>> insert(
    _i1.DatabaseSession session,
    List<MessageReceipt> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<MessageReceipt>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [MessageReceipt] and returns the inserted row.
  ///
  /// The returned [MessageReceipt] will have its `id` field set.
  Future<MessageReceipt> insertRow(
    _i1.DatabaseSession session,
    MessageReceipt row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<MessageReceipt>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [MessageReceipt]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<MessageReceipt>> update(
    _i1.DatabaseSession session,
    List<MessageReceipt> rows, {
    _i1.ColumnSelections<MessageReceiptTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<MessageReceipt>(
      rows,
      columns: columns?.call(MessageReceipt.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MessageReceipt]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MessageReceipt> updateRow(
    _i1.DatabaseSession session,
    MessageReceipt row, {
    _i1.ColumnSelections<MessageReceiptTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<MessageReceipt>(
      row,
      columns: columns?.call(MessageReceipt.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MessageReceipt] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MessageReceipt?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<MessageReceiptUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<MessageReceipt>(
      id,
      columnValues: columnValues(MessageReceipt.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MessageReceipt]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<MessageReceipt>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<MessageReceiptUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<MessageReceiptTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MessageReceiptTable>? orderBy,
    _i1.OrderByListBuilder<MessageReceiptTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<MessageReceipt>(
      columnValues: columnValues(MessageReceipt.t.updateTable),
      where: where(MessageReceipt.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MessageReceipt.t),
      orderByList: orderByList?.call(MessageReceipt.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [MessageReceipt]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<MessageReceipt>> delete(
    _i1.DatabaseSession session,
    List<MessageReceipt> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<MessageReceipt>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [MessageReceipt].
  Future<MessageReceipt> deleteRow(
    _i1.DatabaseSession session,
    MessageReceipt row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MessageReceipt>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<MessageReceipt>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MessageReceiptTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<MessageReceipt>(
      where: where(MessageReceipt.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MessageReceiptTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<MessageReceipt>(
      where: where?.call(MessageReceipt.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MessageReceipt] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MessageReceiptTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MessageReceipt>(
      where: where(MessageReceipt.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class MessageReceiptAttachRowRepository {
  const MessageReceiptAttachRowRepository._();

  /// Creates a relation between the given [MessageReceipt] and [Message]
  /// by setting the [MessageReceipt]'s foreign key `messageId` to refer to the [Message].
  Future<void> message(
    _i1.DatabaseSession session,
    MessageReceipt messageReceipt,
    _i2.Message message, {
    _i1.Transaction? transaction,
  }) async {
    if (messageReceipt.id == null) {
      throw ArgumentError.notNull('messageReceipt.id');
    }
    if (message.id == null) {
      throw ArgumentError.notNull('message.id');
    }

    var $messageReceipt = messageReceipt.copyWith(messageId: message.id);
    await session.db.updateRow<MessageReceipt>(
      $messageReceipt,
      columns: [MessageReceipt.t.messageId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [MessageReceipt] and [MessengerUser]
  /// by setting the [MessageReceipt]'s foreign key `userId` to refer to the [MessengerUser].
  Future<void> user(
    _i1.DatabaseSession session,
    MessageReceipt messageReceipt,
    _i3.MessengerUser user, {
    _i1.Transaction? transaction,
  }) async {
    if (messageReceipt.id == null) {
      throw ArgumentError.notNull('messageReceipt.id');
    }
    if (user.id == null) {
      throw ArgumentError.notNull('user.id');
    }

    var $messageReceipt = messageReceipt.copyWith(userId: user.id);
    await session.db.updateRow<MessageReceipt>(
      $messageReceipt,
      columns: [MessageReceipt.t.userId],
      transaction: transaction,
    );
  }
}
