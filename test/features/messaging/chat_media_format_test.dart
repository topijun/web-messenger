import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_messenger/features/messaging/domain/chat_media_format.dart';

import '../../support/message_fakes.dart';
import '../../support/profile_fakes.dart';

void main() {
  test('detectAudio accepts WAV and detect ignores it', () {
    final wav = testWavBytes();
    expect(ChatMediaFormat.detectAudio(wav)?.mimeType, 'audio/wav');
    expect(ChatMediaFormat.detectAudio(wav)?.isAudio, isTrue);
    expect(ChatMediaFormat.detect(wav), isNull);
  });

  test('detectAudio rejects JPEG and undersized payloads', () {
    expect(ChatMediaFormat.detectAudio(Uint8List(0)), isNull);
    expect(ChatMediaFormat.detectAudio(Uint8List(10)), isNull);
    expect(
      ChatMediaFormat.detectAudio(
        Uint8List.fromList([0xFF, 0xD8, 0xFF, ...List.filled(50, 1)]),
      ),
      isNull,
    );
  });

  test('detect accepts JPEG, PNG, MP4, and WebM', () {
    expect(ChatMediaFormat.detect(_jpeg())?.mimeType, 'image/jpeg');
    expect(ChatMediaFormat.detect(testPngBytes)?.mimeType, 'image/png');
    expect(ChatMediaFormat.detect(_ftyp('isom'))?.mimeType, 'video/mp4');
    expect(ChatMediaFormat.detect(_ftyp('isom'))?.isVideo, isTrue);
    expect(ChatMediaFormat.detect(_webm())?.mimeType, 'video/webm');
    expect(ChatMediaFormat.detect(_webm())?.isVideo, isTrue);
  });

  test('detect accepts MOV, M4V, 3GP, and HEVC-in-MP4 containers', () {
    expect(ChatMediaFormat.detect(_ftyp('qt  '))?.mimeType, 'video/quicktime');
    expect(ChatMediaFormat.detect(_ftyp('qt  '))?.isVideo, isTrue);
    expect(ChatMediaFormat.detect(_ftyp('M4V '))?.mimeType, 'video/x-m4v');
    expect(ChatMediaFormat.detect(_ftyp('3gp4'))?.mimeType, 'video/3gpp');
    expect(ChatMediaFormat.detect(_ftyp('hev1'))?.mimeType, 'video/mp4');
    expect(ChatMediaFormat.detect(_ftyp('hvc1'))?.mimeType, 'video/mp4');
  });

  test('detect still rejects HEIC, GIF, and Matroska', () {
    expect(ChatMediaFormat.detect(_ftyp('heic')), isNull);
    expect(ChatMediaFormat.detect(_ftyp('mif1')), isNull);
    expect(ChatMediaFormat.detect(_gif()), isNull);
    expect(ChatMediaFormat.detect(_matroska()), isNull);
  });
}

Uint8List _jpeg() => Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]);

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
