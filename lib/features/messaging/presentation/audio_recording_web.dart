import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Dummy path; the web recorder ignores it and returns a blob URL from stop.
Future<String> recordingOutputPath() async => 'audio.wav';

/// Fetches WAV bytes from the blob URL returned by [AudioRecorder.stop].
Future<Uint8List> readRecordingBytes(String path) async {
  final response = await web.window.fetch(path.toJS).toDart;
  final buffer = await response.arrayBuffer().toDart;
  return buffer.toDart.asUint8List();
}

/// Releases the blob URL after the bytes have been copied.
Future<void> deleteRecordingFile(String path) async {
  try {
    web.URL.revokeObjectURL(path);
  } catch (_) {
    // Blob URLs that were already revoked are ignored.
  }
}
