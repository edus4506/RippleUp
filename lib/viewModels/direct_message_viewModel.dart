import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/models/message.dart';
import '../data/repositories/direct_message_repository.dart';
import '../data/repositories/user_repository.dart';

import '../services/notification_service.dart';

class DirectMessageViewModel extends ChangeNotifier {
  final DirectMessageRepository _repository;


  final UserRepository _userRepository;

  DirectMessageViewModel(this._repository, this._userRepository);

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

    await _repository.createMessage(chatId: chatId, message: message);

    final participants = chatId.split('_');

    final receiverId = participants.firstWhere(
      (id) => id != firebaseUser.uid,
    );

    final currentUserData =
        await _userRepository.getUser(
          firebaseUser.uid,
        );

    final senderName =
        currentUserData?.name ?? 'Someone';

    await NotificationService
        .createOrUpdateDirectMessageNotification(
          receiverId: receiverId,
          senderName: senderName,
          senderId: firebaseUser.uid,
          chatId: chatId,
        );
  }

  Stream<List<Message>> getMessages(String chatId) {
    return _repository.getMessages(chatId);
  }

  Future<void> markChatAsSeen({
    required String chatId,
    required String userId,
  }) async {
    await _repository.markChatAsSeen(chatId: chatId, userId: userId);
  }
}
