import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/events/event.dart';
import '../../models/reviews/review.dart';
import '../../models/reviews/review_history_item.dart';

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

  Future<void> deleteReview(String eventId, String reviewId) async {
    await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('reviews')
        .doc(reviewId)
        .delete();
  }

  Stream<List<ReviewHistoryItem>> getUserReviewsHistory(String userId) {
    return FirebaseFirestore.instance.collection('events').snapshots().asyncMap(
      (eventSnapshot) async {
        final items = <ReviewHistoryItem>[];

        for (final eventDoc in eventSnapshot.docs) {
          final event = Event.fromMap(eventDoc.data(), eventDoc.id);

          final reviewsSnapshot = await eventDoc.reference
              .collection('reviews')
              .where('userId', isEqualTo: userId)
              .get();

          for (final reviewDoc in reviewsSnapshot.docs) {
            final review = Review.fromMap(reviewDoc.data(), reviewDoc.id);

            items.add(ReviewHistoryItem(review: review, event: event));
          }
        }

        items.sort((a, b) => b.review.createdAt.compareTo(a.review.createdAt));

        return items;
      },
    );
  }
}
