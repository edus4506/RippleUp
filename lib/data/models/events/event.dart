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
  final String idCreator;
  final String country;
  final String district;
  final String city;
  final List<int> objectives;
  final List<String> imageUrls;
  final String? coverImageUrl;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.startDate,
    required this.endDate,
    required this.maxUsers,
    required this.currentUsers,
    required this.idCreator,
    required this.country,
    required this.district,
    required this.city,
    required this.objectives,
    required this.imageUrls,
    this.coverImageUrl,
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
      idCreator: map['idCreator'] ?? '',
      country: map['country'] ?? '',
      district: map['district'] ?? '',
      city: map['city'] ?? '',
      objectives: List<int>.from(map['objectives'] ?? []),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      coverImageUrl: map['coverImageUrl'],
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
      'idCreator': idCreator,
      'country': country,
      'district': district,
      'city': city,
      'objectives': objectives,
      'imageUrls': imageUrls,
      'coverImageUrl': coverImageUrl,
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
