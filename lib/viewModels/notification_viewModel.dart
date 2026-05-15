
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:t5/data/models/event.dart';
import 'package:t5/data/models/notification.dart';
import 'package:t5/data/models/participation.dart';
import 'package:t5/data/repositories/event_repository.dart';
import 'package:t5/data/repositories/notification_repository.dart';
import 'package:t5/data/repositories/participation_repository.dart';

class AppNotificationViewModel extends ChangeNotifier{
  final NotificationRepository _notificationRepository;
  final ParticipationRepository _participationRepository;
  final EventRepository _eventRepository;
  //final User _firebaseUser;

  //use dependency injection for later tests
  AppNotificationViewModel(this._notificationRepository, this._participationRepository, this._eventRepository);
  User? get _firebaseUser => FirebaseAuth.instance.currentUser;

  Future<void> createUpComingEventNotification(Event event) async{    
    //use firebase user to know wich collection is
    String receiverId =_firebaseUser!.uid;
    DateTime createdAt = DateTime.now();

    final difference = event.startDate.difference(createdAt);
    final hoursLeft = difference.inHours;

    final notification = AppNotification(
      id: '', //automaticly generated
      receiverId: receiverId,
      title: 'Upcoming Event!',
      body:
          'The event "${event.title}" starts in $hoursLeft hours.',
      createdAt: createdAt,
      seen: false,
      eventId: event.id,
    );

    await _notificationRepository.createNotification(uid: _firebaseUser!.uid, notification: notification);

  }

  //very inneficient since the events and the participations are in 2 different collections :// 
  Future<void> checkUpcomingEvents() async{
    //get all user participations
    List<Participation> participations = await _participationRepository.getParticipationsByUser(_firebaseUser!.uid);
    //get all the events through the participations
    for(Participation p in participations){
      Event currEvent = await _eventRepository.getEventById(p.idEvent);
      
      final difference = currEvent.startDate.difference(DateTime.now());

      if(difference.inHours <= 48 && difference.inHours > 0){
        //need to check if the notification wasnt already created!!
        bool exists = await _notificationRepository.notificationAlreadyExists(uid: _firebaseUser!.uid,eventId: currEvent.id,);

        if (!exists) {
          await createUpComingEventNotification(currEvent);
        }
      }
    }

  }

  Stream<List<AppNotification>> getNotifications() {

  return _notificationRepository
      .listenUserNotifications(_firebaseUser!.uid);
  }

  Future<void> markAsSeen(AppNotification notification) async {

    final updated = AppNotification(
      id: notification.id,
      receiverId: notification.receiverId,
      title: notification.title,
      body: notification.body,
      createdAt: notification.createdAt,
      seen: true,
      eventId: notification.eventId,
    );

    await _notificationRepository.updateNotification( _firebaseUser!.uid, updated);

  }



}