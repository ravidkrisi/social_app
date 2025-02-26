import 'dart:typed_data';

abstract class StorageRepo {
  // PROFILE IMAGE
  // upload profile images on mobile platforms
  Future<String?> uploadProfileImageMobile(String path, String fileName);

  // upload profile images on web platform
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String fileName);

  // POSTS
  // upload profile images on mobile platforms
  Future<String?> uploadPostImageMobile(String path, String fileName);

  // upload profile images on web platform
  Future<String?> uploadPostImageWeb(Uint8List fileBytes, String fileName);
}
