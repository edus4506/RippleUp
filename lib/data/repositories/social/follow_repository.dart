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

  Future<List<String>> getFollowerIds(String userId) async {
    final snapshot = await _db
        .collection('follows')
        .where('followedId', isEqualTo: userId)
        .get();
    return snapshot.docs
        .map((doc) => doc.data()['followerId'] as String)
        .toList();
  }

  Future<List<String>> getFollowingIds(String userId) async {
    final snapshot = await _db
        .collection('follows')
        .where('followerId', isEqualTo: userId)
        .get();
    return snapshot.docs
        .map((doc) => doc.data()['followedId'] as String)
        .toList();
  }

  Stream<int> followersCountStream(String userId) {
    return _db
        .collection('follows')
        .where('followedId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Stream<int> followingCountStream(String userId) {
    return _db
        .collection('follows')
        .where('followerId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.length);
  }
}
