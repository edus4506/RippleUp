import 'package:cloud_firestore/cloud_firestore.dart';

class EventChatPreview {
  final String eventId;

  final String title;

  final String lastMessage;

  final DateTime? lastMessageAt;

  final String lastSenderId;

  final List<String>
  participantsHistory;

  EventChatPreview({
    required this.eventId,

    required this.title,

    required this.lastMessage,

    required this.lastMessageAt,

    required this.lastSenderId,

    required this.participantsHistory,
  });

  factory EventChatPreview.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return EventChatPreview(
      eventId: documentId,

      title: map['title'] ?? '',

      lastMessage:
          map['lastMessage'] ?? '',

      lastMessageAt:
          map['lastMessageAt'] != null
              ? (map['lastMessageAt']
                      as Timestamp)
                  .toDate()
              : null,

      lastSenderId:
          map['lastSenderId'] ?? '',

      participantsHistory:
          List<String>.from(
            map['participantsHistory'] ??
                [],
          ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,

      'lastMessage': lastMessage,

      'lastMessageAt':
          lastMessageAt != null
              ? Timestamp.fromDate(
                  lastMessageAt!,
                )
              : null,

      'lastSenderId':
          lastSenderId,

      'participantsHistory':
          participantsHistory,
    };
  }
}