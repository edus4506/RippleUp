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
        throw Exception('Evento não encontrado');
      }

      if (participationSnap.exists) {
        throw Exception('Já participas neste evento');
      }

      final data = eventSnap.data()!;
      final currentUsers = data['currentUsers'] ?? 0;
      final maxUsers = data['maxUsers'] ?? 0;

      if (currentUsers >= maxUsers) {
        throw Exception('Evento cheio');
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
}