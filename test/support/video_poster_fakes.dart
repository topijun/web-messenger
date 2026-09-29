import 'dart:typed_data';

import 'package:mobile_messenger/features/media/data/video_poster.dart';

/// [VideoPoster] that returns a fixed JPEG without decoding video.
class FakeVideoPoster implements VideoPoster {
  FakeVideoPoster({this.bytes});

  Uint8List? bytes;
  var extractCalls = 0;

  @override
  Future<Uint8List?> extract({
    required Uint8List bytes,
    required String mimeType,
  }) async {
    extractCalls += 1;
    return this.bytes;
  }
}
