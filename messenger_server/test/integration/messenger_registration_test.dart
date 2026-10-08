import 'package:messenger_server/src/auth/password_policy.dart';
import 'package:messenger_server/src/generated/protocol.dart';
import 'package:messenger_server/src/users/messenger_registration.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

const _verificationCode = 'verify01';
const _validPassword = 'Password1!';

void _configureAuthServices() {
  AuthServices.set(
    tokenManagerBuilders: [
      ServerSideSessionsConfig(sessionKeyHashPepper: 'test-pepper'),
    ],
    identityProviderBuilders: [
      EmailIdpConfig(
        secretHashPepper: 'pepper',
        registrationVerificationCodeGenerator: () => _verificationCode,
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
      ),
    ],
  );
}

void main() {
  _configureAuthServices();

  withServerpod(
    'Given valid registration input',
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      late Session session;

      setUp(() async {
        session = sessionBuilder.build();
        await _cleanup(session);
      });

      tearDown(() => _cleanup(session));

      test(
        'when completing registration then AuthUser and MessengerUser are created together',
        () async {
          final authSuccess = await _register(
            endpoints,
            sessionBuilder,
            email: 'topi@example.com',
            username: 'Topi.J',
          );

          final messengerUsers = await MessengerUser.db.find(session);
          final authUsers = await AuthUser.db.find(session);

          expect(authUsers, hasLength(1));
          expect(messengerUsers, hasLength(1));
          expect(authSuccess.authUserId, authUsers.single.id);
          expect(messengerUsers.single.authUserId, authUsers.single.id);
          expect(messengerUsers.single.username, 'Topi.J');
          expect(messengerUsers.single.usernameNormalized, 'topi.j');
          expect(await MessengerRegistrationRequest.db.find(session), isEmpty);
        },
      );
    },
  );

  withServerpod(
    'Given an existing Messenger username',
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      late Session session;

      setUp(() async {
        session = sessionBuilder.build();
        await _cleanup(session);
        await _register(
          endpoints,
          sessionBuilder,
          email: 'alice@example.com',
          username: 'Alice_1',
        );
      });

      tearDown(() => _cleanup(session));

      test(
        'when starting registration with the same username in different casing then it fails',
        () async {
          await expectLater(
            () => endpoints.messengerRegistration.start(
              sessionBuilder,
              email: 'bob@example.com',
              username: 'alice_1',
            ),
            throwsA(isA<MessengerUsernameTakenException>()),
          );
        },
      );

      test(
        'when another registration has reserved the username then start fails',
        () async {
          await endpoints.messengerRegistration.start(
            sessionBuilder,
            email: 'pending@example.com',
            username: 'PendingUser',
          );

          await expectLater(
            () => endpoints.messengerRegistration.start(
              sessionBuilder,
              email: 'other@example.com',
              username: 'pendinguser',
            ),
            throwsA(isA<MessengerUsernameTakenException>()),
          );
        },
      );
    },
  );

  withServerpod(
    'Given invalid registration input',
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      late Session session;

      setUp(() async {
        session = sessionBuilder.build();
        await _cleanup(session);
      });

      tearDown(() => _cleanup(session));

      test('when username is too short then start fails', () async {
        await expectLater(
          () => endpoints.messengerRegistration.start(
            sessionBuilder,
            email: 'user@example.com',
            username: 'to',
          ),
          throwsA(isA<MessengerInvalidUsernameException>()),
        );
      });

      test(
        'when username is longer than 30 characters then start fails',
        () async {
          await expectLater(
            () => endpoints.messengerRegistration.start(
              sessionBuilder,
              email: 'user@example.com',
              username: 'a' * 31,
            ),
            throwsA(isA<MessengerInvalidUsernameException>()),
          );
        },
      );

      test('when username contains a space then start fails', () async {
        await expectLater(
          () => endpoints.messengerRegistration.start(
            sessionBuilder,
            email: 'user@example.com',
            username: 'topi juntunen',
          ),
          throwsA(isA<MessengerInvalidUsernameException>()),
        );
      });

      test(
        'when username contains a disallowed special character then start fails',
        () async {
          await expectLater(
            () => endpoints.messengerRegistration.start(
              sessionBuilder,
              email: 'user@example.com',
              username: 'topi@juntunen',
            ),
            throwsA(isA<MessengerInvalidUsernameException>()),
          );
        },
      );

      test('when email is empty then start fails', () async {
        await expectLater(
          () => endpoints.messengerRegistration.start(
            sessionBuilder,
            email: '   ',
            username: 'topi',
          ),
          throwsA(isA<MessengerInvalidRegistrationInputException>()),
        );
      });

      test('when password is empty then finish fails', () async {
        final accountRequestId = await endpoints.messengerRegistration.start(
          sessionBuilder,
          email: 'empty-password@example.com',
          username: 'empty_pw',
        );
        final token = await endpoints.messengerRegistration.verify(
          sessionBuilder,
          accountRequestId: accountRequestId,
          verificationCode: _verificationCode,
        );

        await expectLater(
          () => endpoints.messengerRegistration.finish(
            sessionBuilder,
            registrationToken: token,
            password: '',
          ),
          throwsA(isA<MessengerInvalidRegistrationInputException>()),
        );
      });

      test(
        'when password does not meet the policy then finish fails and no account is created',
        () async {
          final accountRequestId = await endpoints.messengerRegistration.start(
            sessionBuilder,
            email: 'weak-password@example.com',
            username: 'weak_pw',
          );
          final token = await endpoints.messengerRegistration.verify(
            sessionBuilder,
            accountRequestId: accountRequestId,
            verificationCode: _verificationCode,
          );

          await expectLater(
            () => endpoints.messengerRegistration.finish(
              sessionBuilder,
              registrationToken: token,
              password: 'password',
            ),
            throwsA(
              isA<EmailAccountRequestException>().having(
                (error) => error.reason,
                'reason',
                EmailAccountRequestExceptionReason.policyViolation,
              ),
            ),
          );

          expect(await AuthUser.db.find(session), isEmpty);
          expect(await MessengerUser.db.find(session), isEmpty);
        },
      );
    },
  );

  withServerpod(
    'Given an email that is already registered',
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      late Session session;

      setUp(() async {
        session = sessionBuilder.build();
        await _cleanup(session);
        await _register(
          endpoints,
          sessionBuilder,
          email: 'alice@example.com',
          username: 'Alice_1',
        );
      });

      tearDown(() => _cleanup(session));

      test(
        'when starting registration with that email then start fails without naming the email',
        () async {
          await expectLater(
            () => endpoints.messengerRegistration.start(
              sessionBuilder,
              email: 'alice@example.com',
              username: 'Different_1',
            ),
            throwsA(isA<MessengerRegistrationIncompleteException>()),
          );
        },
      );
    },
  );

  withServerpod(
    'Given an official Email IDP registration without a reserved username',
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      late Session session;

      setUp(() async {
        session = sessionBuilder.build();
        await _cleanup(session);
      });

      tearDown(() => _cleanup(session));

      test(
        'when finishing registration then AuthUser and MessengerUser stay consistent',
        () async {
          final accountRequestId = await AuthServices.instance.emailIdp
              .startRegistration(
                session,
                email: 'orphan@example.com',
              );
          final token = await AuthServices.instance.emailIdp
              .verifyRegistrationCode(
                session,
                accountRequestId: accountRequestId,
                verificationCode: _verificationCode,
              );

          await expectLater(
            () => AuthServices.instance.emailIdp.finishRegistration(
              session,
              registrationToken: token,
              password: _validPassword,
            ),
            throwsA(isA<MessengerRegistrationIncompleteException>()),
          );

          expect(await AuthUser.db.find(session), isEmpty);
          expect(await MessengerUser.db.find(session), isEmpty);
          expect(await EmailAccount.db.find(session), isEmpty);
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
