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
import '../chats/chat_invitation_status.dart' as _i4;
import 'package:messenger_server/src/generated/protocol.dart' as _i5;

/// Invitation to a direct or group [Chat]. Direct invitations have no chat
/// until they are accepted.
abstract class ChatInvitation
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  ChatInvitation._({
    this.id,
    this.chatId,
    this.chat,
    required this.senderId,
    this.sender,
    required this.receiverId,
    this.receiver,
    required this.status,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ChatInvitation({
    int? id,
    int? chatId,
    _i2.Chat? chat,
    required int senderId,
    _i3.MessengerUser? sender,
    required int receiverId,
    _i3.MessengerUser? receiver,
    required _i4.ChatInvitationStatus status,
    DateTime? createdAt,
  }) = _ChatInvitationImpl;

  factory ChatInvitation.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatInvitation(
      id: jsonSerialization['id'] as int?,
      chatId: jsonSerialization['chatId'] as int?,
      chat: jsonSerialization['chat'] == null
          ? null
          : _i5.Protocol().deserialize<_i2.Chat>(jsonSerialization['chat']),
      senderId: jsonSerialization['senderId'] as int,
      sender: jsonSerialization['sender'] == null
          ? null
          : _i5.Protocol().deserialize<_i3.MessengerUser>(
              jsonSerialization['sender'],
            ),
      receiverId: jsonSerialization['receiverId'] as int,
      receiver: jsonSerialization['receiver'] == null
          ? null
          : _i5.Protocol().deserialize<_i3.MessengerUser>(
              jsonSerialization['receiver'],
            ),
      status: _i4.ChatInvitationStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = ChatInvitationTable();

  static const db = ChatInvitationRepository._();

  @override
  int? id;

  int? chatId;

  _i2.Chat? chat;

  int senderId;

  _i3.MessengerUser? sender;

  int receiverId;

  _i3.MessengerUser? receiver;

  _i4.ChatInvitationStatus status;

  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ChatInvitation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatInvitation copyWith({
    int? id,
    int? chatId,
    _i2.Chat? chat,
    int? senderId,
    _i3.MessengerUser? sender,
    int? receiverId,
    _i3.MessengerUser? receiver,
    _i4.ChatInvitationStatus? status,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatInvitation',
      if (id != null) 'id': id,
      if (chatId != null) 'chatId': chatId,
      if (chat != null) 'chat': chat?.toJson(),
      'senderId': senderId,
      if (sender != null) 'sender': sender?.toJson(),
      'receiverId': receiverId,
      if (receiver != null) 'receiver': receiver?.toJson(),
      'status': status.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ChatInvitation',
      if (id != null) 'id': id,
      if (chatId != null) 'chatId': chatId,
      if (chat != null) 'chat': chat?.toJsonForProtocol(),
      'senderId': senderId,
      if (sender != null) 'sender': sender?.toJsonForProtocol(),
      'receiverId': receiverId,
      if (receiver != null) 'receiver': receiver?.toJsonForProtocol(),
      'status': status.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  static ChatInvitationInclude include({
    _i2.ChatInclude? chat,
    _i3.MessengerUserInclude? sender,
    _i3.MessengerUserInclude? receiver,
  }) {
    return ChatInvitationInclude._(
      chat: chat,
      sender: sender,
      receiver: receiver,
    );
  }

  static ChatInvitationIncludeList includeList({
    _i1.WhereExpressionBuilder<ChatInvitationTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatInvitationTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatInvitationTable>? orderByList,
    ChatInvitationInclude? include,
  }) {
    return ChatInvitationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatInvitation.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ChatInvitation.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatInvitationImpl extends ChatInvitation {
  _ChatInvitationImpl({
    int? id,
    int? chatId,
    _i2.Chat? chat,
    required int senderId,
    _i3.MessengerUser? sender,
    required int receiverId,
    _i3.MessengerUser? receiver,
    required _i4.ChatInvitationStatus status,
    DateTime? createdAt,
  }) : super._(
         id: id,
         chatId: chatId,
         chat: chat,
         senderId: senderId,
         sender: sender,
         receiverId: receiverId,
         receiver: receiver,
         status: status,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ChatInvitation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatInvitation copyWith({
    Object? id = _Undefined,
    Object? chatId = _Undefined,
    Object? chat = _Undefined,
    int? senderId,
    Object? sender = _Undefined,
    int? receiverId,
    Object? receiver = _Undefined,
    _i4.ChatInvitationStatus? status,
    DateTime? createdAt,
  }) {
    return ChatInvitation(
      id: id is int? ? id : this.id,
      chatId: chatId is int? ? chatId : this.chatId,
      chat: chat is _i2.Chat? ? chat : this.chat?.copyWith(),
      senderId: senderId ?? this.senderId,
      sender: sender is _i3.MessengerUser? ? sender : this.sender?.copyWith(),
      receiverId: receiverId ?? this.receiverId,
      receiver: receiver is _i3.MessengerUser?
          ? receiver
          : this.receiver?.copyWith(),
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ChatInvitationUpdateTable extends _i1.UpdateTable<ChatInvitationTable> {
  ChatInvitationUpdateTable(super.table);

  _i1.ColumnValue<int, int> chatId(int? value) => _i1.ColumnValue(
    table.chatId,
    value,
  );

  _i1.ColumnValue<int, int> senderId(int value) => _i1.ColumnValue(
    table.senderId,
    value,
  );

  _i1.ColumnValue<int, int> receiverId(int value) => _i1.ColumnValue(
    table.receiverId,
    value,
  );

  _i1.ColumnValue<_i4.ChatInvitationStatus, _i4.ChatInvitationStatus> status(
    _i4.ChatInvitationStatus value,
  ) => _i1.ColumnValue(
    table.status,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class ChatInvitationTable extends _i1.Table<int?> {
  ChatInvitationTable({super.tableRelation})
    : super(tableName: 'messenger_chat_invitation') {
    updateTable = ChatInvitationUpdateTable(this);
    chatId = _i1.ColumnInt(
      'chatId',
      this,
    );
    senderId = _i1.ColumnInt(
      'senderId',
      this,
    );
    receiverId = _i1.ColumnInt(
      'receiverId',
      this,
    );
    status = _i1.ColumnEnum(
      'status',
      this,
      _i1.EnumSerialization.byName,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final ChatInvitationUpdateTable updateTable;

  late final _i1.ColumnInt chatId;

  _i2.ChatTable? _chat;

  late final _i1.ColumnInt senderId;

  _i3.MessengerUserTable? _sender;

  late final _i1.ColumnInt receiverId;

  _i3.MessengerUserTable? _receiver;

  late final _i1.ColumnEnum<_i4.ChatInvitationStatus> status;

  late final _i1.ColumnDateTime createdAt;

  _i2.ChatTable get chat {
    if (_chat != null) return _chat!;
    _chat = _i1.createRelationTable(
      relationFieldName: 'chat',
      field: ChatInvitation.t.chatId,
      foreignField: _i2.Chat.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.ChatTable(tableRelation: foreignTableRelation),
    );
    return _chat!;
  }

  _i3.MessengerUserTable get sender {
    if (_sender != null) return _sender!;
    _sender = _i1.createRelationTable(
      relationFieldName: 'sender',
      field: ChatInvitation.t.senderId,
      foreignField: _i3.MessengerUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i3.MessengerUserTable(tableRelation: foreignTableRelation),
    );
    return _sender!;
  }

  _i3.MessengerUserTable get receiver {
    if (_receiver != null) return _receiver!;
    _receiver = _i1.createRelationTable(
      relationFieldName: 'receiver',
      field: ChatInvitation.t.receiverId,
      foreignField: _i3.MessengerUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i3.MessengerUserTable(tableRelation: foreignTableRelation),
    );
    return _receiver!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    chatId,
    senderId,
    receiverId,
    status,
    createdAt,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'chat') {
      return chat;
    }
    if (relationField == 'sender') {
      return sender;
    }
    if (relationField == 'receiver') {
      return receiver;
    }
    return null;
  }
}

class ChatInvitationInclude extends _i1.IncludeObject {
  ChatInvitationInclude._({
    _i2.ChatInclude? chat,
    _i3.MessengerUserInclude? sender,
    _i3.MessengerUserInclude? receiver,
  }) {
    _chat = chat;
    _sender = sender;
    _receiver = receiver;
  }

  _i2.ChatInclude? _chat;

  _i3.MessengerUserInclude? _sender;

  _i3.MessengerUserInclude? _receiver;

  @override
  Map<String, _i1.Include?> get includes => {
    'chat': _chat,
    'sender': _sender,
    'receiver': _receiver,
  };

  @override
  _i1.Table<int?> get table => ChatInvitation.t;
}

class ChatInvitationIncludeList extends _i1.IncludeList {
  ChatInvitationIncludeList._({
    _i1.WhereExpressionBuilder<ChatInvitationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ChatInvitation.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ChatInvitation.t;
}

class ChatInvitationRepository {
  const ChatInvitationRepository._();

  final attachRow = const ChatInvitationAttachRowRepository._();

  final detachRow = const ChatInvitationDetachRowRepository._();

  /// Returns a list of [ChatInvitation]s matching the given query parameters.
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
  Future<List<ChatInvitation>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatInvitationTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatInvitationTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatInvitationTable>? orderByList,
    _i1.Transaction? transaction,
    ChatInvitationInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ChatInvitation>(
      where: where?.call(ChatInvitation.t),
      orderBy: orderBy?.call(ChatInvitation.t),
      orderByList: orderByList?.call(ChatInvitation.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ChatInvitation] matching the given query parameters.
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
  Future<ChatInvitation?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatInvitationTable>? where,
    int? offset,
    _i1.OrderByBuilder<ChatInvitationTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatInvitationTable>? orderByList,
    _i1.Transaction? transaction,
    ChatInvitationInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ChatInvitation>(
      where: where?.call(ChatInvitation.t),
      orderBy: orderBy?.call(ChatInvitation.t),
      orderByList: orderByList?.call(ChatInvitation.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ChatInvitation] by its [id] or null if no such row exists.
  Future<ChatInvitation?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    ChatInvitationInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ChatInvitation>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ChatInvitation]s in the list and returns the inserted rows.
  ///
  /// The returned [ChatInvitation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<ChatInvitation>> insert(
    _i1.DatabaseSession session,
    List<ChatInvitation> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<ChatInvitation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [ChatInvitation] and returns the inserted row.
  ///
  /// The returned [ChatInvitation] will have its `id` field set.
  Future<ChatInvitation> insertRow(
    _i1.DatabaseSession session,
    ChatInvitation row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ChatInvitation>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ChatInvitation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ChatInvitation>> update(
    _i1.DatabaseSession session,
    List<ChatInvitation> rows, {
    _i1.ColumnSelections<ChatInvitationTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ChatInvitation>(
      rows,
      columns: columns?.call(ChatInvitation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatInvitation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ChatInvitation> updateRow(
    _i1.DatabaseSession session,
    ChatInvitation row, {
    _i1.ColumnSelections<ChatInvitationTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ChatInvitation>(
      row,
      columns: columns?.call(ChatInvitation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatInvitation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ChatInvitation?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<ChatInvitationUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ChatInvitation>(
      id,
      columnValues: columnValues(ChatInvitation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ChatInvitation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ChatInvitation>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<ChatInvitationUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ChatInvitationTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatInvitationTable>? orderBy,
    _i1.OrderByListBuilder<ChatInvitationTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ChatInvitation>(
      columnValues: columnValues(ChatInvitation.t.updateTable),
      where: where(ChatInvitation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatInvitation.t),
      orderByList: orderByList?.call(ChatInvitation.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ChatInvitation]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ChatInvitation>> delete(
    _i1.DatabaseSession session,
    List<ChatInvitation> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ChatInvitation>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ChatInvitation].
  Future<ChatInvitation> deleteRow(
    _i1.DatabaseSession session,
    ChatInvitation row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ChatInvitation>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ChatInvitation>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ChatInvitationTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ChatInvitation>(
      where: where(ChatInvitation.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatInvitationTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ChatInvitation>(
      where: where?.call(ChatInvitation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ChatInvitation] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ChatInvitationTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ChatInvitation>(
      where: where(ChatInvitation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class ChatInvitationAttachRowRepository {
  const ChatInvitationAttachRowRepository._();

  /// Creates a relation between the given [ChatInvitation] and [Chat]
  /// by setting the [ChatInvitation]'s foreign key `chatId` to refer to the [Chat].
  Future<void> chat(
    _i1.DatabaseSession session,
    ChatInvitation chatInvitation,
    _i2.Chat chat, {
    _i1.Transaction? transaction,
  }) async {
    if (chatInvitation.id == null) {
      throw ArgumentError.notNull('chatInvitation.id');
    }
    if (chat.id == null) {
      throw ArgumentError.notNull('chat.id');
    }

    var $chatInvitation = chatInvitation.copyWith(chatId: chat.id);
    await session.db.updateRow<ChatInvitation>(
      $chatInvitation,
      columns: [ChatInvitation.t.chatId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [ChatInvitation] and [MessengerUser]
  /// by setting the [ChatInvitation]'s foreign key `senderId` to refer to the [MessengerUser].
  Future<void> sender(
    _i1.DatabaseSession session,
    ChatInvitation chatInvitation,
    _i3.MessengerUser sender, {
    _i1.Transaction? transaction,
  }) async {
    if (chatInvitation.id == null) {
      throw ArgumentError.notNull('chatInvitation.id');
    }
    if (sender.id == null) {
      throw ArgumentError.notNull('sender.id');
    }

    var $chatInvitation = chatInvitation.copyWith(senderId: sender.id);
    await session.db.updateRow<ChatInvitation>(
      $chatInvitation,
      columns: [ChatInvitation.t.senderId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [ChatInvitation] and [MessengerUser]
  /// by setting the [ChatInvitation]'s foreign key `receiverId` to refer to the [MessengerUser].
  Future<void> receiver(
    _i1.DatabaseSession session,
    ChatInvitation chatInvitation,
    _i3.MessengerUser receiver, {
    _i1.Transaction? transaction,
  }) async {
    if (chatInvitation.id == null) {
      throw ArgumentError.notNull('chatInvitation.id');
    }
    if (receiver.id == null) {
      throw ArgumentError.notNull('receiver.id');
    }

    var $chatInvitation = chatInvitation.copyWith(receiverId: receiver.id);
    await session.db.updateRow<ChatInvitation>(
      $chatInvitation,
      columns: [ChatInvitation.t.receiverId],
      transaction: transaction,
    );
  }
}

class ChatInvitationDetachRowRepository {
  const ChatInvitationDetachRowRepository._();

  /// Detaches the relation between this [ChatInvitation] and the [Chat] set in `chat`
  /// by setting the [ChatInvitation]'s foreign key `chatId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> chat(
    _i1.DatabaseSession session,
    ChatInvitation chatInvitation, {
    _i1.Transaction? transaction,
  }) async {
    if (chatInvitation.id == null) {
      throw ArgumentError.notNull('chatInvitation.id');
    }

    var $chatInvitation = chatInvitation.copyWith(chatId: null);
    await session.db.updateRow<ChatInvitation>(
      $chatInvitation,
      columns: [ChatInvitation.t.chatId],
      transaction: transaction,
    );
  }
}
