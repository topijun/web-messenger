import 'package:messenger_server/src/auth/password_policy.dart';
import 'package:messenger_server/src/generated/protocol.dart';
import 'package:messenger_server/src/users/messenger_registration.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

const _verificationCode = 'verify01';
const _resetCode = 'reset001';
const _validPassword = 'Password1!';
const _newPassword = 'NewPass1!';

void _configureAuthServices() {
  AuthServices.set(
    tokenManagerBuilders: [
      ServerSideSessionsConfig(sessionKeyHashPepper: 'test-pepper'),
    ],
    identityProviderBuilders: [
      EmailIdpConfig(
        secretHashPepper: 'pepper',
        registrationVerificationCodeGenerator: () => _verificationCode,
        passwordResetVerificationCodeGenerator: () => _resetCode,
        passwordValidationFunction: messengerPasswordPolicy,
        onAfterAccountCreated: MessengerRegistration.attachMessengerUser,
        sendRegistrationVerificationCode:
            (
              session, {
              required email,
              required accountRequestId,
              required verificationCode,
              required transaction,
            }) {},
        sendPasswordResetVerificationCode:
            (
              session, {
              required email,
              required passwordResetRequestId,
              required verificationCode,
              required transaction,
            }) {},
      ),
    ],
  );
}

void main() {
  _configureAuthServices();

  withServerpod(
    'Given a registered Email IDP account',
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      late Session session;

      setUp(() async {
        session = sessionBuilder.build();
        await _cleanup(session);
      });

      tearDown(() => _cleanup(session));

      test(
        'when completing password reset then the new password can log in',
        () async {
          await _register(
            endpoints,
            sessionBuilder,
            email: 'reset.topi@example.com',
            username: 'Reset.Topi',
          );

          final requestId = await endpoints.emailIdp.startPasswordReset(
            sessionBuilder,
            email: 'reset.topi@example.com',
          );
          final token = await endpoints.emailIdp.verifyPasswordResetCode(
            sessionBuilder,
            passwordResetRequestId: requestId,
            verificationCode: _resetCode,
          );
          await endpoints.emailIdp.finishPasswordReset(
            sessionBuilder,
            finishPasswordResetToken: token,
            newPassword: _newPassword,
          );

          final authSuccess = await endpoints.emailIdp.login(
            sessionBuilder,
            email: 'reset.topi@example.com',
            password: _newPassword,
          );
          expect(authSuccess.authUserId, isNotNull);

          await expectLater(
            endpoints.emailIdp.login(
              sessionBuilder,
              email: 'reset.topi@example.com',
              password: _validPassword,
            ),
            throwsA(isA<EmailAccountLoginException>()),
          );
        },
      );

      test(
        'when starting reset for an unknown email then a request id is still returned',
        () async {
          final requestId = await endpoints.emailIdp.startPasswordReset(
            sessionBuilder,
            email: 'reset.missing@example.com',
          );

          expect(requestId, isA<UuidValue>());
          await expectLater(
            endpoints.emailIdp.verifyPasswordResetCode(
              sessionBuilder,
              passwordResetRequestId: requestId,
              verificationCode: _resetCode,
            ),
            throwsA(isA<EmailAccountPasswordResetException>()),
          );
        },
      );
    },
  );
}

Future<AuthSuccess> _register(
  TestEndpoints endpoints,
  TestSessionBuilder sessionBuilder, {
  required String email,
  required String username,
}) async {
  final accountRequestId = await endpoints.messengerRegistration.start(
    sessionBuilder,
    email: email,
    username: username,
  );
  final token = await endpoints.messengerRegistration.verify(
    sessionBuilder,
    accountRequestId: accountRequestId,
    verificationCode: _verificationCode,
  );
  return endpoints.messengerRegistration.finish(
    sessionBuilder,
    registrationToken: token,
    password: _validPassword,
  );
}

Future<void> _cleanup(Session session) async {
  await EmailAccountPasswordResetRequest.db.deleteWhere(
    session,
    where: (_) => Constant.bool(true),
  );
  await RateLimitedRequestAttempt.db.deleteWhere(
    session,
    where: (_) => Constant.bool(true),
  );
  await MessengerRegistrationRequest.db.deleteWhere(
    session,
    where: (_) => Constant.bool(true),
  );
  await MessengerUser.db.deleteWhere(
    session,
    where: (_) => Constant.bool(true),
  );
  await EmailAccount.db.deleteWhere(
    session,
    where: (_) => Constant.bool(true),
  );
  await EmailAccountRequest.db.deleteWhere(
    session,
    where: (_) => Constant.bool(true),
  );
  await UserProfile.db.deleteWhere(
    session,
    where: (_) => Constant.bool(true),
  );
  await AuthUser.db.deleteWhere(
    session,
    where: (_) => Constant.bool(true),
  );
}
