import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/events/event.dart';
import 'package:t5/viewModels/events/event_viewModel.dart';
import 'package:t5/viewModels/search/search_viewModel.dart';
import 'package:t5/views/pages/discover/search_events_page.dart';

class MockEventViewModel extends Mock implements EventViewModel {}

Event buildEvent({required String title, String city = 'Porto'}) {
  final now = DateTime.now();

  return Event(
    id: title,
    imageUrls: [],
    title: title,
    description: 'Environmental activity',
    createdAt: now,
    startDate: now.add(const Duration(days: 1)),
    endDate: now.add(const Duration(days: 2)),
    maxUsers: 10,
    currentUsers: 2,
    idCreator: 'creator',
    country: 'Portugal',
    district: 'Porto',
    city: city,
    objectives: const [1],
  );
}

Widget buildTestable({
  required EventViewModel eventVm,
  required SearchViewModel searchVm,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SearchViewModel>.value(value: searchVm),
      ChangeNotifierProvider<EventViewModel>.value(value: eventVm),
    ],
    child: const MaterialApp(home: SearchEventsPage()),
  );
}

void main() {
  late MockEventViewModel eventVm;
  late SearchViewModel searchVm;

  setUp(() {
    eventVm = MockEventViewModel();
    searchVm = SearchViewModel(eventVm);

    when(() => eventVm.addListener(any())).thenAnswer((_) {});
    when(() => eventVm.removeListener(any())).thenAnswer((_) {});
  });

  group('SearchEventsPage rendering', () {
    testWidgets('shows page title', (tester) async {
      when(() => eventVm.eventsStream).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(
        buildTestable(eventVm: eventVm, searchVm: searchVm),
      );

      await tester.pumpAndSettle();

      expect(find.text('Search Events'), findsOneWidget);
    });

    testWidgets('shows search field', (tester) async {
      when(() => eventVm.eventsStream).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(
        buildTestable(eventVm: eventVm, searchVm: searchVm),
      );

      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows no results message when stream is empty', (
      tester,
    ) async {
      when(() => eventVm.eventsStream).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(
        buildTestable(eventVm: eventVm, searchVm: searchVm),
      );

      await tester.pumpAndSettle();

      expect(find.text('No matching events found.'), findsOneWidget);
    });

    testWidgets('shows event title from stream', (tester) async {
      final events = [buildEvent(title: 'Beach Cleanup')];

      when(() => eventVm.eventsStream).thenAnswer((_) => Stream.value(events));

      await tester.pumpWidget(
        buildTestable(eventVm: eventVm, searchVm: searchVm),
      );

      await tester.pumpAndSettle();

      expect(find.text('Beach Cleanup'), findsOneWidget);
    });

    testWidgets('shows multiple events', (tester) async {
      final events = [
        buildEvent(title: 'Beach Cleanup'),
        buildEvent(title: 'Tree Planting'),
      ];

      when(() => eventVm.eventsStream).thenAnswer((_) => Stream.value(events));

      await tester.pumpWidget(
        buildTestable(eventVm: eventVm, searchVm: searchVm),
      );

      await tester.pumpAndSettle();

      expect(find.text('Beach Cleanup'), findsOneWidget);
      expect(find.text('Tree Planting'), findsOneWidget);
    });

    testWidgets('filters events when typing in search field', (tester) async {
      final events = [
        buildEvent(title: 'Beach Cleanup'),
        buildEvent(title: 'Tree Planting'),
      ];

      when(() => eventVm.eventsStream).thenAnswer((_) => Stream.value(events));

      await tester.pumpWidget(
        buildTestable(eventVm: eventVm, searchVm: searchVm),
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Beach');

      await tester.pumpAndSettle();

      expect(find.text('Beach Cleanup'), findsOneWidget);
      expect(find.text('Tree Planting'), findsNothing);
    });

    testWidgets('shows clear button when text is entered', (tester) async {
      when(() => eventVm.eventsStream).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(
        buildTestable(eventVm: eventVm, searchVm: searchVm),
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Beach');

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('shows search icon', (tester) async {
      when(() => eventVm.eventsStream).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(
        buildTestable(eventVm: eventVm, searchVm: searchVm),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      when(() => eventVm.eventsStream).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(
        buildTestable(eventVm: eventVm, searchVm: searchVm),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });
  });
}
