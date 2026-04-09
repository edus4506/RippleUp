import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/user.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  ProfileViewModel(this._userRepository);

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
}