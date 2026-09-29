import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_messenger/core/theme/app_theme.dart';
import 'package:mobile_messenger/features/profile/data/profile_image_store.dart';
import 'package:mobile_messenger/features/profile/presentation/profile_scope.dart';
import 'package:mobile_messenger/features/profile/presentation/widgets/default_avatar.dart';
import 'package:mobile_messenger/features/profile/presentation/widgets/profile_avatar.dart';

import '../../support/profile_fakes.dart';

void main() {
  testWidgets('missing profile image uses the placeholder', (tester) async {
    await tester.pumpWidget(
      _app(const ProfileAvatar(key: Key('subject'), size: 40)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('subject')), findsOneWidget);
    expect(find.byType(DefaultAvatar), findsOneWidget);
  });

  testWidgets('loads bytes once and reuses the cache on rebuild', (
    tester,
  ) async {
    final repository = FakeProfileRepository(
      image: testProfileImage(mediaId: 9, bytes: testPngBytes),
    );
    final store = ProfileImageStore(repository);

    await tester.pumpWidget(
      _app(
        const ProfileAvatar(profileImageId: 9, size: 40),
        repository: repository,
        store: store,
      ),
    );
    await tester.pumpAndSettle();
    expect(repository.getProfileImageCalls, 1);
    expect(find.byType(CircleAvatar), findsOneWidget);

    await tester.pumpWidget(
      _app(
        const Column(
          children: [
            ProfileAvatar(profileImageId: 9, size: 40),
            ProfileAvatar(profileImageId: 9, size: 32),
          ],
        ),
        repository: repository,
        store: store,
      ),
    );
    await tester.pumpAndSettle();
    expect(repository.getProfileImageCalls, 1);
  });

  testWidgets('a failed load falls back to the placeholder', (tester) async {
    final repository = FakeProfileRepository(imageError: Exception('down'));
    await tester.pumpWidget(
      _app(
        const Material(
          child: Column(
            children: [
              Text('Home stays up'),
              ProfileAvatar(profileImageId: 9, size: 40),
            ],
          ),
        ),
        repository: repository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home stays up'), findsOneWidget);
    expect(find.byType(DefaultAvatar), findsOneWidget);
  });

  testWidgets('placeholder is readable in light and dark themes', (
    tester,
  ) async {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(body: DefaultAvatar(size: 40)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DefaultAvatar), findsOneWidget);
    }
  });
}

Widget _app(
  Widget child, {
  FakeProfileRepository? repository,
  ProfileImageStore? store,
}) {
  final repo = repository ?? FakeProfileRepository();
  return ProfileScope(
    repository: repo,
    images: store ?? ProfileImageStore(repo),
    child: MaterialApp(home: Scaffold(body: child)),
  );
}
