import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/core/lifecycle/app_resume_guard.dart';
import 'package:mobile_messenger/features/chats/application/chat_controller.dart';
import 'package:mobile_messenger/features/chats/presentation/chat_detail_screen.dart';
import 'package:mobile_messenger/features/chats/presentation/chat_nav_title.dart';
import 'package:mobile_messenger/features/media/data/image_library_picker.dart';
import 'package:mobile_messenger/features/media/data/video_poster.dart';
import 'package:mobile_messenger/features/messaging/application/conversation_controller.dart';
import 'package:mobile_messenger/features/messaging/data/message_repository.dart';
import 'package:mobile_messenger/features/messaging/domain/chat_audio.dart';
import 'package:mobile_messenger/features/messaging/domain/chat_media_format.dart';
import 'package:mobile_messenger/features/messaging/presentation/chat_video_player.dart';
import 'package:mobile_messenger/features/messaging/presentation/device_chat_audio.dart';
import 'package:mobile_messenger/features/profile/presentation/widgets/profile_avatar.dart';

/// Functional conversation UI for one chat: history, composer, receipts.
class ConversationScreen extends StatefulWidget {
  /// Creates a [ConversationScreen].
  const ConversationScreen({
    super.key,
    required this.chatController,
    required this.summary,
    required this.messages,
    this.selfProfileImageId,
    this.recorder,
    this.playback,
    this.imagePicker,
    this.poster,
    this.embedded = false,
  });

  final ChatController chatController;
  final ChatSummary summary;
  final MessageRepository messages;
  final int? selfProfileImageId;

  /// When true, this screen fills a pane instead of a pushed route.
  ///
  /// The app bar does not show a back button. Chat switching is owned by
  /// the surrounding layout.
  final bool embedded;
  final ChatAudioRecorder? recorder;
  final ChatAudioPlayback? playback;
  final ImageLibraryPicker? imagePicker;
  final VideoPoster? poster;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen>
    with WidgetsBindingObserver {
  final _resume = AppResumeGuard();
  late final ConversationController _controller;
  final _composer = TextEditingController();
  final _composerFocus = FocusNode();
  Uint8List? _draftBytes;
  String? _draftLabel;
  ChatAudioRecorder? _createdRecorder;
  ChatAudioPlayback? _createdPlayback;
  ImageLibraryPicker? _createdImagePicker;
  var _listeningPlayback = false;
  var _recording = false;
  var _previewing = false;
  var _elapsed = Duration.zero;
  Uint8List? _recordedBytes;
  Timer? _recordTimer;
  String? _recordError;

  ChatAudioRecorder get _recorder {
    return widget.recorder ?? (_createdRecorder ??= DeviceChatAudioRecorder());
  }

  ChatAudioPlayback get _playback {
    final value =
        widget.playback ?? (_createdPlayback ??= DeviceChatAudioPlayback());
    if (!_listeningPlayback) {
      _listeningPlayback = true;
      value.addListener(_onChanged);
    }
    return value;
  }

  ImageLibraryPicker get _imagePicker {
    return widget.imagePicker ??
        (_createdImagePicker ??= DeviceImageLibraryPicker());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = ConversationController(
      repository: widget.messages,
      chatId: widget.summary.chat.id!,
      selfUserId: widget.summary.membership.userId,
      selfProfileImageId: widget.selfProfileImageId,
      poster: widget.poster ?? const DeviceVideoPoster(),
    );
    _controller.addListener(_onChanged);
    _controller.load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recordTimer?.cancel();
    if (_listeningPlayback) {
      _playback.removeListener(_onChanged);
    }
    unawaited(_abandonRecording(notify: false));
    final recorder = _createdRecorder ?? widget.recorder;
    if (recorder != null) {
      unawaited(recorder.dispose());
    }
    final playback = _createdPlayback ?? widget.playback;
    if (playback != null) {
      unawaited(playback.dispose());
    }
    _controller.removeListener(_onChanged);
    _controller.dispose();
    _composer.dispose();
    _composerFocus.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_abandonRecording());
      if (_listeningPlayback) {
        unawaited(_playback.pause());
      }
    }
    if (_resume.shouldRefresh(state)) {
      unawaited(_resume.run(_controller.refreshOnResume));
    }
  }

  void _onChanged() {
    final playing = _listeningPlayback ? _playback.activeKey : null;
    if (playing != null) {
      final stillPlayable = _controller.items.any(
        (item) => item.localKey == playing && !item.isDeleted,
      );
      if (!stillPlayable) {
        unawaited(_playback.stop());
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _abandonRecording({bool notify = true}) async {
    _recordTimer?.cancel();
    _recordTimer = null;
    if (_recording) {
      await _recorder.cancel();
    }
    _recording = false;
    _previewing = false;
    _recordedBytes = null;
    _elapsed = Duration.zero;
    if (notify && mounted) {
      setState(() {});
    }
  }

  Future<void> _startRecording() async {
    if (_controller.isMutating || _controller.isEditing) {
      return;
    }
    _clearDraft();
    await _controller.stopTyping();
    try {
      final permitted = await _recorder.hasPermission();
      if (!permitted) {
        _showRecordError('Microphone permission is required to record audio.');
        return;
      }
      await _recorder.start();
      _recordTimer?.cancel();
      _elapsed = Duration.zero;
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _elapsed += const Duration(seconds: 1);
        });
      });
      if (!mounted) {
        await _recorder.cancel();
        return;
      }
      setState(() {
        _recording = true;
        _previewing = false;
        _recordedBytes = null;
        _recordError = null;
      });
    } on ChatAudioPermissionDenied {
      _showRecordError('Microphone permission is required to record audio.');
    } catch (_) {
      _showRecordError('Could not start recording.');
    }
  }

  Future<void> _stopRecording() async {
    if (!_recording) {
      return;
    }
    _recordTimer?.cancel();
    _recordTimer = null;
    try {
      final bytes = await _recorder.stop();
      if (!mounted) {
        return;
      }
      if (bytes == null || bytes.length <= ChatMediaFormat.wavHeaderBytes) {
        _showRecordError('Audio cannot be empty.');
        setState(() {
          _recording = false;
          _previewing = false;
          _recordedBytes = null;
        });
        return;
      }
      if (bytes.length > ChatMediaFormat.maxAudioBytes) {
        _showRecordError('Audio must be at most 10 MB.');
        setState(() {
          _recording = false;
          _previewing = false;
          _recordedBytes = null;
        });
        return;
      }
      if (ChatMediaFormat.detectAudio(bytes) == null) {
        _showRecordError('Audio must be WAV.');
        setState(() {
          _recording = false;
          _previewing = false;
          _recordedBytes = null;
        });
        return;
      }
      setState(() {
        _recording = false;
        _previewing = true;
        _recordedBytes = bytes;
        _recordError = null;
      });
    } catch (_) {
      _showRecordError('Could not finish recording.');
    }
  }

  Future<void> _cancelRecording() async {
    await _abandonRecording();
  }

  Future<void> _sendRecording() async {
    final bytes = _recordedBytes;
    if (bytes == null) {
      return;
    }
    setState(() {
      _previewing = false;
      _recordedBytes = null;
    });
    await _controller.sendAudio(bytes);
  }

  void _showRecordError(String message) {
    if (!mounted) {
      return;
    }
    setState(() {
      _recording = false;
      _previewing = false;
      _recordError = message;
    });
  }

  Future<void> _openDetails() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatDetailScreen(
          controller: widget.chatController,
          summary: widget.summary,
        ),
      ),
    );
  }

  Future<void> _send() async {
    if (_controller.isEditing) {
      await _controller.saveEdit(_composer.text);
      if (_controller.editingItem == null && mounted) {
        _composer.clear();
      }
      return;
    }
    final draft = _draftBytes;
    if (draft != null) {
      setState(() {
        _draftBytes = null;
        _draftLabel = null;
      });
      await _controller.sendMedia(draft);
      return;
    }
    if (_previewing && _recordedBytes != null) {
      await _sendRecording();
      return;
    }
    final text = _composer.text;
    _composer.clear();
    await _controller.send(text);
    _composerFocus.requestFocus();
  }

  void _clearDraft() {
    setState(() {
      _draftBytes = null;
      _draftLabel = null;
    });
  }

  void _startEdit(ConversationItem item) {
    _controller.beginEdit(item);
    _composer.text = item.text;
    _composerFocus.requestFocus();
  }

  void _cancelEdit() {
    _controller.cancelEdit();
    _composer.clear();
  }

  Future<void> _confirmDelete(ConversationItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete message?'),
          content: const Text(
            'The message will stay in the chat as a deleted placeholder.',
          ),
          actions: [
            TextButton(
              key: const Key('cancelDeleteMessage'),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              key: const Key('confirmDeleteMessage'),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed == true && mounted) {
      await _controller.deleteMessage(item);
    }
  }

  Future<void> _pick() async {
    final picked = await _imagePicker.pickMedia();
    final bytes = picked?.bytes;
    final name = picked?.name;
    if (bytes == null || !mounted) {
      return;
    }
    if (bytes.length > ChatMediaFormat.maxBytes) {
      setState(() {});
      _controller.sendMedia(bytes);
      return;
    }
    final format = ChatMediaFormat.detect(bytes);
    if (format == null) {
      await _controller.sendMedia(bytes);
      return;
    }
    final sizeKb = (bytes.length / 1024).toStringAsFixed(0);
    setState(() {
      _draftBytes = bytes;
      _draftLabel =
          '${name ?? (format.isVideo ? 'Video' : 'Photo')} · $sizeKb KB';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('conversationScreen'),
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: ChatNavTitle(summary: widget.summary),
        actions: [
          IconButton(
            key: const Key('openChatDetails'),
            tooltip: 'Chat details',
            onPressed: _openDetails,
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          if (_controller.typingLabel != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _controller.typingLabel!,
                  key: const Key('typingIndicator'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          if (_controller.errorMessage != null || _recordError != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                _recordError ?? _controller.errorMessage!,
                key: const Key('conversationErrorBanner'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          _Composer(
            controller: _composer,
            focusNode: _composerFocus,
            onSend: _send,
            onChanged: _controller.onComposerTextChanged,
            onPick:
                _controller.isMutating ||
                    _controller.isEditing ||
                    _recording ||
                    _previewing
                ? null
                : _pick,
            sending: _controller.isMutating,
            draftLabel: _draftLabel,
            onClearDraft: _draftBytes == null ? null : _clearDraft,
            editing: _controller.isEditing,
            onCancelEdit: _cancelEdit,
            recording: _recording,
            previewing: _previewing,
            elapsed: _elapsed,
            onStartRecording: _controller.isMutating || _controller.isEditing
                ? null
                : _startRecording,
            onStopRecording: _stopRecording,
            onCancelRecording: _cancelRecording,
            onSendRecording: _sendRecording,
          ),
        ],
      ),
    );
  }

  bool _showMessageAvatar(int index) {
    final items = _controller.items;
    final item = items[index];
    if (index + 1 >= items.length) {
      return true;
    }
    final older = items[index + 1];
    if (item.isMine != older.isMine) {
      return true;
    }
    if (item.isMine) {
      return false;
    }
    return item.senderUsername != older.senderUsername;
  }

  Widget _buildBody() {
    if (_controller.status == ConversationStatus.loading &&
        _controller.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.status == ConversationStatus.error &&
        _controller.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _controller.errorMessage ?? 'Could not load messages.',
                key: const Key('conversationError'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _controller.load,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_controller.items.isEmpty) {
      return const Center(
        child: Text('No messages yet.', key: Key('conversationEmpty')),
      );
    }

    return Column(
      children: [
        if (_controller.hasMore)
          TextButton(
            key: const Key('loadOlderMessages'),
            onPressed: _controller.loadingOlder ? null : _controller.loadOlder,
            child: _controller.loadingOlder
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Load older messages'),
          ),
        Expanded(
          child: ListView.builder(
            key: const Key('messageList'),
            reverse: true,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            itemCount: _controller.items.length,
            itemBuilder: (context, index) {
              final item = _controller.items[index];
              return _MessageBubble(
                item: item,
                showAvatar: _showMessageAvatar(index),
                controller: _controller,
                playback: item.isAudio ? _playback : null,
                onRetry: () => _controller.retry(item.localKey),
                onEdit: item.canEdit ? () => _startEdit(item) : null,
                onDelete: item.canDelete ? () => _confirmDelete(item) : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.onChanged,
    required this.onPick,
    required this.sending,
    this.draftLabel,
    this.onClearDraft,
    this.editing = false,
    this.onCancelEdit,
    this.recording = false,
    this.previewing = false,
    this.elapsed = Duration.zero,
    this.onStartRecording,
    this.onStopRecording,
    this.onCancelRecording,
    this.onSendRecording,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final ValueChanged<String> onChanged;
  final VoidCallback? onPick;
  final bool sending;
  final String? draftLabel;
  final VoidCallback? onClearDraft;
  final bool editing;
  final VoidCallback? onCancelEdit;
  final bool recording;
  final bool previewing;
  final Duration elapsed;
  final VoidCallback? onStartRecording;
  final VoidCallback? onStopRecording;
  final VoidCallback? onCancelRecording;
  final VoidCallback? onSendRecording;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Column(
          children: [
            if (editing)
              Row(
                children: [
                  const Expanded(
                    child: Text('Editing message', key: Key('editModeBanner')),
                  ),
                  TextButton(
                    key: const Key('cancelEdit'),
                    onPressed: sending ? null : onCancelEdit,
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            if (draftLabel != null)
              Row(
                children: [
                  Expanded(
                    child: Text(draftLabel!, key: const Key('mediaDraftLabel')),
                  ),
                  TextButton(
                    key: const Key('cancelMediaDraft'),
                    onPressed: sending ? null : onClearDraft,
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            if (recording || previewing)
              Row(
                children: [
                  Icon(
                    recording ? Icons.mic : Icons.graphic_eq,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recording
                          ? 'Recording ${formatAudioClock(elapsed)}'
                          : 'Audio ${formatAudioClock(elapsed)}',
                      key: recording
                          ? const Key('recordingTimer')
                          : const Key('recordingPreview'),
                    ),
                  ),
                  if (recording)
                    TextButton(
                      key: const Key('stopAudioRecording'),
                      onPressed: sending ? null : onStopRecording,
                      child: const Text('Stop'),
                    )
                  else
                    TextButton(
                      key: const Key('sendAudioRecording'),
                      onPressed: sending ? null : onSendRecording,
                      child: const Text('Send'),
                    ),
                  TextButton(
                    key: const Key('cancelAudioRecording'),
                    onPressed: sending ? null : onCancelRecording,
                    child: const Text('Cancel'),
                  ),
                ],
              )
            else
              Row(
                children: [
                  IconButton(
                    key: const Key('attachMedia'),
                    tooltip: 'Media',
                    onPressed: onPick == null || sending ? null : onPick,
                    icon: const Icon(Icons.attach_file),
                  ),
                  Expanded(
                    child: TextField(
                      key: const Key('messageComposer'),
                      controller: controller,
                      focusNode: focusNode,
                      enabled: !sending && draftLabel == null,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                      onChanged: onChanged,
                      decoration: InputDecoration(
                        hintText: editing ? 'Edit message' : 'Message',
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('startAudioRecording'),
                    tooltip: 'Record audio',
                    onPressed: sending ? null : onStartRecording,
                    icon: const Icon(Icons.mic_none),
                  ),
                  IconButton(
                    key: editing
                        ? const Key('saveEdit')
                        : const Key('sendMessage'),
                    tooltip: editing ? 'Save' : 'Send',
                    onPressed: sending ? null : onSend,
                    icon: sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(editing ? Icons.check : Icons.send),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.item,
    required this.showAvatar,
    required this.controller,
    required this.playback,
    required this.onRetry,
    this.onEdit,
    this.onDelete,
  });

  final ConversationItem item;
  final bool showAvatar;
  final ConversationController controller;
  final ChatAudioPlayback? playback;
  final VoidCallback onRetry;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final audioPlayback = playback;
    final align = item.isMine ? Alignment.centerRight : Alignment.centerLeft;
    final color = item.isMine
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest;
    const avatarSize = 32.0;
    final avatar = showAvatar
        ? ProfileAvatar(
            key: Key('messageAvatar-${item.localKey}'),
            profileImageId: item.senderProfileImageId,
            size: avatarSize,
          )
        : const SizedBox(width: avatarSize, height: avatarSize);
    final bubble = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: GestureDetector(
        key: Key('messageBubble-${item.localKey}'),
        onLongPress: onEdit == null && onDelete == null
            ? null
            : () => _showActions(context),
        child: Card(
          color: color,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              crossAxisAlignment: item.isMine
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!item.isMine && item.senderUsername != null && showAvatar)
                  Text(
                    item.senderUsername!,
                    style: theme.textTheme.labelSmall,
                  ),
                if (item.isDeleted)
                  Text(
                    'Message deleted',
                    key: Key('deletedMessage-${item.localKey}'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else if (item.isMedia)
                  _MediaBody(item: item, controller: controller)
                else if (item.isAudio && audioPlayback != null)
                  _AudioBody(
                    item: item,
                    controller: controller,
                    playback: audioPlayback,
                  )
                else
                  Text(item.text, key: Key('messageText-${item.localKey}')),
                if (item.isEdited)
                  Text(
                    'Edited',
                    key: Key('editedLabel-${item.localKey}'),
                    style: theme.textTheme.labelSmall,
                  ),
                const SizedBox(height: 4),
                if (item.isMine && !item.isDeleted)
                  Text(
                    _statusLabel(item.status),
                    key: Key('receiptStatus-${item.localKey}'),
                    style: theme.textTheme.labelSmall,
                  ),
                if (item.status == ConversationItemStatus.failed)
                  TextButton(
                    key: Key('retryMessage-${item.localKey}'),
                    onPressed: onRetry,
                    child: const Text('Retry'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    return Align(
      alignment: align,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!item.isMine) ...[avatar, const SizedBox(width: 6)],
          Flexible(child: bubble),
          if (item.isMine) ...[const SizedBox(width: 6), avatar],
        ],
      ),
    );
  }

  Future<void> _showActions(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onEdit != null)
                ListTile(
                  key: const Key('editMessageAction'),
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit'),
                  onTap: () {
                    Navigator.of(context).pop();
                    onEdit!();
                  },
                ),
              if (onDelete != null)
                ListTile(
                  key: const Key('deleteMessageAction'),
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Delete'),
                  onTap: () {
                    Navigator.of(context).pop();
                    onDelete!();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  String _statusLabel(ConversationItemStatus status) {
    return switch (status) {
      ConversationItemStatus.sending => 'Sending',
      ConversationItemStatus.sent => 'Sent',
      ConversationItemStatus.delivered => 'Delivered',
      ConversationItemStatus.read => 'Read',
      ConversationItemStatus.failed => 'Failed',
      ConversationItemStatus.received => '',
    };
  }
}

class _MediaBody extends StatefulWidget {
  const _MediaBody({required this.item, required this.controller});

  final ConversationItem item;
  final ConversationController controller;

  @override
  State<_MediaBody> createState() => _MediaBodyState();
}

class _MediaBodyState extends State<_MediaBody> {
  var _playRequested = false;

  @override
  void initState() {
    super.initState();
    _request();
  }

  @override
  void didUpdateWidget(_MediaBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    _request();
  }

  void _request() {
    final item = widget.item;
    if (item.pendingBytes != null) {
      return;
    }
    if (item.type == MessageType.video) {
      final thumbnailId = item.thumbnailMediaId;
      if (thumbnailId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.controller.ensureMedia(thumbnailId);
        });
      }
      return;
    }
    final mediaId = item.mediaId;
    if (mediaId == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.ensureMedia(mediaId);
    });
  }

  Future<void> _playVideo() async {
    setState(() => _playRequested = true);
    final mediaId = widget.item.mediaId;
    if (mediaId != null && widget.controller.mediaBytes(mediaId) == null) {
      await widget.controller.ensureMedia(mediaId);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    if (item.type == MessageType.video) {
      return _buildVideo(item);
    }
    return _buildImage(item);
  }

  Widget _buildImage(ConversationItem item) {
    final bytes =
        item.pendingBytes ??
        (item.mediaId != null
            ? widget.controller.mediaBytes(item.mediaId!)
            : null);
    final status = item.mediaId == null
        ? (bytes == null
              ? ConversationMediaStatus.idle
              : ConversationMediaStatus.loaded)
        : widget.controller.mediaStatus(item.mediaId!);

    if (bytes == null) {
      if (status == ConversationMediaStatus.failed) {
        return Text(
          'Could not load media.',
          key: Key('mediaError-${item.localKey}'),
        );
      }
      return SizedBox(
        key: Key('mediaLoading-${item.localKey}'),
        width: 48,
        height: 48,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return _ChatImage(localKey: item.localKey, bytes: bytes);
  }

  Widget _buildVideo(ConversationItem item) {
    final videoBytes =
        item.pendingBytes ??
        (item.mediaId != null
            ? widget.controller.mediaBytes(item.mediaId!)
            : null);
    final mime =
        item.mimeType ??
        (item.mediaId != null
            ? widget.controller.mediaMimeType(item.mediaId!)
            : null);
    if (_playRequested && videoBytes != null) {
      return ChatVideoPlayer(
        key: Key('videoMessage-${item.localKey}'),
        mediaId: item.mediaId ?? item.localKey.hashCode,
        bytes: videoBytes,
        mimeType: mime ?? 'video/mp4',
        playOnReady: true,
      );
    }

    final thumbnailId = item.thumbnailMediaId;
    final thumbBytes = thumbnailId == null
        ? null
        : widget.controller.mediaBytes(thumbnailId);
    final thumbStatus = thumbnailId == null
        ? ConversationMediaStatus.idle
        : widget.controller.mediaStatus(thumbnailId);
    final videoStatus = item.mediaId == null
        ? ConversationMediaStatus.idle
        : widget.controller.mediaStatus(item.mediaId!);

    return ConstrainedBox(
      key: Key('videoMessage-${item.localKey}'),
      constraints: const BoxConstraints(maxWidth: 240, maxHeight: 240),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (thumbBytes != null)
                Positioned.fill(
                  child: Image.memory(
                    thumbBytes,
                    key: Key('videoThumb-${item.localKey}'),
                    fit: BoxFit.cover,
                  ),
                )
              else
                const ColoredBox(color: Colors.black, child: SizedBox.expand()),
              if (thumbBytes == null &&
                  thumbStatus == ConversationMediaStatus.loading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              if (_playRequested &&
                  videoStatus == ConversationMediaStatus.loading)
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (_playRequested &&
                  videoStatus == ConversationMediaStatus.failed)
                Text(
                  'Could not load media.',
                  key: Key('mediaError-${item.localKey}'),
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                )
              else
                IconButton(
                  key: Key('videoPlay-${item.mediaId ?? item.localKey}'),
                  onPressed: _playVideo,
                  icon: const Icon(
                    Icons.play_circle,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatImage extends StatelessWidget {
  const _ChatImage({required this.localKey, required this.bytes});

  final String localKey;
  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    final image = Image.memory(
      bytes,
      key: Key('imageMessage-$localKey'),
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
    return GestureDetector(
      onTap: () {
        showDialog<void>(
          context: context,
          builder: (context) {
            return Dialog(
              child: InteractiveViewer(
                child: Image.memory(bytes, fit: BoxFit.contain),
              ),
            );
          },
        );
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 240, maxHeight: 240),
        child: image,
      ),
    );
  }
}

class _AudioBody extends StatelessWidget {
  const _AudioBody({
    required this.item,
    required this.controller,
    required this.playback,
  });

  final ConversationItem item;
  final ConversationController controller;
  final ChatAudioPlayback playback;

  @override
  Widget build(BuildContext context) {
    final key = item.localKey;
    final state = playback.stateFor(key);
    final mediaStatus = item.mediaId == null
        ? ConversationMediaStatus.idle
        : controller.mediaStatus(item.mediaId!);
    final failed =
        state == ChatAudioPlaybackState.failed ||
        mediaStatus == ConversationMediaStatus.failed;
    final loading =
        state == ChatAudioPlaybackState.loading ||
        mediaStatus == ConversationMediaStatus.loading;
    final playing = state == ChatAudioPlaybackState.playing;
    final duration = playback.durationFor(key);
    final position = playback.positionFor(key);
    final clock = [
      if (position != null) formatAudioClock(position),
      formatAudioClock(duration ?? Duration.zero),
    ].join(' / ');

    return Row(
      key: Key('audioMessage-$key'),
      mainAxisSize: MainAxisSize.min,
      children: [
        if (failed)
          Flexible(
            child: Text('Could not play audio.', key: Key('audioError-$key')),
          )
        else if (loading)
          SizedBox(
            key: Key('audioLoading-$key'),
            width: 24,
            height: 24,
            child: const CircularProgressIndicator(strokeWidth: 2),
          )
        else ...[
          IconButton(
            key: Key(playing ? 'audioPause-$key' : 'audioPlay-$key'),
            tooltip: playing ? 'Pause' : 'Play',
            onPressed: () => unawaited(_toggle()),
            icon: Icon(playing ? Icons.pause : Icons.play_arrow),
          ),
          const SizedBox(width: 4),
          Text(clock, key: Key('audioDuration-$key')),
        ],
      ],
    );
  }

  Future<void> _toggle() async {
    final key = item.localKey;
    final state = playback.stateFor(key);
    if (state == ChatAudioPlaybackState.playing) {
      await playback.pause();
      return;
    }
    if (state == ChatAudioPlaybackState.paused && playback.activeKey == key) {
      await playback.resume();
      return;
    }
    var bytes =
        item.pendingBytes ??
        (item.mediaId != null ? controller.mediaBytes(item.mediaId!) : null);
    if (bytes == null && item.mediaId != null) {
      await controller.ensureMedia(item.mediaId!);
      bytes = controller.mediaBytes(item.mediaId!);
    }
    if (bytes == null) {
      return;
    }
    await playback.play(
      key: key,
      bytes: bytes,
      mimeType:
          item.mimeType ??
          controller.mediaMimeType(item.mediaId ?? -1) ??
          ChatMediaFormat.wavMime,
    );
  }
}
