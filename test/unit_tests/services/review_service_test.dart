import 'package:flutter_test/flutter_test.dart';
import 'package:t5/data/models/review.dart';
import 'package:t5/services/review_service.dart';

void main() {
  group('ReviewService', () {
    final reviews = [
      Review(
        id: '1',
        userId: 'u1',
        rating: 5,
        comment: 'Great',
        createdAt: DateTime.now(),
      ),
      Review(
        id: '2',
        userId: 'u2',
        rating: 3,
        comment: 'Ok',
        createdAt: DateTime.now(),
      ),
      Review(
        id: '3',
        userId: 'u3',
        rating: 4,
        comment: 'Good',
        createdAt: DateTime.now(),
      ),
    ];

    test('getAverageRating returns correct average', () {
      final average = ReviewService.getAverageRating(reviews);

      expect(average, (5 + 3 + 4) / 3);
    });

    test('getAverageRating returns 0 when list is empty', () {
      final average = ReviewService.getAverageRating([]);

      expect(average, 0);
    });

    test('getTotalReviews returns correct count', () {
      final total = ReviewService.getTotalReviews(reviews);

      expect(total, 3);
    });

    test('hasReviews returns true when list is not empty', () {
      final result = ReviewService.hasReviews(reviews);

      expect(result, true);
    });

    test('hasReviews returns false when list is empty', () {
      final result = ReviewService.hasReviews([]);

      expect(result, false);
    });

    test(
      'canDeleteReview returns true when review belongs to current user',
      () {
        final review = Review(
          id: '1',
          userId: 'u1',
          rating: 5,
          comment: 'Great',
          createdAt: DateTime.now(),
        );

        final result = ReviewService.canDeleteReview(review, 'u1');

        expect(result, true);
      },
    );

    test(
      'canDeleteReview returns false when review belongs to another user',
      () {
        final review = Review(
          id: '1',
          userId: 'u1',
          rating: 5,
          comment: 'Great',
          createdAt: DateTime.now(),
        );

        final result = ReviewService.canDeleteReview(review, 'u2');

        expect(result, false);
      },
    );

    test('canDeleteReview returns false when current user id is empty', () {
      final review = Review(
        id: '1',
        userId: 'u1',
        rating: 5,
        comment: 'Great',
        createdAt: DateTime.now(),
      );

      final result = ReviewService.canDeleteReview(review, '');

      expect(result, false);
    });
  });
}
