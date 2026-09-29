import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/features/profile/data/profile_repository.dart';

/// 1x1 PNG used when widget tests decode the profile photo.
final Uint8List testPngBytes = Uint8List.fromList(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  ),
);

/// 1x1 JPEG used for video posters and JPEG magic-byte checks.
final Uint8List testJpegBytes = Uint8List.fromList(
  base64Decode(
    '/9j/4AAQSkZJRgABAQAAAQABAAD/2wAAAAD/wgARCAABAAEDAREAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAb/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIQAxAAAAGf/8QAFBABAAAAAAAAAAAAAAAAAAAAAP/aAAgBAQABPxA=',
  ),
);

Profile testProfile({
  String aboutMe = '',
  int? profileImageId,
  int userId = 1,
}) {
  return Profile(
    id: 1,
    userId: userId,
    aboutMe: aboutMe,
    profileImageId: profileImageId,
  );
}

ProfileImage testProfileImage({
  int mediaId = 9,
  String mimeType = 'image/jpeg',
  Uint8List? bytes,
}) {
  final payload = bytes ?? Uint8List.fromList([0xFF, 0xD8, 0xFF, 1, 2, 3]);
  return ProfileImage(
    mediaId: mediaId,
    mimeType: mimeType,
    size: payload.length,
    bytes: ByteData.sublistView(payload),
  );
}

class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({
    this.profile,
    this.loadError,
    this.saveError,
    this.uploadError,
    this.imageError,
    this.loadCompleter,
    this.image,
  });

  Profile? profile;
  Object? loadError;
  Object? saveError;
  Object? uploadError;
  Object? imageError;
  Completer<Profile>? loadCompleter;
  ProfileImage? image;
  String? lastSavedAboutMe;
  Uint8List? lastUploadedBytes;
  int loadCalls = 0;

  @override
  Future<Profile> getMine() async {
    loadCalls += 1;
    if (loadCompleter != null) {
      return loadCompleter!.future;
    }
    if (loadError != null) {
      throw loadError!;
    }
    return profile ?? testProfile();
  }

  @override
  Future<Profile> updateMine({required String aboutMe}) async {
    lastSavedAboutMe = aboutMe;
    if (saveError != null) {
      throw saveError!;
    }
    profile = testProfile(
      aboutMe: aboutMe,
      profileImageId: profile?.profileImageId,
    );
    return profile!;
  }

  @override
  Future<ProfileImage> uploadProfileImage({required Uint8List bytes}) async {
    lastUploadedBytes = bytes;
    if (uploadError != null) {
      throw uploadError!;
    }
    image = testProfileImage(bytes: bytes);
    profile = testProfile(
      aboutMe: profile?.aboutMe ?? '',
      profileImageId: image!.mediaId,
    );
    return image!;
  }

  int getProfileImageCalls = 0;
  int? lastRequestedMediaId;

  @override
  Future<ProfileImage?> getProfileImage({int? mediaId}) async {
    getProfileImageCalls += 1;
    lastRequestedMediaId = mediaId;
    if (imageError != null) {
      throw imageError!;
    }
    if (mediaId != null && image != null && image!.mediaId != mediaId) {
      return null;
    }
    return image;
  }
}
