import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/models/notification.dart';

class NotificationService {
  static Future<void> createOrUpdateDirectMessageNotification({
    required String receiverId,
    required String senderName,
    required String senderId,
    required String chatId,
  }) async {
    final notificationsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('notifications');

    final existing = await notificationsRef
        .where('type', isEqualTo: 'direct_message')
        .where('chatId', isEqualTo: chatId)
        .where('seen', isEqualTo: false)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;

      final data = doc.data();

      int count = data['messageCount'] ?? 1;

      count++;

      final displayCount =
          count >= 4 ? '4+' : count.toString();

      await doc.reference.update({
        'messageCount': count,

        'body':
            'You received $displayCount messages from $senderName',

        'createdAt': Timestamp.now(),
      });

      return;
    }

    final notification = AppNotification(
      id: '',
      title: 'New Message',
      body: 'You received 1 message from $senderName',
      createdAt: DateTime.now(),
      seen: false,
      type: 'direct_message',
    );

    await notificationsRef.add({
      ...notification.toMap(),

      'chatId': chatId,

      'senderId': senderId,

      'messageCount': 1,
    });
  }

  static Future<void> createOrUpdateEventMessageNotification({
    required String receiverId,
    required String eventId,
    required String eventTitle,
  }) async {
    final notificationsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('notifications');

    final existing = await notificationsRef
        .where('type', isEqualTo: 'event_message')
        .where('eventId', isEqualTo: eventId)
        .where('seen', isEqualTo: false)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;

      final data = doc.data();

      int count = data['messageCount'] ?? 1;

      count++;

      final displayCount =
          count >= 4 ? '4+' : count.toString();

      await doc.reference.update({
        'messageCount': count,

        'body':
            'You received $displayCount messages in $eventTitle',

        'createdAt': Timestamp.now(),
      });

      return;
    }

    final notification = AppNotification(
      id: '',
      title: 'Event Messages',
      body: 'You received 1 message in $eventTitle',
      createdAt: DateTime.now(),
      seen: false,
      type: 'event_message',
      eventId: eventId,
    );

    await notificationsRef.add({
      ...notification.toMap(),

      'messageCount': 1,
    });
  }
}