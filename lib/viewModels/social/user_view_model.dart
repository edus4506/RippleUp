import 'package:flutter/material.dart';
import 'package:t5/data/models/social/user.dart';
import 'package:t5/data/repositories/social/user_repository.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  UserViewModel(this._userRepository);

  Stream<Users?> userStream(String uid) {
    return _userRepository.listenToUser(uid);
  }
}
