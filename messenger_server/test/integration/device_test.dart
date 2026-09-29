import 'package:messenger_server/src/generated/protocol.dart';
import 'package:messenger_server/src/users/messenger_users.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

UuidValue _clientId(String nibble) =>
    UuidValue.fromString('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa$nibble');

void main() {
  const authUsers = AuthUsers();
  const messengerUsers = MessengerUsers();

  withServerpod('Given an unauthenticated session', (
    sessionBuilder,
    endpoints,
  ) {
    test('when registering a device then it is rejected', () async {
      await expectLater(
        () => endpoints.device.register(
          sessionBuilder,
          clientId: _clientId('1'),
          platform: DevicePlatform.android,
        ),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });

    test('when listing devices then it is rejected', () async {
      await expectLater(
        () => endpoints.device.listMine(sessionBuilder),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });
  });

  withServerpod('Given an authenticated MessengerUser', (
    sessionBuilder,
    endpoints,
  ) {
    late Session session;
    late MessengerUser messengerUser;
    late TestSessionBuilder authenticatedSession;

    setUp(() async {
      session = sessionBuilder.build();
      final authUser = await authUsers.create(session);
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

    test('when registering a device then it belongs to that user', () async {
      final device = await endpoints.device.register(
        authenticatedSession,
        clientId: _clientId('1'),
        platform: DevicePlatform.android,
      );

      expect(device.userId, messengerUser.id);
      expect(device.clientId, _clientId('1'));
      expect(device.platform, DevicePlatform.android);
      expect(device.pushToken, isNull);
      expect(device.lastSeenAt, isNotNull);
    });

    test(
      'when registering two devices then both belong to the same user',
      () async {
        await endpoints.device.register(
          authenticatedSession,
          clientId: _clientId('1'),
          platform: DevicePlatform.android,
        );
        await endpoints.device.register(
          authenticatedSession,
          clientId: _clientId('2'),
          platform: DevicePlatform.ios,
        );

        final devices = await endpoints.device.listMine(authenticatedSession);

        expect(devices, hasLength(2));
        expect(devices.map((device) => device.userId).toSet(), {
          messengerUser.id,
        });
        expect(devices.map((device) => device.platform).toSet(), {
          DevicePlatform.android,
          DevicePlatform.ios,
        });
      },
    );

    test('when touching a device then lastSeenAt is updated', () async {
      final registered = await endpoints.device.register(
        authenticatedSession,
        clientId: _clientId('1'),
        platform: DevicePlatform.web,
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));

      final touched = await endpoints.device.touch(
        authenticatedSession,
        clientId: _clientId('1'),
      );

      expect(touched.id, registered.id);
      expect(touched.userId, messengerUser.id);
      expect(touched.lastSeenAt.isAfter(registered.lastSeenAt), isTrue);
    });

    test(
      'when registering the same clientId again then the existing device is updated',
      () async {
        await endpoints.device.register(
          authenticatedSession,
          clientId: _clientId('1'),
          platform: DevicePlatform.android,
        );
        final updated = await endpoints.device.register(
          authenticatedSession,
          clientId: _clientId('1'),
          platform: DevicePlatform.web,
        );

        final devices = await endpoints.device.listMine(authenticatedSession);
        expect(devices, hasLength(1));
        expect(updated.platform, DevicePlatform.web);
      },
    );
  });

  withServerpod('Given two authenticated MessengerUsers', (
    sessionBuilder,
    endpoints,
  ) {
    late TestSessionBuilder aliceSession;
    late TestSessionBuilder bobSession;
    late MessengerUser bob;

    setUp(() async {
      final session = sessionBuilder.build();
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
      await messengerUsers.create(
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
      'when Alice registers a device then Bob cannot update its lastSeenAt',
      () async {
        await endpoints.device.register(
          aliceSession,
          clientId: _clientId('1'),
          platform: DevicePlatform.android,
        );

        await expectLater(
          () => endpoints.device.touch(
            bobSession,
            clientId: _clientId('1'),
          ),
          throwsA(isA<MessengerDeviceNotFoundException>()),
        );
      },
    );

    test('when each user registers a device then listMine is scoped', () async {
      await endpoints.device.register(
        aliceSession,
        clientId: _clientId('1'),
        platform: DevicePlatform.android,
      );
      await endpoints.device.register(
        bobSession,
        clientId: _clientId('2'),
        platform: DevicePlatform.ios,
      );

      final bobDevices = await endpoints.device.listMine(bobSession);
      expect(bobDevices, hasLength(1));
      expect(bobDevices.single.userId, bob.id);
      expect(bobDevices.single.clientId, _clientId('2'));
    });
  });
}
