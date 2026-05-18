import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:t5/data/models/notification.dart';

class NotificationRepository {
  Future<void> createNotification({
    required String uid,
    required AppNotification notification,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .add(notification.toMap());
  }

  Stream<List<AppNotification>> listenUserNotifications(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> updateNotification(
    String uid,
    AppNotification notification,
  ) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notification.id)
        .update(notification.toMap());
  }

  Future<bool> notificationAlreadyExists({
    required String uid,
    required String eventId,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('eventId', isEqualTo: eventId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> deleteNotification(
    String uid,
    String notificationId,
  ) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }
}
