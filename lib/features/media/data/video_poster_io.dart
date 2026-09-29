import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// Captures a 320px JPEG using the platform video decoder.
Future<Uint8List?> extractVideoPoster({
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
  final dir = await getTemporaryDirectory();
  final file = File(
    '${dir.path}/messenger_poster_${bytes.hashCode}.$extension',
  );
  await file.writeAsBytes(bytes, flush: true);
  try {
    return await VideoThumbnail.thumbnailData(
      video: file.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 320,
      quality: 70,
    );
  } catch (_) {
    return null;
  } finally {
    if (await file.exists()) {
      await file.delete();
    }
  }
}
