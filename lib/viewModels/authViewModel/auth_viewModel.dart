import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:t5/data/models/user.dart';
import 'package:t5/data/repositories/user_repository.dart';
import 'package:t5/data/repositories/storage_repository.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'dart:io';


class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository; //to signUPusers
  final StorageRepository _storageRepository;

  User? currentUser;
  bool isLoading = false;
  String? errorMessage;

  AuthViewModel(this._userRepository, this._storageRepository) {
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

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

    } on FirebaseAuthException catch (e) {
      errorMessage = _mapError(e);
    } catch (e) {
      errorMessage = "Erro inesperado";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password, XFile profilePicture) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final firebaseUser = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final imageUrl = await _storageRepository.uploadProfileImage(userId: firebaseUser.user!.uid, file: profilePicture);
      Users user = Users(name: name, email: email, profilePictureUrl: imageUrl);
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

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Utilizador não encontrado';
      case 'wrong-password':
        return 'Password incorreta';
      case 'email-already-in-use':
        return 'Email já em uso';
      case 'invalid-email':
        return 'Email inválido';
      default:
        return 'Erro de autenticação';
    }
  }
}