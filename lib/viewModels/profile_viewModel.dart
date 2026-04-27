import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/user.dart';
import '../services/profile_image_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final ProfileImageService _profileImageService;

  ProfileViewModel(this._userRepository, this._profileImageService);

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
      print("ProfileVM error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> softDeleteAcc() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;

    await _userRepository.softDeleteUser(uid: firebaseUser.uid);
  }

  Future<void> updateUserProfile({
    Users? updatedUser,
    XFile? profilePicture,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return;

      Users? currentUser = await _userRepository.getUser(firebaseUser.uid);

      if (currentUser == null) return;

      if (profilePicture != null) {
        currentUser.profilePictureUrl = await _profileImageService
            .uploadProfileImage(userId: firebaseUser.uid, file: profilePicture);
      }

      if (updatedUser != null) {
        if (updatedUser.name != currentUser.name) {
          currentUser.name = updatedUser.name;
        }
      }

      user = currentUser;

      await _userRepository.updateUser(
        uid: firebaseUser.uid,
        updatedUser: currentUser,
      );
    } catch (e) {
      print("ProfileVM error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
