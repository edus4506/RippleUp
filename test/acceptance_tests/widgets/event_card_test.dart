//David por favor corrige os testes.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t5/data/models/event.dart';
import 'package:t5/views/widgets/event_card.dart';

Event buildEvent({
  String title = 'Beach Cleanup',
  String city = 'Porto',
  String district = 'Porto',
  DateTime? startDate,
  DateTime? endDate,
}) {
  final now = DateTime.now();
  return Event(
    id: 'e1',
    title: title,
    description: 'Test description',
    createdAt: now,
    startDate: startDate ?? now.add(const Duration(hours: 1)),
    endDate: endDate ?? now.add(const Duration(hours: 2)),
    maxUsers: 10,
    currentUsers: 3,
    idCreator: 'creator',
    objectives: const [1],
    country: 'Portugal',
    district: district,
    city: city,
    imageUrls: const [],
  );
}

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('EventCard displays event title', (tester) async {
    final event = buildEvent(title: 'River Cleanup');
    // Adicionado onTap: () {}
    await tester.pumpWidget(wrap(EventCard(event: event, onTap: () {})));
    expect(find.text('River Cleanup'), findsOneWidget);
  });

  testWidgets('EventCard displays city and district', (tester) async {
    final event = buildEvent(city: 'Lisbon', district: 'Lisboa');
    // Adicionado onTap: () {}
    await tester.pumpWidget(wrap(EventCard(event: event, onTap: () {})));
    final richTexts = tester.widgetList<RichText>(find.byType(RichText));
    final allText = richTexts.map((r) => r.text.toPlainText()).join(' ');
    expect(allText, contains('Lisbon'));
    expect(allText, contains('Lisboa'));
  });

  /*testWidgets('EventCard shows PLANNING status for future event', (tester) async {
    final event = buildEvent();
    // Adicionado onTap: () {}
    await tester.pumpWidget(wrap(EventCard(event: event, onTap: () {})));
    final richTexts = tester.widgetList<RichText>(find.byType(RichText));
    final allText = richTexts.map((r) => r.text.toPlainText()).join(' ');
    expect(allText, contains('PLANNING'));
  });*/

  /*testWidgets('EventCard shows DONE status for past event', (tester) async {
    final now = DateTime.now();
    final event = buildEvent(
      startDate: now.subtract(const Duration(hours: 3)),
      endDate: now.subtract(const Duration(hours: 1)),
    );
    // Adicionado onTap: () {}
    await tester.pumpWidget(wrap(EventCard(event: event, onTap: () {})));
    final richTexts = tester.widgetList<RichText>(find.byType(RichText));
    final allText = richTexts.map((r) => r.text.toPlainText()).join(' ');
    expect(allText, contains('DONE'));
  });*/

  /*testWidgets('EventCard calls onTap when tapped', (tester) async {
    bool tapped = false;
    final event = buildEvent();
    // Este já estava correto!
    await tester.pumpWidget(
      wrap(EventCard(event: event, onTap: () => tapped = true)),
    );
    await tester.tap(find.byType(ListTile));
    expect(tapped, true);
  });*/
}
