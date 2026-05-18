import 'package:t5/data/models/user.dart';

class UserSearchService {
  // O(n * m)
  // Searches and ranks users using exact, partial,
  // prefix, and fuzzy matching.
  static List<Users> search(
    List<Users> users,
    String query,
  ) {
    final normalizedQuery = query.toLowerCase().trim();

    if (normalizedQuery.isEmpty) {
      return users;
    }

    final scoredUsers = users
        .map(
          (user) => _ScoredUser(
            user: user,
            score: _calculateScore(
              user,
              normalizedQuery,
            ),
          ),
        )
        .where(
          (scoredUser) => scoredUser.score > 0,
        )
        .toList();

    scoredUsers.sort(
      (a, b) => b.score.compareTo(a.score),
    );

    return scoredUsers
        .map((scoredUser) => scoredUser.user)
        .toList();
  }

  // O(f)
  // Calculates the relevance score of a user
  // based on searchable fields.
  static int _calculateScore(
    Users user,
    String query,
  ) {
    int score = 0;

    final name = user.name.toLowerCase();
    final email = user.email.toLowerCase();

    score += _scoreField(
      name,
      query,
      exactWeight: 140,
      containsWeight: 120,
    );

    score += _scoreField(
      email,
      query,
      exactWeight: 90,
      containsWeight: 70,
    );

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

    final words = field.split(
      RegExp(r'\s+'),
    );

    for (final word in words) {
      if (word.isEmpty) continue;

      if (word.startsWith(query)) {
        return containsWeight + 20;
      }

      final distance = _levenshteinDistance(
        query,
        word,
      );

      if (word.length > 4 && distance <= 2) {
        return 20;
      }
    }

    return 0;
  }

  // O(a * b)
  // Computes the Levenshtein distance between
  // two strings for fuzzy search matching.
  static int _levenshteinDistance(
    String s1,
    String s2,
  ) {
    final dp = List.generate(
      s1.length + 1,
      (_) => List.filled(
        s2.length + 1,
        0,
      ),
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
              ].reduce(
                (a, b) => a < b ? a : b,
              );
        }
      }
    }

    return dp[s1.length][s2.length];
  }
}

class _ScoredUser {
  final Users user;
  final int score;

  const _ScoredUser({
    required this.user,
    required this.score,
  });
}