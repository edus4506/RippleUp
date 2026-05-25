import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t5/data/models/events/event.dart';
import 'package:t5/data/repositories/events/recommended_event_repository.dart';
import 'package:t5/viewModels/events/recommended_event_viewModel.dart';

class MockRecommendedEventRepository extends Mock
    implements RecommendedEventRepository {}

Event _buildEvent(String id) {
  final now = DateTime.now();
  return Event(
    id: id,
    title: 'Event $id',
    description: '',
    createdAt: now,
    startDate: now.add(const Duration(hours: 1)),
    endDate: now.add(const Duration(hours: 2)),
    maxUsers: 10,
    currentUsers: 1,
    idCreator: 'creator',
    country: 'Portugal',
    district: 'Porto',
    city: 'Porto',
    objectives: const [],
    imageUrls: const [],
  );
}

void main() {
  late MockRecommendedEventRepository mockRepo;
  late RecommendedEventViewModel vm;

  setUp(() {
    mockRepo = MockRecommendedEventRepository();
    vm = RecommendedEventViewModel(currentUserId: 'u1', repository: mockRepo);
  });

  group('RecommendedEventViewModel initial state', () {
    test('recommendedEvents starts empty', () {
      expect(vm.recommendedEvents, isEmpty);
    });

    test('isLoading starts false', () {
      expect(vm.isLoading, false);
    });

    test('errorMessage starts null', () {
      expect(vm.errorMessage, isNull);
    });

    test('hasNoData is true initially', () {
      expect(vm.hasNoData, true);
    });
  });

  group('RecommendedEventViewModel.loadRecommendedEvents', () {
    test('populates recommendedEvents on success', () async {
      when(
        () => mockRepo.getRecommendedEvents(
          currentUserId: 'u1',
          limit: any(named: 'limit'),
          maxAttempts: any(named: 'maxAttempts'),
        ),
      ).thenAnswer((_) async => [_buildEvent('e1'), _buildEvent('e2')]);

      await vm.loadRecommendedEvents();

      expect(vm.recommendedEvents.length, 2);
      expect(vm.isLoading, false);
      expect(vm.errorMessage, isNull);
    });

    test('sets errorMessage when repository returns empty list', () async {
      when(
        () => mockRepo.getRecommendedEvents(
          currentUserId: 'u1',
          limit: any(named: 'limit'),
          maxAttempts: any(named: 'maxAttempts'),
        ),
      ).thenAnswer((_) async => []);

      await vm.loadRecommendedEvents();

      expect(vm.recommendedEvents, isEmpty);
      expect(vm.errorMessage, isNotNull);
    });

    test('sets errorMessage when repository throws', () async {
      when(
        () => mockRepo.getRecommendedEvents(
          currentUserId: any(named: 'currentUserId'),
          limit: any(named: 'limit'),
          maxAttempts: any(named: 'maxAttempts'),
        ),
      ).thenThrow(Exception('network error'));

      await vm.loadRecommendedEvents();

      expect(vm.recommendedEvents, isEmpty);
      expect(vm.errorMessage, isNotNull);
      expect(vm.isLoading, false);
    });

    test('isLoading is false after successful load', () async {
      when(
        () => mockRepo.getRecommendedEvents(
          currentUserId: 'u1',
          limit: any(named: 'limit'),
          maxAttempts: any(named: 'maxAttempts'),
        ),
      ).thenAnswer((_) async => [_buildEvent('e1')]);

      await vm.loadRecommendedEvents();

      expect(vm.isLoading, false);
    });

    test('hasNoData is false when events are loaded', () async {
      when(
        () => mockRepo.getRecommendedEvents(
          currentUserId: 'u1',
          limit: any(named: 'limit'),
          maxAttempts: any(named: 'maxAttempts'),
        ),
      ).thenAnswer((_) async => [_buildEvent('e1')]);

      await vm.loadRecommendedEvents();

      expect(vm.hasNoData, false);
    });

    test('notifies listeners during and after load', () async {
      when(
        () => mockRepo.getRecommendedEvents(
          currentUserId: 'u1',
          limit: any(named: 'limit'),
          maxAttempts: any(named: 'maxAttempts'),
        ),
      ).thenAnswer((_) async => [_buildEvent('e1')]);

      int count = 0;
      vm.addListener(() => count++);

      await vm.loadRecommendedEvents();

      expect(count, greaterThanOrEqualTo(2));
    });
  });

  group('RecommendedEventViewModel.refreshRecommendations', () {
    test('clears previous events before reloading', () async {
      when(
        () => mockRepo.getRecommendedEvents(
          currentUserId: 'u1',
          limit: any(named: 'limit'),
          maxAttempts: any(named: 'maxAttempts'),
        ),
      ).thenAnswer((_) async => [_buildEvent('e1')]);

      await vm.loadRecommendedEvents();
      expect(vm.recommendedEvents.length, 1);

      when(
        () => mockRepo.getRecommendedEvents(
          currentUserId: 'u1',
          limit: any(named: 'limit'),
          maxAttempts: any(named: 'maxAttempts'),
        ),
      ).thenAnswer((_) async => [_buildEvent('e2'), _buildEvent('e3')]);

      await vm.refreshRecommendations();

      expect(vm.recommendedEvents.length, 2);
    });
  });

  group('RecommendedEventViewModel.clear', () {
    test('resets all state', () async {
      when(
        () => mockRepo.getRecommendedEvents(
          currentUserId: 'u1',
          limit: any(named: 'limit'),
          maxAttempts: any(named: 'maxAttempts'),
        ),
      ).thenAnswer((_) async => [_buildEvent('e1')]);

      await vm.loadRecommendedEvents();
      vm.clear();

      expect(vm.recommendedEvents, isEmpty);
      expect(vm.isLoading, false);
      expect(vm.errorMessage, isNull);
    });
  });
}
