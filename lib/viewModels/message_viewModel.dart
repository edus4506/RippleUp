import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:t5/data/repositories/message_repository.dart';
import '../data/repositories/participation_repository.dart';
import '../data/repositories/event_repository.dart';
import '../../data/models/message.dart';
import '../data/repositories/event_chat_repository.dart';
import '../services/notification_service.dart';

class MessageViewModel extends ChangeNotifier {
  final MessageRepository _messageRepository;

  final ParticipationRepository _participationRepository;

  final EventRepository _eventRepository;

  final EventChatRepository _eventChatRepository;

  MessageViewModel(
    this._messageRepository,
    this._participationRepository,
    this._eventRepository,
    this._eventChatRepository,
  );

  //user uuid will be caught in the firebase.instance
  Future<void> sendMessage(
    String eventId,
    String text, {
    User? currentUser,
  }) async {
    final firebaseUser = currentUser ?? FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;

    final isParticipant = await _participationRepository.hasUserParticipated(
      firebaseUser.uid,
      eventId,
    );

    if (!isParticipant) {
      return;
    }

    final message = Message(
      id: '', //gerado automaticamente
      senderId: firebaseUser.uid,
      text: text,
      createdAt: DateTime.now(),
    );

    final event = await _eventRepository.getEventById(eventId);

    final participations = await _participationRepository
        .getParticipationsByEvent(eventId);

    await _messageRepository.createMessage(eventId, message);

    await _eventChatRepository.updateEventChatPreview(
      eventId: eventId,

      eventTitle: event.title,

      message: message,

      participantIds: participations.map((p) => p.idUser).toList(),
    );

    for (final participation in participations) {
      if (participation.idUser == firebaseUser.uid) {
        continue;
      }

      await NotificationService.createOrUpdateEventMessageNotification(
        receiverId: participation.idUser,

        eventId: eventId,

        eventTitle: event.title,
      );
    }
  }

  Stream<List<Message>> getMessages(String eventId) {
    return _messageRepository.getEventMessages(eventId);
  }
}
