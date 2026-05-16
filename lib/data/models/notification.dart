import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  //final String receiverId;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool seen;
  final String type;

  final String?
  eventId; //para depois ao clicar na notificação, ir direito para o evento

  AppNotification({
    required this.id,
    //required this.receiverId,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.seen,
    required this.type,
    this.eventId,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map, String documentId) {
    return AppNotification(
      id: documentId,
      //receiverId: map['receiverId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      seen: map['seen'] ?? false,
      type: map['type'] ?? '',
      eventId: map['eventId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      //'receiverId': receiverId,
      'title': title,
      'body': body,
      'createdAt': Timestamp.fromDate(createdAt),
      'seen': seen,
      'type': type,
      'eventId': eventId,
    };
  }
}
