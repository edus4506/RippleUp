import 'package:cloud_firestore/cloud_firestore.dart';

class FollowRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _docId(String followerId, String followedId) =>
      '${followerId}_$followedId';

  Future<void> follow({
    required String followerId,
    required String followedId,
  }) async {
    await _db.collection('follows').doc(_docId(followerId, followedId)).set({
      'followerId': followerId,
      'followedId': followedId,
    });
  }

  Future<void> unfollow({
    required String followerId,
    required String followedId,
  }) async {
    await _db
        .collection('follows')
        .doc(_docId(followerId, followedId))
        .delete();
  }

  Stream<bool> isFollowing({
    required String followerId,
    required String followedId,
  }) {
    return _db
        .collection('follows')
        .doc(_docId(followerId, followedId))
        .snapshots()
        .map((doc) => doc.exists);
  }
}
