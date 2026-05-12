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

  Stream<List<AppNotification>> listenUserNotifications(
    String uid,
  ) {

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => AppNotification.fromMap(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList(),
        );
  }



  Future<void> updateNotification(String uid,AppNotification notification) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notification.id)
        .update(notification.toMap());
  }
}