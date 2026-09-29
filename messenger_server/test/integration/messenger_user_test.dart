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
    test('when calling get then it is rejected', () async {
      await expectLater(
        () => endpoints.messengerUser.get(sessionBuilder),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });
  });

  withServerpod('Given an authenticated AuthUser without a MessengerUser', (
    sessionBuilder,
    endpoints,
  ) {
    late Session session;
    late AuthUserModel authUser;
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
    });

    test('when calling get then it returns null', () async {
      final messengerUser = await endpoints.messengerUser.get(
        authenticatedSession,
      );

      expect(messengerUser, isNull);
    });

    test(
      'when creating a MessengerUser then it is linked to that AuthUser',
      () async {
        final messengerUser = await messengerUsers.create(
          session,
          authUserId: authUser.id,
          username: 'alice',
        );

        expect(messengerUser.authUserId, authUser.id);
        expect(messengerUser.username, 'alice');
        expect(messengerUser.id, isNotNull);
      },
    );
  });

  withServerpod('Given an authenticated AuthUser with a MessengerUser', (
    sessionBuilder,
    endpoints,
  ) {
    late Session session;
    late AuthUserModel authUser;
    late TestSessionBuilder authenticatedSession;
    late MessengerUser existingUser;

    setUp(() async {
      session = sessionBuilder.build();
      authUser = await authUsers.create(session);
      authenticatedSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          authUser.id.toString(),
          {},
        ),
      );
      existingUser = await messengerUsers.create(
        session,
        authUserId: authUser.id,
        username: 'alice',
      );
    });

    test('when calling get then it returns that MessengerUser', () async {
      final messengerUser = await endpoints.messengerUser.get(
        authenticatedSession,
      );

      expect(messengerUser?.id, existingUser.id);
      expect(messengerUser?.authUserId, authUser.id);
      expect(messengerUser?.username, 'alice');
    });

    test(
      'when creating a second MessengerUser for the same AuthUser then it fails',
      () async {
        await expectLater(
          () => messengerUsers.create(
            session,
            authUserId: authUser.id,
            username: 'alice_2',
          ),
          throwsA(isA<MessengerUserAlreadyExistsException>()),
        );
      },
    );
  });

  withServerpod('Given two authenticated AuthUsers', (
    sessionBuilder,
    endpoints,
  ) {
    late Session session;
    late AuthUserModel firstAuthUser;
    late AuthUserModel secondAuthUser;

    setUp(() async {
      session = sessionBuilder.build();
      firstAuthUser = await authUsers.create(session);
      secondAuthUser = await authUsers.create(session);
    });

    test(
      'when they choose the same username ignoring case then the second create fails',
      () async {
        await messengerUsers.create(
          session,
          authUserId: firstAuthUser.id,
          username: 'Alice',
        );

        await expectLater(
          () => messengerUsers.create(
            session,
            authUserId: secondAuthUser.id,
            username: 'alice',
          ),
          throwsA(isA<MessengerUsernameTakenException>()),
        );
      },
    );

    test(
      'when they choose different usernames then both MessengerUsers exist',
      () async {
        final firstUser = await messengerUsers.create(
          session,
          authUserId: firstAuthUser.id,
          username: 'alice',
        );
        final secondUser = await messengerUsers.create(
          session,
          authUserId: secondAuthUser.id,
          username: 'bob',
        );

        expect(firstUser.authUserId, firstAuthUser.id);
        expect(secondUser.authUserId, secondAuthUser.id);
        expect(firstUser.username, 'alice');
        expect(secondUser.username, 'bob');
      },
    );
  });

  withServerpod('Given a MessengerUser linked to an AuthUser', (
    sessionBuilder,
    endpoints,
  ) {
    late Session session;
    late AuthUserModel authUser;

    setUp(() async {
      session = sessionBuilder.build();
      authUser = await authUsers.create(session);
      await messengerUsers.create(
        session,
        authUserId: authUser.id,
        username: 'alice',
      );
    });

    test(
      'when the AuthUser is deleted then the MessengerUser is removed',
      () async {
        await authUsers.delete(session, authUserId: authUser.id);

        expect(
          await MessengerUser.db.findFirstRow(
            session,
            where: (t) => t.authUserId.equals(authUser.id),
          ),
          isNull,
        );
      },
    );
  });
}
