import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/participation.dart';

class ParticipationRepository {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Stream<List<Participation>> listenToUserParticipations(String userId) {
    return _db
        .collection('participations')
        .where('idUser', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Participation.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<bool> hasUserParticipated(String userId, String eventId) async {
    final snapshot = await _db
        .collection('participations')
        .where('idUser', isEqualTo: userId)
        .where('idEvent', isEqualTo: eventId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<List<Participation>> getParticipationsByUser(String userId) async {
    final snapshot = await _db
        .collection('participations')
        .where('idUser', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => Participation.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<Participation>> getParticipationsByEvent(String idEvent) async {
    final snapshot = await _db
        .collection('participations')
        .where('idEvent', isEqualTo: idEvent)
        .get();

    return snapshot.docs
        .map((doc) => Participation.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<Participation>> listenToEventParticipations(String eventId) {
    return _db
        .collection('participations')
        .where('idEvent', isEqualTo: eventId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Participation.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
