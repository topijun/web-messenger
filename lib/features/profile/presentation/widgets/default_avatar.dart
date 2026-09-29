import 'package:flutter/material.dart';

/// Placeholder avatar used when [Profile.profileImageId] is null.
class DefaultAvatar extends StatelessWidget {
  /// Creates a [DefaultAvatar].
  const DefaultAvatar({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      key: const Key('defaultAvatar'),
      radius: size / 2,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Icon(
        Icons.person,
        size: size * 0.55,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}
