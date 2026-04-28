import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:t5/data/models/user.dart';
import 'package:t5/data/repositories/message_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/message.dart';

class MessageViewModel extends ChangeNotifier {
  final MessageRepository _messageRepository;

  MessageViewModel(this._messageRepository);

  //user uuid will be caught in the firebase.instance
  Future<void> sendMessage(
    String eventId,
    String text, {
    User? currentUser,
  }) async {
    final firebaseUser = currentUser ?? FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;

    final message = Message(
      id: '', //gerado automaticamente
      senderId: firebaseUser.uid,
      text: text,
      createdAt: DateTime.now(),
    );

    await _messageRepository.createMessage(eventId, message);
  }

  Stream<List<Message>> getMessages(String eventId) {
    return _messageRepository.getEventMessages(eventId);
  }
}
