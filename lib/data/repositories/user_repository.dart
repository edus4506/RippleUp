import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Users?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();

    if (doc.exists) {
      return Users.fromMap(doc.data()!);
    }

    return null;
  }

  Future<void> updateProfilePicture({
    required String uid,
    required String imageUrl,
  }) async {
    await _db.collection('users').doc(uid).update({
      'profilePictureUrl': imageUrl,
    });
  }

  Future<void> createUser({
    required String uid,
    required Users user,
  }) async {
    await _db.collection('users').doc(uid).set(user.toMap());
  }


  Future<void> softDeleteUser({
    required String uid,
    required Users user,
  }) async {

  }


  Future<void> updateUser({
    required String uid,
    required Users updatedUser,
  }) async {
    await _db.collection('users').doc(uid).update(updatedUser.toMap());

  }
}