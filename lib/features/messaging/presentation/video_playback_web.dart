import 'dart:js_interop';
import 'dart:typed_data';

import 'package:video_player/video_player.dart';
import 'package:web/web.dart' as web;

/// Creates a blob URL so HTML5 video can play decrypted bytes.
Future<VideoPlayerController> createChatVideoController({
  required int mediaId,
  required Uint8List bytes,
  required String mimeType,
}) async {
  final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: mimeType));
  final url = web.URL.createObjectURL(blob);
  return VideoPlayerController.networkUrl(Uri.parse(url));
}
