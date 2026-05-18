import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/message.dart';
import '../models/direct_chat_preview.dart';

class DirectMessageRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createMessage({
    required String chatId,
    required Message message,
  }) async {
    final chatDoc = _db
        .collection('direct_chats')
        .doc(chatId);

    await chatDoc.set({
      'createdAt': FieldValue.serverTimestamp(),

      'participants': chatId.split('_'),

      'lastMessage': message.text,

      'lastSenderId': message.senderId,

      'lastMessageAt': FieldValue.serverTimestamp(),

      'lastSeenBy': [
        message.senderId,
      ],

    }, SetOptions(merge: true));

    await chatDoc
        .collection('messages')
        .add(message.toMap());
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
    final doc = await _db
        .collection('direct_chats')
        .doc(chatId)
        .get();

    return doc.exists;
  }

  Stream<List<DirectChatPreview>> getUserChats(
    String userId,
  ) {
    return _db
        .collection('direct_chats')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => DirectChatPreview.fromMap(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  Future<void> markChatAsSeen({
    required String chatId,
    required String userId,
  }) async {
    await _db
        .collection('direct_chats')
        .doc(chatId)
        .set({
          'lastSeenBy': FieldValue.arrayUnion(
            [userId],
          ),
        }, SetOptions(merge: true));
  }
}