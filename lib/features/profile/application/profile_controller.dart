import 'package:flutter/foundation.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/features/profile/data/profile_repository.dart';

/// Status of the profile screen (About Me / metadata).
enum ProfileStatus {
  /// Fetching the profile.
  loading,

  /// Profile is available for viewing/editing.
  ready,

  /// A save is in progress.
  saving,

  /// Loading or saving failed.
  error,
}

/// Status of the profile picture, independent of About Me.
enum ProfileImageStatus {
  /// No uploaded image; show the default avatar.
  none,

  /// Fetching the existing image.
  loading,

  /// Decrypted image bytes are available.
  loaded,

  /// An upload is in progress.
  uploading,

  /// Image load or upload failed; profile remains usable.
  failed,
}

/// Owns the signed-in user's profile for presentation.
class ProfileController extends ChangeNotifier {
  /// Creates a [ProfileController].
  ProfileController({
    required ProfileRepository repository,
    required this.username,
  }) : _repository = repository;

  static const maxProfileImageBytes = 5 * 1024 * 1024;

  final ProfileRepository _repository;

  /// Messenger username shown on the profile screen.
  final String username;

  ProfileStatus _status = ProfileStatus.loading;
  Profile? _profile;
  String? _errorMessage;
  ProfileImageStatus _imageStatus = ProfileImageStatus.none;
  Uint8List? _imageBytes;
  Future<void>? _loadInFlight;

  ProfileStatus get status => _status;
  Profile? get profile => _profile;
  String? get errorMessage => _errorMessage;
  ProfileImageStatus get imageStatus => _imageStatus;
  Uint8List? get imageBytes => _imageBytes;
  bool get usesDefaultAvatar => _imageBytes == null;
  bool get isBusy =>
      _status == ProfileStatus.loading ||
      _status == ProfileStatus.saving ||
      _imageStatus == ProfileImageStatus.uploading;

  /// Loads or creates the current user's profile, then the picture if any.
  Future<void> load() {
    return _loadInFlight ??= _load().whenComplete(() {
      _loadInFlight = null;
    });
  }

  Future<void> _load() async {
    _status = ProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _profile = await _repository.getMine();
      _status = ProfileStatus.ready;
    } catch (_) {
      _status = ProfileStatus.error;
      _errorMessage = 'Could not load your profile. Please try again.';
      notifyListeners();
      return;
    }
    notifyListeners();
    await _loadImage();
  }

  /// Saves [aboutMe] for the current user.
  Future<bool> saveAboutMe(String aboutMe) async {
    _status = ProfileStatus.saving;
    _errorMessage = null;
    notifyListeners();
    try {
      _profile = await _repository.updateMine(aboutMe: aboutMe);
      _status = ProfileStatus.ready;
      notifyListeners();
      return true;
    } catch (error) {
      _status = ProfileStatus.error;
      _errorMessage = _saveError(error);
      notifyListeners();
      return false;
    }
  }

  /// Uploads JPEG/PNG [bytes] as the profile picture.
  Future<bool> uploadProfileImage(Uint8List bytes) async {
    if (bytes.length > maxProfileImageBytes) {
      _errorMessage = 'Profile pictures must be at most 5 MB.';
      notifyListeners();
      return false;
    }

    final previousBytes = _imageBytes;
    final previousStatus = _imageStatus;
    _imageStatus = ProfileImageStatus.uploading;
    _errorMessage = null;
    notifyListeners();
    try {
      final uploaded = await _repository.uploadProfileImage(bytes: bytes);
      _profile = _profile?.copyWith(profileImageId: uploaded.mediaId);
      _imageBytes = profileImageBytes(uploaded);
      _imageStatus = ProfileImageStatus.loaded;
      notifyListeners();
      return true;
    } catch (error) {
      _imageBytes = previousBytes;
      _imageStatus = previousBytes != null
          ? previousStatus == ProfileImageStatus.uploading
                ? ProfileImageStatus.loaded
                : previousStatus
          : ProfileImageStatus.failed;
      if (_imageBytes != null) {
        _imageStatus = ProfileImageStatus.loaded;
      }
      _errorMessage = _imageError(error);
      notifyListeners();
      return false;
    }
  }

  Future<void> _loadImage() async {
    final mediaId = _profile?.profileImageId;
    if (mediaId == null) {
      _imageBytes = null;
      _imageStatus = ProfileImageStatus.none;
      notifyListeners();
      return;
    }
    _imageStatus = ProfileImageStatus.loading;
    notifyListeners();
    try {
      final image = await _repository.getProfileImage();
      if (image == null) {
        _imageBytes = null;
        _imageStatus = ProfileImageStatus.none;
      } else {
        _imageBytes = profileImageBytes(image);
        _imageStatus = ProfileImageStatus.loaded;
      }
    } catch (error) {
      _imageBytes = null;
      _imageStatus = ProfileImageStatus.failed;
      _errorMessage = _imageError(error);
    }
    notifyListeners();
  }

  String _saveError(Object error) {
    if (error is MessengerInvalidProfileInputException) {
      return error.message;
    }
    if (error is MessengerEncryptedDataException) {
      return error.message;
    }
    return 'Could not save your profile. Please try again.';
  }

  String _imageError(Object error) {
    if (error is MessengerInvalidMediaException) {
      return error.message;
    }
    if (error is MessengerEncryptedDataException) {
      return 'The profile picture could not be read. Please try again.';
    }
    if (error is MessengerMediaNotFoundException) {
      return 'The profile picture could not be found.';
    }
    if (error is ServerpodClientException) {
      return 'A connection error occurred. Please check your internet '
          'connection and try again.';
    }
    return 'Could not update your profile picture. Please try again.';
  }
}
