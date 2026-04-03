import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t5/views/pages/home_page.dart';

void main() {
  group('Event Details Dialog Tests', () {
    testWidgets('Tapping first event shows correct details', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      // Tap first event
      final firstEventTile = find.byKey(const Key('event_1'));
      expect(firstEventTile, findsOneWidget);
      await tester.tap(firstEventTile);
      await tester.pumpAndSettle();

      // Find dialog
      final dialogFinder = find.byType(AlertDialog);
      expect(dialogFinder, findsOneWidget);

      // Verify dialog contents
      expect(find.descendant(of: dialogFinder, matching: find.text('Beach Cleanup')), findsOneWidget);
      expect(find.descendant(of: dialogFinder, matching: find.text('Cleaning trash from the beach')), findsOneWidget);
      expect(find.descendant(of: dialogFinder, matching: find.textContaining('Objectives: 14')), findsOneWidget);
      expect(find.descendant(of: dialogFinder, matching: find.textContaining('Country: Portugal')), findsOneWidget);
      expect(find.descendant(of: dialogFinder, matching: find.textContaining('District: Porto')), findsOneWidget);
      expect(find.descendant(of: dialogFinder, matching: find.textContaining('City: Matosinhos')), findsOneWidget);
      expect(find.descendant(of: dialogFinder, matching: find.textContaining('Max Users: 100')), findsOneWidget);

      // Close dialog
      await tester.tap(find.descendant(of: dialogFinder, matching: find.text('Close')));
      await tester.pumpAndSettle();
      expect(dialogFinder, findsNothing);
    });

    testWidgets('Tapping second event shows correct details', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      final secondEventTile = find.byKey(const Key('event_2'));
      expect(secondEventTile, findsOneWidget);
      await tester.tap(secondEventTile);
      await tester.pumpAndSettle();

      final dialogFinder = find.byType(AlertDialog);
      expect(dialogFinder, findsOneWidget);

      expect(find.descendant(of: dialogFinder, matching: find.text('Tree Planting')), findsOneWidget);
      expect(find.descendant(of: dialogFinder, matching: find.text('Planting trees in the park')), findsOneWidget);
      expect(find.descendant(of: dialogFinder, matching: find.textContaining('Objectives: 13, 15')), findsOneWidget);
      expect(find.descendant(of: dialogFinder, matching: find.textContaining('Country: Portugal')), findsOneWidget);
      expect(find.descendant(of: dialogFinder, matching: find.textContaining('District: Porto')), findsOneWidget);
      expect(find.descendant(of: dialogFinder, matching: find.textContaining('City: Porto')), findsOneWidget);
      expect(find.descendant(of: dialogFinder, matching: find.textContaining('Max Users: 80')), findsOneWidget);

      await tester.tap(find.descendant(of: dialogFinder, matching: find.text('Close')));
      await tester.pumpAndSettle();
      expect(dialogFinder, findsNothing);
    });

    testWidgets('Tapping Spain event shows correct details', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      final eventTile = find.byKey(const Key('event_3'));
      expect(eventTile, findsOneWidget);
      await tester.tap(eventTile);
      await tester.pumpAndSettle();

      final dialogFinder = find.byType(AlertDialog);
      expect(dialogFinder, findsOneWidget);

      expect(find.descendant(of: dialogFinder, matching: find.text('Ocean Cleanup')), findsOneWidget);
      expect(find.descendant(of: dialogFinder, matching: find.textContaining('Objectives: 14')), findsOneWidget);
      expect(find.descendant(of: dialogFinder, matching: find.textContaining('Country: Spain')), findsOneWidget);
      expect(find.descendant(of: dialogFinder, matching: find.textContaining('District: Galicia')), findsOneWidget);
      expect(find.descendant(of: dialogFinder, matching: find.textContaining('City: Vigo')), findsOneWidget);

      await tester.tap(find.descendant(of: dialogFinder, matching: find.text('Close')));
      await tester.pumpAndSettle();
      expect(dialogFinder, findsNothing);
    });

    testWidgets('Dialog can be opened and closed without errors', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      final firstEventTile = find.byKey(const Key('event_1'));
      await tester.tap(firstEventTile);
      await tester.pumpAndSettle();

      final dialogFinder = find.byType(AlertDialog);
      expect(dialogFinder, findsOneWidget);

      await tester.tap(find.descendant(of: dialogFinder, matching: find.text('Close')));
      await tester.pumpAndSettle();
      expect(dialogFinder, findsNothing);
    });
  });
}