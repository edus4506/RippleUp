import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/event.dart';
import 'package:t5/data/repositories/event_repository.dart';
import 'package:t5/data/repositories/storage_repository.dart';
import 'package:t5/viewModels/event_viewModel.dart';
import 'package:t5/views/dialogs/event_filter_dialog.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:t5/data/repositories/storage_repository.dart';

class FakeRepo implements EventRepository {
  @override
  Future<List<Event>> getCreatedEventsByUser(String uid) async {
    return [];
  }

  @override
  Future<List<Event>> getJoinedEventsByUser(String uid) async {
    return [];
  }

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
  }) async {
    return 'https://fake-url.com/$path';
  }

  @override
  Future<String> uploadFile({required String path, required File file}) async {
    return 'https://fake-url.com/$path';
  }

  @override
  Future<void> deleteProfilePicture({required String uuid}) async {}

  @override
  Future<String> uploadEventImage({
    required File file,
    required String eventId,
    required String fileName,
  }) async {
    return 'https://fake-url.com/$eventId/$fileName';
  }

  @override
  Future<String> uploadEventBytes({
    required String path,
    required Uint8List bytes,
  }) async {
    return 'https://fake-url.com/$path';
  }

  @override
  Future<void> deleteEventImages({required String eventId}) async {}
}

void main() {
  testWidgets('EventFilterDialog opens and shows UI', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    final stRepo = FakeStorageRepository();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => EventViewModel(FakeRepo(), stRepo),
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const EventFilterDialog(),
                    );
                  },
                  child: const Text('Open'),
                );
              },
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
}
