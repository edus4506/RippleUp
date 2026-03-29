import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t5/views/pages/home_page.dart';

void main() {
  testWidgets('Tapping an event shows details dialog', (WidgetTester tester) async {

    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();

    final firstEventTile = find.byKey(const Key('event_1'));
    expect(firstEventTile, findsOneWidget);
    await tester.tap(firstEventTile);
    await tester.pumpAndSettle();

    final dialogFinder = find.byType(AlertDialog);
    expect(dialogFinder, findsOneWidget);

    expect(find.descendant(of: dialogFinder, matching: find.text('Beach Cleanup')), findsOneWidget);
    expect(find.descendant(of: dialogFinder, matching: find.text('Cleaning trash from the beach')), findsOneWidget);
    expect(find.descendant(of: dialogFinder, matching: find.textContaining('Objectives: 14')), findsOneWidget);
    expect(find.descendant(of: dialogFinder, matching: find.textContaining('Country: Portugal')), findsOneWidget);
    expect(find.descendant(of: dialogFinder, matching: find.textContaining('District: Porto')), findsOneWidget);
    expect(find.descendant(of: dialogFinder, matching: find.textContaining('City: Matosinhos')), findsOneWidget);
    expect(find.descendant(of: dialogFinder, matching: find.textContaining('Max Users: 100')), findsOneWidget);

    await tester.tap(find.descendant(of: dialogFinder, matching: find.text('Close')));
    await tester.pumpAndSettle();

    expect(dialogFinder, findsNothing);
  });
}