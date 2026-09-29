import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import '../generated/protocol.dart';
import 'messenger_username.dart';

/// Creates and looks up [MessengerUser] rows for authenticated [AuthUser]s.
class MessengerUsers {
  /// Creates a [MessengerUsers] instance.
  const MessengerUsers();

  /// Returns the [MessengerUser] for [authUserId], if one exists.
  Future<MessengerUser?> findByAuthUserId(
    Session session, {
    required UuidValue authUserId,
    Transaction? transaction,
  }) {
    return MessengerUser.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
      transaction: transaction,
    );
  }

  /// Returns the [MessengerUser] with [username], ignoring case.
  Future<MessengerUser?> findByUsername(
    Session session, {
    required String username,
    Transaction? transaction,
  }) {
    final usernameNormalized = username.trim().toLowerCase();
    if (usernameNormalized.isEmpty) {
      return Future.value(null);
    }
    return MessengerUser.db.findFirstRow(
      session,
      where: (t) => t.usernameNormalized.equals(usernameNormalized),
      transaction: transaction,
    );
  }

  /// Returns the [MessengerUser] whose Email IDP account matches [email].
  ///
  /// [email] is compared case-insensitively against the authoritative
  /// `EmailAccount` row. Does not copy email onto [MessengerUser].
  Future<MessengerUser?> findByEmail(
    Session session, {
    required String email,
    Transaction? transaction,
  }) async {
    final emailNormalized = email.trim().toLowerCase();
    if (emailNormalized.isEmpty || !emailNormalized.contains('@')) {
      return null;
    }
    final account = await EmailAccount.db.findFirstRow(
      session,
      where: (t) => t.email.equals(emailNormalized),
      transaction: transaction,
    );
    if (account == null) {
      return null;
    }
    return findByAuthUserId(
      session,
      authUserId: account.authUserId,
      transaction: transaction,
    );
  }

  /// Exact username lookup, or email lookup when [query] contains `@`.
  Future<MessengerUser?> findByQuery(
    Session session, {
    required String query,
    Transaction? transaction,
  }) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return Future.value(null);
    }
    if (trimmed.contains('@')) {
      return findByEmail(session, email: trimmed, transaction: transaction);
    }
    return findByUsername(session, username: trimmed, transaction: transaction);
  }

  /// Returns whether [username] is already used, ignoring case.
  Future<bool> isUsernameTaken(
    Session session, {
    required String username,
    Transaction? transaction,
  }) async {
    final usernameNormalized = MessengerUsername.normalized(
      MessengerUsername.display(username),
    );
    return _isNormalizedUsernameTaken(
      session,
      usernameNormalized: usernameNormalized,
      transaction: transaction,
    );
  }

  /// Creates a [MessengerUser] for [authUserId].
  ///
  /// Throws [MessengerUserAlreadyExistsException] if this auth user already has
  /// a Messenger user.
  ///
  /// Throws [MessengerUsernameTakenException] if [username] is already used.
  Future<MessengerUser> create(
    Session session, {
    required UuidValue authUserId,
    required String username,
    Transaction? transaction,
  }) async {
    final displayUsername = MessengerUsername.display(username);
    final usernameNormalized = MessengerUsername.normalized(displayUsername);

    return DatabaseUtil.runInTransactionOrSavepoint(session.db, transaction, (
      transaction,
    ) async {
      final existing = await findByAuthUserId(
        session,
        authUserId: authUserId,
        transaction: transaction,
      );
      if (existing != null) {
        throw MessengerUserAlreadyExistsException(authUserId: authUserId);
      }

      final takenUser = await MessengerUser.db.findFirstRow(
        session,
        where: (t) => t.usernameNormalized.equals(usernameNormalized),
        transaction: transaction,
      );
      if (takenUser != null) {
        throw MessengerUsernameTakenException(username: displayUsername);
      }

      try {
        return await MessengerUser.db.insertRow(
          session,
          MessengerUser(
            authUserId: authUserId,
            username: displayUsername,
            usernameNormalized: usernameNormalized,
          ),
          transaction: transaction,
        );
      } on DatabaseQueryException catch (error) {
        _rethrowUniqueViolation(
          error,
          authUserId: authUserId,
          username: displayUsername,
        );
      }
    });
  }

  Future<bool> _isNormalizedUsernameTaken(
    Session session, {
    required String usernameNormalized,
    Transaction? transaction,
  }) async {
    final existingUser = await MessengerUser.db.findFirstRow(
      session,
      where: (t) => t.usernameNormalized.equals(usernameNormalized),
      transaction: transaction,
    );
    if (existingUser != null) {
      return true;
    }

    final pending = await MessengerRegistrationRequest.db.findFirstRow(
      session,
      where: (t) => t.usernameNormalized.equals(usernameNormalized),
      transaction: transaction,
    );
    return pending != null;
  }

  Never _rethrowUniqueViolation(
    DatabaseQueryException error, {
    required UuidValue authUserId,
    required String username,
  }) {
    if (error.code != '23505') {
      throw error;
    }

    final constraintName = error.constraintName ?? '';
    if (constraintName.contains('username')) {
      throw MessengerUsernameTakenException(username: username);
    }
    if (constraintName.contains('auth_user') ||
        constraintName.contains('authUser')) {
      throw MessengerUserAlreadyExistsException(authUserId: authUserId);
    }
    throw error;
  }
}
