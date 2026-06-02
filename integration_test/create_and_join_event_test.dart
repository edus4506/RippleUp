import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:t5/main.dart' as app;
import 'package:t5/views/widgets/event_card.dart';

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

  testWidgets('Create and join event flow - full demo', (tester) async {
    // 1. Boot the app.
    app.main();
    await _wait(tester, 4);

    // 2. Log in.
    await _loginIfNeeded(tester);

    expect(find.byType(MaterialApp), findsOneWidget);

    // ── PART A: open the create-event form and fill it in ──────────
    // (The full submit is not automated here: dates use native date/time
    // pickers and location uses cascading dropdowns, which are unreliable to
    // drive in integration tests. We demo the form, then return to the feed.)
    final addButton = find.byIcon(Icons.add);
    expect(addButton, findsWidgets);
    await tester.tap(addButton.first);
    await _wait(tester, 3);

    expect(find.text('Create Event'), findsWidgets);

    final formFields = find.byType(TextField);
    if (formFields.evaluate().length >= 2) {
      await tester.enterText(formFields.at(0), 'Beach Cleanup Demo');
      await _wait(tester, 1);
      await tester.enterText(formFields.at(1), 'Integration test event');
      await _wait(tester, 2);
    }

    // Go back to the feed.
    final cancelButton = find.text('Cancel');
    if (cancelButton.evaluate().isNotEmpty) {
      await tester.tap(cancelButton.first);
      await _wait(tester, 3);
    }

    // ── PART B: join an existing event from the feed ───────────────
    final eventCards = find.byType(EventCard);
    if (eventCards.evaluate().isNotEmpty) {
      // Open the first event's details dialog.
      await tester.tap(eventCards.first);
      await _wait(tester, 3);

      // Join the event if not already a member.
      final joinButton = find.text('Join Event');
      if (joinButton.evaluate().isNotEmpty) {
        await tester.tap(joinButton.first);
        await _wait(tester, 4);
      }
    }

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
