import '../models/user.dart';

class UserRepository {
  Future<User?> getUserByEmailPassword(String email, String password) async {
    // simular delay (tipo API)
    await Future.delayed(const Duration(seconds: 1));

    if (email == 'test@test.com' && password == '1234') {
      return User(
        id: '1',
        email: email,
      );
    }

    return null;
  }
}