import 'dart:typed_data';

import 'package:messenger_server/src/generated/protocol.dart';
import 'package:messenger_server/src/media/media_bytes.dart';
import 'package:messenger_server/src/profiles/profiles.dart';
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
    test('when uploading a profile image then it is rejected', () async {
      await expectLater(
        () => endpoints.profile.uploadProfileImage(
          sessionBuilder,
          bytes: _jpegBytes(),
        ),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });

    test('when getting a profile image then it is rejected', () async {
      await expectLater(
        () => endpoints.profile.getProfileImage(sessionBuilder),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });
  });

  withServerpod('Given an authenticated MessengerUser', (
    sessionBuilder,
    endpoints,
  ) {
    late Session session;
    late TestSessionBuilder authenticatedSession;
    late MessengerUser messengerUser;

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
        username: 'alice_pic',
      );
    });

    test('when uploading a JPEG then it is stored encrypted', () async {
      final original = _jpegPayload();
      final uploaded = await endpoints.profile.uploadProfileImage(
        authenticatedSession,
        bytes: ByteData.sublistView(original),
      );

      expect(uploaded.mimeType, 'image/jpeg');
      expect(uploaded.size, original.length);
      expect(uint8ListFromByteData(uploaded.bytes), original);

      final profile = await endpoints.profile.getMine(authenticatedSession);
      expect(profile.profileImageId, uploaded.mediaId);

      final stored = await Media.db.findById(session, uploaded.mediaId);
      expect(stored, isNotNull);
      expect(stored!.userId, messengerUser.id);
      expect(stored.mimeType, 'image/jpeg');
      expect(stored.size, original.length);
      final ciphertext = uint8ListFromByteData(stored.encryptedData);
      expect(ciphertext, isNot(equals(original)));
      expect(ciphertext.first, 0x01);

      final fetched = await endpoints.profile.getProfileImage(
        authenticatedSession,
      );
      expect(fetched, isNotNull);
      expect(uint8ListFromByteData(fetched!.bytes), original);
    });

    test('when uploading a PNG then it is stored encrypted', () async {
      final original = _pngPayload();
      final uploaded = await endpoints.profile.uploadProfileImage(
        authenticatedSession,
        bytes: ByteData.sublistView(original),
      );

      expect(uploaded.mimeType, 'image/png');
      expect(uint8ListFromByteData(uploaded.bytes), original);

      final stored = await Media.db.findById(session, uploaded.mediaId);
      expect(
        uint8ListFromByteData(stored!.encryptedData),
        isNot(equals(original)),
      );
    });

    test('when uploading an unsupported format then it is rejected', () async {
      final gif = Uint8List.fromList([
        0x47,
        0x49,
        0x46,
        0x38,
        0x39,
        0x61,
        0x01,
        0x00,
      ]);
      await expectLater(
        () => endpoints.profile.uploadProfileImage(
          authenticatedSession,
          bytes: ByteData.sublistView(gif),
        ),
        throwsA(
          isA<MessengerInvalidMediaException>().having(
            (error) => error.code,
            'code',
            'unsupportedFormat',
          ),
        ),
      );
      expect(await Media.db.count(session), 0);
    });

    test('when uploading more than 5 MB then it is rejected', () async {
      final tooLarge = Uint8List(Profiles.maxProfileImageBytes + 1);
      tooLarge[0] = 0xFF;
      tooLarge[1] = 0xD8;
      tooLarge[2] = 0xFF;
      await expectLater(
        () => endpoints.profile.uploadProfileImage(
          authenticatedSession,
          bytes: ByteData.sublistView(tooLarge),
        ),
        throwsA(
          isA<MessengerInvalidMediaException>().having(
            (error) => error.code,
            'code',
            'tooLarge',
          ),
        ),
      );
    });

    test('when uploading exactly 5 MB JPEG then it is accepted', () async {
      final exact = Uint8List(Profiles.maxProfileImageBytes);
      exact[0] = 0xFF;
      exact[1] = 0xD8;
      exact[2] = 0xFF;
      final uploaded = await endpoints.profile.uploadProfileImage(
        authenticatedSession,
        bytes: ByteData.sublistView(exact),
      );
      expect(uploaded.size, Profiles.maxProfileImageBytes);
      expect(uint8ListFromByteData(uploaded.bytes), exact);
    });

    test(
      'when replacing a picture then the old Media row is removed',
      () async {
        final first = await endpoints.profile.uploadProfileImage(
          authenticatedSession,
          bytes: _jpegBytes(),
        );
        final secondOriginal = _pngPayload();
        final second = await endpoints.profile.uploadProfileImage(
          authenticatedSession,
          bytes: ByteData.sublistView(secondOriginal),
        );

        expect(second.mediaId, isNot(first.mediaId));
        final profile = await endpoints.profile.getMine(authenticatedSession);
        expect(profile.profileImageId, second.mediaId);
        expect(await Media.db.findById(session, first.mediaId), isNull);
        expect(await Media.db.count(session), 1);

        final fetched = await endpoints.profile.getProfileImage(
          authenticatedSession,
        );
        expect(uint8ListFromByteData(fetched!.bytes), secondOriginal);
      },
    );

    test('when no picture is uploaded then getProfileImage is null', () async {
      await endpoints.profile.getMine(authenticatedSession);
      expect(
        await endpoints.profile.getProfileImage(authenticatedSession),
        isNull,
      );
    });

    test(
      'when updating About Me then the profile image id is unchanged',
      () async {
        final uploaded = await endpoints.profile.uploadProfileImage(
          authenticatedSession,
          bytes: _jpegBytes(),
        );
        final updated = await endpoints.profile.updateMine(
          authenticatedSession,
          aboutMe: 'Keeps the photo',
        );
        expect(updated.aboutMe, 'Keeps the photo');
        expect(updated.profileImageId, uploaded.mediaId);
      },
    );
  });

  withServerpod('Given two authenticated MessengerUsers', (
    sessionBuilder,
    endpoints,
  ) {
    late Session session;
    late TestSessionBuilder aliceSession;
    late TestSessionBuilder bobSession;

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
      await messengerUsers.create(
        session,
        authUserId: aliceAuth.id,
        username: 'alice_media',
      );
      await messengerUsers.create(
        session,
        authUserId: bobAuth.id,
        username: 'bob_media',
      );
    });

    test('when Bob uploads then Alice\'s picture is unchanged', () async {
      final aliceImage = await endpoints.profile.uploadProfileImage(
        aliceSession,
        bytes: _jpegBytes(),
      );
      await endpoints.profile.uploadProfileImage(
        bobSession,
        bytes: ByteData.sublistView(_pngPayload()),
      );

      final aliceProfile = await endpoints.profile.getMine(aliceSession);
      expect(aliceProfile.profileImageId, aliceImage.mediaId);

      final aliceFetched = await endpoints.profile.getProfileImage(
        aliceSession,
      );
      expect(uint8ListFromByteData(aliceFetched!.bytes), _jpegPayload());

      final bobFetched = await endpoints.profile.getProfileImage(bobSession);
      expect(uint8ListFromByteData(bobFetched!.bytes), _pngPayload());
    });

    test(
      'when Bob requests Alice\'s media id then he receives her picture',
      () async {
        final aliceImage = await endpoints.profile.uploadProfileImage(
          aliceSession,
          bytes: _jpegBytes(),
        );

        final fetched = await endpoints.profile.getProfileImage(
          bobSession,
          mediaId: aliceImage.mediaId,
        );
        expect(fetched, isNotNull);
        expect(fetched!.mediaId, aliceImage.mediaId);
        expect(uint8ListFromByteData(fetched.bytes), _jpegPayload());
      },
    );
  });
}

Uint8List _jpegPayload() =>
    Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 7, 8, 9]);

ByteData _jpegBytes() => ByteData.sublistView(_jpegPayload());

Uint8List _pngPayload() => Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  1,
  2,
  3,
]);
