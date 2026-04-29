import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';

class ReviewRepository {
  Future<void> createReview(String eventId, Review review) async {
    await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('reviews')
        .add(review.toMap());
  }

  Stream<List<Review>> getEventReviews(String eventId) {
    return FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Review.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<bool> hasUserReviewed(String eventId, String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }
}
