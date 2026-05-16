import 'package:flutter_test/flutter_test.dart';
import 'package:t5/data/models/event.dart';
import 'package:t5/data/repositories/event_repository.dart';
import 'package:t5/data/repositories/storage_repository.dart';
import 'package:t5/viewModels/event_viewModel.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:t5/data/repositories/storage_repository.dart';

class FakeEventRepository implements EventRepository {
  FakeEventRepository({
    this.shouldThrow = false,
    this.exceptionMessage = 'Error',
  });

  bool shouldThrow;
  String exceptionMessage;
  String? receivedEventId;
  String? receivedUserId;

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
  Future<void> joinEvent({
    required String eventId,
    required String userId,
  }) async {
    receivedEventId = eventId;
    receivedUserId = userId;

    if (shouldThrow) {
      throw Exception(exceptionMessage);
    }
  }

  @override
  Future<void> leaveEvent({
    required String eventId,
    required String userId,
  }) async {
    if (shouldThrow) {
      throw Exception(exceptionMessage);
    }
  }

  @override
  Stream<bool> isUserInEvent({
    required String eventId,
    required String userId,
  }) {
    return Stream.value(false);
  }

  @override
  Future<void> deleteEvent(String eventId) async {}
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
  group('EventViewModel.joinEvent', () {
    test('returns true when repository join succeeds', () async {
      final repo = FakeEventRepository();
      final stRepo = FakeStorageRepository();
      final viewModel = EventViewModel(repo, stRepo);

      final result = await viewModel.joinEvent(
        eventId: 'event-1',
        userId: 'user-1',
      );

      expect(result, true);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, false);
      expect(repo.receivedEventId, 'event-1');
      expect(repo.receivedUserId, 'user-1');
    });

    test(
      'returns false and sets errorMessage when repository throws',
      () async {
        final repo = FakeEventRepository(
          shouldThrow: true,
          exceptionMessage: 'Event is full',
        );
        final stRepo = FakeStorageRepository();
        final viewModel = EventViewModel(repo, stRepo);

        final result = await viewModel.joinEvent(
          eventId: 'event-1',
          userId: 'user-1',
        );

        expect(result, false);
        expect(viewModel.errorMessage, 'Event is full');
        expect(viewModel.isLoading, false);
        expect(repo.receivedEventId, 'event-1');
        expect(repo.receivedUserId, 'user-1');
      },
    );
  });
}
