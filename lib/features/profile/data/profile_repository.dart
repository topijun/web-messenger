import 'dart:typed_data';

import 'package:messenger_client/messenger_client.dart';

/// Server-backed profile operations for the signed-in user.
abstract class ProfileRepository {
  /// Loads or creates the current user's profile.
  Future<Profile> getMine();

  /// Saves the current user's about-me text.
  Future<Profile> updateMine({required String aboutMe});

  /// Uploads JPEG/PNG bytes as the current user's profile picture.
  Future<ProfileImage> uploadProfileImage({required Uint8List bytes});

  /// Loads a decrypted profile picture.
  ///
  /// Omitting [mediaId] returns the current user's picture.
  Future<ProfileImage?> getProfileImage({int? mediaId});
}

/// [ProfileRepository] that talks to the generated Serverpod client.
class ServerpodProfileRepository implements ProfileRepository {
  /// Creates a [ServerpodProfileRepository].
  const ServerpodProfileRepository(this._client);

  final Client _client;

  @override
  Future<Profile> getMine() => _client.profile.getMine();

  @override
  Future<Profile> updateMine({required String aboutMe}) {
    return _client.profile.updateMine(aboutMe: aboutMe);
  }

  @override
  Future<ProfileImage> uploadProfileImage({required Uint8List bytes}) {
    return _client.profile.uploadProfileImage(
      bytes: ByteData.sublistView(bytes),
    );
  }

  @override
  Future<ProfileImage?> getProfileImage({int? mediaId}) {
    return _client.profile.getProfileImage(mediaId: mediaId);
  }
}

/// Copies [ProfileImage.bytes] into a [Uint8List].
Uint8List profileImageBytes(ProfileImage image) {
  return Uint8List.sublistView(image.bytes);
}
