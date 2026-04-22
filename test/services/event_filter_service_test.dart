import 'package:flutter_test/flutter_test.dart';
import 'package:t5/data/models/event.dart';
import 'package:t5/services/event_filter.dart';
import 'package:t5/services/event_filter_service.dart';

Event buildEvent({
  int currentUsers = 1,
  int maxUsers = 5,
  List<int> objectives = const [1],
  String country = 'Portugal',
  String district = 'Porto',
  String city = 'Porto',
  DateTime? startDate,
  DateTime? endDate,
}) {
  final now = DateTime.now();

  return Event(
    id: '1',
    title: 'Test Event',
    description: '',
    createdAt: now,
    startDate: startDate ?? now.add(const Duration(hours: 1)), // planning
    endDate: endDate ?? now.add(const Duration(hours: 2)),
    maxUsers: maxUsers,
    currentUsers: currentUsers,
    idCreator: 'creator',
    objectives: objectives,
    country: country,
    district: district,
    city: city,
  );
}

void main() {
  group('EventFilterService.apply', () {

    test('returns all events when no filters are applied', () {
      final events = [buildEvent(), buildEvent()];

      final result = EventFilterService.apply(events, const EventFilter());

      expect(result.length, 2);
    });

    test('filters full events when hideFull is true', () {
      final events = [
        buildEvent(currentUsers: 5, maxUsers: 5),
        buildEvent(currentUsers: 2, maxUsers: 5),
      ];

      final filter = EventFilter(hideFull: true);

      final result = EventFilterService.apply(events, filter);

      expect(result.length, 1);
      expect(result.first.currentUsers, 2);
    });

    test('filters done events when showDone is false', () {
      final events = [
        buildEvent(
          startDate: DateTime.now().subtract(const Duration(hours: 2)),
          endDate: DateTime.now().subtract(const Duration(hours: 1)),
        ), // done
        buildEvent(), // planning
      ];

      final filter = EventFilter(showDone: false);

      final result = EventFilterService.apply(events, filter);

      expect(result.length, 1);
    });

    test('filters by goals', () {
      final events = [
        buildEvent(objectives: [1, 2]),
        buildEvent(objectives: [3]),
      ];

      final filter = EventFilter(goals: {1});

      final result = EventFilterService.apply(events, filter);

      expect(result.length, 1);
      expect(result.first.objectives.contains(1), true);
    });

    test('filters by minCapacity', () {
      final events = [
        buildEvent(maxUsers: 3),
        buildEvent(maxUsers: 10),
      ];

      final filter = EventFilter(minCapacity: 5);

      final result = EventFilterService.apply(events, filter);

      expect(result.length, 1);
      expect(result.first.maxUsers, 10);
    });

    test('filters by maxCapacity', () {
      final events = [
        buildEvent(maxUsers: 3),
        buildEvent(maxUsers: 10),
      ];

      final filter = EventFilter(maxCapacity: 5);

      final result = EventFilterService.apply(events, filter);

      expect(result.length, 1);
      expect(result.first.maxUsers, 3);
    });

    test('filters by current users range', () {
      final events = [
        buildEvent(currentUsers: 2),
        buildEvent(currentUsers: 8),
      ];

      final filter = EventFilter(
        minCurrentUsers: 5,
        maxCurrentUsers: 10,
      );

      final result = EventFilterService.apply(events, filter);

      expect(result.length, 1);
      expect(result.first.currentUsers, 8);
    });

    test('filters by country', () {
      final events = [
        buildEvent(country: 'Portugal'),
        buildEvent(country: 'Spain'),
      ];

      final filter = EventFilter(country: 'Portugal');

      final result = EventFilterService.apply(events, filter);

      expect(result.length, 1);
      expect(result.first.country, 'Portugal');
    });

    test('filters by district', () {
      final events = [
        buildEvent(district: 'Porto'),
        buildEvent(district: 'Lisboa'),
      ];

      final filter = EventFilter(district: 'Porto');

      final result = EventFilterService.apply(events, filter);

      expect(result.length, 1);
      expect(result.first.district, 'Porto');
    });

    test('filters by city', () {
      final events = [
        buildEvent(city: 'Porto'),
        buildEvent(city: 'Vigo'),
      ];

      final filter = EventFilter(city: 'Porto');

      final result = EventFilterService.apply(events, filter);

      expect(result.length, 1);
      expect(result.first.city, 'Porto');
    });

    test('applies multiple filters together', () {
      final events = [
        buildEvent(currentUsers: 5, maxUsers: 5), // full → remove
        buildEvent(currentUsers: 3, maxUsers: 10), // valid
        buildEvent(currentUsers: 3, maxUsers: 10, country: 'Spain'), // wrong country
      ];

      final filter = EventFilter(
        hideFull: true,
        country: 'Portugal',
      );

      final result = EventFilterService.apply(events, filter);

      expect(result.length, 1);
      expect(result.first.country, 'Portugal');
      expect(result.first.currentUsers, 3);
    });
  });
}