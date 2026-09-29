import 'dart:io';
import 'dart:typed_data';

import 'package:video_player/video_player.dart';

/// Writes decrypted bytes to a temp file and opens them with [VideoPlayerController].
Future<VideoPlayerController> createChatVideoController({
  required int mediaId,
  required Uint8List bytes,
  required String mimeType,
}) async {
  final extension = switch (mimeType) {
    'video/webm' => 'webm',
    'video/quicktime' => 'mov',
    'video/x-m4v' => 'm4v',
    'video/3gpp' => '3gp',
    _ => 'mp4',
  };
  final file = File(
    '${Directory.systemTemp.path}/messenger_$mediaId.$extension',
  );
  await file.writeAsBytes(bytes, flush: true);
  return VideoPlayerController.file(file);
}
