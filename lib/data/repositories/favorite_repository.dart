import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/favorite_userEvent.dart';

class FavoriteRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addFavorite({
    required String userId,
    required String eventId,
  }) async {
    await _db.collection('favorites').doc('${eventId}_$userId').set({
      'idUser': userId,
      'idEvent': eventId,
    });
  }

  Future<void> removeFavorite({
    required String userId,
    required String eventId,
  }) async {
    await _db.collection('favorites').doc('${eventId}_$userId').delete();
  }

  Stream<bool> isEventFavorited({
    required String userId,
    required String eventId,
  }) {
    return _db
        .collection('favorites')
        .doc('${eventId}_$userId')
        .snapshots()
        .map((doc) => doc.exists);
  }

  Stream<List<Favorite>> listenToUserFavorites(String userId) {
    return _db
        .collection('favorites')
        .where('idUser', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Favorite.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
