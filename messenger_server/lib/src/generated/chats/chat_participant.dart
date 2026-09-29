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
import '../chats/chat.dart' as _i2;
import '../users/messenger_user.dart' as _i3;
import '../chats/chat_participant_role.dart' as _i4;
import 'package:messenger_server/src/generated/protocol.dart' as _i5;

/// Membership of a [MessengerUser] in a [Chat]. Settings are per user.
abstract class ChatParticipant
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  ChatParticipant._({
    this.id,
    required this.chatId,
    this.chat,
    required this.userId,
    this.user,
    required this.role,
    DateTime? joinedAt,
    bool? archived,
    bool? notificationsMuted,
  }) : joinedAt = joinedAt ?? DateTime.now(),
       archived = archived ?? false,
       notificationsMuted = notificationsMuted ?? false;

  factory ChatParticipant({
    int? id,
    required int chatId,
    _i2.Chat? chat,
    required int userId,
    _i3.MessengerUser? user,
    required _i4.ChatParticipantRole role,
    DateTime? joinedAt,
    bool? archived,
    bool? notificationsMuted,
  }) = _ChatParticipantImpl;

  factory ChatParticipant.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatParticipant(
      id: jsonSerialization['id'] as int?,
      chatId: jsonSerialization['chatId'] as int,
      chat: jsonSerialization['chat'] == null
          ? null
          : _i5.Protocol().deserialize<_i2.Chat>(jsonSerialization['chat']),
      userId: jsonSerialization['userId'] as int,
      user: jsonSerialization['user'] == null
          ? null
          : _i5.Protocol().deserialize<_i3.MessengerUser>(
              jsonSerialization['user'],
            ),
      role: _i4.ChatParticipantRole.fromJson(
        (jsonSerialization['role'] as String),
      ),
      joinedAt: jsonSerialization['joinedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['joinedAt']),
      archived: jsonSerialization['archived'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['archived']),
      notificationsMuted: jsonSerialization['notificationsMuted'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(
              jsonSerialization['notificationsMuted'],
            ),
    );
  }

  static final t = ChatParticipantTable();

  static const db = ChatParticipantRepository._();

  @override
  int? id;

  int chatId;

  _i2.Chat? chat;

  int userId;

  _i3.MessengerUser? user;

  _i4.ChatParticipantRole role;

  DateTime joinedAt;

  bool archived;

  bool notificationsMuted;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ChatParticipant]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatParticipant copyWith({
    int? id,
    int? chatId,
    _i2.Chat? chat,
    int? userId,
    _i3.MessengerUser? user,
    _i4.ChatParticipantRole? role,
    DateTime? joinedAt,
    bool? archived,
    bool? notificationsMuted,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatParticipant',
      if (id != null) 'id': id,
      'chatId': chatId,
      if (chat != null) 'chat': chat?.toJson(),
      'userId': userId,
      if (user != null) 'user': user?.toJson(),
      'role': role.toJson(),
      'joinedAt': joinedAt.toJson(),
      'archived': archived,
      'notificationsMuted': notificationsMuted,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ChatParticipant',
      if (id != null) 'id': id,
      'chatId': chatId,
      if (chat != null) 'chat': chat?.toJsonForProtocol(),
      'userId': userId,
      if (user != null) 'user': user?.toJsonForProtocol(),
      'role': role.toJson(),
      'joinedAt': joinedAt.toJson(),
      'archived': archived,
      'notificationsMuted': notificationsMuted,
    };
  }

  static ChatParticipantInclude include({
    _i2.ChatInclude? chat,
    _i3.MessengerUserInclude? user,
  }) {
    return ChatParticipantInclude._(
      chat: chat,
      user: user,
    );
  }

  static ChatParticipantIncludeList includeList({
    _i1.WhereExpressionBuilder<ChatParticipantTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatParticipantTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatParticipantTable>? orderByList,
    ChatParticipantInclude? include,
  }) {
    return ChatParticipantIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatParticipant.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ChatParticipant.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatParticipantImpl extends ChatParticipant {
  _ChatParticipantImpl({
    int? id,
    required int chatId,
    _i2.Chat? chat,
    required int userId,
    _i3.MessengerUser? user,
    required _i4.ChatParticipantRole role,
    DateTime? joinedAt,
    bool? archived,
    bool? notificationsMuted,
  }) : super._(
         id: id,
         chatId: chatId,
         chat: chat,
         userId: userId,
         user: user,
         role: role,
         joinedAt: joinedAt,
         archived: archived,
         notificationsMuted: notificationsMuted,
       );

  /// Returns a shallow copy of this [ChatParticipant]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatParticipant copyWith({
    Object? id = _Undefined,
    int? chatId,
    Object? chat = _Undefined,
    int? userId,
    Object? user = _Undefined,
    _i4.ChatParticipantRole? role,
    DateTime? joinedAt,
    bool? archived,
    bool? notificationsMuted,
  }) {
    return ChatParticipant(
      id: id is int? ? id : this.id,
      chatId: chatId ?? this.chatId,
      chat: chat is _i2.Chat? ? chat : this.chat?.copyWith(),
      userId: userId ?? this.userId,
      user: user is _i3.MessengerUser? ? user : this.user?.copyWith(),
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      archived: archived ?? this.archived,
      notificationsMuted: notificationsMuted ?? this.notificationsMuted,
    );
  }
}

class ChatParticipantUpdateTable extends _i1.UpdateTable<ChatParticipantTable> {
  ChatParticipantUpdateTable(super.table);

  _i1.ColumnValue<int, int> chatId(int value) => _i1.ColumnValue(
    table.chatId,
    value,
  );

  _i1.ColumnValue<int, int> userId(int value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<_i4.ChatParticipantRole, _i4.ChatParticipantRole> role(
    _i4.ChatParticipantRole value,
  ) => _i1.ColumnValue(
    table.role,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> joinedAt(DateTime value) =>
      _i1.ColumnValue(
        table.joinedAt,
        value,
      );

  _i1.ColumnValue<bool, bool> archived(bool value) => _i1.ColumnValue(
    table.archived,
    value,
  );

  _i1.ColumnValue<bool, bool> notificationsMuted(bool value) => _i1.ColumnValue(
    table.notificationsMuted,
    value,
  );
}

class ChatParticipantTable extends _i1.Table<int?> {
  ChatParticipantTable({super.tableRelation})
    : super(tableName: 'messenger_chat_participant') {
    updateTable = ChatParticipantUpdateTable(this);
    chatId = _i1.ColumnInt(
      'chatId',
      this,
    );
    userId = _i1.ColumnInt(
      'userId',
      this,
    );
    role = _i1.ColumnEnum(
      'role',
      this,
      _i1.EnumSerialization.byName,
    );
    joinedAt = _i1.ColumnDateTime(
      'joinedAt',
      this,
      hasDefault: true,
    );
    archived = _i1.ColumnBool(
      'archived',
      this,
      hasDefault: true,
    );
    notificationsMuted = _i1.ColumnBool(
      'notificationsMuted',
      this,
      hasDefault: true,
    );
  }

  late final ChatParticipantUpdateTable updateTable;

  late final _i1.ColumnInt chatId;

  _i2.ChatTable? _chat;

  late final _i1.ColumnInt userId;

  _i3.MessengerUserTable? _user;

  late final _i1.ColumnEnum<_i4.ChatParticipantRole> role;

  late final _i1.ColumnDateTime joinedAt;

  late final _i1.ColumnBool archived;

  late final _i1.ColumnBool notificationsMuted;

  _i2.ChatTable get chat {
    if (_chat != null) return _chat!;
    _chat = _i1.createRelationTable(
      relationFieldName: 'chat',
      field: ChatParticipant.t.chatId,
      foreignField: _i2.Chat.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.ChatTable(tableRelation: foreignTableRelation),
    );
    return _chat!;
  }

  _i3.MessengerUserTable get user {
    if (_user != null) return _user!;
    _user = _i1.createRelationTable(
      relationFieldName: 'user',
      field: ChatParticipant.t.userId,
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
    chatId,
    userId,
    role,
    joinedAt,
    archived,
    notificationsMuted,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'chat') {
      return chat;
    }
    if (relationField == 'user') {
      return user;
    }
    return null;
  }
}

class ChatParticipantInclude extends _i1.IncludeObject {
  ChatParticipantInclude._({
    _i2.ChatInclude? chat,
    _i3.MessengerUserInclude? user,
  }) {
    _chat = chat;
    _user = user;
  }

  _i2.ChatInclude? _chat;

  _i3.MessengerUserInclude? _user;

  @override
  Map<String, _i1.Include?> get includes => {
    'chat': _chat,
    'user': _user,
  };

  @override
  _i1.Table<int?> get table => ChatParticipant.t;
}

class ChatParticipantIncludeList extends _i1.IncludeList {
  ChatParticipantIncludeList._({
    _i1.WhereExpressionBuilder<ChatParticipantTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ChatParticipant.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ChatParticipant.t;
}

class ChatParticipantRepository {
  const ChatParticipantRepository._();

  final attachRow = const ChatParticipantAttachRowRepository._();

  /// Returns a list of [ChatParticipant]s matching the given query parameters.
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
  Future<List<ChatParticipant>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatParticipantTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatParticipantTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatParticipantTable>? orderByList,
    _i1.Transaction? transaction,
    ChatParticipantInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ChatParticipant>(
      where: where?.call(ChatParticipant.t),
      orderBy: orderBy?.call(ChatParticipant.t),
      orderByList: orderByList?.call(ChatParticipant.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ChatParticipant] matching the given query parameters.
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
  Future<ChatParticipant?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatParticipantTable>? where,
    int? offset,
    _i1.OrderByBuilder<ChatParticipantTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatParticipantTable>? orderByList,
    _i1.Transaction? transaction,
    ChatParticipantInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ChatParticipant>(
      where: where?.call(ChatParticipant.t),
      orderBy: orderBy?.call(ChatParticipant.t),
      orderByList: orderByList?.call(ChatParticipant.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ChatParticipant] by its [id] or null if no such row exists.
  Future<ChatParticipant?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    ChatParticipantInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ChatParticipant>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ChatParticipant]s in the list and returns the inserted rows.
  ///
  /// The returned [ChatParticipant]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<ChatParticipant>> insert(
    _i1.DatabaseSession session,
    List<ChatParticipant> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<ChatParticipant>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [ChatParticipant] and returns the inserted row.
  ///
  /// The returned [ChatParticipant] will have its `id` field set.
  Future<ChatParticipant> insertRow(
    _i1.DatabaseSession session,
    ChatParticipant row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ChatParticipant>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ChatParticipant]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ChatParticipant>> update(
    _i1.DatabaseSession session,
    List<ChatParticipant> rows, {
    _i1.ColumnSelections<ChatParticipantTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ChatParticipant>(
      rows,
      columns: columns?.call(ChatParticipant.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatParticipant]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ChatParticipant> updateRow(
    _i1.DatabaseSession session,
    ChatParticipant row, {
    _i1.ColumnSelections<ChatParticipantTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ChatParticipant>(
      row,
      columns: columns?.call(ChatParticipant.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatParticipant] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ChatParticipant?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<ChatParticipantUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ChatParticipant>(
      id,
      columnValues: columnValues(ChatParticipant.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ChatParticipant]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ChatParticipant>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<ChatParticipantUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<ChatParticipantTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatParticipantTable>? orderBy,
    _i1.OrderByListBuilder<ChatParticipantTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ChatParticipant>(
      columnValues: columnValues(ChatParticipant.t.updateTable),
      where: where(ChatParticipant.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatParticipant.t),
      orderByList: orderByList?.call(ChatParticipant.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ChatParticipant]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ChatParticipant>> delete(
    _i1.DatabaseSession session,
    List<ChatParticipant> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ChatParticipant>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ChatParticipant].
  Future<ChatParticipant> deleteRow(
    _i1.DatabaseSession session,
    ChatParticipant row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ChatParticipant>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ChatParticipant>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ChatParticipantTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ChatParticipant>(
      where: where(ChatParticipant.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatParticipantTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ChatParticipant>(
      where: where?.call(ChatParticipant.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ChatParticipant] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ChatParticipantTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ChatParticipant>(
      where: where(ChatParticipant.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class ChatParticipantAttachRowRepository {
  const ChatParticipantAttachRowRepository._();

  /// Creates a relation between the given [ChatParticipant] and [Chat]
  /// by setting the [ChatParticipant]'s foreign key `chatId` to refer to the [Chat].
  Future<void> chat(
    _i1.DatabaseSession session,
    ChatParticipant chatParticipant,
    _i2.Chat chat, {
    _i1.Transaction? transaction,
  }) async {
    if (chatParticipant.id == null) {
      throw ArgumentError.notNull('chatParticipant.id');
    }
    if (chat.id == null) {
      throw ArgumentError.notNull('chat.id');
    }

    var $chatParticipant = chatParticipant.copyWith(chatId: chat.id);
    await session.db.updateRow<ChatParticipant>(
      $chatParticipant,
      columns: [ChatParticipant.t.chatId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [ChatParticipant] and [MessengerUser]
  /// by setting the [ChatParticipant]'s foreign key `userId` to refer to the [MessengerUser].
  Future<void> user(
    _i1.DatabaseSession session,
    ChatParticipant chatParticipant,
    _i3.MessengerUser user, {
    _i1.Transaction? transaction,
  }) async {
    if (chatParticipant.id == null) {
      throw ArgumentError.notNull('chatParticipant.id');
    }
    if (user.id == null) {
      throw ArgumentError.notNull('user.id');
    }

    var $chatParticipant = chatParticipant.copyWith(userId: user.id);
    await session.db.updateRow<ChatParticipant>(
      $chatParticipant,
      columns: [ChatParticipant.t.userId],
      transaction: transaction,
    );
  }
}
