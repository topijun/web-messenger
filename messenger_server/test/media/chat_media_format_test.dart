import 'dart:typed_data';

import 'package:messenger_server/src/generated/protocol.dart';
import 'package:messenger_server/src/media/media_bytes.dart';
import 'package:test/test.dart';

void main() {
  test('detects JPEG, PNG, MP4, and WebM from magic bytes', () {
    expect(ChatMediaFormat.detect(_jpeg())?.mimeType, 'image/jpeg');
    expect(ChatMediaFormat.detect(_png())?.mimeType, 'image/png');
    expect(ChatMediaFormat.detect(_ftyp('isom'))?.mimeType, 'video/mp4');
    expect(ChatMediaFormat.detect(_webm())?.mimeType, 'video/webm');
  });

  test('detects MOV, M4V, 3GP, and HEVC-in-MP4 containers', () {
    expect(ChatMediaFormat.detect(_ftyp('qt  '))?.mimeType, 'video/quicktime');
    expect(ChatMediaFormat.detect(_ftyp('qt  '))?.type, MediaType.video);
    expect(ChatMediaFormat.detect(_ftyp('M4V '))?.mimeType, 'video/x-m4v');
    expect(ChatMediaFormat.detect(_ftyp('3gp4'))?.mimeType, 'video/3gpp');
    expect(ChatMediaFormat.detect(_ftyp('hev1'))?.mimeType, 'video/mp4');
    expect(ChatMediaFormat.detect(_ftyp('hvc1'))?.mimeType, 'video/mp4');
  });

  test('rejects GIF, HEIC, and Matroska', () {
    expect(ChatMediaFormat.detect(_gif()), isNull);
    expect(ChatMediaFormat.detect(_ftyp('heic')), isNull);
    expect(ChatMediaFormat.detect(_ftyp('mif1')), isNull);
    expect(ChatMediaFormat.detect(_matroska()), isNull);
  });

  test(
    'detectAudio accepts WAV and rejects image, video, and tiny payloads',
    () {
      expect(ChatMediaFormat.detectAudio(_wav())?.mimeType, 'audio/wav');
      expect(ChatMediaFormat.detectAudio(_wav())?.type, MediaType.audio);
      expect(ChatMediaFormat.detect(_wav()), isNull);
      expect(ChatMediaFormat.detectAudio(_jpeg()), isNull);
      expect(ChatMediaFormat.detectAudio(_ftyp('isom')), isNull);
      expect(ChatMediaFormat.detectAudio(Uint8List(10)), isNull);
    },
  );
}

Uint8List _jpeg() => Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]);

Uint8List _png() => Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
]);

Uint8List _gif() => Uint8List.fromList([0x47, 0x49, 0x46, 0x38, 0x39, 0x61]);

Uint8List _ftyp(String brand) {
  assert(brand.length == 4);
  return Uint8List.fromList([
    0x00,
    0x00,
    0x00,
    0x18,
    0x66,
    0x74,
    0x79,
    0x70,
    ...brand.codeUnits,
  ]);
}

Uint8List _webm() => Uint8List.fromList([
  0x1A,
  0x45,
  0xDF,
  0xA3,
  0x42,
  0x82,
  0x84,
  0x77,
  0x65,
  0x62,
  0x6D,
]);

Uint8List _matroska() => Uint8List.fromList([
  0x1A,
  0x45,
  0xDF,
  0xA3,
  0x6D,
  0x61,
  0x74,
  0x72,
  0x6F,
  0x73,
  0x6B,
  0x61,
]);

Uint8List _wav() {
  final bytes = Uint8List(48);
  bytes[0] = 0x52;
  bytes[1] = 0x49;
  bytes[2] = 0x46;
  bytes[3] = 0x46;
  bytes[8] = 0x57;
  bytes[9] = 0x41;
  bytes[10] = 0x56;
  bytes[11] = 0x45;
  return bytes;
}
