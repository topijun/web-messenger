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
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i2;
import '../chats/chat_invitation.dart' as _i3;
import 'package:messenger_server/src/generated/protocol.dart' as _i4;

/// Messenger domain identity linked to a Serverpod [AuthUser].
///
/// Authentication credentials stay in Serverpod Auth. This table only stores
/// Messenger-specific data such as the unique username.
abstract class MessengerUser
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  MessengerUser._({
    this.id,
    required this.authUserId,
    this.authUser,
    required this.username,
    required this.usernameNormalized,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.sentInvitations,
    this.receivedInvitations,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory MessengerUser({
    int? id,
    required _i1.UuidValue authUserId,
    _i2.AuthUser? authUser,
    required String username,
    required String usernameNormalized,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<_i3.ChatInvitation>? sentInvitations,
    List<_i3.ChatInvitation>? receivedInvitations,
  }) = _MessengerUserImpl;

  factory MessengerUser.fromJson(Map<String, dynamic> jsonSerialization) {
    return MessengerUser(
      id: jsonSerialization['id'] as int?,
      authUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _i4.Protocol().deserialize<_i2.AuthUser>(
              jsonSerialization['authUser'],
            ),
      username: jsonSerialization['username'] as String,
      usernameNormalized: jsonSerialization['usernameNormalized'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      sentInvitations: jsonSerialization['sentInvitations'] == null
          ? null
          : _i4.Protocol().deserialize<List<_i3.ChatInvitation>>(
              jsonSerialization['sentInvitations'],
            ),
      receivedInvitations: jsonSerialization['receivedInvitations'] == null
          ? null
          : _i4.Protocol().deserialize<List<_i3.ChatInvitation>>(
              jsonSerialization['receivedInvitations'],
            ),
    );
  }

  static final t = MessengerUserTable();

  static const db = MessengerUserRepository._();

  @override
  int? id;

  _i1.UuidValue authUserId;

  /// The [AuthUser] this Messenger user belongs to.
  _i2.AuthUser? authUser;

  /// Public Messenger username. Original casing is preserved for display.
  String username;

  /// Lower-cased username used for case-insensitive uniqueness.
  String usernameNormalized;

  DateTime createdAt;

  DateTime updatedAt;

  /// Invitations this user sent.
  List<_i3.ChatInvitation>? sentInvitations;

  /// Invitations this user received.
  List<_i3.ChatInvitation>? receivedInvitations;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [MessengerUser]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MessengerUser copyWith({
    int? id,
    _i1.UuidValue? authUserId,
    _i2.AuthUser? authUser,
    String? username,
    String? usernameNormalized,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<_i3.ChatInvitation>? sentInvitations,
    List<_i3.ChatInvitation>? receivedInvitations,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MessengerUser',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'username': username,
      'usernameNormalized': usernameNormalized,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (sentInvitations != null)
        'sentInvitations': sentInvitations?.toJson(
          valueToJson: (v) => v.toJson(),
        ),
      if (receivedInvitations != null)
        'receivedInvitations': receivedInvitations?.toJson(
          valueToJson: (v) => v.toJson(),
        ),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MessengerUser',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJsonForProtocol(),
      'username': username,
      'usernameNormalized': usernameNormalized,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (sentInvitations != null)
        'sentInvitations': sentInvitations?.toJson(
          valueToJson: (v) => v.toJsonForProtocol(),
        ),
      if (receivedInvitations != null)
        'receivedInvitations': receivedInvitations?.toJson(
          valueToJson: (v) => v.toJsonForProtocol(),
        ),
    };
  }

  static MessengerUserInclude include({
    _i2.AuthUserInclude? authUser,
    _i3.ChatInvitationIncludeList? sentInvitations,
    _i3.ChatInvitationIncludeList? receivedInvitations,
  }) {
    return MessengerUserInclude._(
      authUser: authUser,
      sentInvitations: sentInvitations,
      receivedInvitations: receivedInvitations,
    );
  }

  static MessengerUserIncludeList includeList({
    _i1.WhereExpressionBuilder<MessengerUserTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MessengerUserTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MessengerUserTable>? orderByList,
    MessengerUserInclude? include,
  }) {
    return MessengerUserIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MessengerUser.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(MessengerUser.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MessengerUserImpl extends MessengerUser {
  _MessengerUserImpl({
    int? id,
    required _i1.UuidValue authUserId,
    _i2.AuthUser? authUser,
    required String username,
    required String usernameNormalized,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<_i3.ChatInvitation>? sentInvitations,
    List<_i3.ChatInvitation>? receivedInvitations,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         username: username,
         usernameNormalized: usernameNormalized,
         createdAt: createdAt,
         updatedAt: updatedAt,
         sentInvitations: sentInvitations,
         receivedInvitations: receivedInvitations,
       );

  /// Returns a shallow copy of this [MessengerUser]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MessengerUser copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? authUserId,
    Object? authUser = _Undefined,
    String? username,
    String? usernameNormalized,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? sentInvitations = _Undefined,
    Object? receivedInvitations = _Undefined,
  }) {
    return MessengerUser(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _i2.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      username: username ?? this.username,
      usernameNormalized: usernameNormalized ?? this.usernameNormalized,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sentInvitations: sentInvitations is List<_i3.ChatInvitation>?
          ? sentInvitations
          : this.sentInvitations?.map((e0) => e0.copyWith()).toList(),
      receivedInvitations: receivedInvitations is List<_i3.ChatInvitation>?
          ? receivedInvitations
          : this.receivedInvitations?.map((e0) => e0.copyWith()).toList(),
    );
  }
}

class MessengerUserUpdateTable extends _i1.UpdateTable<MessengerUserTable> {
  MessengerUserUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> authUserId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.authUserId,
    value,
  );

  _i1.ColumnValue<String, String> username(String value) => _i1.ColumnValue(
    table.username,
    value,
  );

  _i1.ColumnValue<String, String> usernameNormalized(String value) =>
      _i1.ColumnValue(
        table.usernameNormalized,
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
}

class MessengerUserTable extends _i1.Table<int?> {
  MessengerUserTable({super.tableRelation})
    : super(tableName: 'messenger_user') {
    updateTable = MessengerUserUpdateTable(this);
    authUserId = _i1.ColumnUuid(
      'authUserId',
      this,
    );
    username = _i1.ColumnString(
      'username',
      this,
    );
    usernameNormalized = _i1.ColumnString(
      'usernameNormalized',
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
  }

  late final MessengerUserUpdateTable updateTable;

  late final _i1.ColumnUuid authUserId;

  /// The [AuthUser] this Messenger user belongs to.
  _i2.AuthUserTable? _authUser;

  /// Public Messenger username. Original casing is preserved for display.
  late final _i1.ColumnString username;

  /// Lower-cased username used for case-insensitive uniqueness.
  late final _i1.ColumnString usernameNormalized;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  /// Invitations this user sent.
  _i3.ChatInvitationTable? ___sentInvitations;

  /// Invitations this user sent.
  _i1.ManyRelation<_i3.ChatInvitationTable>? _sentInvitations;

  /// Invitations this user received.
  _i3.ChatInvitationTable? ___receivedInvitations;

  /// Invitations this user received.
  _i1.ManyRelation<_i3.ChatInvitationTable>? _receivedInvitations;

  _i2.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _i1.createRelationTable(
      relationFieldName: 'authUser',
      field: MessengerUser.t.authUserId,
      foreignField: _i2.AuthUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.AuthUserTable(tableRelation: foreignTableRelation),
    );
    return _authUser!;
  }

  _i3.ChatInvitationTable get __sentInvitations {
    if (___sentInvitations != null) return ___sentInvitations!;
    ___sentInvitations = _i1.createRelationTable(
      relationFieldName: '__sentInvitations',
      field: MessengerUser.t.id,
      foreignField: _i3.ChatInvitation.t.senderId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i3.ChatInvitationTable(tableRelation: foreignTableRelation),
    );
    return ___sentInvitations!;
  }

  _i3.ChatInvitationTable get __receivedInvitations {
    if (___receivedInvitations != null) return ___receivedInvitations!;
    ___receivedInvitations = _i1.createRelationTable(
      relationFieldName: '__receivedInvitations',
      field: MessengerUser.t.id,
      foreignField: _i3.ChatInvitation.t.receiverId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i3.ChatInvitationTable(tableRelation: foreignTableRelation),
    );
    return ___receivedInvitations!;
  }

  _i1.ManyRelation<_i3.ChatInvitationTable> get sentInvitations {
    if (_sentInvitations != null) return _sentInvitations!;
    var relationTable = _i1.createRelationTable(
      relationFieldName: 'sentInvitations',
      field: MessengerUser.t.id,
      foreignField: _i3.ChatInvitation.t.senderId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i3.ChatInvitationTable(tableRelation: foreignTableRelation),
    );
    _sentInvitations = _i1.ManyRelation<_i3.ChatInvitationTable>(
      tableWithRelations: relationTable,
      table: _i3.ChatInvitationTable(
        tableRelation: relationTable.tableRelation!.lastRelation,
      ),
    );
    return _sentInvitations!;
  }

  _i1.ManyRelation<_i3.ChatInvitationTable> get receivedInvitations {
    if (_receivedInvitations != null) return _receivedInvitations!;
    var relationTable = _i1.createRelationTable(
      relationFieldName: 'receivedInvitations',
      field: MessengerUser.t.id,
      foreignField: _i3.ChatInvitation.t.receiverId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i3.ChatInvitationTable(tableRelation: foreignTableRelation),
    );
    _receivedInvitations = _i1.ManyRelation<_i3.ChatInvitationTable>(
      tableWithRelations: relationTable,
      table: _i3.ChatInvitationTable(
        tableRelation: relationTable.tableRelation!.lastRelation,
      ),
    );
    return _receivedInvitations!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    authUserId,
    username,
    usernameNormalized,
    createdAt,
    updatedAt,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'authUser') {
      return authUser;
    }
    if (relationField == 'sentInvitations') {
      return __sentInvitations;
    }
    if (relationField == 'receivedInvitations') {
      return __receivedInvitations;
    }
    return null;
  }
}

class MessengerUserInclude extends _i1.IncludeObject {
  MessengerUserInclude._({
    _i2.AuthUserInclude? authUser,
    _i3.ChatInvitationIncludeList? sentInvitations,
    _i3.ChatInvitationIncludeList? receivedInvitations,
  }) {
    _authUser = authUser;
    _sentInvitations = sentInvitations;
    _receivedInvitations = receivedInvitations;
  }

  _i2.AuthUserInclude? _authUser;

  _i3.ChatInvitationIncludeList? _sentInvitations;

  _i3.ChatInvitationIncludeList? _receivedInvitations;

  @override
  Map<String, _i1.Include?> get includes => {
    'authUser': _authUser,
    'sentInvitations': _sentInvitations,
    'receivedInvitations': _receivedInvitations,
  };

  @override
  _i1.Table<int?> get table => MessengerUser.t;
}

class MessengerUserIncludeList extends _i1.IncludeList {
  MessengerUserIncludeList._({
    _i1.WhereExpressionBuilder<MessengerUserTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MessengerUser.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => MessengerUser.t;
}

class MessengerUserRepository {
  const MessengerUserRepository._();

  final attach = const MessengerUserAttachRepository._();

  final attachRow = const MessengerUserAttachRowRepository._();

  /// Returns a list of [MessengerUser]s matching the given query parameters.
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
  Future<List<MessengerUser>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MessengerUserTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MessengerUserTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MessengerUserTable>? orderByList,
    _i1.Transaction? transaction,
    MessengerUserInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MessengerUser>(
      where: where?.call(MessengerUser.t),
      orderBy: orderBy?.call(MessengerUser.t),
      orderByList: orderByList?.call(MessengerUser.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MessengerUser] matching the given query parameters.
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
  Future<MessengerUser?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MessengerUserTable>? where,
    int? offset,
    _i1.OrderByBuilder<MessengerUserTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MessengerUserTable>? orderByList,
    _i1.Transaction? transaction,
    MessengerUserInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MessengerUser>(
      where: where?.call(MessengerUser.t),
      orderBy: orderBy?.call(MessengerUser.t),
      orderByList: orderByList?.call(MessengerUser.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MessengerUser] by its [id] or null if no such row exists.
  Future<MessengerUser?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    MessengerUserInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MessengerUser>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MessengerUser]s in the list and returns the inserted rows.
  ///
  /// The returned [MessengerUser]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<MessengerUser>> insert(
    _i1.DatabaseSession session,
    List<MessengerUser> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<MessengerUser>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [MessengerUser] and returns the inserted row.
  ///
  /// The returned [MessengerUser] will have its `id` field set.
  Future<MessengerUser> insertRow(
    _i1.DatabaseSession session,
    MessengerUser row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<MessengerUser>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [MessengerUser]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<MessengerUser>> update(
    _i1.DatabaseSession session,
    List<MessengerUser> rows, {
    _i1.ColumnSelections<MessengerUserTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<MessengerUser>(
      rows,
      columns: columns?.call(MessengerUser.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MessengerUser]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MessengerUser> updateRow(
    _i1.DatabaseSession session,
    MessengerUser row, {
    _i1.ColumnSelections<MessengerUserTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<MessengerUser>(
      row,
      columns: columns?.call(MessengerUser.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MessengerUser] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MessengerUser?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<MessengerUserUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<MessengerUser>(
      id,
      columnValues: columnValues(MessengerUser.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MessengerUser]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<MessengerUser>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<MessengerUserUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<MessengerUserTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MessengerUserTable>? orderBy,
    _i1.OrderByListBuilder<MessengerUserTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<MessengerUser>(
      columnValues: columnValues(MessengerUser.t.updateTable),
      where: where(MessengerUser.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MessengerUser.t),
      orderByList: orderByList?.call(MessengerUser.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [MessengerUser]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<MessengerUser>> delete(
    _i1.DatabaseSession session,
    List<MessengerUser> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<MessengerUser>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [MessengerUser].
  Future<MessengerUser> deleteRow(
    _i1.DatabaseSession session,
    MessengerUser row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MessengerUser>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<MessengerUser>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MessengerUserTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<MessengerUser>(
      where: where(MessengerUser.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MessengerUserTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<MessengerUser>(
      where: where?.call(MessengerUser.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MessengerUser] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MessengerUserTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MessengerUser>(
      where: where(MessengerUser.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class MessengerUserAttachRepository {
  const MessengerUserAttachRepository._();

  /// Creates a relation between this [MessengerUser] and the given [ChatInvitation]s
  /// by setting each [ChatInvitation]'s foreign key `senderId` to refer to this [MessengerUser].
  Future<void> sentInvitations(
    _i1.DatabaseSession session,
    MessengerUser messengerUser,
    List<_i3.ChatInvitation> chatInvitation, {
    _i1.Transaction? transaction,
  }) async {
    if (chatInvitation.any((e) => e.id == null)) {
      throw ArgumentError.notNull('chatInvitation.id');
    }
    if (messengerUser.id == null) {
      throw ArgumentError.notNull('messengerUser.id');
    }

    var $chatInvitation = chatInvitation
        .map((e) => e.copyWith(senderId: messengerUser.id))
        .toList();
    await session.db.update<_i3.ChatInvitation>(
      $chatInvitation,
      columns: [_i3.ChatInvitation.t.senderId],
      transaction: transaction,
    );
  }

  /// Creates a relation between this [MessengerUser] and the given [ChatInvitation]s
  /// by setting each [ChatInvitation]'s foreign key `receiverId` to refer to this [MessengerUser].
  Future<void> receivedInvitations(
    _i1.DatabaseSession session,
    MessengerUser messengerUser,
    List<_i3.ChatInvitation> chatInvitation, {
    _i1.Transaction? transaction,
  }) async {
    if (chatInvitation.any((e) => e.id == null)) {
      throw ArgumentError.notNull('chatInvitation.id');
    }
    if (messengerUser.id == null) {
      throw ArgumentError.notNull('messengerUser.id');
    }

    var $chatInvitation = chatInvitation
        .map((e) => e.copyWith(receiverId: messengerUser.id))
        .toList();
    await session.db.update<_i3.ChatInvitation>(
      $chatInvitation,
      columns: [_i3.ChatInvitation.t.receiverId],
      transaction: transaction,
    );
  }
}

class MessengerUserAttachRowRepository {
  const MessengerUserAttachRowRepository._();

  /// Creates a relation between the given [MessengerUser] and [AuthUser]
  /// by setting the [MessengerUser]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _i1.DatabaseSession session,
    MessengerUser messengerUser,
    _i2.AuthUser authUser, {
    _i1.Transaction? transaction,
  }) async {
    if (messengerUser.id == null) {
      throw ArgumentError.notNull('messengerUser.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $messengerUser = messengerUser.copyWith(authUserId: authUser.id);
    await session.db.updateRow<MessengerUser>(
      $messengerUser,
      columns: [MessengerUser.t.authUserId],
      transaction: transaction,
    );
  }

  /// Creates a relation between this [MessengerUser] and the given [ChatInvitation]
  /// by setting the [ChatInvitation]'s foreign key `senderId` to refer to this [MessengerUser].
  Future<void> sentInvitations(
    _i1.DatabaseSession session,
    MessengerUser messengerUser,
    _i3.ChatInvitation chatInvitation, {
    _i1.Transaction? transaction,
  }) async {
    if (chatInvitation.id == null) {
      throw ArgumentError.notNull('chatInvitation.id');
    }
    if (messengerUser.id == null) {
      throw ArgumentError.notNull('messengerUser.id');
    }

    var $chatInvitation = chatInvitation.copyWith(senderId: messengerUser.id);
    await session.db.updateRow<_i3.ChatInvitation>(
      $chatInvitation,
      columns: [_i3.ChatInvitation.t.senderId],
      transaction: transaction,
    );
  }

  /// Creates a relation between this [MessengerUser] and the given [ChatInvitation]
  /// by setting the [ChatInvitation]'s foreign key `receiverId` to refer to this [MessengerUser].
  Future<void> receivedInvitations(
    _i1.DatabaseSession session,
    MessengerUser messengerUser,
    _i3.ChatInvitation chatInvitation, {
    _i1.Transaction? transaction,
  }) async {
    if (chatInvitation.id == null) {
      throw ArgumentError.notNull('chatInvitation.id');
    }
    if (messengerUser.id == null) {
      throw ArgumentError.notNull('messengerUser.id');
    }

    var $chatInvitation = chatInvitation.copyWith(receiverId: messengerUser.id);
    await session.db.updateRow<_i3.ChatInvitation>(
      $chatInvitation,
      columns: [_i3.ChatInvitation.t.receiverId],
      transaction: transaction,
    );
  }
}
