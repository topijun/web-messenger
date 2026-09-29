import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Captures a 320px JPEG from a blob-backed HTML video element.
Future<Uint8List?> extractVideoPoster({
  required Uint8List bytes,
  required String mimeType,
}) async {
  final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: mimeType));
  final url = web.URL.createObjectURL(blob);
  final video = web.HTMLVideoElement()
    ..src = url
    ..muted = true
    ..preload = 'auto';
  video.setAttribute('playsinline', 'true');
  try {
    await video.onLoadedData.first.timeout(const Duration(seconds: 5));
    if (video.videoWidth == 0 || video.videoHeight == 0) {
      return null;
    }
    video.currentTime = video.duration > 0.2 ? 0.1 : 0;
    await video.onSeeked.first.timeout(const Duration(seconds: 5));
    const width = 320;
    final height = (width * video.videoHeight / video.videoWidth).round().clamp(
      1,
      1280,
    );
    final canvas = web.HTMLCanvasElement()
      ..width = width
      ..height = height;
    canvas.context2D.drawImage(
      video,
      0,
      0,
      width.toDouble(),
      height.toDouble(),
    );
    final dataUrl = canvas.toDataUrl('image/jpeg', 0.7);
    final comma = dataUrl.indexOf(',');
    if (comma < 0) {
      return null;
    }
    return Uint8List.fromList(base64Decode(dataUrl.substring(comma + 1)));
  } catch (_) {
    return null;
  } finally {
    web.URL.revokeObjectURL(url);
    video.remove();
  }
}
