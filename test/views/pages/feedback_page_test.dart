import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';

import 'package:t5/views/pages/feedback_page.dart';
import 'package:t5/viewModels/review_viewModel.dart';
import 'package:t5/viewModels/user_view_model.dart';
import 'package:t5/data/models/review.dart';
import 'package:t5/data/repositories/participation_repository.dart';
import 'package:t5/data/models/participation.dart';
import 'package:t5/data/repositories/user_repository.dart';

class MockUserRepository extends Mock implements UserRepository {}

class FakeReviewViewModel extends ChangeNotifier implements ReviewViewModel {
  Stream<List<Review>> reviewsStream = const Stream.empty();
  bool userHasReviewed = false;

  @override
  Stream<List<Review>> getReviews(String eventId) {
    return reviewsStream;
  }

  @override
  Future<void> addReview(String eventId, int rating, String comment) async {}

  @override
  Future<bool> hasUserReviewed(String eventId, String userId) async {
    return userHasReviewed;
  }
}

class FakeParticipationRepository implements ParticipationRepository {
  final bool participated;
  FakeParticipationRepository({this.participated = false});

  @override
  Stream<List<Participation>> listenToUserParticipations(String userId) =>
      Stream.value([]);

  @override
  Future<bool> hasUserParticipated(String userId, String eventId) async =>
      participated;
}

Widget createWidget(
  FakeReviewViewModel vm, {
  DateTime? endDate,
  bool participated = false,
}) {
  final userRepo = MockUserRepository();
  when(
    () => userRepo.listenToUser(any()),
  ).thenAnswer((_) => const Stream.empty());

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ReviewViewModel>.value(value: vm),
      Provider<ParticipationRepository>.value(
        value: FakeParticipationRepository(participated: participated),
      ),
      ChangeNotifierProvider(create: (_) => UserViewModel(userRepo)),
    ],
    child: MaterialApp(
      home: FeedbackPage(
        eventId: 'event1',
        title: 'Test Event',
        endDate: endDate ?? DateTime.now().subtract(const Duration(days: 1)),
        currentUserId: 'user-1',
      ),
    ),
  );
}

void main() {
  testWidgets('Shows nothing when no reviews exist', (tester) async {
    final vm = FakeReviewViewModel();
    vm.reviewsStream = Stream<List<Review>>.value([]).asBroadcastStream();

    await tester.pumpWidget(createWidget(vm));
    await tester.pumpAndSettle();

    expect(find.text('No reviews yet'), findsOneWidget);
  });

  testWidgets('Shows average rating when reviews exist', (tester) async {
    final vm = FakeReviewViewModel();
    vm.reviewsStream = Stream<List<Review>>.value([
      Review(
        id: 'r1',
        userId: 'user-2',
        rating: 4,
        comment: 'Great event!',
        createdAt: DateTime.now(),
      ),
    ]).asBroadcastStream();

    await tester.pumpWidget(createWidget(vm));
    await tester.pumpAndSettle();

    expect(find.text('Average Rating'), findsOneWidget);
    expect(find.text('Great event!'), findsOneWidget);
  });

  testWidgets('Shows reviews when event ended and user participated', (
    tester,
  ) async {
    final vm = FakeReviewViewModel();
    vm.reviewsStream = Stream<List<Review>>.value([]).asBroadcastStream();

    await tester.pumpWidget(
      createWidget(
        vm,
        endDate: DateTime.now().subtract(const Duration(days: 1)),
        participated: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.rate_review), findsOneWidget);
  });

  testWidgets('Hides reviews when event has not ended', (tester) async {
    final vm = FakeReviewViewModel();
    vm.reviewsStream = Stream<List<Review>>.value([]).asBroadcastStream();

    await tester.pumpWidget(
      createWidget(
        vm,
        endDate: DateTime.now().add(const Duration(days: 1)),
        participated: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.rate_review), findsNothing);
  });

  testWidgets('Hides reviews when user did not participate', (tester) async {
    final vm = FakeReviewViewModel();
    vm.reviewsStream = Stream<List<Review>>.value([]).asBroadcastStream();

    await tester.pumpWidget(
      createWidget(
        vm,
        endDate: DateTime.now().subtract(const Duration(days: 1)),
        participated: false,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.rate_review), findsNothing);
  });
}
