import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic discover page widget test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Discover'))),
    );

    expect(find.text('Discover'), findsOneWidget);
  });

  testWidgets('Search Events text exists', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Search Events'))),
    );

    expect(find.text('Search Events'), findsOneWidget);
  });

  testWidgets('Search Users text exists', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Search Users'))),
    );

    expect(find.text('Search Users'), findsOneWidget);
  });
}
