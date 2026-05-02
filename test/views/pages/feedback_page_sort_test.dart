import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:t5/data/models/review.dart';
import 'package:t5/data/models/user.dart';
import 'package:t5/data/repositories/participation_repository.dart';
import 'package:t5/viewModels/review_viewModel.dart';
import 'package:t5/viewModels/user_view_model.dart';
import 'package:t5/views/pages/feedback_page.dart';

class FakeReviewViewModel extends ChangeNotifier implements ReviewViewModel {
  Stream<List<Review>> reviewsStream = const Stream.empty();
  bool reviewed = false;
  bool deleteResult = true;
  String? deletedEventId;
  Review? deletedReview;
  String? deletedCurrentUserId;

  @override
  Stream<List<Review>> getReviews(String eventId) => reviewsStream;

  @override
  Future<void> addReview(String eventId, int rating, String comment) async {}

  @override
  Future<bool> hasUserReviewed(String eventId, String userId) async => reviewed;

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
  Future<bool> hasUserParticipated(String userId, String eventId) async =>
      participated;
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

List<Review> _buildReviews() {
  return [
    Review(
      id: 'r1',
      userId: 'u1',
      rating: 2,
      comment: 'Low rating old',
      createdAt: DateTime(2025, 1, 1),
    ),
    Review(
      id: 'r2',
      userId: 'u2',
      rating: 5,
      comment: 'High rating recent',
      createdAt: DateTime(2025, 6, 1),
    ),
    Review(
      id: 'r3',
      userId: 'u3',
      rating: 3,
      comment: 'Mid rating mid',
      createdAt: DateTime(2025, 3, 1),
    ),
  ];
}

void main() {
  group('FeedbackPage sorting', () {
    testWidgets('Sort dropdown is visible when reviews exist', (tester) async {
      final vm = FakeReviewViewModel();
      vm.reviewsStream = Stream.value(_buildReviews()).asBroadcastStream();

      await pumpFeedbackPage(tester, vm);

      expect(find.text('Sort by: '), findsOneWidget);
      expect(find.text('Most Recent'), findsOneWidget);
    });

    testWidgets('Default sort is Most Recent (newest first)', (tester) async {
      final vm = FakeReviewViewModel();
      vm.reviewsStream = Stream.value(_buildReviews()).asBroadcastStream();

      await pumpFeedbackPage(tester, vm);

      final items = tester.widgetList<Text>(
        find.descendant(of: find.byType(ListView), matching: find.byType(Text)),
      );
      final texts = items.map((t) => t.data ?? '').toList();

      final highIdx = texts.indexOf('High rating recent');
      final midIdx = texts.indexOf('Mid rating mid');
      final lowIdx = texts.indexOf('Low rating old');

      expect(highIdx, lessThan(midIdx));
      expect(midIdx, lessThan(lowIdx));
    });

    testWidgets('Selecting Oldest sorts from oldest to newest', (tester) async {
      final vm = FakeReviewViewModel();
      vm.reviewsStream = Stream.value(_buildReviews()).asBroadcastStream();

      await pumpFeedbackPage(tester, vm);

      await tester.tap(find.text('Most Recent'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Oldest').last);
      await tester.pumpAndSettle();

      final items = tester.widgetList<Text>(
        find.descendant(of: find.byType(ListView), matching: find.byType(Text)),
      );
      final texts = items.map((t) => t.data ?? '').toList();

      final highIdx = texts.indexOf('High rating recent');
      final midIdx = texts.indexOf('Mid rating mid');
      final lowIdx = texts.indexOf('Low rating old');

      expect(lowIdx, lessThan(midIdx));
      expect(midIdx, lessThan(highIdx));
    });

    testWidgets('Selecting Highest Rating sorts from highest to lowest', (
      tester,
    ) async {
      final vm = FakeReviewViewModel();
      vm.reviewsStream = Stream.value(_buildReviews()).asBroadcastStream();

      await pumpFeedbackPage(tester, vm);

      await tester.tap(find.text('Most Recent'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Highest Rating').last);
      await tester.pumpAndSettle();

      final items = tester.widgetList<Text>(
        find.descendant(of: find.byType(ListView), matching: find.byType(Text)),
      );
      final texts = items.map((t) => t.data ?? '').toList();

      final highIdx = texts.indexOf('High rating recent'); // rating 5
      final midIdx = texts.indexOf('Mid rating mid'); // rating 3
      final lowIdx = texts.indexOf('Low rating old'); // rating 2

      expect(highIdx, lessThan(midIdx));
      expect(midIdx, lessThan(lowIdx));
    });

    testWidgets('Selecting Lowest Rating sorts from lowest to highest', (
      tester,
    ) async {
      final vm = FakeReviewViewModel();
      vm.reviewsStream = Stream.value(_buildReviews()).asBroadcastStream();

      await pumpFeedbackPage(tester, vm);

      await tester.tap(find.text('Most Recent'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lowest Rating').last);
      await tester.pumpAndSettle();

      final items = tester.widgetList<Text>(
        find.descendant(of: find.byType(ListView), matching: find.byType(Text)),
      );
      final texts = items.map((t) => t.data ?? '').toList();

      final highIdx = texts.indexOf('High rating recent'); // rating 5
      final midIdx = texts.indexOf('Mid rating mid'); // rating 3
      final lowIdx = texts.indexOf('Low rating old'); // rating 2

      expect(lowIdx, lessThan(midIdx));
      expect(midIdx, lessThan(highIdx));
    });

    testWidgets('Sorting updates immediately without page reload', (
      tester,
    ) async {
      final vm = FakeReviewViewModel();
      vm.reviewsStream = Stream.value(_buildReviews()).asBroadcastStream();

      await pumpFeedbackPage(tester, vm);

      // Starts as Most Recent
      expect(find.text('Most Recent'), findsOneWidget);

      // Switch to Oldest
      await tester.tap(find.text('Most Recent'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Oldest').last);
      await tester.pumpAndSettle();

      // Dropdown now shows Oldest
      expect(find.text('Oldest'), findsOneWidget);

      // Switch to Highest Rating
      await tester.tap(find.text('Oldest'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Highest Rating').last);
      await tester.pumpAndSettle();

      expect(find.text('Highest Rating'), findsOneWidget);
    });

    testWidgets('Sort dropdown is NOT visible when there are no reviews', (
      tester,
    ) async {
      final vm = FakeReviewViewModel();
      vm.reviewsStream = Stream<List<Review>>.value([]).asBroadcastStream();

      await pumpFeedbackPage(tester, vm);

      expect(find.text('Sort by: '), findsNothing);
      expect(find.text('No reviews yet'), findsOneWidget);
    });
  });
}
