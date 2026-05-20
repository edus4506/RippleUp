import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Search users text appears', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Search users'))),
    );

    expect(find.text('Search users'), findsOneWidget);
  });

  testWidgets('Person icon appears', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Icon(Icons.person))),
    );

    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets('Arrow icon appears', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Icon(Icons.arrow_forward_ios))),
    );

    expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
  });
}
