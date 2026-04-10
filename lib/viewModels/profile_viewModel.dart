import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:t5/data/repositories/storage_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/user.dart';
import 'package:flutter/foundation.dart'; // kIsWeb

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final StorageRepository _storageRepository;

  ProfileViewModel(this._userRepository, this._storageRepository);

  Users? user;
  bool isLoading = false;

  Future<void> loadUser() async {
    try {
      isLoading = true;
      notifyListeners();

      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) return;

      user = await _userRepository.getUser(firebaseUser.uid);

    } catch (e) {
      print("Erro ProfileVM: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }



  Future<void> uploadProfileImage(XFile pickedFile) async {
    try {
      isLoading = true;
      notifyListeners();

      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return;

      String imageUrl;

      if (kIsWeb) {
        // WEB
        final bytes = await pickedFile.readAsBytes();

        imageUrl = await _storageRepository.uploadProfileImageWeb(
          userId: firebaseUser.uid,
          bytes: bytes,
        );
      } else {
        // MOBILE
        final file = File(pickedFile.path);

        imageUrl = await _storageRepository.uploadProfileImage(
          userId: firebaseUser.uid,
          file: file,
        );
      }

      await _userRepository.updateProfilePicture(
        uid: firebaseUser.uid,
        imageUrl: imageUrl,
      );

      user = Users(
        name: user!.name,
        email: user!.email,
        profilePictureUrl: imageUrl,
      ); 

    } catch (e) {
      print("Erro upload: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
}