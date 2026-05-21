import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/events/event.dart';
import 'package:t5/data/repositories/events/event_repository.dart';
import 'package:t5/services/storage/storage_service.dart';
import 'package:t5/viewModels/events/event_viewModel.dart';
import 'package:t5/views/dialogs/event_filter_dialog.dart';
import 'dart:io';
import 'dart:typed_data';

class FakeRepo implements EventRepository {
  @override
  Future<List<Event>> getCreatedEventsByUser(String uid) async => [];

  @override
  Future<List<Event>> getJoinedEventsByUser(String uid) async => [];

  @override
  Future<Event> getEventById(String eventId) async {
    return Event(
      id: eventId,
      imageUrls: [],
      title: 'Event',
      description: '',
      createdAt: DateTime.now(),
      startDate: DateTime.now().add(const Duration(hours: 24)),
      endDate: DateTime.now().add(const Duration(days: 2)),
      maxUsers: 10,
      currentUsers: 0,
      idCreator: 'creator',
      country: 'PT',
      district: 'Porto',
      city: 'Porto',
      objectives: [],
    );
  }

  @override
  Stream<List<Event>> listenToEvents() => const Stream.empty();

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
  }) => Stream.value(false);
}

class FakeStorageRepository implements StorageRepository {
  @override
  Future<String> uploadBytes({
    required String path,
    required Uint8List bytes,
  }) async => 'https://fake-url.com/$path';

  @override
  Future<String> uploadFile({required String path, required File file}) async =>
      'https://fake-url.com/$path';

  @override
  Future<void> deleteProfilePicture({required String uuid}) async {}

  @override
  Future<String> uploadEventImage({
    required File file,
    required String eventId,
    required String fileName,
  }) async => 'https://fake-url.com/$eventId/$fileName';

  @override
  Future<String> uploadEventBytes({
    required String path,
    required Uint8List bytes,
  }) async => 'https://fake-url.com/$path';

  @override
  Future<void> deleteEventImages({required String eventId}) async {}
}

Widget buildWithDialog() {
  return ChangeNotifierProvider(
    create: (_) => EventViewModel(FakeRepo(), FakeStorageRepository()),
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => ChangeNotifierProvider.value(
                value: context.read<EventViewModel>(),
                child: const EventFilterDialog(currentUserId: 'test-user'),
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('EventFilterDialog opens and shows UI', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => EventViewModel(FakeRepo(), FakeStorageRepository()),
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) =>
                      const EventFilterDialog(currentUserId: 'test-user'),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('Apply'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('tap Cancel closes the dialog', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    await tester.pumpWidget(buildWithDialog());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Filters'), findsNothing);
  });

  testWidgets('tap Apply closes the dialog', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    await tester.pumpWidget(buildWithDialog());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(find.text('Filters'), findsNothing);
  });

  testWidgets('Hide full events checkbox can be toggled', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    await tester.pumpWidget(buildWithDialog());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final checkbox = find.widgetWithText(CheckboxListTile, 'Hide full events');
    expect(tester.widget<CheckboxListTile>(checkbox).value, false);
    await tester.tap(checkbox);
    await tester.pump();
    expect(tester.widget<CheckboxListTile>(checkbox).value, true);
  });

  testWidgets('Show finished events checkbox can be toggled', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    await tester.pumpWidget(buildWithDialog());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final checkbox = find.widgetWithText(
      CheckboxListTile,
      'Show finished events',
    );
    expect(tester.widget<CheckboxListTile>(checkbox).value, false);
    await tester.tap(checkbox);
    await tester.pump();
    expect(tester.widget<CheckboxListTile>(checkbox).value, true);
  });

  testWidgets('Show only events you can join checkbox can be toggled', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    await tester.pumpWidget(buildWithDialog());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final checkbox = find.widgetWithText(
      CheckboxListTile,
      'Show only events you can join',
    );
    expect(tester.widget<CheckboxListTile>(checkbox).value, false);
    await tester.tap(checkbox);
    await tester.pump();
    expect(tester.widget<CheckboxListTile>(checkbox).value, true);
  });

  testWidgets('tap Apply applies startDate and endDate filters', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    final vm = EventViewModel(FakeRepo(), FakeStorageRepository());
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: vm,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => ChangeNotifierProvider.value(
                    value: vm,
                    child: const EventFilterDialog(currentUserId: 'test-user'),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Start Date'),
      '01/01/2026',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'End Date'),
      '10/01/2026',
    );
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(vm.currentFilter.startDate, isNotNull);
    expect(vm.currentFilter.endDate, isNotNull);
    expect(vm.currentFilter.startDate!.day, 1);
    expect(vm.currentFilter.endDate!.day, 10);
  });

  testWidgets('tap Apply applies hideFull filter when checked', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    final vm = EventViewModel(FakeRepo(), FakeStorageRepository());
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: vm,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => ChangeNotifierProvider.value(
                    value: vm,
                    child: const EventFilterDialog(currentUserId: 'test-user'),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Hide full events'));
    await tester.pump();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(vm.currentFilter.hideFull, true);
  });
}
