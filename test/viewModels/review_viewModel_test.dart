import 'package:flutter_test/flutter_test.dart';
import 'package:t5/data/models/review.dart';
import 'package:t5/data/repositories/review_repository.dart';
import 'package:t5/viewModels/review_viewModel.dart';

class FakeReviewRepository extends ReviewRepository {
  String? receivedEventId;
  String? deletedEventId;
  String? deletedReviewId;
  bool reviewed = false;
  Stream<List<Review>> reviewsStream = const Stream.empty();

  @override
  Future<void> createReview(String eventId, Review review) async {}

  @override
  Stream<List<Review>> getEventReviews(String eventId) {
    receivedEventId = eventId;
    return reviewsStream;
  }

  @override
  Future<bool> hasUserReviewed(String eventId, String userId) async {
    return reviewed;
  }

  @override
  Future<void> deleteReview(String eventId, String reviewId) async {
    deletedEventId = eventId;
    deletedReviewId = reviewId;
  }
}

void main() {
  late FakeReviewRepository fakeRepository;
  late ReviewViewModel viewModel;

  setUp(() {
    fakeRepository = FakeReviewRepository();
    viewModel = ReviewViewModel(fakeRepository);
  });

  group('ReviewViewModel', () {
    test('getReviews returns repository stream for event', () {
      final reviews = [
        Review(
          id: '1',
          userId: 'u1',
          rating: 5,
          comment: 'Great',
          createdAt: DateTime(2025, 1, 1),
        ),
      ];

      fakeRepository.reviewsStream = Stream.value(reviews);

      final stream = viewModel.getReviews('event1');

      expect(fakeRepository.receivedEventId, 'event1');
      expect(stream, emits(reviews));
    });

    test('hasUserReviewed returns repository result', () async {
      fakeRepository.reviewed = true;

      final result = await viewModel.hasUserReviewed('event1', 'u1');

      expect(result, true);
    });

    test(
      'deleteReview deletes review when it belongs to current user',
      () async {
        final review = Review(
          id: 'review1',
          userId: 'u1',
          rating: 5,
          comment: 'Great',
          createdAt: DateTime(2025, 1, 1),
        );

        final result = await viewModel.deleteReview('event1', review, 'u1');

        expect(result, true);
        expect(fakeRepository.deletedEventId, 'event1');
        expect(fakeRepository.deletedReviewId, 'review1');
      },
    );

    test('deleteReview does not delete review from another user', () async {
      final review = Review(
        id: 'review1',
        userId: 'u1',
        rating: 5,
        comment: 'Great',
        createdAt: DateTime(2025, 1, 1),
      );

      final result = await viewModel.deleteReview('event1', review, 'u2');

      expect(result, false);
      expect(fakeRepository.deletedEventId, isNull);
      expect(fakeRepository.deletedReviewId, isNull);
    });
  });
}
