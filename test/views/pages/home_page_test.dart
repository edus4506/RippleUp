import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/event.dart';
import 'package:t5/data/repositories/event_repository.dart';
import 'package:t5/viewModels/event_viewModel.dart';
import 'package:t5/views/pages/home_page.dart';

class FakeEventRepository implements EventRepository {
  @override
  Future<void> createEvent(Event event) async {}

  @override
  Future<void> deleteEvent(String eventId) async {}

  @override
  Future<void> joinEvent({
    required String eventId,
    required String userId,
  }) async {}

  @override
  Future<void> leaveEvent({
    required String eventId,
    required String userId,
  }) async {}

  @override
  Stream<bool> isUserInEvent({
    required String eventId,
    required String userId,
  }) {
    return Stream.value(false);
  }

  @override
  Stream<List<Event>> listenToEvents() {
    return const Stream.empty();
  }
}

void main() {
  Widget buildApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => EventViewModel(FakeEventRepository()),
        ),
      ],
      child: const MaterialApp(
        home: HomePage(),
      ),
    );
  }

  testWidgets('HomePage shows title', (tester) async {
    await tester.pumpWidget(buildApp());

    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('Filter button is visible on first tab', (tester) async {
    await tester.pumpWidget(buildApp());

    expect(find.byIcon(Icons.filter_list), findsOneWidget);
  });

  testWidgets('Bottom navigation exists', (tester) async {
    await tester.pumpWidget(buildApp());

    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}