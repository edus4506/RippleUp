enum ReviewSortOption { mostRecent, oldest, highestRating, lowestRating }

extension ReviewSortOptionExtension on ReviewSortOption {
  String get label {
    switch (this) {
      case ReviewSortOption.mostRecent:
        return 'Most Recent';
      case ReviewSortOption.oldest:
        return 'Oldest';
      case ReviewSortOption.highestRating:
        return 'Highest Rating';
      case ReviewSortOption.lowestRating:
        return 'Lowest Rating';
    }
  }
}