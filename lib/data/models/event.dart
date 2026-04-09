import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String idEnvGoal;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final int maxUsers;
  final String eventStatus;
  final String idLocation;
  final String idCreator;

  Event({
    required this.id,
    required this.idEnvGoal,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.maxUsers,
    required this.eventStatus,
    required this.idLocation,
    required this.idCreator,
  });

  factory Event.fromMap(Map<String, dynamic> map, String documentId) {
    return Event(
      id: documentId,
      idEnvGoal: map['idEnvGoal'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      maxUsers: map['maxUsers'] ?? 0,
      eventStatus: map['eventStatus'] ?? 'PLANNING',
      idLocation: map['idLocation'] ?? '',
      idCreator: map['idCreator'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idEnvGoal': idEnvGoal,
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'maxUsers': maxUsers,
      'eventStatus': eventStatus,
      'idLocation': idLocation,
      'idCreator': idCreator,
    };
  }
}