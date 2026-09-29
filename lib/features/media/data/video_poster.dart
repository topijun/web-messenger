import 'dart:typed_data';

import 'package:mobile_messenger/features/media/data/video_poster_stub.dart'
    if (dart.library.io) 'package:mobile_messenger/features/media/data/video_poster_io.dart'
    if (dart.library.js_interop) 'package:mobile_messenger/features/media/data/video_poster_web.dart';

/// Extracts a small JPEG poster from video bytes.
abstract class VideoPoster {
  /// Returns JPEG bytes, or `null` when a frame cannot be captured.
  Future<Uint8List?> extract({
    required Uint8List bytes,
    required String mimeType,
  });
}

/// Platform [VideoPoster] used by the conversation composer.
class DeviceVideoPoster implements VideoPoster {
  /// Creates a [DeviceVideoPoster].
  const DeviceVideoPoster();

  @override
  Future<Uint8List?> extract({
    required Uint8List bytes,
    required String mimeType,
  }) {
    return extractVideoPoster(bytes: bytes, mimeType: mimeType);
  }
}
