


import 'dart:nativewrappers/_internal/vm/lib/ffi_native_type_patch.dart';

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
  final User _firebaseUser;

  //use dependency injection for later tests
  AppNotificationViewModel(this._notificationRepository, this._firebaseUser, this._participationRepository, this._eventRepository);

  Future<void> createUpComingEventNotification(Event event) async{    
    //use firebase user to know wich collection is
    String receiverId =_firebaseUser.uid;
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

    await _notificationRepository.createNotification(uid: _firebaseUser.uid, notification: notification);

  }

  //very inneficient since the events and the participations are in 2 different collections :// 
  Future<void> checkUpcomingEvents() async{
    //get all user participations
    List<Participation> participations = await _participationRepository.getParticipationsByUser(_firebaseUser.uid);
    //get all the events through the participations
    for(Participation p in participations){
      Event currEvent = await _eventRepository.getEventById(p.idEvent);
      
      final difference = currEvent.startDate.difference(DateTime.now());

      if(difference.inHours <= 24 && difference.inHours > 0){
        //need to check if the notification wasnt already created!!
        await createUpComingEventNotification(currEvent);
      }
    }

  }

  Stream<List<AppNotification>> getNotifications() {

  return _notificationRepository
      .listenUserNotifications(_firebaseUser.uid);
  }



}