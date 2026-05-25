import 'package:flutter_test/flutter_test.dart';
import 'package:t5/data/models/events/event.dart';
import 'package:t5/data/models/events/event_status.dart';

Event _buildEvent({
  DateTime? startDate,
  DateTime? endDate,
  int maxUsers = 10,
  int currentUsers = 1,
  List<int> objectives = const [1],
  String? coverImageUrl,
}) {
  final now = DateTime.now();
  return Event(
    id: 'e1',
    title: 'Beach Cleanup',
    description: 'A cleanup event',
    createdAt: now,
    startDate: startDate ?? now.add(const Duration(hours: 1)),
    endDate: endDate ?? now.add(const Duration(hours: 3)),
    maxUsers: maxUsers,
    currentUsers: currentUsers,
    idCreator: 'creator1',
    country: 'Portugal',
    district: 'Porto',
    city: 'Porto',
    objectives: objectives,
    imageUrls: const ['img1.jpg', 'img2.jpg'],
    coverImageUrl: coverImageUrl,
  );
}

void main() {
  group('Event.status', () {
    test('returns planning when event has not started yet', () {
      final event = _buildEvent(
        startDate: DateTime.now().add(const Duration(hours: 2)),
        endDate: DateTime.now().add(const Duration(hours: 4)),
      );
      expect(event.status, EventStatus.planning);
    });

    test('returns occurring when event is in progress', () {
      final event = _buildEvent(
        startDate: DateTime.now().subtract(const Duration(hours: 1)),
        endDate: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(event.status, EventStatus.occurring);
    });

    test('returns done when event has ended', () {
      final event = _buildEvent(
        startDate: DateTime.now().subtract(const Duration(hours: 3)),
        endDate: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(event.status, EventStatus.done);
    });
  });

  group('EventStatus.text', () {
    test('planning returns PLANNING', () {
      expect(EventStatus.planning.text, 'PLANNING');
    });

    test('occurring returns OCCURRING', () {
      expect(EventStatus.occurring.text, 'OCCURRING');
    });

    test('done returns DONE', () {
      expect(EventStatus.done.text, 'DONE');
    });
  });

  group('Event.toMap', () {
    test('contains all required fields', () {
      final event = _buildEvent();
      final map = event.toMap();

      expect(map['title'], 'Beach Cleanup');
      expect(map['description'], 'A cleanup event');
      expect(map['maxUsers'], 10);
      expect(map['currentUsers'], 1);
      expect(map['idCreator'], 'creator1');
      expect(map['country'], 'Portugal');
      expect(map['district'], 'Porto');
      expect(map['city'], 'Porto');
      expect(map['objectives'], [1]);
      expect(map['imageUrls'], ['img1.jpg', 'img2.jpg']);
    });

    test('coverImageUrl is included when set', () {
      final event = _buildEvent(coverImageUrl: 'cover.jpg');
      final map = event.toMap();
      expect(map['coverImageUrl'], 'cover.jpg');
    });

    test('coverImageUrl is null when not set', () {
      final event = _buildEvent();
      final map = event.toMap();
      expect(map['coverImageUrl'], isNull);
    });
  });

  group('Event fields', () {
    test('id is set correctly', () {
      final event = _buildEvent();
      expect(event.id, 'e1');
    });

    test('imageUrls list is preserved', () {
      final event = _buildEvent();
      expect(event.imageUrls.length, 2);
      expect(event.imageUrls, containsAll(['img1.jpg', 'img2.jpg']));
    });

    test('objectives list is preserved', () {
      final event = _buildEvent(objectives: [1, 5, 12]);
      expect(event.objectives, [1, 5, 12]);
    });
  });
}
