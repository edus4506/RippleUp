import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Users?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();

    if (doc.exists) {
      return Users.fromMap(doc.data()!, doc.id);
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

  Future<void> createUser({required String uid, required Users user}) async {
    await _db.collection('users').doc(uid).set(user.toMap());
  }

  Future<void> softDeleteUser({required String uid}) async {
    Users defaultUser = Users(
      uid: uid,
      name: "deletedUser",
      email: "deletedUser@gmail.com",
      profilePictureUrl: "",
    );
    await _db.collection('users').doc(uid).update(defaultUser.toMap());
  }

  Future<void> updateUser({
    required String uid,
    required Users updatedUser,
  }) async {
    await _db.collection('users').doc(uid).update(updatedUser.toMap());
  }

  Stream<Users?> listenToUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return Users.fromMap(doc.data()!, doc.id);
    });
  }

  Future<List<Users?>> getAllUsers() async {
    final snapshot = await _db.collection('users').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      if (data.isEmpty) return null;

      return Users.fromMap(data, doc.id);
    }).toList();
  }
}
