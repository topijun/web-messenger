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
import '../users/messenger_user.dart' as _i2;
import '../media/media_type.dart' as _i3;
import 'dart:typed_data' as _i4;
import 'package:messenger_server/src/generated/protocol.dart' as _i5;

/// Encrypted media blob and metadata. Used for profile pictures and
/// chat image/video/audio messages.
///
/// [encryptedData] is AES-256-GCM ciphertext (version byte + nonce +
/// ciphertext + tag). Original media bytes are never stored.
abstract class Media implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Media._({
    this.id,
    required this.userId,
    this.user,
    required this.type,
    required this.mimeType,
    required this.size,
    required this.encryptedData,
    this.thumbnailMediaId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Media({
    int? id,
    required int userId,
    _i2.MessengerUser? user,
    required _i3.MediaType type,
    required String mimeType,
    required int size,
    required _i4.ByteData encryptedData,
    int? thumbnailMediaId,
    DateTime? createdAt,
  }) = _MediaImpl;

  factory Media.fromJson(Map<String, dynamic> jsonSerialization) {
    return Media(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      user: jsonSerialization['user'] == null
          ? null
          : _i5.Protocol().deserialize<_i2.MessengerUser>(
              jsonSerialization['user'],
            ),
      type: _i3.MediaType.fromJson((jsonSerialization['type'] as String)),
      mimeType: jsonSerialization['mimeType'] as String,
      size: jsonSerialization['size'] as int,
      encryptedData: _i1.ByteDataJsonExtension.fromJson(
        jsonSerialization['encryptedData'],
      ),
      thumbnailMediaId: jsonSerialization['thumbnailMediaId'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = MediaTable();

  static const db = MediaRepository._();

  @override
  int? id;

  int userId;

  /// Owner. Profile pictures are only readable/replaceable by this user.
  _i2.MessengerUser? user;

  _i3.MediaType type;

  String mimeType;

  /// Original plaintext size in bytes, before encryption.
  int size;

  /// AES-256-GCM packed ciphertext. Not the original file bytes.
  _i4.ByteData encryptedData;

  /// Optional encrypted JPEG poster media id for a video row.
  int? thumbnailMediaId;

  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Media]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Media copyWith({
    int? id,
    int? userId,
    _i2.MessengerUser? user,
    _i3.MediaType? type,
    String? mimeType,
    int? size,
    _i4.ByteData? encryptedData,
    int? thumbnailMediaId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Media',
      if (id != null) 'id': id,
      'userId': userId,
      if (user != null) 'user': user?.toJson(),
      'type': type.toJson(),
      'mimeType': mimeType,
      'size': size,
      'encryptedData': encryptedData.toJson(),
      if (thumbnailMediaId != null) 'thumbnailMediaId': thumbnailMediaId,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Media',
      if (id != null) 'id': id,
      'userId': userId,
      if (user != null) 'user': user?.toJsonForProtocol(),
      'type': type.toJson(),
      'mimeType': mimeType,
      'size': size,
      'encryptedData': encryptedData.toJson(),
      if (thumbnailMediaId != null) 'thumbnailMediaId': thumbnailMediaId,
      'createdAt': createdAt.toJson(),
    };
  }

  static MediaInclude include({_i2.MessengerUserInclude? user}) {
    return MediaInclude._(user: user);
  }

  static MediaIncludeList includeList({
    _i1.WhereExpressionBuilder<MediaTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MediaTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MediaTable>? orderByList,
    MediaInclude? include,
  }) {
    return MediaIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Media.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Media.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MediaImpl extends Media {
  _MediaImpl({
    int? id,
    required int userId,
    _i2.MessengerUser? user,
    required _i3.MediaType type,
    required String mimeType,
    required int size,
    required _i4.ByteData encryptedData,
    int? thumbnailMediaId,
    DateTime? createdAt,
  }) : super._(
         id: id,
         userId: userId,
         user: user,
         type: type,
         mimeType: mimeType,
         size: size,
         encryptedData: encryptedData,
         thumbnailMediaId: thumbnailMediaId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Media]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Media copyWith({
    Object? id = _Undefined,
    int? userId,
    Object? user = _Undefined,
    _i3.MediaType? type,
    String? mimeType,
    int? size,
    _i4.ByteData? encryptedData,
    Object? thumbnailMediaId = _Undefined,
    DateTime? createdAt,
  }) {
    return Media(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      user: user is _i2.MessengerUser? ? user : this.user?.copyWith(),
      type: type ?? this.type,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      encryptedData: encryptedData ?? this.encryptedData.clone(),
      thumbnailMediaId: thumbnailMediaId is int?
          ? thumbnailMediaId
          : this.thumbnailMediaId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MediaUpdateTable extends _i1.UpdateTable<MediaTable> {
  MediaUpdateTable(super.table);

  _i1.ColumnValue<int, int> userId(int value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<_i3.MediaType, _i3.MediaType> type(_i3.MediaType value) =>
      _i1.ColumnValue(
        table.type,
        value,
      );

  _i1.ColumnValue<String, String> mimeType(String value) => _i1.ColumnValue(
    table.mimeType,
    value,
  );

  _i1.ColumnValue<int, int> size(int value) => _i1.ColumnValue(
    table.size,
    value,
  );

  _i1.ColumnValue<_i4.ByteData, _i4.ByteData> encryptedData(
    _i4.ByteData value,
  ) => _i1.ColumnValue(
    table.encryptedData,
    value,
  );

  _i1.ColumnValue<int, int> thumbnailMediaId(int? value) => _i1.ColumnValue(
    table.thumbnailMediaId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class MediaTable extends _i1.Table<int?> {
  MediaTable({super.tableRelation}) : super(tableName: 'messenger_media') {
    updateTable = MediaUpdateTable(this);
    userId = _i1.ColumnInt(
      'userId',
      this,
    );
    type = _i1.ColumnEnum(
      'type',
      this,
      _i1.EnumSerialization.byName,
    );
    mimeType = _i1.ColumnString(
      'mimeType',
      this,
    );
    size = _i1.ColumnInt(
      'size',
      this,
    );
    encryptedData = _i1.ColumnByteData(
      'encryptedData',
      this,
    );
    thumbnailMediaId = _i1.ColumnInt(
      'thumbnailMediaId',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final MediaUpdateTable updateTable;

  late final _i1.ColumnInt userId;

  /// Owner. Profile pictures are only readable/replaceable by this user.
  _i2.MessengerUserTable? _user;

  late final _i1.ColumnEnum<_i3.MediaType> type;

  late final _i1.ColumnString mimeType;

  /// Original plaintext size in bytes, before encryption.
  late final _i1.ColumnInt size;

  /// AES-256-GCM packed ciphertext. Not the original file bytes.
  late final _i1.ColumnByteData encryptedData;

  /// Optional encrypted JPEG poster media id for a video row.
  late final _i1.ColumnInt thumbnailMediaId;

  late final _i1.ColumnDateTime createdAt;

  _i2.MessengerUserTable get user {
    if (_user != null) return _user!;
    _user = _i1.createRelationTable(
      relationFieldName: 'user',
      field: Media.t.userId,
      foreignField: _i2.MessengerUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.MessengerUserTable(tableRelation: foreignTableRelation),
    );
    return _user!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    userId,
    type,
    mimeType,
    size,
    encryptedData,
    thumbnailMediaId,
    createdAt,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'user') {
      return user;
    }
    return null;
  }
}

class MediaInclude extends _i1.IncludeObject {
  MediaInclude._({_i2.MessengerUserInclude? user}) {
    _user = user;
  }

  _i2.MessengerUserInclude? _user;

  @override
  Map<String, _i1.Include?> get includes => {'user': _user};

  @override
  _i1.Table<int?> get table => Media.t;
}

class MediaIncludeList extends _i1.IncludeList {
  MediaIncludeList._({
    _i1.WhereExpressionBuilder<MediaTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Media.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Media.t;
}

class MediaRepository {
  const MediaRepository._();

  final attachRow = const MediaAttachRowRepository._();

  /// Returns a list of [Media]s matching the given query parameters.
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
  Future<List<Media>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MediaTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MediaTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MediaTable>? orderByList,
    _i1.Transaction? transaction,
    MediaInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Media>(
      where: where?.call(Media.t),
      orderBy: orderBy?.call(Media.t),
      orderByList: orderByList?.call(Media.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Media] matching the given query parameters.
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
  Future<Media?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MediaTable>? where,
    int? offset,
    _i1.OrderByBuilder<MediaTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MediaTable>? orderByList,
    _i1.Transaction? transaction,
    MediaInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Media>(
      where: where?.call(Media.t),
      orderBy: orderBy?.call(Media.t),
      orderByList: orderByList?.call(Media.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Media] by its [id] or null if no such row exists.
  Future<Media?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    MediaInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Media>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Media]s in the list and returns the inserted rows.
  ///
  /// The returned [Media]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Media>> insert(
    _i1.DatabaseSession session,
    List<Media> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Media>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Media] and returns the inserted row.
  ///
  /// The returned [Media] will have its `id` field set.
  Future<Media> insertRow(
    _i1.DatabaseSession session,
    Media row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Media>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Media]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Media>> update(
    _i1.DatabaseSession session,
    List<Media> rows, {
    _i1.ColumnSelections<MediaTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Media>(
      rows,
      columns: columns?.call(Media.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Media]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Media> updateRow(
    _i1.DatabaseSession session,
    Media row, {
    _i1.ColumnSelections<MediaTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Media>(
      row,
      columns: columns?.call(Media.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Media] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Media?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<MediaUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Media>(
      id,
      columnValues: columnValues(Media.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Media]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Media>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<MediaUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<MediaTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MediaTable>? orderBy,
    _i1.OrderByListBuilder<MediaTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Media>(
      columnValues: columnValues(Media.t.updateTable),
      where: where(Media.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Media.t),
      orderByList: orderByList?.call(Media.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Media]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Media>> delete(
    _i1.DatabaseSession session,
    List<Media> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Media>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Media].
  Future<Media> deleteRow(
    _i1.DatabaseSession session,
    Media row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Media>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Media>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MediaTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Media>(
      where: where(Media.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MediaTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Media>(
      where: where?.call(Media.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Media] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MediaTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Media>(
      where: where(Media.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class MediaAttachRowRepository {
  const MediaAttachRowRepository._();

  /// Creates a relation between the given [Media] and [MessengerUser]
  /// by setting the [Media]'s foreign key `userId` to refer to the [MessengerUser].
  Future<void> user(
    _i1.DatabaseSession session,
    Media media,
    _i2.MessengerUser user, {
    _i1.Transaction? transaction,
  }) async {
    if (media.id == null) {
      throw ArgumentError.notNull('media.id');
    }
    if (user.id == null) {
      throw ArgumentError.notNull('user.id');
    }

    var $media = media.copyWith(userId: user.id);
    await session.db.updateRow<Media>(
      $media,
      columns: [Media.t.userId],
      transaction: transaction,
    );
  }
}
