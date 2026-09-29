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
import '../chats/chat_type.dart' as _i2;

/// A direct or group conversation.
abstract class Chat implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Chat._({
    this.id,
    required this.type,
    this.name,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.lastMessageAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Chat({
    int? id,
    required _i2.ChatType type,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastMessageAt,
  }) = _ChatImpl;

  factory Chat.fromJson(Map<String, dynamic> jsonSerialization) {
    return Chat(
      id: jsonSerialization['id'] as int?,
      type: _i2.ChatType.fromJson((jsonSerialization['type'] as String)),
      name: jsonSerialization['name'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      lastMessageAt: jsonSerialization['lastMessageAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastMessageAt'],
            ),
    );
  }

  static final t = ChatTable();

  static const db = ChatRepository._();

  @override
  int? id;

  /// Direct chats have two participants. Group chats can have more.
  _i2.ChatType type;

  /// Encrypted display name for group chats (AES-256-GCM). Null for direct chats.
  String? name;

  DateTime createdAt;

  DateTime updatedAt;

  /// Denormalized timestamp for chat-list sorting. Null until messages exist.
  DateTime? lastMessageAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Chat]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Chat copyWith({
    int? id,
    _i2.ChatType? type,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastMessageAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Chat',
      if (id != null) 'id': id,
      'type': type.toJson(),
      if (name != null) 'name': name,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (lastMessageAt != null) 'lastMessageAt': lastMessageAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Chat',
      if (id != null) 'id': id,
      'type': type.toJson(),
      if (name != null) 'name': name,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (lastMessageAt != null) 'lastMessageAt': lastMessageAt?.toJson(),
    };
  }

  static ChatInclude include() {
    return ChatInclude._();
  }

  static ChatIncludeList includeList({
    _i1.WhereExpressionBuilder<ChatTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatTable>? orderByList,
    ChatInclude? include,
  }) {
    return ChatIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Chat.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Chat.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatImpl extends Chat {
  _ChatImpl({
    int? id,
    required _i2.ChatType type,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastMessageAt,
  }) : super._(
         id: id,
         type: type,
         name: name,
         createdAt: createdAt,
         updatedAt: updatedAt,
         lastMessageAt: lastMessageAt,
       );

  /// Returns a shallow copy of this [Chat]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Chat copyWith({
    Object? id = _Undefined,
    _i2.ChatType? type,
    Object? name = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? lastMessageAt = _Undefined,
  }) {
    return Chat(
      id: id is int? ? id : this.id,
      type: type ?? this.type,
      name: name is String? ? name : this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessageAt: lastMessageAt is DateTime?
          ? lastMessageAt
          : this.lastMessageAt,
    );
  }
}

class ChatUpdateTable extends _i1.UpdateTable<ChatTable> {
  ChatUpdateTable(super.table);

  _i1.ColumnValue<_i2.ChatType, _i2.ChatType> type(_i2.ChatType value) =>
      _i1.ColumnValue(
        table.type,
        value,
      );

  _i1.ColumnValue<String, String> name(String? value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> lastMessageAt(DateTime? value) =>
      _i1.ColumnValue(
        table.lastMessageAt,
        value,
      );
}

class ChatTable extends _i1.Table<int?> {
  ChatTable({super.tableRelation}) : super(tableName: 'messenger_chat') {
    updateTable = ChatUpdateTable(this);
    type = _i1.ColumnEnum(
      'type',
      this,
      _i1.EnumSerialization.byName,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
    lastMessageAt = _i1.ColumnDateTime(
      'lastMessageAt',
      this,
    );
  }

  late final ChatUpdateTable updateTable;

  /// Direct chats have two participants. Group chats can have more.
  late final _i1.ColumnEnum<_i2.ChatType> type;

  /// Encrypted display name for group chats (AES-256-GCM). Null for direct chats.
  late final _i1.ColumnString name;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  /// Denormalized timestamp for chat-list sorting. Null until messages exist.
  late final _i1.ColumnDateTime lastMessageAt;

  @override
  List<_i1.Column> get columns => [
    id,
    type,
    name,
    createdAt,
    updatedAt,
    lastMessageAt,
  ];
}

class ChatInclude extends _i1.IncludeObject {
  ChatInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Chat.t;
}

class ChatIncludeList extends _i1.IncludeList {
  ChatIncludeList._({
    _i1.WhereExpressionBuilder<ChatTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Chat.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Chat.t;
}

class ChatRepository {
  const ChatRepository._();

  /// Returns a list of [Chat]s matching the given query parameters.
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
  Future<List<Chat>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Chat>(
      where: where?.call(Chat.t),
      orderBy: orderBy?.call(Chat.t),
      orderByList: orderByList?.call(Chat.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Chat] matching the given query parameters.
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
  Future<Chat?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatTable>? where,
    int? offset,
    _i1.OrderByBuilder<ChatTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Chat>(
      where: where?.call(Chat.t),
      orderBy: orderBy?.call(Chat.t),
      orderByList: orderByList?.call(Chat.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Chat] by its [id] or null if no such row exists.
  Future<Chat?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Chat>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Chat]s in the list and returns the inserted rows.
  ///
  /// The returned [Chat]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Chat>> insert(
    _i1.DatabaseSession session,
    List<Chat> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Chat>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Chat] and returns the inserted row.
  ///
  /// The returned [Chat] will have its `id` field set.
  Future<Chat> insertRow(
    _i1.DatabaseSession session,
    Chat row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Chat>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Chat]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Chat>> update(
    _i1.DatabaseSession session,
    List<Chat> rows, {
    _i1.ColumnSelections<ChatTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Chat>(
      rows,
      columns: columns?.call(Chat.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Chat]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Chat> updateRow(
    _i1.DatabaseSession session,
    Chat row, {
    _i1.ColumnSelections<ChatTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Chat>(
      row,
      columns: columns?.call(Chat.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Chat] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Chat?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<ChatUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Chat>(
      id,
      columnValues: columnValues(Chat.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Chat]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Chat>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<ChatUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ChatTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatTable>? orderBy,
    _i1.OrderByListBuilder<ChatTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Chat>(
      columnValues: columnValues(Chat.t.updateTable),
      where: where(Chat.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Chat.t),
      orderByList: orderByList?.call(Chat.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Chat]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Chat>> delete(
    _i1.DatabaseSession session,
    List<Chat> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Chat>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Chat].
  Future<Chat> deleteRow(
    _i1.DatabaseSession session,
    Chat row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Chat>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Chat>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ChatTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Chat>(
      where: where(Chat.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Chat>(
      where: where?.call(Chat.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Chat] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ChatTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Chat>(
      where: where(Chat.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
