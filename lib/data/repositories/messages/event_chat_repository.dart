import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/messages/event_chat_preview.dart';
import '../../models/messages/message.dart';

class EventChatRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> updateEventChatPreview({
    required String eventId,
    required String eventTitle,
    required Message message,
    required List<String> participantIds,
  }) async {
    await _db.collection('event_chats').doc(eventId).set({
      'title': eventTitle,
      'lastMessage': message.text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastSenderId': message.senderId,
      'participantsHistory': FieldValue.arrayUnion(participantIds),
      'lastSeenBy': [message.senderId],
    }, SetOptions(merge: true));
  }

  Stream<List<EventChatPreview>> getUserEventChats(String userId) {
    return _db
        .collection('event_chats')
        .where('participantsHistory', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EventChatPreview.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> markEventChatAsSeen({
    required String eventId,
    required String userId,
  }) async {
    await _db.collection('event_chats').doc(eventId).set({
      'lastSeenBy': FieldValue.arrayUnion([userId]),
    }, SetOptions(merge: true));
  }
}
