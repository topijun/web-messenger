import 'package:flutter/material.dart';
import 'package:mobile_messenger/features/profile/data/profile_image_store.dart';
import 'package:mobile_messenger/features/profile/data/profile_repository.dart';

/// Provides the app-wide [ProfileRepository] and image cache.
class ProfileScope extends InheritedWidget {
  /// Creates a [ProfileScope].
  const ProfileScope({
    super.key,
    required this.repository,
    required this.images,
    required super.child,
  });

  final ProfileRepository repository;
  final ProfileImageStore images;

  /// The nearest [ProfileScope], if any.
  static ProfileScope? maybeScopeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ProfileScope>();
  }

  /// The nearest [ProfileRepository], if any.
  static ProfileRepository? maybeOf(BuildContext context) {
    return maybeScopeOf(context)?.repository;
  }

  /// The nearest [ProfileRepository].
  static ProfileRepository of(BuildContext context) {
    final repository = maybeOf(context);
    assert(repository != null, 'ProfileScope is missing from the widget tree.');
    return repository!;
  }

  @override
  bool updateShouldNotify(ProfileScope oldWidget) =>
      repository != oldWidget.repository || images != oldWidget.images;
}
