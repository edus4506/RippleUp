import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/models/message.dart';
import '../data/repositories/direct_message_repository.dart';

class DirectMessageViewModel extends ChangeNotifier {
  final DirectMessageRepository _repository;

  DirectMessageViewModel(this._repository);

  Future<void> sendMessage({
    required String chatId,
    required String text,
    User? currentUser,
  }) async {
    final firebaseUser = currentUser ?? FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return;
    }

    final message = Message(
      id: '',
      senderId: firebaseUser.uid,
      text: text,
      createdAt: DateTime.now(),
    );

    await _repository.createMessage(
      chatId: chatId,
      message: message,
    );
  }

  Stream<List<Message>> getMessages(String chatId) {
    return _repository.getMessages(chatId);
  }
}