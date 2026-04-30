import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:t5/data/models/review.dart';
import 'package:t5/data/models/user.dart';
import 'package:t5/viewModels/user_view_model.dart';
import 'package:t5/views/widgets/review_card.dart';

class FakeUserViewModel extends ChangeNotifier implements UserViewModel {
  @override
  Stream<Users?> userStream(String userId) {
    return Stream.value(
      Users(name: 'Test User', email: 'test@test.com', profilePictureUrl: ''),
    );
  }
}

void main() {
  testWidgets('ReviewCard displays user, rating and comment', (tester) async {
    final review = Review(
      id: '1',
      userId: 'u1',
      rating: 4,
      comment: 'Nice event',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<UserViewModel>.value(
        value: FakeUserViewModel(),
        child: MaterialApp(
          home: Scaffold(
            body: ReviewCard(
              review: review,
              currentUserId: 'u1',
              onDelete: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('Nice event'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsNWidgets(4));
    expect(find.byIcon(Icons.star_border), findsOneWidget);
  });

  testWidgets('ReviewCard shows delete button for review owner', (
    tester,
  ) async {
    var deleted = false;

    final review = Review(
      id: '1',
      userId: 'u1',
      rating: 4,
      comment: 'Nice event',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<UserViewModel>.value(
        value: FakeUserViewModel(),
        child: MaterialApp(
          home: Scaffold(
            body: ReviewCard(
              review: review,
              currentUserId: 'u1',
              onDelete: () {
                deleted = true;
              },
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.byIcon(Icons.delete_outline), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();

    expect(deleted, true);
  });

  testWidgets('ReviewCard hides delete button for another user', (
    tester,
  ) async {
    final review = Review(
      id: '1',
      userId: 'u1',
      rating: 4,
      comment: 'Nice event',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<UserViewModel>.value(
        value: FakeUserViewModel(),
        child: MaterialApp(
          home: Scaffold(
            body: ReviewCard(
              review: review,
              currentUserId: 'u2',
              onDelete: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });
}
