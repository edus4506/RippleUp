import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String idEvent;
  final String idSender;
  final String text;
  final DateTime dateTime; //this can be precise as a timeStamp? see later

  Message({
    required this.id,
    required this.idEvent,
    required this.idSender,
    required this.text,
    required this.dateTime,
  });

  factory Message.fromMap(Map<String, dynamic> map, String documentId) {
    return Message(
      id: documentId,
      idEvent: map['idEvent'] ?? '',
      idSender: map['idSender'] ?? '',
      text: map['text'] ?? '',
      dateTime: (map['dateTime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idEvent': idEvent,
      'idSender': idSender,
      'text': text,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }
}
