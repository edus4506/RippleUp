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

  testWidgets('Followers/Following flow - full demo', (tester) async {
    // 1. Boot the app.
    app.main();
    await _wait(tester, 4);

    // 2. Log in.
    await _loginIfNeeded(tester);

    // App is alive.
    expect(find.byType(MaterialApp), findsOneWidget);

    // 3. Navigate to the Profile tab.
    final profileTab = find.text('Profile');
    expect(profileTab, findsWidgets);
    await tester.tap(profileTab.first);
    await _wait(tester, 3);

    // 4. Open the connections page via the Followers count.
    final followersFinder = find.textContaining('Followers');
    if (followersFinder.evaluate().isNotEmpty) {
      await tester.tap(followersFinder.first);
      await _wait(tester, 3);

      // The connections page is titled "Friends".
      expect(find.text('Friends'), findsOneWidget);
      expect(find.textContaining('Followers'), findsWidgets);
      expect(find.textContaining('Following'), findsWidgets);

      // 5. If there is a user in the list, open their profile.
      final listTileFinder = find.byType(ListTile);
      if (listTileFinder.evaluate().isNotEmpty) {
        await tester.tap(listTileFinder.first);
        await _wait(tester, 3);
        expect(find.byType(Scaffold), findsWidgets);
      }
    }
  });
}
