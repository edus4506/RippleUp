import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/review.dart';
import '../data/repositories/review_repository.dart';

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
}
