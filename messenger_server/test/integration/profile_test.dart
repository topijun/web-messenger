import 'package:messenger_server/src/generated/protocol.dart';
import 'package:messenger_server/src/users/messenger_users.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  const authUsers = AuthUsers();
  const messengerUsers = MessengerUsers();

  withServerpod('Given an unauthenticated session', (
    sessionBuilder,
    endpoints,
  ) {
    test('when calling profile.getMine then it is rejected', () async {
      await expectLater(
        () => endpoints.profile.getMine(sessionBuilder),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });

    test('when calling profile.updateMine then it is rejected', () async {
      await expectLater(
        () => endpoints.profile.updateMine(sessionBuilder, aboutMe: 'Hello'),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });
  });

  withServerpod(
    'Given an authenticated AuthUser without a MessengerUser',
    (sessionBuilder, endpoints) {
      late TestSessionBuilder authenticatedSession;

      setUp(() async {
        final session = sessionBuilder.build();
        final authUser = await authUsers.create(session);
        authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            authUser.id.toString(),
            {},
          ),
        );
      });

      test(
        'when calling getMine then it requires a Messenger account',
        () async {
          await expectLater(
            () => endpoints.profile.getMine(authenticatedSession),
            throwsA(isA<MessengerAccountRequiredException>()),
          );
        },
      );
    },
  );

  withServerpod('Given an authenticated MessengerUser', (
    sessionBuilder,
    endpoints,
  ) {
    late Session session;
    late AuthUserModel authUser;
    late MessengerUser messengerUser;
    late TestSessionBuilder authenticatedSession;

    setUp(() async {
      session = sessionBuilder.build();
      authUser = await authUsers.create(session);
      authenticatedSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          authUser.id.toString(),
          {},
        ),
      );
      messengerUser = await messengerUsers.create(
        session,
        authUserId: authUser.id,
        username: 'alice',
      );
    });

    test(
      'when calling getMine then a profile is created for that user',
      () async {
        final profile = await endpoints.profile.getMine(authenticatedSession);

        expect(profile.userId, messengerUser.id);
        expect(profile.aboutMe, '');
        expect(profile.profileImageId, isNull);
        expect(profile.id, isNotNull);
      },
    );

    test(
      'when calling getMine twice then the same profile is returned',
      () async {
        final first = await endpoints.profile.getMine(authenticatedSession);
        final second = await endpoints.profile.getMine(authenticatedSession);

        expect(second.id, first.id);
        expect(second.userId, messengerUser.id);
      },
    );

    test('when updating aboutMe then the profile is saved', () async {
      await endpoints.profile.getMine(authenticatedSession);

      final updated = await endpoints.profile.updateMine(
        authenticatedSession,
        aboutMe: '  Hello from Alice  ',
      );

      expect(updated.userId, messengerUser.id);
      expect(updated.aboutMe, 'Hello from Alice');
    });

    test('when aboutMe is too long then update fails', () async {
      await expectLater(
        () => endpoints.profile.updateMine(
          authenticatedSession,
          aboutMe: 'a' * 501,
        ),
        throwsA(isA<MessengerInvalidProfileInputException>()),
      );
    });
  });

  withServerpod('Given two authenticated MessengerUsers', (
    sessionBuilder,
    endpoints,
  ) {
    late Session session;
    late TestSessionBuilder aliceSession;
    late TestSessionBuilder bobSession;
    late MessengerUser alice;
    late MessengerUser bob;

    setUp(() async {
      session = sessionBuilder.build();
      final aliceAuth = await authUsers.create(session);
      final bobAuth = await authUsers.create(session);
      aliceSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          aliceAuth.id.toString(),
          {},
        ),
      );
      bobSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          bobAuth.id.toString(),
          {},
        ),
      );
      alice = await messengerUsers.create(
        session,
        authUserId: aliceAuth.id,
        username: 'alice',
      );
      bob = await messengerUsers.create(
        session,
        authUserId: bobAuth.id,
        username: 'bob',
      );
    });

    test(
      'when Bob updates his profile then Alice\'s profile is unchanged',
      () async {
        await endpoints.profile.updateMine(
          aliceSession,
          aboutMe: 'Alice about me',
        );

        await endpoints.profile.updateMine(bobSession, aboutMe: 'Bob about me');

        final aliceProfile = await endpoints.profile.getMine(aliceSession);
        final bobProfile = await endpoints.profile.getMine(bobSession);

        expect(aliceProfile.userId, alice.id);
        expect(bobProfile.userId, bob.id);
        expect(aliceProfile.aboutMe, 'Alice about me');
        expect(bobProfile.aboutMe, 'Bob about me');
      },
    );
  });
}
