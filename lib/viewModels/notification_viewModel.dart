import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:t5/data/models/event.dart';
import 'package:t5/data/models/notification.dart';
import 'package:t5/data/models/participation.dart';
import 'package:t5/data/models/user.dart';
import 'package:t5/data/repositories/event_repository.dart';
import 'package:t5/data/repositories/notification_repository.dart';
import 'package:t5/data/repositories/participation_repository.dart';
import 'package:t5/data/repositories/user_repository.dart';

class AppNotificationViewModel extends ChangeNotifier {
  final NotificationRepository _notificationRepository;
  final ParticipationRepository _participationRepository;
  final EventRepository _eventRepository;
  final UserRepository _userRepository;

  AppNotificationViewModel(
    this._notificationRepository,
    this._participationRepository,
    this._eventRepository,
    this._userRepository,
  );

  Future<void> createUpComingEventNotification(
    Event event,
    String userId,
  ) async {
    //use firebase user to know wich collection is
    DateTime createdAt = DateTime.now();

    final difference = event.startDate.difference(createdAt);
    final hoursLeft = difference.inHours;

    final notification = AppNotification(
      id: '', //automaticly generated
      title: 'Upcoming Event!',
      body: 'The event "${event.title}" starts in $hoursLeft hours.',
      createdAt: createdAt,
      seen: false,
      type: 'upcoming_event',
      eventId: event.id,
    );

    await _notificationRepository.createNotification(
      uid: userId,
      notification: notification,
    );
  }

  //very inneficient since the events and the participations are in 2 different collections ://
  Future<void> checkUpcomingEvents(String userId) async {
    //get all user participations
    List<Participation> participations = await _participationRepository
        .getParticipationsByUser(userId);
    //get all the events through the participations
    for (Participation p in participations) {
      Event currEvent = await _eventRepository.getEventById(p.idEvent);

      final difference = currEvent.startDate.difference(DateTime.now());

      if (difference.inHours <= 48 && difference.inHours > 0) {
        //need to check if the notification wasnt already created!!
        bool exists = await _notificationRepository.notificationAlreadyExists(
          uid: userId,
          eventId: currEvent.id,
        );

        if (!exists) {
          await createUpComingEventNotification(currEvent, userId);
        }
      }
    }
  }

  Stream<List<AppNotification>> getNotifications(String userId) {
    return _notificationRepository.listenUserNotifications(userId);
  }

  Future<void> markAsSeen(AppNotification notification, String userId) async {
    final updated = AppNotification(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      createdAt: notification.createdAt,
      seen: true,
      type: notification.type,
      eventId: notification.eventId,
    );

    await _notificationRepository.updateNotification(userId, updated);
  }

  Future<void> createNewEventNotification(Event event) async {
    //sends notification to all the users, except the one who created the event
    String idCreator = event.idCreator;
    final creator = await _userRepository.getUser(idCreator);
    final allUsers = await _userRepository.getAllUsers();

    for (Users? u in allUsers) {
      if (u == null)
        continue; //model doesnt have access to uid, just do email, its is unique too so it works
      if (u.uid == creator!.uid) continue;

      AppNotification notification = createNewEventNotificationTemplate(
        creator,
        event,
      );
      await _notificationRepository.createNotification(
        uid: u.uid,
        notification: notification,
      ); //need to add uid later to user model
    }
  }

  AppNotification createNewEventNotificationTemplate(
    Users creator,
    Event event,
  ) {
    final createdAt = DateTime.now();

    return AppNotification(
      id: '',
      //receiverId: '',
      title: 'New Event Available!',
      body: '${creator.name} created "${event.title}".',
      createdAt: createdAt,
      seen: false,
      type: 'new_event',
      eventId: event.id,
    );
  }
}
