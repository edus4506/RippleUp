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
}
