import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/messages/message.dart';
import '../../models/messages/direct_chat_preview.dart';

class DirectMessageRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<
    ({List<DirectChatPreview> chats, DocumentSnapshot? lastDoc, bool hasMore})
  >
  fetchChatsPaged({
    required String userId,
    DocumentSnapshot? startAfter,
    int pageSize = 10,
  }) async {
    Query query = _db
        .collection('direct_chats')
        .where('participants', arrayContains: userId) // ← ver nota abaixo
        .orderBy('lastMessageAt', descending: true)
        .limit(pageSize + 1);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final docs = snapshot.docs;

    final hasMore = docs.length > pageSize;
    final pageDocs = hasMore ? docs.sublist(0, pageSize) : docs;

    final chats = pageDocs
        .map(
          (doc) => DirectChatPreview.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        )
        .toList();

    return (
      chats: chats,
      lastDoc: pageDocs.isNotEmpty ? pageDocs.last : null,
      hasMore: hasMore,
    );
  }

  Future<void> createMessage({
    required String chatId,
    required Message message,
  }) async {
    final chatDoc = _db.collection('direct_chats').doc(chatId);

    await chatDoc.set({
      'createdAt': FieldValue.serverTimestamp(),

      'participants': chatId.split('_'),

      'lastMessage': message.text,

      'lastSenderId': message.senderId,

      'lastMessageAt': FieldValue.serverTimestamp(),

      'lastSeenBy': [message.senderId],
    }, SetOptions(merge: true));

    await chatDoc.collection('messages').add(message.toMap());
  }

  Stream<List<Message>> getMessages(String chatId) {
    return _db
        .collection('direct_chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Message.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<bool> chatExists(String chatId) async {
    final doc = await _db.collection('direct_chats').doc(chatId).get();

    return doc.exists;
  }

  Future<void> markChatAsSeen({
    required String chatId,
    required String userId,
  }) async {
    await _db.collection('direct_chats').doc(chatId).set({
      'lastSeenBy': FieldValue.arrayUnion([userId]),
    }, SetOptions(merge: true));
  }
}
