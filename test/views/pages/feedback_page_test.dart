import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:t5/data/models/review.dart';
import 'package:t5/data/models/user.dart';
import 'package:t5/data/repositories/participation_repository.dart';
import 'package:t5/viewModels/review_viewModel.dart';
import 'package:t5/viewModels/user_view_model.dart';
import 'package:t5/views/pages/feedback_page.dart';
import 'package:t5/data/models/review_history_item.dart';

class FakeReviewViewModel extends ChangeNotifier implements ReviewViewModel {
  Stream<List<Review>> reviewsStream = const Stream.empty();
  bool reviewed = false;
  bool deleteResult = true;
  String? deletedEventId;
  Review? deletedReview;
  String? deletedCurrentUserId;

  @override
  Stream<List<Review>> getReviews(String eventId) {
    return reviewsStream;
  }

  @override
  Stream<List<ReviewHistoryItem>> getUserReviewsHistory(String userId) {
    return Stream.value([]);
  }

  @override
  Future<void> addReview(String eventId, int rating, String comment) async {}

  @override
  Future<bool> hasUserReviewed(String eventId, String userId) async {
    return reviewed;
  }

  @override
  Future<bool> deleteReview(
    String eventId,
    Review review,
    String currentUserId,
  ) async {
    deletedEventId = eventId;
    deletedReview = review;
    deletedCurrentUserId = currentUserId;

    return deleteResult;
  }
}

class FakeParticipationRepository extends ParticipationRepository {
  bool participated = true;

  @override
  Future<bool> hasUserParticipated(String userId, String eventId) async {
    return participated;
  }
}

class FakeUserViewModel extends ChangeNotifier implements UserViewModel {
  @override
  Stream<Users?> userStream(String userId) {
    return Stream.value(
      Users(name: 'Test User', email: 'test@test.com', profilePictureUrl: ''),
    );
  }
}

Future<void> pumpFeedbackPage(
  WidgetTester tester,
  FakeReviewViewModel vm, {
  bool participated = true,
  DateTime? endDate,
  String currentUserId = 'u1',
}) async {
  final participationRepository = FakeParticipationRepository()
    ..participated = participated;

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ReviewViewModel>.value(value: vm),
        Provider<ParticipationRepository>.value(value: participationRepository),
        ChangeNotifierProvider<UserViewModel>.value(value: FakeUserViewModel()),
      ],
      child: MaterialApp(
        home: FeedbackPage(
          eventId: 'event1',
          title: 'Beach Cleanup',
          endDate: endDate ?? DateTime.now().subtract(const Duration(days: 1)),
          currentUserId: currentUserId,
        ),
      ),
    ),
  );

  await tester.pump();
}

void main() {
  testWidgets('Shows no reviews message when no reviews exist', (tester) async {
    final vm = FakeReviewViewModel();
    vm.reviewsStream = Stream<List<Review>>.value([]).asBroadcastStream();

    await pumpFeedbackPage(tester, vm);

    expect(find.text('No reviews yet'), findsOneWidget);
  });

  testWidgets('Shows average rating when reviews exist', (tester) async {
    final vm = FakeReviewViewModel();
    vm.reviewsStream = Stream<List<Review>>.value([
      Review(
        id: 'review1',
        userId: 'u1',
        rating: 5,
        comment: 'Great event',
        createdAt: DateTime(2025, 1, 1),
      ),
      Review(
        id: 'review2',
        userId: 'u2',
        rating: 3,
        comment: 'Good event',
        createdAt: DateTime(2025, 1, 2),
      ),
    ]).asBroadcastStream();

    await pumpFeedbackPage(tester, vm);

    expect(find.text('Average Rating'), findsOneWidget);
    expect(find.text('4.0 (2 reviews)'), findsOneWidget);
    expect(find.text('Great event'), findsOneWidget);
    expect(find.text('Good event'), findsOneWidget);
  });

  testWidgets('Shows review button when event ended and user participated', (
    tester,
  ) async {
    final vm = FakeReviewViewModel();
    vm.reviewsStream = Stream<List<Review>>.value([]).asBroadcastStream();

    await pumpFeedbackPage(tester, vm, participated: true);

    expect(find.byIcon(Icons.rate_review), findsOneWidget);
  });

  testWidgets('Hides review button when event has not ended', (tester) async {
    final vm = FakeReviewViewModel();
    vm.reviewsStream = Stream<List<Review>>.value([]).asBroadcastStream();

    await pumpFeedbackPage(
      tester,
      vm,
      participated: true,
      endDate: DateTime.now().add(const Duration(days: 1)),
    );

    expect(find.byIcon(Icons.rate_review), findsNothing);
  });

  testWidgets('Hides review button when user did not participate', (
    tester,
  ) async {
    final vm = FakeReviewViewModel();
    vm.reviewsStream = Stream<List<Review>>.value([]).asBroadcastStream();

    await pumpFeedbackPage(tester, vm, participated: false);

    expect(find.byIcon(Icons.rate_review), findsNothing);
  });

  testWidgets('Shows already reviewed button when user already reviewed', (
    tester,
  ) async {
    final vm = FakeReviewViewModel();
    vm.reviewed = true;
    vm.reviewsStream = Stream<List<Review>>.value([]).asBroadcastStream();

    await pumpFeedbackPage(tester, vm, participated: true);

    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byIcon(Icons.rate_review), findsNothing);
  });

  testWidgets('Deletes own review after confirmation', (tester) async {
    final vm = FakeReviewViewModel();
    final review = Review(
      id: 'review1',
      userId: 'u1',
      rating: 5,
      comment: 'Great event',
      createdAt: DateTime(2025, 1, 1),
    );

    vm.reviewed = true;
    vm.reviewsStream = Stream<List<Review>>.value([review]).asBroadcastStream();

    await pumpFeedbackPage(tester, vm, participated: true);

    expect(find.byIcon(Icons.delete_outline), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Delete review?'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(vm.deletedEventId, 'event1');
    expect(vm.deletedReview, review);
    expect(vm.deletedCurrentUserId, 'u1');
    expect(find.text('Review deleted'), findsOneWidget);
  });
}
