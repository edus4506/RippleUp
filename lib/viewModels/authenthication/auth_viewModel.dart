import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:t5/data/models/social/user.dart';
import 'package:t5/data/repositories/social/user_repository.dart';
import 'package:t5/services/social/profile_image_service.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository;
  final ProfileImageService _profileImageService;

  User? currentUser;
  bool isLoading = false;
  String? errorMessage;

  AuthViewModel(this._userRepository, this._profileImageService) {
    _auth.authStateChanges().listen((user) {
      currentUser = user;
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      errorMessage = _mapError(e);
    } catch (e) {
      errorMessage = "Unexpected error";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    XFile profilePicture,
  ) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final firebaseUser = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final imageUrl = await _profileImageService.uploadProfileImage(
        userId: firebaseUser.user!.uid,
        file: profilePicture,
      );

      Users user = Users(
        uid: firebaseUser.user!.uid,
        name: name,
        email: email,
        profilePictureUrl: imageUrl,
      );

      await _userRepository.createUser(uid: firebaseUser.user!.uid, user: user);
    } on FirebaseAuthException catch (e) {
      errorMessage = _mapError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> deleteAcc() async {
    try {
      isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) return;

      await user.delete();
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      errorMessage = e.code == 'requires-recent-login'
          ? 'You need to log in again to delete your account'
          : _mapError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final user = _auth.currentUser;

      if (user == null || user.email == null) {
        errorMessage = 'User not authenticated';
        return;
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'Current password is incorrect';
          break;
        case 'requires-recent-login':
          errorMessage = 'Please log in again';
          break;
        default:
          errorMessage = 'Something went wrong';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'User not found';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'invalid-email':
        return 'Invalid email';
      default:
        return 'Authentication error';
    }
  }
}
