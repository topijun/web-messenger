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
import '../media/media.dart' as _i3;
import 'package:messenger_server/src/generated/protocol.dart' as _i4;

/// Messenger presentation identity. 1:1 with [MessengerUser].
///
/// [profileImage] is null when the user has no uploaded picture; Flutter then
/// shows the default avatar.
abstract class Profile
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Profile._({
    this.id,
    required this.userId,
    this.user,
    required this.aboutMe,
    this.profileImageId,
    this.profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Profile({
    int? id,
    required int userId,
    _i2.MessengerUser? user,
    required String aboutMe,
    int? profileImageId,
    _i3.Media? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProfileImpl;

  factory Profile.fromJson(Map<String, dynamic> jsonSerialization) {
    return Profile(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      user: jsonSerialization['user'] == null
          ? null
          : _i4.Protocol().deserialize<_i2.MessengerUser>(
              jsonSerialization['user'],
            ),
      aboutMe: jsonSerialization['aboutMe'] as String,
      profileImageId: jsonSerialization['profileImageId'] as int?,
      profileImage: jsonSerialization['profileImage'] == null
          ? null
          : _i4.Protocol().deserialize<_i3.Media>(
              jsonSerialization['profileImage'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = ProfileTable();

  static const db = ProfileRepository._();

  @override
  int? id;

  int userId;

  /// The [MessengerUser] this profile belongs to.
  _i2.MessengerUser? user;

  /// Encrypted about-me text (AES-256-GCM). Empty until the user writes one.
  String aboutMe;

  int? profileImageId;

  /// Optional encrypted profile picture. Null shows the default avatar.
  _i3.Media? profileImage;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Profile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Profile copyWith({
    int? id,
    int? userId,
    _i2.MessengerUser? user,
    String? aboutMe,
    int? profileImageId,
    _i3.Media? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Profile',
      if (id != null) 'id': id,
      'userId': userId,
      if (user != null) 'user': user?.toJson(),
      'aboutMe': aboutMe,
      if (profileImageId != null) 'profileImageId': profileImageId,
      if (profileImage != null) 'profileImage': profileImage?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Profile',
      if (id != null) 'id': id,
      'userId': userId,
      if (user != null) 'user': user?.toJsonForProtocol(),
      'aboutMe': aboutMe,
      if (profileImageId != null) 'profileImageId': profileImageId,
      if (profileImage != null)
        'profileImage': profileImage?.toJsonForProtocol(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static ProfileInclude include({
    _i2.MessengerUserInclude? user,
    _i3.MediaInclude? profileImage,
  }) {
    return ProfileInclude._(
      user: user,
      profileImage: profileImage,
    );
  }

  static ProfileIncludeList includeList({
    _i1.WhereExpressionBuilder<ProfileTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProfileTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProfileTable>? orderByList,
    ProfileInclude? include,
  }) {
    return ProfileIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Profile.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Profile.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProfileImpl extends Profile {
  _ProfileImpl({
    int? id,
    required int userId,
    _i2.MessengerUser? user,
    required String aboutMe,
    int? profileImageId,
    _i3.Media? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         userId: userId,
         user: user,
         aboutMe: aboutMe,
         profileImageId: profileImageId,
         profileImage: profileImage,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Profile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Profile copyWith({
    Object? id = _Undefined,
    int? userId,
    Object? user = _Undefined,
    String? aboutMe,
    Object? profileImageId = _Undefined,
    Object? profileImage = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      user: user is _i2.MessengerUser? ? user : this.user?.copyWith(),
      aboutMe: aboutMe ?? this.aboutMe,
      profileImageId: profileImageId is int?
          ? profileImageId
          : this.profileImageId,
      profileImage: profileImage is _i3.Media?
          ? profileImage
          : this.profileImage?.copyWith(),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ProfileUpdateTable extends _i1.UpdateTable<ProfileTable> {
  ProfileUpdateTable(super.table);

  _i1.ColumnValue<int, int> userId(int value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<String, String> aboutMe(String value) => _i1.ColumnValue(
    table.aboutMe,
    value,
  );

  _i1.ColumnValue<int, int> profileImageId(int? value) => _i1.ColumnValue(
    table.profileImageId,
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

class ProfileTable extends _i1.Table<int?> {
  ProfileTable({super.tableRelation}) : super(tableName: 'messenger_profile') {
    updateTable = ProfileUpdateTable(this);
    userId = _i1.ColumnInt(
      'userId',
      this,
    );
    aboutMe = _i1.ColumnString(
      'aboutMe',
      this,
    );
    profileImageId = _i1.ColumnInt(
      'profileImageId',
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

  late final ProfileUpdateTable updateTable;

  late final _i1.ColumnInt userId;

  /// The [MessengerUser] this profile belongs to.
  _i2.MessengerUserTable? _user;

  /// Encrypted about-me text (AES-256-GCM). Empty until the user writes one.
  late final _i1.ColumnString aboutMe;

  late final _i1.ColumnInt profileImageId;

  /// Optional encrypted profile picture. Null shows the default avatar.
  _i3.MediaTable? _profileImage;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  _i2.MessengerUserTable get user {
    if (_user != null) return _user!;
    _user = _i1.createRelationTable(
      relationFieldName: 'user',
      field: Profile.t.userId,
      foreignField: _i2.MessengerUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.MessengerUserTable(tableRelation: foreignTableRelation),
    );
    return _user!;
  }

  _i3.MediaTable get profileImage {
    if (_profileImage != null) return _profileImage!;
    _profileImage = _i1.createRelationTable(
      relationFieldName: 'profileImage',
      field: Profile.t.profileImageId,
      foreignField: _i3.Media.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i3.MediaTable(tableRelation: foreignTableRelation),
    );
    return _profileImage!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    userId,
    aboutMe,
    profileImageId,
    createdAt,
    updatedAt,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'user') {
      return user;
    }
    if (relationField == 'profileImage') {
      return profileImage;
    }
    return null;
  }
}

class ProfileInclude extends _i1.IncludeObject {
  ProfileInclude._({
    _i2.MessengerUserInclude? user,
    _i3.MediaInclude? profileImage,
  }) {
    _user = user;
    _profileImage = profileImage;
  }

  _i2.MessengerUserInclude? _user;

  _i3.MediaInclude? _profileImage;

  @override
  Map<String, _i1.Include?> get includes => {
    'user': _user,
    'profileImage': _profileImage,
  };

  @override
  _i1.Table<int?> get table => Profile.t;
}

class ProfileIncludeList extends _i1.IncludeList {
  ProfileIncludeList._({
    _i1.WhereExpressionBuilder<ProfileTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Profile.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Profile.t;
}

class ProfileRepository {
  const ProfileRepository._();

  final attachRow = const ProfileAttachRowRepository._();

  final detachRow = const ProfileDetachRowRepository._();

  /// Returns a list of [Profile]s matching the given query parameters.
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
  Future<List<Profile>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProfileTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProfileTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProfileTable>? orderByList,
    _i1.Transaction? transaction,
    ProfileInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Profile>(
      where: where?.call(Profile.t),
      orderBy: orderBy?.call(Profile.t),
      orderByList: orderByList?.call(Profile.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Profile] matching the given query parameters.
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
  Future<Profile?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProfileTable>? where,
    int? offset,
    _i1.OrderByBuilder<ProfileTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProfileTable>? orderByList,
    _i1.Transaction? transaction,
    ProfileInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Profile>(
      where: where?.call(Profile.t),
      orderBy: orderBy?.call(Profile.t),
      orderByList: orderByList?.call(Profile.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Profile] by its [id] or null if no such row exists.
  Future<Profile?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    ProfileInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Profile>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Profile]s in the list and returns the inserted rows.
  ///
  /// The returned [Profile]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Profile>> insert(
    _i1.DatabaseSession session,
    List<Profile> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Profile>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Profile] and returns the inserted row.
  ///
  /// The returned [Profile] will have its `id` field set.
  Future<Profile> insertRow(
    _i1.DatabaseSession session,
    Profile row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Profile>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Profile]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Profile>> update(
    _i1.DatabaseSession session,
    List<Profile> rows, {
    _i1.ColumnSelections<ProfileTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Profile>(
      rows,
      columns: columns?.call(Profile.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Profile]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Profile> updateRow(
    _i1.DatabaseSession session,
    Profile row, {
    _i1.ColumnSelections<ProfileTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Profile>(
      row,
      columns: columns?.call(Profile.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Profile] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Profile?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<ProfileUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Profile>(
      id,
      columnValues: columnValues(Profile.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Profile]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Profile>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<ProfileUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ProfileTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProfileTable>? orderBy,
    _i1.OrderByListBuilder<ProfileTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Profile>(
      columnValues: columnValues(Profile.t.updateTable),
      where: where(Profile.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Profile.t),
      orderByList: orderByList?.call(Profile.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Profile]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Profile>> delete(
    _i1.DatabaseSession session,
    List<Profile> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Profile>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Profile].
  Future<Profile> deleteRow(
    _i1.DatabaseSession session,
    Profile row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Profile>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Profile>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ProfileTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Profile>(
      where: where(Profile.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProfileTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Profile>(
      where: where?.call(Profile.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Profile] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ProfileTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Profile>(
      where: where(Profile.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class ProfileAttachRowRepository {
  const ProfileAttachRowRepository._();

  /// Creates a relation between the given [Profile] and [MessengerUser]
  /// by setting the [Profile]'s foreign key `userId` to refer to the [MessengerUser].
  Future<void> user(
    _i1.DatabaseSession session,
    Profile profile,
    _i2.MessengerUser user, {
    _i1.Transaction? transaction,
  }) async {
    if (profile.id == null) {
      throw ArgumentError.notNull('profile.id');
    }
    if (user.id == null) {
      throw ArgumentError.notNull('user.id');
    }

    var $profile = profile.copyWith(userId: user.id);
    await session.db.updateRow<Profile>(
      $profile,
      columns: [Profile.t.userId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [Profile] and [Media]
  /// by setting the [Profile]'s foreign key `profileImageId` to refer to the [Media].
  Future<void> profileImage(
    _i1.DatabaseSession session,
    Profile profile,
    _i3.Media profileImage, {
    _i1.Transaction? transaction,
  }) async {
    if (profile.id == null) {
      throw ArgumentError.notNull('profile.id');
    }
    if (profileImage.id == null) {
      throw ArgumentError.notNull('profileImage.id');
    }

    var $profile = profile.copyWith(profileImageId: profileImage.id);
    await session.db.updateRow<Profile>(
      $profile,
      columns: [Profile.t.profileImageId],
      transaction: transaction,
    );
  }
}

class ProfileDetachRowRepository {
  const ProfileDetachRowRepository._();

  /// Detaches the relation between this [Profile] and the [Media] set in `profileImage`
  /// by setting the [Profile]'s foreign key `profileImageId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> profileImage(
    _i1.DatabaseSession session,
    Profile profile, {
    _i1.Transaction? transaction,
  }) async {
    if (profile.id == null) {
      throw ArgumentError.notNull('profile.id');
    }

    var $profile = profile.copyWith(profileImageId: null);
    await session.db.updateRow<Profile>(
      $profile,
      columns: [Profile.t.profileImageId],
      transaction: transaction,
    );
  }
}
