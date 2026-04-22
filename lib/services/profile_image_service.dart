import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import '../data/repositories/storage_repository.dart';

class ProfileImageService {
  final StorageRepository _storageRepository;

  ProfileImageService(this._storageRepository);

  Future<String> uploadProfileImage({
    required String userId,
    required XFile file,
  }) async {
    final path =
        'profile-images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      return await _storageRepository.uploadBytes(
        path: path,
        bytes: bytes,
      );
    } else {
      return await _storageRepository.uploadFile(
        path: path,
        file: File(file.path),
      );
    }
  }
}