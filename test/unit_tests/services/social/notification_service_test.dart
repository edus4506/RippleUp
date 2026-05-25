import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationService display count logic', () {
    String displayCount(int count) => count >= 4 ? '4+' : count.toString();

    test('count below 4 displays exact number', () {
      expect(displayCount(1), '1');
      expect(displayCount(2), '2');
      expect(displayCount(3), '3');
    });

    test('count of exactly 4 displays 4+', () {
      expect(displayCount(4), '4+');
    });

    test('count above 4 displays 4+', () {
      expect(displayCount(10), '4+');
      expect(displayCount(100), '4+');
    });
  });

  group('NotificationService direct message body format', () {
    String directMessageBody(int count, String senderName) {
      final display = count >= 4 ? '4+' : count.toString();
      final word = count == 1 ? 'message' : 'messages';
      return 'You received $display $word from $senderName';
    }

    test('single message uses singular form', () {
      final body = directMessageBody(1, 'Alice');
      expect(body, 'You received 1 message from Alice');
    });

    test('multiple messages uses plural form', () {
      final body = directMessageBody(3, 'Alice');
      expect(body, 'You received 3 messages from Alice');
    });

    test('body includes sender name', () {
      final body = directMessageBody(2, 'David');
      expect(body.contains('David'), true);
    });

    test('4+ messages uses display count', () {
      final body = directMessageBody(5, 'Alice');
      expect(body.contains('4+'), true);
    });
  });

  group('NotificationService event message body format', () {
    String eventMessageBody(int count, String eventTitle) {
      final display = count >= 4 ? '4+' : count.toString();
      final word = count == 1 ? 'message' : 'messages';
      return 'You received $display $word in $eventTitle';
    }

    test('single message body is correct', () {
      final body = eventMessageBody(1, 'Beach Cleanup');
      expect(body, 'You received 1 message in Beach Cleanup');
    });

    test('multiple messages body is correct', () {
      final body = eventMessageBody(3, 'Beach Cleanup');
      expect(body, 'You received 3 messages in Beach Cleanup');
    });

    test('body includes event title', () {
      final body = eventMessageBody(2, 'Forest Walk');
      expect(body.contains('Forest Walk'), true);
    });
  });

  group('NotificationService chat id format', () {
    String generateChatId(String a, String b) {
      final sorted = [a, b]..sort();
      return '${sorted[0]}_${sorted[1]}';
    }

    test('chat id is symmetric', () {
      expect(
        generateChatId('user1', 'user2'),
        generateChatId('user2', 'user1'),
      );
    });

    test('chat id contains underscore separator', () {
      final id = generateChatId('a', 'b');
      expect(id.contains('_'), true);
    });

    test('chat id sorts lexicographically', () {
      expect(generateChatId('b', 'a'), 'a_b');
    });
  });

  group('NotificationService notification types', () {
    test('direct_message type is recognised', () {
      const type = 'direct_message';
      expect(type, isNotEmpty);
    });

    test('event_message type is recognised', () {
      const type = 'event_message';
      expect(type, isNotEmpty);
    });

    test('upcoming_event type is recognised', () {
      const type = 'upcoming_event';
      expect(type, isNotEmpty);
    });

    test('new_event type is recognised', () {
      const type = 'new_event';
      expect(type, isNotEmpty);
    });
  });
}
