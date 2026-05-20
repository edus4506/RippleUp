import 'package:flutter_test/flutter_test.dart';
import 'package:t5/data/models/reviews/review.dart';
import 'package:t5/services/sort/sort_review_service.dart';
import 'package:t5/data/models/reviews/sort_review.dart';

void main() {
  final reviews = [
    Review(
      id: '1',
      userId: 'u1',
      rating: 2,
      comment: 'Bad',
      createdAt: DateTime(2025, 1, 1),
    ),
    Review(
      id: '2',
      userId: 'u2',
      rating: 5,
      comment: 'Great',
      createdAt: DateTime(2025, 3, 1),
    ),
    Review(
      id: '3',
      userId: 'u3',
      rating: 3,
      comment: 'Ok',
      createdAt: DateTime(2025, 2, 1),
    ),
  ];

  group('SortReviewService', () {
    test('mostRecent returns reviews ordered by date descending', () {
      final result = SortReviewService.apply(
        reviews,
        ReviewSortOption.mostRecent,
      );

      expect(result[0].id, '2');
      expect(result[1].id, '3');
      expect(result[2].id, '1');
    });

    test('oldest returns reviews ordered by date ascending', () {
      final result = SortReviewService.apply(reviews, ReviewSortOption.oldest);

      expect(result[0].id, '1');
      expect(result[1].id, '3');
      expect(result[2].id, '2');
    });

    test('highestRating returns reviews ordered by rating descending', () {
      final result = SortReviewService.apply(
        reviews,
        ReviewSortOption.highestRating,
      );

      expect(result[0].rating, 5);
      expect(result[1].rating, 3);
      expect(result[2].rating, 2);
    });

    test('lowestRating returns reviews ordered by rating ascending', () {
      final result = SortReviewService.apply(
        reviews,
        ReviewSortOption.lowestRating,
      );

      expect(result[0].rating, 2);
      expect(result[1].rating, 3);
      expect(result[2].rating, 5);
    });

    test('returns empty list when given empty list', () {
      final result = SortReviewService.apply([], ReviewSortOption.mostRecent);

      expect(result, isEmpty);
    });

    test('does not mutate the original list', () {
      final original = List<Review>.from(reviews);
      SortReviewService.apply(reviews, ReviewSortOption.highestRating);

      expect(reviews[0].id, original[0].id);
      expect(reviews[1].id, original[1].id);
      expect(reviews[2].id, original[2].id);
    });
  });
}
