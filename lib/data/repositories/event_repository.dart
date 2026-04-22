import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createEvent(Event event) async {
    final eventRef = _db.collection('events').doc();
    final participationRef =
        _db.collection('participations').doc('${eventRef.id}_${event.idCreator}');

    final batch = _db.batch();

    batch.set(eventRef, {
      ...event.toMap(),
      'currentUsers': 1,
    });

    batch.set(participationRef, {
      'idUser': event.idCreator,
      'idEvent': eventRef.id,
    });

    await batch.commit();
  }

  Stream<List<Event>> listenToEvents() {
    return _db.collection('events').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Event.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> joinEvent({
    required String eventId,
    required String userId,
  }) async {
    final eventRef = _db.collection('events').doc(eventId);
    final participationRef =
        _db.collection('participations').doc('${eventId}_$userId');

    await _db.runTransaction((transaction) async {
      final eventSnap = await transaction.get(eventRef);
      final participationSnap = await transaction.get(participationRef);

      if (!eventSnap.exists) {
        throw Exception('Event not found');
      }

      if (participationSnap.exists) {
        throw Exception('You are already participating in this event');
      }

      final data = eventSnap.data()!;
      final currentUsers = data['currentUsers'] ?? 0;
      final maxUsers = data['maxUsers'] ?? 0;

      if (currentUsers >= maxUsers) {
        throw Exception('Event is full');
      }

      transaction.set(participationRef, {
        'idUser': userId,
        'idEvent': eventId,
      });

      transaction.update(eventRef, {
        'currentUsers': currentUsers + 1,
      });
    });
  }

  Stream<bool> isUserInEvent({
    required String eventId,
    required String userId,
  }) {
    return _db
        .collection('participations')
        .doc('${eventId}_$userId')
        .snapshots()
        .map((doc) => doc.exists);
  }

  Future<void> leaveEvent({
    required String eventId,
    required String userId,
  }) async {
    final eventRef = _db.collection('events').doc(eventId);
    final participationRef =
        _db.collection('participations').doc('${eventId}_$userId');

    await _db.runTransaction((transaction) async {
      final eventSnap = await transaction.get(eventRef);
      final participationSnap = await transaction.get(participationRef);

      if (!eventSnap.exists) {
        throw Exception('Event not found');
      }

      if (!participationSnap.exists) {
        throw Exception('You are not participating in this event');
      }

      final data = eventSnap.data()!;
      final currentUsers = data['currentUsers'] ?? 0;

      transaction.delete(participationRef);

      transaction.update(eventRef, {
        'currentUsers': (currentUsers > 0) ? currentUsers - 1 : 0,
      });
    });
  }

  Future<void> deleteEvent(String eventId) async {
    final eventRef = _db.collection('events').doc(eventId);

    final participations = await _db
        .collection('participations')
        .where('idEvent', isEqualTo: eventId)
        .get();

    final batch = _db.batch();

    for (var doc in participations.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(eventRef);

    await batch.commit();
  }
}