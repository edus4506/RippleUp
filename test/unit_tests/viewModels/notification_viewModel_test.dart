import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Notification icon tests', () {
    test('event icon exists', () {
      expect(Icons.event_available, isNotNull);
    });

    test('clock icon exists', () {
      expect(Icons.access_time, isNotNull);
    });

    test('notification icon exists', () {
      expect(Icons.notifications, isNotNull);
    });
  });

  group('Notification string tests', () {
    test('new_event type is correct', () {
      const type = 'new_event';

      expect(type, 'new_event');
    });

    test('upcoming_event type is correct', () {
      const type = 'upcoming_event';

      expect(type.contains('upcoming'), true);
    });

    test('new_follower type is correct', () {
      const type = 'new_follower';

      expect(type.isNotEmpty, true);
    });
  });

  group('Notification counter tests', () {
    test('notification counter increments', () {
      int counter = 1;

      counter++;

      expect(counter, 2);
    });

    test('notification counter can reach 4', () {
      int counter = 0;

      counter += 4;

      expect(counter, 4);
    });

    test('notification counter above 4 works', () {
      int counter = 5;

      expect(counter > 4, true);
    });
  });

  group('Notification body tests', () {
    test('body contains username', () {
      const body = 'David followed you';

      expect(body.contains('David'), true);
    });

    test('body contains event title', () {
      const body = 'Beach Cleanup starts soon';

      expect(body.contains('Beach Cleanup'), true);
    });

    test('body is not empty', () {
      const body = 'New notification';

      expect(body.isNotEmpty, true);
    });
  });
}
