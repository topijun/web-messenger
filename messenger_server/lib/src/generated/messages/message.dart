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
import '../messages/message_type.dart' as _i4;
import '../media/media.dart' as _i5;
import '../messages/message_receipt.dart' as _i6;
import 'package:messenger_server/src/generated/protocol.dart' as _i7;

/// A chat message. One row for every type of content.
///
/// [encryptedText] is AES-256-GCM ciphertext produced by EncryptionService.
/// Do not add a separate plaintext text column.
abstract class Message
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Message._({
    this.id,
    required this.chatId,
    this.chat,
    required this.senderId,
    this.sender,
    required this.type,
    required this.encryptedText,
    this.mediaId,
    this.media,
    this.pollId,
    required this.createdAt,
    this.editedAt,
    this.deletedAt,
    this.receipts,
  });

  factory Message({
    int? id,
    required int chatId,
    _i2.Chat? chat,
    required int senderId,
    _i3.MessengerUser? sender,
    required _i4.MessageType type,
    required String encryptedText,
    int? mediaId,
    _i5.Media? media,
    int? pollId,
    required DateTime createdAt,
    DateTime? editedAt,
    DateTime? deletedAt,
    List<_i6.MessageReceipt>? receipts,
  }) = _MessageImpl;

  factory Message.fromJson(Map<String, dynamic> jsonSerialization) {
    return Message(
      id: jsonSerialization['id'] as int?,
      chatId: jsonSerialization['chatId'] as int,
      chat: jsonSerialization['chat'] == null
          ? null
          : _i7.Protocol().deserialize<_i2.Chat>(jsonSerialization['chat']),
      senderId: jsonSerialization['senderId'] as int,
      sender: jsonSerialization['sender'] == null
          ? null
          : _i7.Protocol().deserialize<_i3.MessengerUser>(
              jsonSerialization['sender'],
            ),
      type: _i4.MessageType.fromJson((jsonSerialization['type'] as String)),
      encryptedText: jsonSerialization['encryptedText'] as String,
      mediaId: jsonSerialization['mediaId'] as int?,
      media: jsonSerialization['media'] == null
          ? null
          : _i7.Protocol().deserialize<_i5.Media>(jsonSerialization['media']),
      pollId: jsonSerialization['pollId'] as int?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      editedAt: jsonSerialization['editedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['editedAt']),
      deletedAt: jsonSerialization['deletedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['deletedAt']),
      receipts: jsonSerialization['receipts'] == null
          ? null
          : _i7.Protocol().deserialize<List<_i6.MessageReceipt>>(
              jsonSerialization['receipts'],
            ),
    );
  }

  static final t = MessageTable();

  static const db = MessageRepository._();

  @override
  int? id;

  int chatId;

  _i2.Chat? chat;

  int senderId;

  _i3.MessengerUser? sender;

  _i4.MessageType type;

  /// Ciphertext of the message body (AES-256-GCM, server-side).
  /// Clients send and receive plaintext through the API; PostgreSQL stores
  /// only the versioned ciphertext from EncryptionService.
  String encryptedText;

  int? mediaId;

  /// Optional encrypted image/video. Null for text messages.
  _i5.Media? media;

  /// Optional Poll reference. Unused until the poll phase.
  int? pollId;

  DateTime createdAt;

  DateTime? editedAt;

  DateTime? deletedAt;

  List<_i6.MessageReceipt>? receipts;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Message]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Message copyWith({
    int? id,
    int? chatId,
    _i2.Chat? chat,
    int? senderId,
    _i3.MessengerUser? sender,
    _i4.MessageType? type,
    String? encryptedText,
    int? mediaId,
    _i5.Media? media,
    int? pollId,
    DateTime? createdAt,
    DateTime? editedAt,
    DateTime? deletedAt,
    List<_i6.MessageReceipt>? receipts,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Message',
      if (id != null) 'id': id,
      'chatId': chatId,
      if (chat != null) 'chat': chat?.toJson(),
      'senderId': senderId,
      if (sender != null) 'sender': sender?.toJson(),
      'type': type.toJson(),
      'encryptedText': encryptedText,
      if (mediaId != null) 'mediaId': mediaId,
      if (media != null) 'media': media?.toJson(),
      if (pollId != null) 'pollId': pollId,
      'createdAt': createdAt.toJson(),
      if (editedAt != null) 'editedAt': editedAt?.toJson(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      if (receipts != null)
        'receipts': receipts?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Message',
      if (id != null) 'id': id,
      'chatId': chatId,
      if (chat != null) 'chat': chat?.toJsonForProtocol(),
      'senderId': senderId,
      if (sender != null) 'sender': sender?.toJsonForProtocol(),
      'type': type.toJson(),
      'encryptedText': encryptedText,
      if (mediaId != null) 'mediaId': mediaId,
      if (media != null) 'media': media?.toJsonForProtocol(),
      if (pollId != null) 'pollId': pollId,
      'createdAt': createdAt.toJson(),
      if (editedAt != null) 'editedAt': editedAt?.toJson(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      if (receipts != null)
        'receipts': receipts?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  static MessageInclude include({
    _i2.ChatInclude? chat,
    _i3.MessengerUserInclude? sender,
    _i5.MediaInclude? media,
    _i6.MessageReceiptIncludeList? receipts,
  }) {
    return MessageInclude._(
      chat: chat,
      sender: sender,
      media: media,
      receipts: receipts,
    );
  }

  static MessageIncludeList includeList({
    _i1.WhereExpressionBuilder<MessageTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MessageTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MessageTable>? orderByList,
    MessageInclude? include,
  }) {
    return MessageIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Message.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Message.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MessageImpl extends Message {
  _MessageImpl({
    int? id,
    required int chatId,
    _i2.Chat? chat,
    required int senderId,
    _i3.MessengerUser? sender,
    required _i4.MessageType type,
    required String encryptedText,
    int? mediaId,
    _i5.Media? media,
    int? pollId,
    required DateTime createdAt,
    DateTime? editedAt,
    DateTime? deletedAt,
    List<_i6.MessageReceipt>? receipts,
  }) : super._(
         id: id,
         chatId: chatId,
         chat: chat,
         senderId: senderId,
         sender: sender,
         type: type,
         encryptedText: encryptedText,
         mediaId: mediaId,
         media: media,
         pollId: pollId,
         createdAt: createdAt,
         editedAt: editedAt,
         deletedAt: deletedAt,
         receipts: receipts,
       );

  /// Returns a shallow copy of this [Message]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Message copyWith({
    Object? id = _Undefined,
    int? chatId,
    Object? chat = _Undefined,
    int? senderId,
    Object? sender = _Undefined,
    _i4.MessageType? type,
    String? encryptedText,
    Object? mediaId = _Undefined,
    Object? media = _Undefined,
    Object? pollId = _Undefined,
    DateTime? createdAt,
    Object? editedAt = _Undefined,
    Object? deletedAt = _Undefined,
    Object? receipts = _Undefined,
  }) {
    return Message(
      id: id is int? ? id : this.id,
      chatId: chatId ?? this.chatId,
      chat: chat is _i2.Chat? ? chat : this.chat?.copyWith(),
      senderId: senderId ?? this.senderId,
      sender: sender is _i3.MessengerUser? ? sender : this.sender?.copyWith(),
      type: type ?? this.type,
      encryptedText: encryptedText ?? this.encryptedText,
      mediaId: mediaId is int? ? mediaId : this.mediaId,
      media: media is _i5.Media? ? media : this.media?.copyWith(),
      pollId: pollId is int? ? pollId : this.pollId,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt is DateTime? ? editedAt : this.editedAt,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
      receipts: receipts is List<_i6.MessageReceipt>?
          ? receipts
          : this.receipts?.map((e0) => e0.copyWith()).toList(),
    );
  }
}

class MessageUpdateTable extends _i1.UpdateTable<MessageTable> {
  MessageUpdateTable(super.table);

  _i1.ColumnValue<int, int> chatId(int value) => _i1.ColumnValue(
    table.chatId,
    value,
  );

  _i1.ColumnValue<int, int> senderId(int value) => _i1.ColumnValue(
    table.senderId,
    value,
  );

  _i1.ColumnValue<_i4.MessageType, _i4.MessageType> type(
    _i4.MessageType value,
  ) => _i1.ColumnValue(
    table.type,
    value,
  );

  _i1.ColumnValue<String, String> encryptedText(String value) =>
      _i1.ColumnValue(
        table.encryptedText,
        value,
      );

  _i1.ColumnValue<int, int> mediaId(int? value) => _i1.ColumnValue(
    table.mediaId,
    value,
  );

  _i1.ColumnValue<int, int> pollId(int? value) => _i1.ColumnValue(
    table.pollId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> editedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.editedAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> deletedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.deletedAt,
        value,
      );
}

class MessageTable extends _i1.Table<int?> {
  MessageTable({super.tableRelation}) : super(tableName: 'messenger_message') {
    updateTable = MessageUpdateTable(this);
    chatId = _i1.ColumnInt(
      'chatId',
      this,
    );
    senderId = _i1.ColumnInt(
      'senderId',
      this,
    );
    type = _i1.ColumnEnum(
      'type',
      this,
      _i1.EnumSerialization.byName,
    );
    encryptedText = _i1.ColumnString(
      'encryptedText',
      this,
    );
    mediaId = _i1.ColumnInt(
      'mediaId',
      this,
    );
    pollId = _i1.ColumnInt(
      'pollId',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    editedAt = _i1.ColumnDateTime(
      'editedAt',
      this,
    );
    deletedAt = _i1.ColumnDateTime(
      'deletedAt',
      this,
    );
  }

  late final MessageUpdateTable updateTable;

  late final _i1.ColumnInt chatId;

  _i2.ChatTable? _chat;

  late final _i1.ColumnInt senderId;

  _i3.MessengerUserTable? _sender;

  late final _i1.ColumnEnum<_i4.MessageType> type;

  /// Ciphertext of the message body (AES-256-GCM, server-side).
  /// Clients send and receive plaintext through the API; PostgreSQL stores
  /// only the versioned ciphertext from EncryptionService.
  late final _i1.ColumnString encryptedText;

  late final _i1.ColumnInt mediaId;

  /// Optional encrypted image/video. Null for text messages.
  _i5.MediaTable? _media;

  /// Optional Poll reference. Unused until the poll phase.
  late final _i1.ColumnInt pollId;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime editedAt;

  late final _i1.ColumnDateTime deletedAt;

  _i6.MessageReceiptTable? ___receipts;

  _i1.ManyRelation<_i6.MessageReceiptTable>? _receipts;

  _i2.ChatTable get chat {
    if (_chat != null) return _chat!;
    _chat = _i1.createRelationTable(
      relationFieldName: 'chat',
      field: Message.t.chatId,
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
      field: Message.t.senderId,
      foreignField: _i3.MessengerUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i3.MessengerUserTable(tableRelation: foreignTableRelation),
    );
    return _sender!;
  }

  _i5.MediaTable get media {
    if (_media != null) return _media!;
    _media = _i1.createRelationTable(
      relationFieldName: 'media',
      field: Message.t.mediaId,
      foreignField: _i5.Media.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i5.MediaTable(tableRelation: foreignTableRelation),
    );
    return _media!;
  }

  _i6.MessageReceiptTable get __receipts {
    if (___receipts != null) return ___receipts!;
    ___receipts = _i1.createRelationTable(
      relationFieldName: '__receipts',
      field: Message.t.id,
      foreignField: _i6.MessageReceipt.t.messageId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i6.MessageReceiptTable(tableRelation: foreignTableRelation),
    );
    return ___receipts!;
  }

  _i1.ManyRelation<_i6.MessageReceiptTable> get receipts {
    if (_receipts != null) return _receipts!;
    var relationTable = _i1.createRelationTable(
      relationFieldName: 'receipts',
      field: Message.t.id,
      foreignField: _i6.MessageReceipt.t.messageId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i6.MessageReceiptTable(tableRelation: foreignTableRelation),
    );
    _receipts = _i1.ManyRelation<_i6.MessageReceiptTable>(
      tableWithRelations: relationTable,
      table: _i6.MessageReceiptTable(
        tableRelation: relationTable.tableRelation!.lastRelation,
      ),
    );
    return _receipts!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    chatId,
    senderId,
    type,
    encryptedText,
    mediaId,
    pollId,
    createdAt,
    editedAt,
    deletedAt,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'chat') {
      return chat;
    }
    if (relationField == 'sender') {
      return sender;
    }
    if (relationField == 'media') {
      return media;
    }
    if (relationField == 'receipts') {
      return __receipts;
    }
    return null;
  }
}

class MessageInclude extends _i1.IncludeObject {
  MessageInclude._({
    _i2.ChatInclude? chat,
    _i3.MessengerUserInclude? sender,
    _i5.MediaInclude? media,
    _i6.MessageReceiptIncludeList? receipts,
  }) {
    _chat = chat;
    _sender = sender;
    _media = media;
    _receipts = receipts;
  }

  _i2.ChatInclude? _chat;

  _i3.MessengerUserInclude? _sender;

  _i5.MediaInclude? _media;

  _i6.MessageReceiptIncludeList? _receipts;

  @override
  Map<String, _i1.Include?> get includes => {
    'chat': _chat,
    'sender': _sender,
    'media': _media,
    'receipts': _receipts,
  };

  @override
  _i1.Table<int?> get table => Message.t;
}

class MessageIncludeList extends _i1.IncludeList {
  MessageIncludeList._({
    _i1.WhereExpressionBuilder<MessageTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Message.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Message.t;
}

class MessageRepository {
  const MessageRepository._();

  final attach = const MessageAttachRepository._();

  final attachRow = const MessageAttachRowRepository._();

  final detach = const MessageDetachRepository._();

  final detachRow = const MessageDetachRowRepository._();

  /// Returns a list of [Message]s matching the given query parameters.
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
  Future<List<Message>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MessageTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MessageTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MessageTable>? orderByList,
    _i1.Transaction? transaction,
    MessageInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Message>(
      where: where?.call(Message.t),
      orderBy: orderBy?.call(Message.t),
      orderByList: orderByList?.call(Message.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Message] matching the given query parameters.
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
  Future<Message?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MessageTable>? where,
    int? offset,
    _i1.OrderByBuilder<MessageTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MessageTable>? orderByList,
    _i1.Transaction? transaction,
    MessageInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Message>(
      where: where?.call(Message.t),
      orderBy: orderBy?.call(Message.t),
      orderByList: orderByList?.call(Message.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Message] by its [id] or null if no such row exists.
  Future<Message?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    MessageInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Message>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Message]s in the list and returns the inserted rows.
  ///
  /// The returned [Message]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Message>> insert(
    _i1.DatabaseSession session,
    List<Message> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Message>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Message] and returns the inserted row.
  ///
  /// The returned [Message] will have its `id` field set.
  Future<Message> insertRow(
    _i1.DatabaseSession session,
    Message row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Message>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Message]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Message>> update(
    _i1.DatabaseSession session,
    List<Message> rows, {
    _i1.ColumnSelections<MessageTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Message>(
      rows,
      columns: columns?.call(Message.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Message]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Message> updateRow(
    _i1.DatabaseSession session,
    Message row, {
    _i1.ColumnSelections<MessageTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Message>(
      row,
      columns: columns?.call(Message.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Message] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Message?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<MessageUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Message>(
      id,
      columnValues: columnValues(Message.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Message]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Message>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<MessageUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<MessageTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MessageTable>? orderBy,
    _i1.OrderByListBuilder<MessageTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Message>(
      columnValues: columnValues(Message.t.updateTable),
      where: where(Message.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Message.t),
      orderByList: orderByList?.call(Message.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Message]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Message>> delete(
    _i1.DatabaseSession session,
    List<Message> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Message>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Message].
  Future<Message> deleteRow(
    _i1.DatabaseSession session,
    Message row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Message>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Message>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MessageTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Message>(
      where: where(Message.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MessageTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Message>(
      where: where?.call(Message.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Message] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MessageTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Message>(
      where: where(Message.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class MessageAttachRepository {
  const MessageAttachRepository._();

  /// Creates a relation between this [Message] and the given [MessageReceipt]s
  /// by setting each [MessageReceipt]'s foreign key `messageId` to refer to this [Message].
  Future<void> receipts(
    _i1.DatabaseSession session,
    Message message,
    List<_i6.MessageReceipt> messageReceipt, {
    _i1.Transaction? transaction,
  }) async {
    if (messageReceipt.any((e) => e.id == null)) {
      throw ArgumentError.notNull('messageReceipt.id');
    }
    if (message.id == null) {
      throw ArgumentError.notNull('message.id');
    }

    var $messageReceipt = messageReceipt
        .map((e) => e.copyWith(messageId: message.id))
        .toList();
    await session.db.update<_i6.MessageReceipt>(
      $messageReceipt,
      columns: [_i6.MessageReceipt.t.messageId],
      transaction: transaction,
    );
  }
}

class MessageAttachRowRepository {
  const MessageAttachRowRepository._();

  /// Creates a relation between the given [Message] and [Chat]
  /// by setting the [Message]'s foreign key `chatId` to refer to the [Chat].
  Future<void> chat(
    _i1.DatabaseSession session,
    Message message,
    _i2.Chat chat, {
    _i1.Transaction? transaction,
  }) async {
    if (message.id == null) {
      throw ArgumentError.notNull('message.id');
    }
    if (chat.id == null) {
      throw ArgumentError.notNull('chat.id');
    }

    var $message = message.copyWith(chatId: chat.id);
    await session.db.updateRow<Message>(
      $message,
      columns: [Message.t.chatId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [Message] and [MessengerUser]
  /// by setting the [Message]'s foreign key `senderId` to refer to the [MessengerUser].
  Future<void> sender(
    _i1.DatabaseSession session,
    Message message,
    _i3.MessengerUser sender, {
    _i1.Transaction? transaction,
  }) async {
    if (message.id == null) {
      throw ArgumentError.notNull('message.id');
    }
    if (sender.id == null) {
      throw ArgumentError.notNull('sender.id');
    }

    var $message = message.copyWith(senderId: sender.id);
    await session.db.updateRow<Message>(
      $message,
      columns: [Message.t.senderId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [Message] and [Media]
  /// by setting the [Message]'s foreign key `mediaId` to refer to the [Media].
  Future<void> media(
    _i1.DatabaseSession session,
    Message message,
    _i5.Media media, {
    _i1.Transaction? transaction,
  }) async {
    if (message.id == null) {
      throw ArgumentError.notNull('message.id');
    }
    if (media.id == null) {
      throw ArgumentError.notNull('media.id');
    }

    var $message = message.copyWith(mediaId: media.id);
    await session.db.updateRow<Message>(
      $message,
      columns: [Message.t.mediaId],
      transaction: transaction,
    );
  }

  /// Creates a relation between this [Message] and the given [MessageReceipt]
  /// by setting the [MessageReceipt]'s foreign key `messageId` to refer to this [Message].
  Future<void> receipts(
    _i1.DatabaseSession session,
    Message message,
    _i6.MessageReceipt messageReceipt, {
    _i1.Transaction? transaction,
  }) async {
    if (messageReceipt.id == null) {
      throw ArgumentError.notNull('messageReceipt.id');
    }
    if (message.id == null) {
      throw ArgumentError.notNull('message.id');
    }

    var $messageReceipt = messageReceipt.copyWith(messageId: message.id);
    await session.db.updateRow<_i6.MessageReceipt>(
      $messageReceipt,
      columns: [_i6.MessageReceipt.t.messageId],
      transaction: transaction,
    );
  }
}

class MessageDetachRepository {
  const MessageDetachRepository._();

  /// Detaches the relation between this [Message] and the given [MessageReceipt]
  /// by setting the [MessageReceipt]'s foreign key `messageId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> receipts(
    _i1.DatabaseSession session,
    List<_i6.MessageReceipt> messageReceipt, {
    _i1.Transaction? transaction,
  }) async {
    if (messageReceipt.any((e) => e.id == null)) {
      throw ArgumentError.notNull('messageReceipt.id');
    }

    var $messageReceipt = messageReceipt
        .map((e) => e.copyWith(messageId: null))
        .toList();
    await session.db.update<_i6.MessageReceipt>(
      $messageReceipt,
      columns: [_i6.MessageReceipt.t.messageId],
      transaction: transaction,
    );
  }
}

class MessageDetachRowRepository {
  const MessageDetachRowRepository._();

  /// Detaches the relation between this [Message] and the [Media] set in `media`
  /// by setting the [Message]'s foreign key `mediaId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> media(
    _i1.DatabaseSession session,
    Message message, {
    _i1.Transaction? transaction,
  }) async {
    if (message.id == null) {
      throw ArgumentError.notNull('message.id');
    }

    var $message = message.copyWith(mediaId: null);
    await session.db.updateRow<Message>(
      $message,
      columns: [Message.t.mediaId],
      transaction: transaction,
    );
  }

  /// Detaches the relation between this [Message] and the given [MessageReceipt]
  /// by setting the [MessageReceipt]'s foreign key `messageId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> receipts(
    _i1.DatabaseSession session,
    _i6.MessageReceipt messageReceipt, {
    _i1.Transaction? transaction,
  }) async {
    if (messageReceipt.id == null) {
      throw ArgumentError.notNull('messageReceipt.id');
    }

    var $messageReceipt = messageReceipt.copyWith(messageId: null);
    await session.db.updateRow<_i6.MessageReceipt>(
      $messageReceipt,
      columns: [_i6.MessageReceipt.t.messageId],
      transaction: transaction,
    );
  }
}
