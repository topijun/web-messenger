import 'package:messenger_server/src/auth/password_policy.dart';
import 'package:messenger_server/src/email/auth_email_hooks.dart';
import 'package:messenger_server/src/email/auth_email_sender.dart';
import 'package:messenger_server/src/email/auth_email_service.dart';
import 'package:messenger_server/src/generated/protocol.dart';
import 'package:messenger_server/src/users/messenger_registration.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:test/test.dart';

import '../email/fake_auth_email_sender.dart';
import 'test_tools/serverpod_test_tools.dart';

const _verificationCode = 'verify01';
const _resetCode = 'reset001';
const _validPassword = 'Password1!';

final _sender = FakeAuthEmailSender();

void _configureAuthServices() {
  final hooks = AuthEmailHooks(AuthEmailService(_sender));
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
            hooks.sendRegistrationVerificationCode,
        sendPasswordResetVerificationCode:
            hooks.sendPasswordResetVerificationCode,
      ),
    ],
  );
}

void main() {
  _configureAuthServices();

  withServerpod(
    'Given Email IDP callbacks wired to a fake sender',
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      late Session session;

      setUp(() async {
        session = sessionBuilder.build();
        _sender.sent.clear();
        _sender.errorToThrow = null;
        await _cleanup(session);
      });

      tearDown(() => _cleanup(session));

      test(
        'when starting registration then the verification email is sent',
        () async {
          await endpoints.messengerRegistration.start(
            sessionBuilder,
            email: 'smtp.reg@example.com',
            username: 'Smtp.Reg',
          );

          expect(_sender.sent, hasLength(1));
          expect(_sender.sent.single.recipient, 'smtp.reg@example.com');
          expect(_sender.sent.single.body, contains(_verificationCode));
          expect(_sender.sent.single.body, isNot(contains('smtpPassword')));
        },
      );

      test(
        'when starting password reset for a registered email then a reset email is sent',
        () async {
          await _register(
            endpoints,
            sessionBuilder,
            email: 'smtp.reset@example.com',
            username: 'Smtp.Reset',
          );
          _sender.sent.clear();

          await endpoints.emailIdp.startPasswordReset(
            sessionBuilder,
            email: 'smtp.reset@example.com',
          );

          expect(_sender.sent, hasLength(1));
          expect(_sender.sent.single.recipient, 'smtp.reset@example.com');
          expect(_sender.sent.single.body, contains(_resetCode));
          expect(_sender.sent.single.body, isNot(contains('smtpPassword')));
        },
      );

      test(
        'when starting password reset for an unknown email then no email is sent',
        () async {
          await endpoints.emailIdp.startPasswordReset(
            sessionBuilder,
            email: 'smtp.missing@example.com',
          );

          expect(_sender.sent, isEmpty);
        },
      );

      test(
        'when email delivery fails then start fails and the server stays usable',
        () async {
          _sender.errorToThrow = Exception(
            'simulated SMTP failure smtpPassword=test-smtp-secret-value',
          );

          await expectLater(
            endpoints.messengerRegistration.start(
              sessionBuilder,
              email: 'smtp.fail@example.com',
              username: 'Smtp.Fail',
            ),
            throwsA(
              isA<AuthEmailDeliveryException>().having(
                (error) => error.toString(),
                'message',
                allOf(
                  isNot(contains('test-smtp-secret-value')),
                  isNot(contains('smtpPassword')),
                ),
              ),
            ),
          );
          expect(_sender.sent, isEmpty);

          _sender.errorToThrow = null;
          await endpoints.messengerRegistration.start(
            sessionBuilder,
            email: 'smtp.ok@example.com',
            username: 'Smtp.Ok',
          );

          expect(_sender.sent, hasLength(1));
          expect(_sender.sent.single.recipient, 'smtp.ok@example.com');
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
