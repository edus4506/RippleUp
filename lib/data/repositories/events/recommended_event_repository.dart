import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:t5/data/models/events/event.dart';
import 'package:t5/data/models/social/user.dart';

class RecommendedEventRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Users?> getRandomUser(String currentUserId) async {
    try {
      final snapshot = await _db.collection('users').get();

      if (snapshot.docs.isEmpty) return null;

      final otherUsers = snapshot.docs
          .where((doc) => doc.id != currentUserId)
          .toList();

      if (otherUsers.isEmpty) return null;

      otherUsers.shuffle();
      final randomUserDoc = otherUsers.first;

      return Users.fromMap(
        randomUserDoc.data() as Map<String, dynamic>,
        randomUserDoc.id,
      );
    } catch (e) {
      print('Error getting random user: $e');
      return null;
    }
  }

  Future<List<Event>> getRecentEventsByUser(
    String userId, {
    int limit = 5,
  }) async {
    try {
      final participationsSnapshot = await _db
          .collection('participations')
          .where('idUser', isEqualTo: userId)
          .get();

      if (participationsSnapshot.docs.isEmpty) return [];

      final eventIds = participationsSnapshot.docs
          .map((doc) => doc.data()['idEvent'] as String)
          .toList();

      if (eventIds.isEmpty) return [];

      final List<Event> events = [];
      for (int i = 0; i < eventIds.length; i += 10) {
        final batch = eventIds.sublist(
          i,
          (i + 10 > eventIds.length) ? eventIds.length : i + 10,
        );

        final eventsSnapshot = await _db
            .collection('events')
            .where(FieldPath.documentId, whereIn: batch)
            .orderBy('createdAt', descending: true)
            .get();

        events.addAll(
          eventsSnapshot.docs
              .map((doc) => Event.fromMap(doc.data(), doc.id))
              .toList(),
        );
      }

      final filteredEvents = events
          .where(
            (event) =>
                event.status.name != 'done' && event.status.name != 'occurring',
          )
          .toList();

      filteredEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return filteredEvents.take(limit).toList();
    } catch (e) {
      print('Error getting recent events by user: $e');
      return [];
    }
  }

  Future<Set<String>> getUserParticipatedEventIds(String userId) async {
    try {
      final snapshot = await _db
          .collection('participations')
          .where('idUser', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['idEvent'] as String)
          .toSet();
    } catch (e) {
      print('Error getting user participated events: $e');
      return {};
    }
  }

  Future<List<Event>> getRecommendedEvents({
    required String currentUserId,
    int limit = 10,
    int maxAttempts = 3,
  }) async {
    try {
      final currentUserEventIds = await getUserParticipatedEventIds(
        currentUserId,
      );

      for (int attempt = 0; attempt < maxAttempts; attempt++) {
        final randomUser = await getRandomUser(currentUserId);

        if (randomUser == null) {
          print('No random user found on attempt $attempt');
          continue;
        }

        final recentEvents = await getRecentEventsByUser(
          randomUser.uid,
          limit: limit * 2,
        );

        final recommendedEvents = recentEvents
            .where((event) => !currentUserEventIds.contains(event.id))
            .take(limit)
            .toList();

        if (recommendedEvents.isNotEmpty) {
          print(
            'Found ${recommendedEvents.length} recommended events from user ${randomUser.uid}',
          );
          return recommendedEvents;
        }

        print(
          'User ${randomUser.profilePictureUrl} has no new events, trying next...',
        );
      }

      print('Could not find recommended events after $maxAttempts attempts');
      return [];
    } catch (e) {
      print('Error getting recommended events: $e');
      return [];
    }
  }
}
