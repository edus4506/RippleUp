import 'package:flutter_test/flutter_test.dart';
import 'package:t5/data/models/event.dart';
import 'package:t5/data/repositories/event_repository.dart';
import 'package:t5/viewModels/event_viewModel.dart';

class FakeEventRepository implements EventRepository {
  FakeEventRepository({
    this.shouldThrow = false,
    this.exceptionMessage = 'Erro',
  });

  bool shouldThrow;
  String exceptionMessage;
  String? receivedEventId;
  String? receivedUserId;

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

void main() {
  group('EventViewModel.joinEvent', () {
    test('returns true when repository join succeeds', () async {
      final repo = FakeEventRepository();
      final viewModel = EventViewModel(repo);

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

    test('returns false and sets errorMessage when repository throws', () async {
      final repo = FakeEventRepository(
        shouldThrow: true,
        exceptionMessage: 'Evento cheio',
      );
      final viewModel = EventViewModel(repo);

      final result = await viewModel.joinEvent(
        eventId: 'event-1',
        userId: 'user-1',
      );

      expect(result, false);
      expect(viewModel.errorMessage, 'Evento cheio');
      expect(viewModel.isLoading, false);
      expect(repo.receivedEventId, 'event-1');
      expect(repo.receivedUserId, 'user-1');
    });
  });
}