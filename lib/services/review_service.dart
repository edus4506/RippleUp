import 'package:t5/data/models/review.dart';

class ReviewService {
  static double getAverageRating(List<Review> reviews) {
    if (reviews.isEmpty) return 0;

    final total = reviews
        .map((r) => r.rating)
        .reduce((a, b) => a + b);

    return total / reviews.length;
  }

  static int getTotalReviews(List<Review> reviews) {
    return reviews.length;
  }

  static bool hasReviews(List<Review> reviews) {
    return reviews.isNotEmpty;
  }
}