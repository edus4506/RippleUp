import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/models/review.dart';
import '../data/models/review_history_item.dart';
import '../data/repositories/review_repository.dart';
import '../services/review_service.dart';

class ReviewViewModel extends ChangeNotifier {
  final ReviewRepository _repository;

  ReviewViewModel(this._repository);

  Future<void> addReview(String eventId, int rating, String comment) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final review = Review(
      id: '',
      userId: user.uid,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    await _repository.createReview(eventId, review);
  }

  Stream<List<Review>> getReviews(String eventId) {
    return _repository.getEventReviews(eventId);
  }

  Stream<List<ReviewHistoryItem>> getUserReviewsHistory(String userId) {
    return _repository.getUserReviewsHistory(userId);
  }

  Future<bool> hasUserReviewed(String eventId, String userId) {
    return _repository.hasUserReviewed(eventId, userId);
  }

  Future<bool> deleteReview(
    String eventId,
    Review review,
    String currentUserId,
  ) async {
    if (!ReviewService.canDeleteReview(review, currentUserId)) {
      return false;
    }

    await _repository.deleteReview(eventId, review.id);
    notifyListeners();

    return true;
  }
}
