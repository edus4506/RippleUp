import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createEvent(Event event) async {
    await _db.collection('events').add(event.toMap());
  }

  Stream<List<Event>> listenToEvents() {
    return _db.collection('events').snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => Event.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }
}