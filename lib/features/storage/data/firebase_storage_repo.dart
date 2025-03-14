import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:social_app/features/storage/domain/storage_repo.dart';

class FirebaseStorageRepo implements StorageRepo {
  final storage = FirebaseStorage.instance;

  // PROFILE IMAGE
  @override
  Future<String?> uploadProfileImageMobile(String path, String fileName) {
    return _uploadFile(path, fileName, 'profile_images');
  }

  @override
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String fileName) {
    return _uploadFileBytes(fileBytes, fileName, 'profile_images');
  }

  // POSTS
  @override
  Future<String?> uploadPostImageMobile(String path, String fileName) {
    return _uploadFile(path, fileName, 'posts_images');
  }

  @override
  Future<String?> uploadPostImageWeb(Uint8List fileBytes, String fileName) {
    return _uploadFileBytes(fileBytes, fileName, 'posts_images');
  }

  /*

  HELPER METHODS - to upload files to storage

  */

  // mobile platforms (file)
  Future<String?> _uploadFile(
    String path,
    String fileName,
    String folder,
  ) async {
    try {
      // get file
      final file = File(path);

      // find place to store
      final storageRef = storage.ref().child('$folder/$fileName');

      // upload
      final uploadTask = await storageRef.putFile(file);

      // get image download url
      final downloadUrl = uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('error uploading file on mobile: $e');
      return null;
    }
  }

  // web platforms (bytes)
  Future<String?> _uploadFileBytes(
    Uint8List fileBytes,
    String fileName,
    String folder,
  ) async {
    try {
      // find place to store
      final storageRef = storage.ref().child('$folder/$fileName');

      // upload
      final uploadTask = await storageRef.putData(fileBytes);

      // get image download url
      final downloadUrl = uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('error uploading file on web: $e');
      return null;
    }
  }
}
