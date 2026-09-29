import 'dart:typed_data';

import 'package:video_player/video_player.dart';

/// Creates a [VideoPlayerController] from decrypted chat media bytes.
Future<VideoPlayerController> createChatVideoController({
  required int mediaId,
  required Uint8List bytes,
  required String mimeType,
}) {
  throw UnsupportedError('Video playback is not supported on this platform.');
}
