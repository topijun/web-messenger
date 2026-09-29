import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile_messenger/features/profile/presentation/profile_scope.dart';
import 'package:mobile_messenger/features/profile/presentation/widgets/default_avatar.dart';

/// Circular avatar loaded from a profile-image media id.
///
/// Missing ids, in-flight loads, and fetch failures all use [DefaultAvatar].
class ProfileAvatar extends StatefulWidget {
  /// Creates a [ProfileAvatar].
  const ProfileAvatar({
    super.key,
    this.profileImageId,
    this.bytes,
    this.size = 40,
    this.placeholderKey,
  });

  /// Server media id. Ignored when [bytes] is already available.
  final int? profileImageId;

  /// Already-decoded bytes, typically the current user's loaded picture.
  final Uint8List? bytes;

  final double size;

  /// Optional key applied to the placeholder [DefaultAvatar].
  final Key? placeholderKey;

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  Uint8List? _loaded;
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureLoad();
  }

  @override
  void didUpdateWidget(covariant ProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profileImageId != widget.profileImageId ||
        oldWidget.bytes != widget.bytes) {
      _loaded = null;
      _started = false;
      _ensureLoad();
    }
  }

  void _ensureLoad() {
    if (widget.bytes != null || widget.profileImageId == null || _started) {
      return;
    }
    final store = ProfileScope.maybeScopeOf(context)?.images;
    final cached = store?.cachedBytes(widget.profileImageId!);
    if (cached != null) {
      _loaded = cached;
      return;
    }
    if (store == null) {
      return;
    }
    _started = true;
    store.bytesFor(widget.profileImageId!).then((bytes) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loaded = bytes;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bytes = widget.bytes ?? _loaded;
    if (bytes == null) {
      return DefaultAvatar(key: widget.placeholderKey, size: widget.size);
    }
    return CircleAvatar(
      radius: widget.size / 2,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      backgroundImage: MemoryImage(bytes),
    );
  }
}

/// Overlapping avatars for a group chat row.
class GroupAvatarStack extends StatelessWidget {
  /// Creates a [GroupAvatarStack].
  const GroupAvatarStack({
    super.key,
    required this.imageIds,
    this.size = 36,
    this.maxAvatars = 3,
  });

  /// Profile image ids in deterministic display order. Null means placeholder.
  final List<int?> imageIds;

  final double size;
  final int maxAvatars;

  @override
  Widget build(BuildContext context) {
    final shown = imageIds.take(maxAvatars).toList();
    if (shown.isEmpty) {
      return ProfileAvatar(size: size);
    }
    if (shown.length == 1) {
      return ProfileAvatar(profileImageId: shown.single, size: size);
    }

    const overlap = 12.0;
    final width = size + (shown.length - 1) * (size - overlap);
    return SizedBox(
      width: width,
      height: size,
      child: Stack(
        children: [
          for (var index = 0; index < shown.length; index++)
            Positioned(
              left: index * (size - overlap),
              child: ProfileAvatar(profileImageId: shown[index], size: size),
            ),
        ],
      ),
    );
  }
}

