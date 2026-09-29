import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/features/profile/application/profile_controller.dart';

import '../../support/profile_fakes.dart';

void main() {
  test('load puts the profile into the ready state', () async {
    final controller = ProfileController(
      repository: FakeProfileRepository(profile: testProfile(aboutMe: 'Hi')),
      username: 'Topi.J',
    );

    await controller.load();

    expect(controller.status, ProfileStatus.ready);
    expect(controller.profile?.aboutMe, 'Hi');
    expect(controller.usesDefaultAvatar, isTrue);
    expect(controller.errorMessage, isNull);
  });

  test('overlapping load joins the in-flight request', () async {
    final load = Completer<Profile>();
    final repository = FakeProfileRepository(loadCompleter: load);
    final controller = ProfileController(
      repository: repository,
      username: 'Topi.J',
    );

    final first = controller.load();
    final second = controller.load();
    load.complete(testProfile(aboutMe: 'Hi'));
    await Future.wait([first, second]);

    expect(repository.loadCalls, 1);
    expect(controller.status, ProfileStatus.ready);
    expect(controller.isBusy, isFalse);
    controller.dispose();
  });

  test('load failure is an error state', () async {
    final controller = ProfileController(
      repository: FakeProfileRepository(loadError: Exception('down')),
      username: 'Topi.J',
    );

    await controller.load();

    expect(controller.status, ProfileStatus.error);
    expect(controller.errorMessage, contains('Could not load your profile'));
  });

  test('saveAboutMe updates the profile', () async {
    final repository = FakeProfileRepository(profile: testProfile());
    final controller = ProfileController(
      repository: repository,
      username: 'Topi.J',
    );
    await controller.load();

    final saved = await controller.saveAboutMe('New about me');

    expect(saved, isTrue);
    expect(repository.lastSavedAboutMe, 'New about me');
    expect(controller.profile?.aboutMe, 'New about me');
    expect(controller.status, ProfileStatus.ready);
  });

  test('save failure keeps an error state', () async {
    final controller = ProfileController(
      repository: FakeProfileRepository(
        profile: testProfile(),
        saveError: MessengerInvalidProfileInputException(
          field: 'aboutMe',
          message: 'About me must be at most 500 characters.',
        ),
      ),
      username: 'Topi.J',
    );
    await controller.load();

    final saved = await controller.saveAboutMe('x' * 501);

    expect(saved, isFalse);
    expect(controller.status, ProfileStatus.error);
    expect(controller.errorMessage, contains('500 characters'));
  });

  test('a loaded profile image replaces the default avatar', () async {
    final jpeg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 1]);
    final controller = ProfileController(
      repository: FakeProfileRepository(
        profile: testProfile(profileImageId: 9),
        image: testProfileImage(bytes: jpeg),
      ),
      username: 'Topi.J',
    );

    await controller.load();

    expect(controller.usesDefaultAvatar, isFalse);
    expect(controller.imageStatus, ProfileImageStatus.loaded);
    expect(controller.imageBytes, jpeg);
  });

  test('successful image upload updates profile state', () async {
    final repository = FakeProfileRepository(profile: testProfile());
    final controller = ProfileController(
      repository: repository,
      username: 'Topi.J',
    );
    await controller.load();
    expect(controller.usesDefaultAvatar, isTrue);

    final jpeg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 4, 5]);
    final uploaded = await controller.uploadProfileImage(jpeg);

    expect(uploaded, isTrue);
    expect(repository.lastUploadedBytes, jpeg);
    expect(controller.usesDefaultAvatar, isFalse);
    expect(controller.imageBytes, jpeg);
    expect(controller.profile?.profileImageId, 9);
    expect(controller.errorMessage, isNull);
  });

  test('upload failure produces an error message', () async {
    final controller = ProfileController(
      repository: FakeProfileRepository(
        profile: testProfile(),
        uploadError: MessengerInvalidMediaException(
          code: 'unsupportedFormat',
          message: 'Profile pictures must be JPEG or PNG.',
        ),
      ),
      username: 'Topi.J',
    );
    await controller.load();

    final uploaded = await controller.uploadProfileImage(
      Uint8List.fromList([0x47, 0x49, 0x46]),
    );

    expect(uploaded, isFalse);
    expect(controller.usesDefaultAvatar, isTrue);
    expect(controller.errorMessage, contains('JPEG or PNG'));
  });

  test('oversized upload is rejected before the server is called', () async {
    final repository = FakeProfileRepository(profile: testProfile());
    final controller = ProfileController(
      repository: repository,
      username: 'Topi.J',
    );
    await controller.load();

    final uploaded = await controller.uploadProfileImage(
      Uint8List(ProfileController.maxProfileImageBytes + 1),
    );

    expect(uploaded, isFalse);
    expect(repository.lastUploadedBytes, isNull);
    expect(controller.errorMessage, contains('5 MB'));
  });
}
