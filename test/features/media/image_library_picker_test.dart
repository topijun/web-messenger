import 'package:flutter_test/flutter_test.dart';

import '../../support/image_picker_fakes.dart';
import '../../support/profile_fakes.dart';

void main() {
  test('fake picker returns the selected image once', () async {
    final picker = FakeImageLibraryPicker(
      image: fakePickedImage(bytes: testPngBytes, name: 'roll.png'),
    );

    final first = await picker.pickImage();
    expect(first?.name, 'roll.png');
    expect(first?.bytes, testPngBytes);
    expect(picker.pickImageCalls, 1);
    expect(picker.pickMediaCalls, 0);
  });

  test('fake media picker returns an image or a video', () async {
    final picker = FakeImageLibraryPicker(
      media: fakePickedImage(bytes: testMp4Bytes, name: 'clip.mp4'),
    );

    final first = await picker.pickMedia();
    expect(first?.name, 'clip.mp4');
    expect(first?.bytes, testMp4Bytes);
    expect(picker.pickMediaCalls, 1);
    expect(picker.pickImageCalls, 0);
  });

  test('fake picker treats a cancelled selection as null', () async {
    final picker = FakeImageLibraryPicker();

    expect(await picker.pickImage(), isNull);
    expect(await picker.pickMedia(), isNull);
    expect(picker.pickImageCalls, 1);
    expect(picker.pickMediaCalls, 1);
  });
}
