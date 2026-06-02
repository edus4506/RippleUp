import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:t5/main.dart' as app;

/// Pumps fixed-duration frames so the UI is visibly rendered on the device
/// without relying on pumpAndSettle (which can hang on Firestore streams).
Future<void> _wait(WidgetTester tester, [int seconds = 2]) async {
  for (var i = 0; i < seconds * 2; i++) {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

Future<void> _loginIfNeeded(WidgetTester tester) async {
  if (find.text('Sign in').evaluate().isNotEmpty) {
    await tester.enterText(find.byType(TextField).at(0), 'edu@gmail.com');
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await _wait(tester, 1);
    await tester.tap(find.text('Sign in'));
    await _wait(tester, 6);
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Search users flow - full demo', (tester) async {
    // 1. Boot the app.
    app.main();
    await _wait(tester, 4);

    // 2. Log in.
    await _loginIfNeeded(tester);

    expect(find.byType(MaterialApp), findsOneWidget);

    // 3. Go to the Discover tab.
    final discoverTab = find.text('Discover');
    expect(discoverTab, findsWidgets);
    await tester.tap(discoverTab.first);
    await _wait(tester, 3);

    // 4. Open the "Search Users" page.
    final searchUsersCard = find.text('Search Users');
    expect(searchUsersCard, findsWidgets);
    await tester.tap(searchUsersCard.first);
    await _wait(tester, 3);

    // 5. Type into the search field — results filter live.
    final searchField = find.byType(TextField);
    expect(searchField, findsWidgets);
    await tester.enterText(searchField.first, 'a');
    await _wait(tester, 3);

    // 6. Either a list of matching users or the empty state is shown.
    final hasResults = find.byType(ListView).evaluate().isNotEmpty;
    final isEmpty = find.text('No users found.').evaluate().isNotEmpty;
    expect(hasResults || isEmpty, isTrue);

    // 7. Open the first matching user's profile. Each user card carries a
    // trailing chevron icon; tapping it triggers the card's navigation.
    final userChevron = find.byIcon(Icons.chevron_right_rounded);
    if (userChevron.evaluate().isNotEmpty) {
      await tester.tap(userChevron.first);
      await _wait(tester, 3);
      expect(find.byType(Scaffold), findsWidgets);
    }
  });
}
