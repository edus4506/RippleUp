import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:t5/data/repositories/message_repository.dart';
import '../data/repositories/participation_repository.dart';
import '../data/repositories/event_repository.dart';
import '../../data/models/message.dart';
import '../services/notification_service.dart';

class MessageViewModel extends ChangeNotifier {
  final MessageRepository _messageRepository;

  final ParticipationRepository _participationRepository;

  final EventRepository _eventRepository;

  MessageViewModel(this._messageRepository, this._participationRepository, this._eventRepository);

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

    final participations =
        await _participationRepository
            .getParticipationsByEvent(
              eventId,
            );

    final event =
        await _eventRepository.getEventById(
          eventId,
        );

    for (final participation in participations) {
      if (participation.idUser ==
          firebaseUser.uid) {
        continue;
      }

      await NotificationService
          .createOrUpdateEventMessageNotification(
            receiverId:
                participation.idUser,

            eventId: eventId,

            eventTitle:
                event?.title ?? 'Event',
          );
    }
  }

  Stream<List<Message>> getMessages(String eventId) {
    return _messageRepository.getEventMessages(eventId);
  }
}
