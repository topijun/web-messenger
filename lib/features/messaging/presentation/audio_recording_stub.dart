import 'dart:typed_data';

/// Fallback when neither IO nor web libraries are available.
Future<String> recordingOutputPath() {
  throw UnsupportedError('Audio recording is not supported on this platform.');
}

/// Reads WAV bytes from a recorder output path.
Future<Uint8List> readRecordingBytes(String path) {
  throw UnsupportedError('Audio recording is not supported on this platform.');
}

/// Deletes a temporary recording if one exists.
Future<void> deleteRecordingFile(String path) async {}
