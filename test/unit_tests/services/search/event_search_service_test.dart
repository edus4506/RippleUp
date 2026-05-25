import 'package:flutter_test/flutter_test.dart';
import 'package:t5/data/models/events/event.dart';
import 'package:t5/services/search/event_search_service.dart';

Event buildEvent({
  String title = 'Test Event',
  String description = '',
  String country = 'Portugal',
  String district = 'Porto',
  String city = 'Porto',
}) {
  final now = DateTime.now();

  return Event(
    id: '1',
    title: title,
    description: description,
    createdAt: now,
    startDate: now.add(const Duration(hours: 1)),
    endDate: now.add(const Duration(hours: 2)),
    maxUsers: 10,
    currentUsers: 1,
    idCreator: 'creator',
    objectives: const [1],
    country: country,
    district: district,
    city: city,
    imageUrls: const [],
    coverImageUrl: null,
  );
}

void main() {
  group('EventSearchService.search', () {

    test('returns all events when query is empty', () {
      final events = [
        buildEvent(title: 'Music Festival'),
        buildEvent(title: 'Beach Cleanup'),
      ];

      final result = EventSearchService.search(events, '');

      expect(result.length, 2);
    });

    test('finds events by exact title match', () {
      final events = [
        buildEvent(title: 'Music Festival'),
        buildEvent(title: 'Beach Cleanup'),
      ];

      final result = EventSearchService.search(events, 'music');

      expect(result.length, 1);
      expect(result.first.title, 'Music Festival');
    });

    test('finds events by description match', () {
      final events = [
        buildEvent(description: 'Community music event'),
        buildEvent(description: 'Environmental activity'),
      ];

      final result = EventSearchService.search(events, 'music');

      expect(result.length, 1);
      expect(result.first.description.contains('music'), true);
    });

    test('matches events with small typing mistakes', () {
      final events = [buildEvent(title: 'Music Festival')];

      final result = EventSearchService.search(events, 'musci');

      expect(result.length, 1);
      expect(result.first.title, 'Music Festival');
    });

    test('matches events using city name', () {
      final events = [buildEvent(city: 'Lisbon'), buildEvent(city: 'Porto')];

      final result = EventSearchService.search(events, 'lisbon');

      expect(result.length, 1);
      expect(result.first.city, 'Lisbon');
    });

    test('ranks exact matches before partial matches', () {
      final events = [
        buildEvent(title: 'Music Festival'),
        buildEvent(description: 'People who enjoy music outdoors'),
      ];

      final result = EventSearchService.search(events, 'music');

      expect(result.length, 2);
      expect(result.first.title, 'Music Festival');
    });
  });
}
