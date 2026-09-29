import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile_messenger/features/messaging/presentation/video_playback.dart';
import 'package:video_player/video_player.dart';

/// Play/pause video for decrypted chat media. Does not transcode or stream.
class ChatVideoPlayer extends StatefulWidget {
  /// Creates a [ChatVideoPlayer].
  const ChatVideoPlayer({
    super.key,
    required this.mediaId,
    required this.bytes,
    required this.mimeType,
    this.playOnReady = false,
  });

  final int mediaId;
  final Uint8List bytes;
  final String mimeType;
  final bool playOnReady;

  @override
  State<ChatVideoPlayer> createState() => _ChatVideoPlayerState();
}

class _ChatVideoPlayerState extends State<ChatVideoPlayer> {
  VideoPlayerController? _controller;
  var _initializing = false;
  var _failed = false;

  @override
  void initState() {
    super.initState();
    if (widget.playOnReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(_toggle());
        }
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_failed) {
      return;
    }
    var controller = _controller;
    if (controller == null) {
      setState(() => _initializing = true);
      try {
        controller = await createChatVideoController(
          mediaId: widget.mediaId,
          bytes: widget.bytes,
          mimeType: widget.mimeType,
        );
        await controller.initialize();
        if (!mounted) {
          await controller.dispose();
          return;
        }
        _controller = controller;
        controller.addListener(() {
          if (mounted) {
            setState(() {});
          }
        });
      } catch (_) {
        await controller?.dispose();
        if (mounted) {
          setState(() {
            _failed = true;
            _initializing = false;
          });
        }
        return;
      }
      if (mounted) {
        setState(() => _initializing = false);
      }
    }
    if (_controller!.value.isPlaying) {
      await _controller!.pause();
    } else {
      await _controller!.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final playing = controller?.value.isPlaying ?? false;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240, maxHeight: 240),
      child: AspectRatio(
        aspectRatio: controller != null && controller.value.isInitialized
            ? controller.value.aspectRatio
            : 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ColoredBox(
                color: Colors.black,
                child: controller != null && controller.value.isInitialized
                    ? VideoPlayer(controller)
                    : const SizedBox.expand(),
              ),
              if (_failed)
                const Text(
                  'Could not play video.',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                )
              else if (_initializing)
                const CircularProgressIndicator()
              else
                IconButton(
                  key: Key('videoPlay-${widget.mediaId}'),
                  onPressed: _toggle,
                  icon: Icon(
                    playing ? Icons.pause_circle : Icons.play_circle,
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
