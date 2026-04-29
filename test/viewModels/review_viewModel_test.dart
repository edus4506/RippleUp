import 'package:flutter_test/flutter_test.dart';
import 'package:t5/data/models/review.dart';
import 'package:t5/data/repositories/review_repository.dart';
import 'package:t5/viewModels/review_viewModel.dart';

class FakeReviewRepository extends ReviewRepository {
  String? receivedEventId;
  Stream<List<Review>> reviewsStream = const Stream.empty();

  @override
  Future<void> createReview(String eventId, Review review) async {}

  @override
  Stream<List<Review>> getEventReviews(String eventId) {
    receivedEventId = eventId;
    return reviewsStream;
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
  });
}
