import 'package:cloud_firestore/cloud_firestore.dart';

class Event {         //since an event can have multiple enviroment goals, a model EventEnvGoal was created. it has idEvent -> idEnvGoal
  final String id;
  //final String idEnvGoal; //will be acced through event_envGoals
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final int maxUsers;
  final int currentUsers;
  final String eventStatus;
  final String idCreator;
  final String country;
  final String district;
  final String city;
  final List<int> objectives;

  Event({
    required this.id,
    //required this.idEnvGoal,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.maxUsers,
    required this.currentUsers,
    required this.eventStatus,
    required this.idCreator,
    required this.country,
    required this.district,
    required this.city,
    required this.objectives,
  });

  factory Event.fromMap(Map<String, dynamic> map, String documentId) {
    return Event(
      id: documentId,
      //idEnvGoal: map['idEnvGoal'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      maxUsers: map['maxUsers'] ?? 0,
      currentUsers: map['currentUsers'] ?? 0,
      eventStatus: map['eventStatus'] ?? 'PLANNING',
      idCreator: map['idCreator'] ?? '',
      country: map['country'] ?? '',
      district: map['district'] ?? '',
      city: map['city'] ?? '',
      objectives: List<int>.from(map['objectives'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      //'idEnvGoal': idEnvGoal,
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'maxUsers': maxUsers,
      'currentUsers': currentUsers,
      'eventStatus': eventStatus,
      'idCreator': idCreator,
      'country': country,
      'district': district,
      'city': city,
      'objectives': objectives,
    };
  }
}