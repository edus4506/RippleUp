import 'package:cloud_firestore/cloud_firestore.dart';

class DirectChatPreview {
  final String chatId;

  final List<String> participants;

  final String lastMessage;

  final String lastSenderId;

  final DateTime? lastMessageAt;

  DirectChatPreview({
    required this.chatId,
    required this.participants,
    required this.lastMessage,
    required this.lastSenderId,
    required this.lastMessageAt,
  });

  factory DirectChatPreview.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return DirectChatPreview(
      chatId: documentId,

      participants: List<String>.from(
        map['participants'] ?? [],
      ),

      lastMessage: map['lastMessage'] ?? '',

      lastSenderId: map['lastSenderId'] ?? '',

      lastMessageAt:
          map['lastMessageAt'] != null
              ? (map['lastMessageAt'] as Timestamp)
                    .toDate()
              : null,
    );
  }
}