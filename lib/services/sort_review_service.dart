import 'package:t5/data/models/review.dart';
import 'sort_review.dart';

class SortReviewService {
  static List<Review> apply(List<Review> reviews, ReviewSortOption option) {
    final sorted = List<Review>.from(reviews);
    switch (option) {
      case ReviewSortOption.mostRecent:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ReviewSortOption.oldest:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case ReviewSortOption.highestRating:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case ReviewSortOption.lowestRating:
        sorted.sort((a, b) => a.rating.compareTo(b.rating));
        break;
    }
    return sorted;
  }
}
