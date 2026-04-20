import 'package:cloud_firestore/cloud_firestore.dart';
import 'event_status.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
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
    required this.title,
    required this.description,
    required this.createdAt,
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
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      startDate: map['startDate'] != null
          ? (map['startDate'] as Timestamp).toDate()
          : DateTime.now(),
      endDate: map['endDate'] != null
          ? (map['endDate'] as Timestamp).toDate()
          : DateTime.now(),
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
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
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

  EventStatus get status {
    final now = DateTime.now();

    if (now.isBefore(startDate)) {
      return EventStatus.planning;
    } else if (now.isAfter(endDate)) {
      return EventStatus.done;
    } else {
      return EventStatus.occurring;
    }
  }
}