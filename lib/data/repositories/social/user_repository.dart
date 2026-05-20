import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/social/user.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Users?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();

    final data = doc.data();

    if (doc.exists && data != null) {
      return Users.fromMap(data, doc.id);
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

  Future<Map<String, Users>> getUsersByIds(List<String> ids) async {
    if (ids.isEmpty) return {};
    final result = <String, Users>{};
    for (int i = 0; i < ids.length; i += 10) {
      final batch = ids.sublist(i, (i + 10).clamp(0, ids.length));
      final snapshot = await _db
          .collection('users')
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      for (final doc in snapshot.docs) {
        result[doc.id] = Users.fromMap(doc.data(), doc.id);
      }
    }
    return result;
  }
}
