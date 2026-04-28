import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:t5/views/widgets/review_card.dart';
import 'package:t5/data/models/review.dart';
import 'package:t5/viewModels/user_view_model.dart';
import 'package:t5/data/models/user.dart';

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
      ChangeNotifierProvider<UserViewModel>(
        create: (_) => FakeUserViewModel(),
        child: MaterialApp(
          home: Scaffold(body: ReviewCard(review: review)),
        ),
      ),
    );

    await tester.pump(); // resolve StreamBuilder

    // name
    expect(find.text('Test User'), findsOneWidget);

    // comment
    expect(find.text('Nice event'), findsOneWidget);

    // stars
    final starIcons = find.byIcon(Icons.star);
    expect(starIcons, findsNWidgets(4));
  });
}
