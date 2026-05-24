import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:t5/data/models/events/event.dart';
import 'package:t5/data/models/social/user.dart';

class RecommendedEventRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Busca um user aleatório (excluindo o current user)
  /// Retorna null se não houver outros users
  Future<Users?> getRandomUser(String currentUserId) async {
    try {
      final snapshot = await _db.collection('users').get();
      
      if (snapshot.docs.isEmpty) return null;

      // Filtra para remover o current user
      final otherUsers = snapshot.docs
          .where((doc) => doc.id != currentUserId)
          .toList();

      if (otherUsers.isEmpty) return null;

      // Pick aleatório
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

  /// Busca eventos recentes em que um user participou
  /// [limit] = quantos eventos retornar (default 5)
  Future<List<Event>> getRecentEventsByUser(
    String userId, {
    int limit = 5,
  }) async {
    try {
      // Step 1: Busca participações do user
      final participationsSnapshot = await _db
          .collection('participations')
          .where('idUser', isEqualTo: userId)
          .get();

      if (participationsSnapshot.docs.isEmpty) return [];

      // Step 2: Extract event IDs
      final eventIds = participationsSnapshot.docs
          .map((doc) => doc.data()['idEvent'] as String)
          .toList();

      if (eventIds.isEmpty) return [];

      // Step 3: Busca event details em batches (Firestore limit = 10 per query)
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

      // Step 4: Filtra eventos 'done' e 'occurring'
      final filteredEvents = events
          .where((event) =>
              event.status.name != 'done' && event.status.name != 'occurring')
          .toList();

      // Step 5: Sort by creation date (most recent first) e limita
      filteredEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return filteredEvents.take(limit).toList();
    } catch (e) {
      print('Error getting recent events by user: $e');
      return [];
    }
  }

  /// Busca event IDs em que um user participou
  /// Usado para filtrar eventos que já participei
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

  /// Busca eventos recomendados baseado em um user aleatório
  /// Tenta até [maxAttempts] users aleatórios até encontrar eventos
  /// Filtra eventos que o current user já participou
  Future<List<Event>> getRecommendedEvents({
    required String currentUserId,
    int limit = 10,
    int maxAttempts = 3,
  }) async {
    try {
      // Busca eventos que current user já participou (para filtrar depois)
      final currentUserEventIds =
          await getUserParticipatedEventIds(currentUserId);

      // Tenta buscar eventos de users aleatórios
      for (int attempt = 0; attempt < maxAttempts; attempt++) {
        final randomUser = await getRandomUser(currentUserId);

        if (randomUser == null) {
          print('No random user found on attempt $attempt');
          continue;
        }

        final recentEvents = await getRecentEventsByUser(
          randomUser.uid,
          limit: limit * 2, // Busca mais para ter margem depois de filtrar
        );

        // Filtra eventos que current user já participou
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

        print('User ${randomUser.profilePictureUrl} has no new events, trying next...');
      }

      print('Could not find recommended events after $maxAttempts attempts');
      return [];
    } catch (e) {
      print('Error getting recommended events: $e');
      return [];
    }
  }
}