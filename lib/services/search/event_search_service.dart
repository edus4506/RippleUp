import 'package:t5/data/models/events/event.dart';

class EventSearchService {
  // O(n * m)
  // Searches and ranks events using exact, partial, prefix,
  // and fuzzy matching based on Levenshtein distance.
  static List<Event> search(List<Event> events, String query) {
    final normalizedQuery = query.toLowerCase().trim();

    if (normalizedQuery.isEmpty) {
      return events;
    }

    final scoredEvents = events
        .map(
          (event) => _ScoredEvent(
            event: event,
            score: _calculateScore(event, normalizedQuery),
          ),
        )
        .where((scoredEvent) => scoredEvent.score > 0)
        .toList();

    scoredEvents.sort((a, b) => b.score.compareTo(a.score));

    return scoredEvents.map((scoredEvent) => scoredEvent.event).toList();
  }

  // O(f)
  // Calculates the relevance score of an event
  // based on multiple searchable fields.
  static int _calculateScore(Event event, String query) {
    int score = 0;

    final title = event.title.toLowerCase();
    final description = event.description.toLowerCase();
    final city = event.city.toLowerCase();
    final district = event.district.toLowerCase();
    final country = event.country.toLowerCase();

    score += _scoreField(title, query, exactWeight: 120, containsWeight: 100);

    score += _scoreField(
      description,
      query,
      exactWeight: 60,
      containsWeight: 40,
    );

    score += _scoreField(city, query, exactWeight: 80, containsWeight: 60);

    score += _scoreField(district, query, exactWeight: 70, containsWeight: 50);

    score += _scoreField(country, query, exactWeight: 50, containsWeight: 35);

    return score;
  }

  // O(w * l)
  // Scores a single text field using exact,
  // prefix, partial, and fuzzy matching.
  static int _scoreField(
    String field,
    String query, {
    required int exactWeight,
    required int containsWeight,
  }) {
    if (field.isEmpty) {
      return 0;
    }

    if (field == query) {
      return exactWeight;
    }

    if (field.startsWith(query)) {
      return containsWeight + 30;
    }

    if (field.contains(query)) {
      return containsWeight;
    }

    final words = field.split(RegExp(r'\s+'));

    for (final word in words) {
      if (word.isEmpty) continue;

      if (word.startsWith(query)) {
        return containsWeight + 20;
      }

      final distance = _levenshteinDistance(query, word);

      if (word.length > 4 && distance <= 2) {
        return 20;
      }
    }

    return 0;
  }

  // O(a * b)
  // Computes the Levenshtein distance between
  // two strings for fuzzy search matching.
  static int _levenshteinDistance(String s1, String s2) {
    final dp = List.generate(
      s1.length + 1,
      (_) => List.filled(s2.length + 1, 0),
    );

    for (int i = 0; i <= s1.length; i++) {
      dp[i][0] = i;
    }

    for (int j = 0; j <= s2.length; j++) {
      dp[0][j] = j;
    }

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        if (s1[i - 1] == s2[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] =
              1 +
              [
                dp[i - 1][j],
                dp[i][j - 1],
                dp[i - 1][j - 1],
              ].reduce((a, b) => a < b ? a : b);
        }
      }
    }

    return dp[s1.length][s2.length];
  }
}

class _ScoredEvent {
  final Event event;
  final int score;

  const _ScoredEvent({required this.event, required this.score});
}
