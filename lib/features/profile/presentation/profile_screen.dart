import 'package:flutter/material.dart';
import 'package:mobile_messenger/core/theme/theme_controller.dart';
import 'package:mobile_messenger/core/theme/theme_scope.dart';
import 'package:mobile_messenger/features/chats/application/chat_controller.dart';
import 'package:mobile_messenger/features/chats/presentation/archived_chats_screen.dart';
import 'package:mobile_messenger/features/media/data/image_library_picker.dart';
import 'package:mobile_messenger/features/profile/application/profile_controller.dart';
import 'package:mobile_messenger/features/profile/presentation/widgets/default_avatar.dart';

/// Signed-in user's profile: username, picture, and About Me.
class ProfileScreen extends StatefulWidget {
  /// Creates a [ProfileScreen].
  const ProfileScreen({
    super.key,
    required this.controller,
    this.chats,
    this.imagePicker,
  });

  final ProfileController controller;
  final ChatController? chats;
  final ImageLibraryPicker? imagePicker;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _aboutMeController;
  ImageLibraryPicker? _createdImagePicker;

  ImageLibraryPicker get _imagePicker {
    return widget.imagePicker ??
        (_createdImagePicker ??= DeviceImageLibraryPicker());
  }

  @override
  void initState() {
    super.initState();
    _aboutMeController = TextEditingController(
      text: widget.controller.profile?.aboutMe ?? '',
    );
    widget.controller.addListener(_onControllerChanged);
    if (widget.controller.profile == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.controller.profile == null) {
          widget.controller.load();
        }
      });
    }
  }

  void _onControllerChanged() {
    final aboutMe = widget.controller.profile?.aboutMe;
    if (aboutMe != null &&
        aboutMe != _aboutMeController.text &&
        widget.controller.status != ProfileStatus.saving) {
      _aboutMeController.text = aboutMe;
    }
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _aboutMeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final saved = await widget.controller.saveAboutMe(_aboutMeController.text);
    if (saved && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile saved.')));
    }
  }

  Future<void> _pickPhoto() async {
    final picked = await _imagePicker.pickImage();
    final bytes = picked?.bytes;
    if (bytes == null || !mounted) {
      return;
    }
    final uploaded = await widget.controller.uploadProfileImage(bytes);
    if (uploaded && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile picture updated.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(child: _body(controller)),
    );
  }

  Widget _body(ProfileController controller) {
    if (controller.status == ProfileStatus.loading &&
        controller.profile == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.status == ProfileStatus.error &&
        controller.profile == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.errorMessage ?? 'Could not load your profile.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: controller.load,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _Avatar(controller: controller),
          const SizedBox(height: 16),
          Text(
            controller.username,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const Key('addProfilePhoto'),
            onPressed: controller.isBusy ? null : _pickPhoto,
            icon: const Icon(Icons.photo_outlined),
            label: Text(
              controller.usesDefaultAvatar ? 'Add photo' : 'Change photo',
            ),
          ),
          const SizedBox(height: 24),
          if (ThemeScope.maybeOf(context) != null) ...[
            _AppearanceSetting(theme: ThemeScope.of(context)),
            const SizedBox(height: 24),
          ],
          if (widget.chats != null) ...[
            ListTile(
              key: const Key('archivedChatsEntry'),
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Archived'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ArchivedChatsScreen(
                      controller: widget.chats!,
                      selfProfileImageId: controller.profile?.profileImageId,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
          if (controller.errorMessage != null) ...[
            Text(
              controller.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _aboutMeController,
            enabled: !controller.isBusy,
            maxLength: 500,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'About me',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: controller.isBusy ? null : _save,
            child: controller.status == ProfileStatus.saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _AppearanceSetting extends StatelessWidget {
  const _AppearanceSetting({required this.theme});

  final ThemeController theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<AppThemePreference>(
          key: const Key('themePreference'),
          segments: const [
            ButtonSegment(
              value: AppThemePreference.light,
              label: Text('Light'),
              icon: Icon(Icons.light_mode_outlined),
            ),
            ButtonSegment(
              value: AppThemePreference.dark,
              label: Text('Dark'),
              icon: Icon(Icons.dark_mode_outlined),
            ),
          ],
          selected: {theme.preference},
          onSelectionChanged: (selected) {
            theme.setPreference(selected.single);
          },
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    final showSpinner =
        controller.imageStatus == ProfileImageStatus.loading ||
        controller.imageStatus == ProfileImageStatus.uploading;
    final bytes = controller.imageBytes;

    Widget avatar;
    if (bytes != null) {
      avatar = CircleAvatar(
        key: const Key('profilePhoto'),
        radius: 48,
        backgroundImage: MemoryImage(bytes),
      );
    } else {
      avatar = const DefaultAvatar();
    }

    if (!showSpinner) {
      return avatar;
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(opacity: 0.55, child: avatar),
        const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      ],
    );
  }
}
