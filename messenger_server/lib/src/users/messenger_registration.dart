import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import '../generated/protocol.dart';
import 'messenger_username.dart';
import 'messenger_users.dart';

/// Messenger registration contract on top of official Email IDP.
class MessengerRegistration {
  static const _messengerUsers = MessengerUsers();

  /// Creates a [MessengerRegistration] instance.
  const MessengerRegistration();

  EmailIdp get _emailIdp => AuthServices.instance.emailIdp;

  /// Starts email verification and reserves [username] for this registration.
  Future<UuidValue> start(
    Session session, {
    required String email,
    required String username,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      throw MessengerInvalidRegistrationInputException(
        field: 'email',
        message: 'Email must not be empty.',
      );
    }

    final displayUsername = MessengerUsername.display(username);
    final usernameNormalized = MessengerUsername.normalized(displayUsername);

    return DatabaseUtil.runInTransactionOrSavepoint(session.db, null, (
      transaction,
    ) async {
      await MessengerRegistrationRequest.db.deleteWhere(
        session,
        where: (t) => t.email.equals(normalizedEmail),
        transaction: transaction,
      );

      if (await _messengerUsers.isUsernameTaken(
        session,
        username: displayUsername,
        transaction: transaction,
      )) {
        throw MessengerUsernameTakenException(username: displayUsername);
      }

      final accountRequestId = await _emailIdp.startRegistration(
        session,
        email: normalizedEmail,
        transaction: transaction,
      );

      final accountRequest = await EmailAccountRequest.db.findById(
        session,
        accountRequestId,
        transaction: transaction,
      );
      if (accountRequest == null) {
        // Email IDP already logged the specific reason and returned an id
        // that does not belong to a request. Fail the start without naming
        // that reason.
        throw MessengerRegistrationIncompleteException();
      }

      await MessengerRegistrationRequest.db.deleteWhere(
        session,
        where: (t) => t.email.equals(accountRequest.email),
        transaction: transaction,
      );

      try {
        await MessengerRegistrationRequest.db.insertRow(
          session,
          MessengerRegistrationRequest(
            accountRequestId: accountRequestId,
            email: accountRequest.email,
            username: displayUsername,
            usernameNormalized: usernameNormalized,
          ),
          transaction: transaction,
        );
      } on DatabaseQueryException catch (error) {
        if (error.code == '23505') {
          throw MessengerUsernameTakenException(username: displayUsername);
        }
        rethrow;
      }

      return accountRequestId;
    });
  }

  /// Verifies the email ownership code using official Email IDP.
  Future<String> verify(
    Session session, {
    required UuidValue accountRequestId,
    required String verificationCode,
  }) {
    return _emailIdp.verifyRegistrationCode(
      session,
      accountRequestId: accountRequestId,
      verificationCode: verificationCode,
    );
  }

  /// Completes official Email IDP registration.
  ///
  /// [MessengerUser] is created in the same transaction by
  /// [attachMessengerUser].
  Future<AuthSuccess> finish(
    Session session, {
    required String registrationToken,
    required String password,
  }) {
    if (password.isEmpty) {
      throw MessengerInvalidRegistrationInputException(
        field: 'password',
        message: 'Password must not be empty.',
      );
    }

    return _emailIdp.finishRegistration(
      session,
      registrationToken: registrationToken,
      password: password,
    );
  }

  /// Creates the [MessengerUser] after official AuthUser creation.
  ///
  /// Runs inside the Email IDP finish-registration transaction. If this throws,
  /// the AuthUser and email account are rolled back with it.
  static Future<void> attachMessengerUser(
    Session session, {
    required String email,
    required UuidValue authUserId,
    required UuidValue emailAccountId,
    required Transaction? transaction,
  }) async {
    final pending = await MessengerRegistrationRequest.db.findFirstRow(
      session,
      where: (t) => t.email.equals(email),
      transaction: transaction,
    );
    if (pending == null) {
      throw MessengerRegistrationIncompleteException();
    }

    await _messengerUsers.create(
      session,
      authUserId: authUserId,
      username: pending.username,
      transaction: transaction,
    );

    await MessengerRegistrationRequest.db.deleteRow(
      session,
      pending,
      transaction: transaction,
    );
  }
}
