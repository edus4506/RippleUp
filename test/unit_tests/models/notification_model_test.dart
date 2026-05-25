import 'package:flutter_test/flutter_test.dart';
import 'package:t5/data/models/social/notification.dart';

void main() {
  group('AppNotification.toMap', () {
    test('includes all required fields', () {
      final now = DateTime(2025, 6, 1, 12, 0, 0);
      final notification = AppNotification(
        id: 'n1',
        title: 'New Message',
        body: 'You have a new message',
        createdAt: now,
        seen: false,
        type: 'direct_message',
      );

      final map = notification.toMap();

      expect(map['title'], 'New Message');
      expect(map['body'], 'You have a new message');
      expect(map['seen'], false);
      expect(map['type'], 'direct_message');
    });

    test('includes eventId when set', () {
      final notification = AppNotification(
        id: 'n1',
        title: 'Event',
        body: 'Body',
        createdAt: DateTime.now(),
        seen: false,
        type: 'new_event',
        eventId: 'e1',
      );

      final map = notification.toMap();
      expect(map['eventId'], 'e1');
    });

    test('eventId is null when not provided', () {
      final notification = AppNotification(
        id: 'n1',
        title: 'Title',
        body: 'Body',
        createdAt: DateTime.now(),
        seen: false,
        type: 'direct_message',
      );

      final map = notification.toMap();
      expect(map['eventId'], isNull);
    });

    test('seen is true when marked as seen', () {
      final notification = AppNotification(
        id: 'n1',
        title: 'Title',
        body: 'Body',
        createdAt: DateTime.now(),
        seen: true,
        type: 'new_event',
      );

      final map = notification.toMap();
      expect(map['seen'], true);
    });
  });

  group('AppNotification fields', () {
    test('id is stored correctly', () {
      final notification = AppNotification(
        id: 'n42',
        title: 'T',
        body: 'B',
        createdAt: DateTime.now(),
        seen: false,
        type: 'new_event',
      );
      expect(notification.id, 'n42');
    });

    test('eventId defaults to null', () {
      final notification = AppNotification(
        id: 'n1',
        title: 'T',
        body: 'B',
        createdAt: DateTime.now(),
        seen: false,
        type: 'new_event',
      );
      expect(notification.eventId, isNull);
    });
  });
}
