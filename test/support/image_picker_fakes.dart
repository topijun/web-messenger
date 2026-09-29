import 'dart:typed_data';

import 'package:mobile_messenger/features/media/data/image_library_picker.dart';

/// [ImageLibraryPicker] that returns a fixed result without a platform plugin.
class FakeImageLibraryPicker implements ImageLibraryPicker {
  FakeImageLibraryPicker({this.image, this.media});

  PickedLibraryImage? image;
  PickedLibraryImage? media;
  var pickCalls = 0;
  var pickImageCalls = 0;
  var pickMediaCalls = 0;

  @override
  Future<PickedLibraryImage?> pickImage() async {
    pickCalls += 1;
    pickImageCalls += 1;
    return image;
  }

  @override
  Future<PickedLibraryImage?> pickMedia() async {
    pickCalls += 1;
    pickMediaCalls += 1;
    return media;
  }
}

PickedLibraryImage fakePickedImage({
  required Uint8List bytes,
  String name = 'photo.png',
}) {
  return PickedLibraryImage(bytes: bytes, name: name);
}

/// Minimal `ftypisom` MP4 header accepted by [ChatMediaFormat.detect].
final Uint8List testMp4Bytes = Uint8List.fromList(const [
  0x00,
  0x00,
  0x00,
  0x18,
  0x66,
  0x74,
  0x79,
  0x70,
  0x69,
  0x73,
  0x6F,
  0x6D,
  0x00,
  0x00,
  0x00,
  0x00,
  0x69,
  0x73,
  0x6F,
  0x6D,
  0x6D,
  0x70,
  0x34,
  0x31,
]);
