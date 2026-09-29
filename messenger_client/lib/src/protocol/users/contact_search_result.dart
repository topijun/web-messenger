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

import 'package:serverpod_client/serverpod_client.dart' as _i1;
import '../users/contact_search_relation.dart' as _i2;

/// Public contact match for invitation targeting.
///
/// Does not include auth identifiers, email, or credentials.
abstract class ContactSearchResult implements _i1.SerializableModel {
  ContactSearchResult._({
    required this.username,
    required this.relation,
    this.profileImageId,
  });

  factory ContactSearchResult({
    required String username,
    required _i2.ContactSearchRelation relation,
    int? profileImageId,
  }) = _ContactSearchResultImpl;

  factory ContactSearchResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return ContactSearchResult(
      username: jsonSerialization['username'] as String,
      relation: _i2.ContactSearchRelation.fromJson(
        (jsonSerialization['relation'] as String),
      ),
      profileImageId: jsonSerialization['profileImageId'] as int?,
    );
  }

  String username;

  _i2.ContactSearchRelation relation;

  int? profileImageId;

  /// Returns a shallow copy of this [ContactSearchResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ContactSearchResult copyWith({
    String? username,
    _i2.ContactSearchRelation? relation,
    int? profileImageId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ContactSearchResult',
      'username': username,
      'relation': relation.toJson(),
      if (profileImageId != null) 'profileImageId': profileImageId,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ContactSearchResultImpl extends ContactSearchResult {
  _ContactSearchResultImpl({
    required String username,
    required _i2.ContactSearchRelation relation,
    int? profileImageId,
  }) : super._(
         username: username,
         relation: relation,
         profileImageId: profileImageId,
       );

  /// Returns a shallow copy of this [ContactSearchResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ContactSearchResult copyWith({
    String? username,
    _i2.ContactSearchRelation? relation,
    Object? profileImageId = _Undefined,
  }) {
    return ContactSearchResult(
      username: username ?? this.username,
      relation: relation ?? this.relation,
      profileImageId: profileImageId is int?
          ? profileImageId
          : this.profileImageId,
    );
  }
}
