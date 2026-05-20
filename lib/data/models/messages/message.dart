import 'package:cloud_firestore/cloud_firestore.dart';

//messages will be within the event at wich they correspond to, so that we can get all of them with one querie
class Message {
  final String id;
  final String senderId;
  final String text;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  factory Message.fromMap(Map<String, dynamic> map, String documentId) {
    return Message(
      id: documentId,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
