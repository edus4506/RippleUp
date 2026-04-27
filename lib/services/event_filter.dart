class EventFilter {
  final bool hideFull;
  final bool showDone;
  final Set<int> goals;

  final int? minCapacity;
  final int? maxCapacity;

  final int? minCurrentUsers;
  final int? maxCurrentUsers;

  final String? country;
  final String? district;
  final String? city;

  const EventFilter({
    this.hideFull = false,
    this.showDone = false,
    this.goals = const {},
    this.minCapacity,
    this.maxCapacity,
    this.minCurrentUsers,
    this.maxCurrentUsers,
    this.country,
    this.district,
    this.city,
  });
}
