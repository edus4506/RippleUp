import 'package:flutter/material.dart';
import '../../data/models/user.dart';
import '../data/repositories/user_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final UserRepository repository;

  AuthViewModel(this.repository);

  User? currentUser;
  bool isLoading = false;
  String? errorMessage;

  Future<void> login(String email, String password) async {
    //for testing: test@test.com; 1234
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final user = await repository.getUserByEmailPassword(email, password);

    if (user != null) {
      currentUser = user;
    } else {
      errorMessage = 'Credenciais inválidas';
      currentUser = null;
    }

    isLoading = false;
    notifyListeners();
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }
}