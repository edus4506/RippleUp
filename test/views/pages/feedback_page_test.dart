import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:t5/views/pages/feedback_page.dart';
import 'package:t5/viewModels/review_viewModel.dart';
import 'package:t5/data/models/review.dart';

class FakeReviewViewModel extends ChangeNotifier implements ReviewViewModel {
  Stream<List<Review>> reviewsStream = const Stream.empty();

  @override
  Stream<List<Review>> getReviews(String eventId) {
    return reviewsStream;
  }

  @override
  Future<void> addReview(String eventId, int rating, String comment) async {}
}

Widget createWidget(FakeReviewViewModel vm) {
  return ChangeNotifierProvider<ReviewViewModel>(
    create: (_) => vm,
    child: const MaterialApp(
      home: FeedbackPage(eventId: 'event1', title: 'Test Event'),
    ),
  );
}

void main() {
  testWidgets('shows empty state when no reviews', (tester) async {
    final vm = FakeReviewViewModel();
    vm.reviewsStream = Stream<List<Review>>.value([]).asBroadcastStream();

    await tester.pumpWidget(createWidget(vm));
    await tester.pump();

    expect(find.text('No reviews yet'), findsWidgets);
  });
}
