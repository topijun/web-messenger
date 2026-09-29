import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/core/theme/theme_controller.dart';
import 'package:mobile_messenger/core/theme/theme_scope.dart';
import 'package:mobile_messenger/features/media/data/image_library_picker.dart';
import 'package:mobile_messenger/features/profile/application/profile_controller.dart';
import 'package:mobile_messenger/features/profile/presentation/profile_screen.dart';
import 'package:mobile_messenger/features/profile/presentation/widgets/default_avatar.dart';

import '../../support/image_picker_fakes.dart';
import '../../support/profile_fakes.dart';

void main() {
  testWidgets('shows a loading state while the profile is fetched', (
    tester,
  ) async {
    final load = Completer<Profile>();
    final controller = ProfileController(
      repository: FakeProfileRepository(loadCompleter: load),
      username: 'Topi.J',
    );

    await tester.pumpWidget(_app(controller));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    load.complete(testProfile(aboutMe: 'Hello'));
    await tester.pumpAndSettle();
    controller.dispose();
  });

  testWidgets('shows username, about me, and the default avatar', (
    tester,
  ) async {
    final controller = ProfileController(
      repository: FakeProfileRepository(
        profile: testProfile(aboutMe: 'Likes dart'),
      ),
      username: 'Topi.J',
    );

    await tester.pumpWidget(_app(controller));
    await tester.pumpAndSettle();

    expect(find.text('Topi.J'), findsOneWidget);
    expect(find.byType(DefaultAvatar), findsOneWidget);
    expect(find.byKey(const Key('defaultAvatar')), findsOneWidget);
    expect(find.widgetWithText(TextField, 'About me'), findsOneWidget);
    expect(find.text('Likes dart'), findsOneWidget);
    expect(find.text('Add photo'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('editing About me and saving persists the text', (tester) async {
    final repository = FakeProfileRepository(profile: testProfile());
    final controller = ProfileController(
      repository: repository,
      username: 'Topi.J',
    );

    await tester.pumpWidget(_app(controller));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'About me'),
      'Works on Messenger',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(repository.lastSavedAboutMe, 'Works on Messenger');
    expect(find.text('Profile saved.'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('shows an error when the profile cannot be loaded', (
    tester,
  ) async {
    final repository = FakeProfileRepository(loadError: Exception('offline'));
    final controller = ProfileController(
      repository: repository,
      username: 'Topi.J',
    );

    await tester.pumpWidget(_app(controller));
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not load your profile'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);

    repository.loadError = null;
    await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
    await tester.pumpAndSettle();

    expect(find.text('About me'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('shows an uploaded photo instead of the default avatar', (
    tester,
  ) async {
    final jpeg = testPngBytes;
    final controller = ProfileController(
      repository: FakeProfileRepository(
        profile: testProfile(profileImageId: 9),
        image: testProfileImage(mimeType: 'image/png', bytes: jpeg),
      ),
      username: 'Topi.J',
    );

    await tester.pumpWidget(_app(controller));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profilePhoto')), findsOneWidget);
    expect(find.byType(DefaultAvatar), findsNothing);
    expect(find.text('Change photo'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('upload failure shows an error and keeps the default avatar', (
    tester,
  ) async {
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

    await tester.pumpWidget(_app(controller));
    await tester.pumpAndSettle();

    final uploaded = await controller.uploadProfileImage(
      Uint8List.fromList([0x00, 0x01]),
    );
    await tester.pump();

    expect(uploaded, isFalse);
    expect(find.byType(DefaultAvatar), findsOneWidget);
    expect(find.text('Profile pictures must be JPEG or PNG.'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('add photo uses the library picker and uploads the image', (
    tester,
  ) async {
    final repository = FakeProfileRepository(profile: testProfile());
    final controller = ProfileController(
      repository: repository,
      username: 'Topi.J',
    );
    final picker = FakeImageLibraryPicker(
      image: fakePickedImage(bytes: testPngBytes, name: 'avatar.png'),
    );

    await tester.pumpWidget(_app(controller, imagePicker: picker));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('addProfilePhoto')));
    await tester.pumpAndSettle();

    expect(picker.pickImageCalls, 1);
    expect(picker.pickMediaCalls, 0);
    expect(repository.lastUploadedBytes, testPngBytes);
    expect(find.byKey(const Key('profilePhoto')), findsOneWidget);
    expect(find.text('Profile picture updated.'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('profile exposes appearance and changing it updates theme state', (
    tester,
  ) async {
    final theme = ThemeController(store: MemoryThemePreferenceStore());
    final controller = ProfileController(
      repository: FakeProfileRepository(profile: testProfile()),
      username: 'Topi.J',
    );

    await tester.pumpWidget(_app(controller, theme: theme));
    await tester.pumpAndSettle();

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.byKey(const Key('themePreference')), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(theme.preference, AppThemePreference.light);

    final dark = find.descendant(
      of: find.byKey(const Key('themePreference')),
      matching: find.text('Dark'),
    );
    await tester.ensureVisible(dark);
    await tester.pumpAndSettle();
    await tester.tap(dark);
    await tester.pumpAndSettle();

    expect(theme.preference, AppThemePreference.dark);
    expect(theme.themeMode, ThemeMode.dark);

    final light = find.descendant(
      of: find.byKey(const Key('themePreference')),
      matching: find.text('Light'),
    );
    await tester.tap(light);
    await tester.pumpAndSettle();

    expect(theme.preference, AppThemePreference.light);
    expect(theme.themeMode, ThemeMode.light);

    theme.dispose();
    controller.dispose();
  });
}

Widget _app(
  ProfileController controller, {
  ImageLibraryPicker? imagePicker,
  ThemeController? theme,
}) {
  Widget home = ProfileScreen(controller: controller, imagePicker: imagePicker);
  if (theme != null) {
    home = ThemeScope(controller: theme, child: home);
  }
  return MaterialApp(home: home);
}
