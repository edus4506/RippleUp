import 'package:t5/data/models/event.dart';

class EventSearchService {
  static List<Event> search(
    List<Event> events,
    String query,
  ) {
    if (query.trim().isEmpty) {
      return events;
    }

    final normalizedQuery = query.toLowerCase().trim();

    return events.where((event) {
      final searchableText = [
        event.title,
        event.description,
        event.city,
        event.district,
      ].join(' ').toLowerCase();

      // Exact/contains match
      if (searchableText.contains(normalizedQuery)) {
        return true;
      }

      // Fuzzy match
      final words = searchableText.split(' ');

      for (final word in words) {
        final distance = _levenshteinDistance(
          normalizedQuery,
          word,
        );

        if (distance <= 2) {
          return true;
        }
      }

      return false;
    }).toList();
  }

  static int _levenshteinDistance(String s1, String s2) {
    List<List<int>> dp = List.generate(
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
          dp[i][j] = 1 +
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
