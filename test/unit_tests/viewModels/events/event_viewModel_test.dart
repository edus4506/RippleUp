import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t5/data/models/events/event.dart';
import 'package:t5/data/repositories/events/event_repository.dart';
import 'package:t5/services/storage/storage_service.dart';
import 'package:t5/viewModels/events/event_viewModel.dart';

class MockEventRepository extends Mock implements EventRepository {}

class MockStorageRepository extends Mock implements StorageRepository {}

Event buildEvent({int currentUsers = 1, int maxUsers = 5}) {
  final now = DateTime.now();
  return Event(
    id: 'e1',
    title: 'Test',
    description: '',
    createdAt: now,
    startDate: now.add(const Duration(hours: 1)),
    endDate: now.add(const Duration(hours: 2)),
    maxUsers: maxUsers,
    currentUsers: currentUsers,
    idCreator: 'creator',
    objectives: const [1],
    country: 'Portugal',
    district: 'Porto',
    city: 'Porto',
    imageUrls: const [],
    coverImageUrl: null,
  );
}

void main() {
  late MockEventRepository mockEventRepo;
  late MockStorageRepository mockStorageRepo;
  late EventViewModel viewModel;

  setUp(() {
    mockEventRepo = MockEventRepository();
    mockStorageRepo = MockStorageRepository();
    viewModel = EventViewModel(mockEventRepo, mockStorageRepo);
  });

  group('EventViewModel.joinEvent', () {
    test('returns true when repository succeeds', () async {
      when(
        () => mockEventRepo.joinEvent(eventId: 'e1', userId: 'u1'),
      ).thenAnswer((_) async {});

      final result = await viewModel.joinEvent(eventId: 'e1', userId: 'u1');

      expect(result, true);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, false);
    });

    test(
      'returns false and sets errorMessage when repository throws',
      () async {
        when(
          () => mockEventRepo.joinEvent(eventId: 'e1', userId: 'u1'),
        ).thenThrow(Exception('Event is full'));

        final result = await viewModel.joinEvent(eventId: 'e1', userId: 'u1');

        expect(result, false);
        expect(viewModel.errorMessage, 'Event is full');
        expect(viewModel.isLoading, false);
      },
    );
  });

  group('EventViewModel.leaveEvent', () {
    test('returns true when repository succeeds', () async {
      when(
        () => mockEventRepo.leaveEvent(eventId: 'e1', userId: 'u1'),
      ).thenAnswer((_) async {});

      final result = await viewModel.leaveEvent(eventId: 'e1', userId: 'u1');

      expect(result, true);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, false);
    });

    test(
      'returns false and sets errorMessage when repository throws',
      () async {
        when(
          () => mockEventRepo.leaveEvent(eventId: 'e1', userId: 'u1'),
        ).thenThrow(Exception('Not participating'));

        final result = await viewModel.leaveEvent(eventId: 'e1', userId: 'u1');

        expect(result, false);
        expect(viewModel.errorMessage, 'Not participating');
        expect(viewModel.isLoading, false);
      },
    );
  });

  group('EventViewModel.deleteEvent', () {
    test('returns true when repository succeeds', () async {
      when(() => mockEventRepo.deleteEvent('e1')).thenAnswer((_) async {});

      final result = await viewModel.deleteEvent('e1');

      expect(result, true);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, false);
    });

    test(
      'returns false and sets errorMessage when repository throws',
      () async {
        when(
          () => mockEventRepo.deleteEvent('e1'),
        ).thenThrow(Exception('Event not found'));

        final result = await viewModel.deleteEvent('e1');

        expect(result, false);
        expect(viewModel.errorMessage, 'Event not found');
        expect(viewModel.isLoading, false);
      },
    );
  });

  group('EventViewModel.createEvent', () {
    test('delegates to repository', () async {
      final event = buildEvent();
      when(() => mockEventRepo.createEvent(event)).thenAnswer((_) async {});

      await viewModel.createEvent(event);

      verify(() => mockEventRepo.createEvent(event)).called(1);
    });
  });

  group('EventViewModel search state', () {
    test('startSearch sets isSearching to true', () {
      viewModel.startSearch();

      expect(viewModel.isSearching, true);
    });

    test('stopSearch sets isSearching to false and clears query', () {
      viewModel.startSearch();
      viewModel.stopSearch();

      expect(viewModel.isSearching, false);
      expect(viewModel.searchQuery, '');
    });

    test('updateSearchQuery updates searchQuery after debounce', () async {
      viewModel.startSearch();
      viewModel.updateSearchQuery('beach');

      await Future.delayed(const Duration(milliseconds: 350));

      expect(viewModel.searchQuery, 'beach');
    });

    test(
      'filteredEventsStream returns search results when isSearching',
      () async {
        final events = [buildEvent()];
        when(
          () => mockEventRepo.listenToEvents(),
        ).thenAnswer((_) => Stream.value(events));

        viewModel.startSearch();
        viewModel.updateSearchQuery('Test');

        await Future.delayed(const Duration(milliseconds: 350));

        final result = await viewModel.filteredEventsStream.first;
        expect(result, isNotEmpty);
      },
    );

    test(
      'filteredEventsStream returns filtered results when not searching',
      () async {
        final events = [buildEvent()];
        when(
          () => mockEventRepo.listenToEvents(),
        ).thenAnswer((_) => Stream.value(events));

        viewModel.applyFilters(
          hideFull: false,
          showDone: true,
          canJoin: false,
          goals: const {},
        );

        final result = await viewModel.filteredEventsStream.first;
        expect(result, isNotEmpty);
      },
    );
  });

  group('EventViewModel.applyFilters', () {
    test('updates currentFilter with provided values', () {
      viewModel.applyFilters(
        hideFull: true,
        showDone: false,
        canJoin: true,
        goals: {1, 2},
        country: 'Portugal',
        district: 'Porto',
        city: 'Porto',
      );

      final filter = viewModel.currentFilter;
      expect(filter.hideFull, true);
      expect(filter.showDone, false);
      expect(filter.canJoin, true);
      expect(filter.goals, {1, 2});
      expect(filter.country, 'Portugal');
      expect(filter.district, 'Porto');
      expect(filter.city, 'Porto');
    });

    test('resets to empty filter when called with defaults', () {
      viewModel.applyFilters(
        hideFull: true,
        showDone: true,
        canJoin: false,
        goals: {3},
      );

      viewModel.applyFilters(
        hideFull: false,
        showDone: true,
        canJoin: true,
        goals: const {},
      );

      final filter = viewModel.currentFilter;
      expect(filter.hideFull, false);
      expect(filter.canJoin, true);
      expect(filter.goals, isEmpty);
      expect(filter.country, isNull);
    });
  });
}
