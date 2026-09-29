import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Image bytes selected from the platform photo library.
class PickedLibraryImage {
  /// Creates a [PickedLibraryImage].
  const PickedLibraryImage({required this.bytes, required this.name});

  final Uint8List bytes;
  final String name;
}

/// Opens the platform photo library and returns one image, or `null` if cancelled.
abstract class ImageLibraryPicker {
  /// Presents the native photo library on iOS/Android, or a browser file input on web.
  Future<PickedLibraryImage?> pickImage();

  /// Presents the native photo/video library and returns one item, or `null` if cancelled.
  Future<PickedLibraryImage?> pickMedia();
}

/// [ImageLibraryPicker] backed by [ImagePicker] gallery source.
class DeviceImageLibraryPicker implements ImageLibraryPicker {
  /// Creates a [DeviceImageLibraryPicker].
  DeviceImageLibraryPicker({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<PickedLibraryImage?> pickImage() async {
    return _read(
      await _picker.pickImage(
        source: ImageSource.gallery,
        requestFullMetadata: false,
      ),
    );
  }

  @override
  Future<PickedLibraryImage?> pickMedia() async {
    return _read(await _picker.pickMedia(requestFullMetadata: false));
  }

  Future<PickedLibraryImage?> _read(XFile? file) async {
    if (file == null) {
      return null;
    }
    return PickedLibraryImage(bytes: await file.readAsBytes(), name: file.name);
  }
}
