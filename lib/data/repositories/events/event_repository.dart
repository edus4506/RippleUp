import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/events/event.dart';
import '../../models/events/event_status.dart';

const int kEventsPageSize = 7;

class EventRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createEvent(Event event) async {
    final eventRef = _db.collection('events').doc();
    final participationRef = _db
        .collection('participations')
        .doc('${eventRef.id}_${event.idCreator}');

    final batch = _db.batch();

    batch.set(eventRef, {...event.toMap(), 'currentUsers': 1});

    batch.set(participationRef, {
      'idUser': event.idCreator,
      'idEvent': eventRef.id,
    });

    await batch.commit();
  }

  // ─── PAGINAÇÃO ───────────────────────────────────────────────────────────────

  /// Devolve [kEventsPageSize] eventos a partir do cursor [startAfter].
  /// Se [startAfter] for null começa do início.
  /// Devolve também o último documento para usar como cursor na próxima página.
  Future<({List<Event> events, DocumentSnapshot? lastDoc, bool hasMore})>
      fetchEventsPaged({DocumentSnapshot? startAfter}) async {
    Query query = _db
        .collection('events')
        .orderBy('createdAt', descending: true)
        .limit(kEventsPageSize + 1); // +1 para saber se há mais

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final docs = snapshot.docs;

    final hasMore = docs.length > kEventsPageSize;
    final pageDocs = hasMore ? docs.sublist(0, kEventsPageSize) : docs;

    final events = pageDocs
        .map((doc) => Event.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    final lastDoc = pageDocs.isNotEmpty ? pageDocs.last : null;

    return (events: events, lastDoc: lastDoc, hasMore: hasMore);
  }

  // ─── STREAM (mantida para outros usos internos) ───────────────────────────

  Stream<List<Event>> listenToEvents() {
    return _db
        .collection('events')
        .snapshots()
        .map(
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
    final participationRef = _db
        .collection('participations')
        .doc('${eventId}_$userId');

    await _db.runTransaction((transaction) async {
      final eventSnap = await transaction.get(eventRef);
      final participationSnap = await transaction.get(participationRef);

      if (!eventSnap.exists) {
        throw Exception('Event not found');
      }

      final data = eventSnap.data()!;
      final event = Event.fromMap(data, eventSnap.id);

      if (event.status == EventStatus.occurring ||
          event.status == EventStatus.done) {
        throw Exception(
          'Cannot join an event that is already ongoing or finished',
        );
      }

      if (participationSnap.exists) {
        throw Exception('You are already participating in this event');
      }

      final currentUsers = data['currentUsers'] ?? 0;
      final maxUsers = data['maxUsers'] ?? 0;

      if (currentUsers >= maxUsers) {
        throw Exception('Event is full');
      }

      transaction.set(participationRef, {'idUser': userId, 'idEvent': eventId});

      transaction.update(eventRef, {'currentUsers': currentUsers + 1});
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

  /// Stream limitado para a página de pesquisa — evita carregar tudo.
  Stream<List<Event>> listenToRecentEvents({int limit = 50}) {
    return _db
        .collection('events')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Event.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> leaveEvent({
    required String eventId,
    required String userId,
  }) async {
    final eventRef = _db.collection('events').doc(eventId);
    final participationRef = _db
        .collection('participations')
        .doc('${eventId}_$userId');

    await _db.runTransaction((transaction) async {
      final eventSnap = await transaction.get(eventRef);
      final participationSnap = await transaction.get(participationRef);

      if (!eventSnap.exists) {
        throw Exception('Event not found');
      }

      final event = Event.fromMap(eventSnap.data()!, eventSnap.id);

      if (event.status == EventStatus.occurring ||
          event.status == EventStatus.done) {
        throw Exception(
          'Cannot leave an event that is already ongoing or finished',
        );
      }

      if (!participationSnap.exists) {
        throw Exception('You are not participating in this event');
      }

      final currentUsers = eventSnap.data()!['currentUsers'] ?? 0;

      transaction.delete(participationRef);

      transaction.update(eventRef, {
        'currentUsers': (currentUsers > 0) ? currentUsers - 1 : 0,
      });
    });
  }

  Future<void> deleteEvent(String eventId) async {
    final eventRef = _db.collection('events').doc(eventId);

    final eventSnap = await eventRef.get();

    if (!eventSnap.exists) {
      throw Exception('Event not found');
    }

    final event = Event.fromMap(eventSnap.data()!, eventSnap.id);

    if (event.status == EventStatus.occurring ||
        event.status == EventStatus.done) {
      throw Exception(
        'Cannot delete an event that is already ongoing or finished',
      );
    }

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

  Future<Event> getEventById(String eventId) async {
    final doc = await _db.collection('events').doc(eventId).get();

    if (!doc.exists) {
      throw Exception('Event not found');
    }

    return Event.fromMap(doc.data()!, doc.id);
  }

  Future<List<Event>> getCreatedEventsByUser(String uid) async {
    final snapshot = await _db
        .collection('events')
        .where('idCreator', isEqualTo: uid)
        .get();

    return snapshot.docs
        .map((doc) => Event.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<Event>> getJoinedEventsByUser(String uid) async {
    final participationsSnapshot = await _db
        .collection('participations')
        .where('idUser', isEqualTo: uid)
        .get();

    if (participationsSnapshot.docs.isEmpty) return [];

    final eventIds = participationsSnapshot.docs
        .map((doc) => doc.data()['idEvent'] as String)
        .toList();

    final List<Event> events = [];

    for (int i = 0; i < eventIds.length; i += 10) {
      final batch = eventIds.sublist(
        i,
        (i + 10 > eventIds.length) ? eventIds.length : i + 10,
      );

      final eventsSnapshot = await _db
          .collection('events')
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      events.addAll(
        eventsSnapshot.docs
            .map((doc) => Event.fromMap(doc.data(), doc.id))
            .toList(),
      );
    }
    return events;
  }

  // =========================
  // UPDATE EVENT
  // =========================

  /// Updates the editable fields of an existing event.
  /// Only the event owner should call this (enforced also in the UI layer).
  Future<void> updateEvent(Event event) async {
    final eventRef = _db.collection('events').doc(event.id);

    final eventSnap = await eventRef.get();

    if (!eventSnap.exists) {
      throw Exception('Event not found');
    }

    final existing = Event.fromMap(eventSnap.data()!, eventSnap.id);

    if (existing.status == EventStatus.occurring ||
        existing.status == EventStatus.done) {
      throw Exception(
        'Cannot edit an event that is already ongoing or finished',
      );
    }

    await eventRef.update({
      'title': event.title,
      'description': event.description,
      'startDate': Timestamp.fromDate(event.startDate),
      'endDate': Timestamp.fromDate(event.endDate),
      'maxUsers': event.maxUsers,
      'country': event.country,
      'district': event.district,
      'city': event.city,
      'objectives': event.objectives,
      'imageUrls': event.imageUrls,
      'coverImageUrl': event.coverImageUrl,
    });
  }
}
