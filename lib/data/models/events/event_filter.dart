class EventFilter {
  final bool hideFull;
  final bool showDone;
  final bool canJoin;

  final String? excludeCreatedBy;

  final Set<int> goals;

  final int? minCapacity;
  final int? maxCapacity;

  final int? minCurrentUsers;
  final int? maxCurrentUsers;

  final String? country;
  final String? district;
  final String? city;

  final DateTime? startDate;
  final DateTime? endDate;

  const EventFilter({
    this.hideFull = false,
    this.showDone = false,
    this.canJoin = false,
    this.excludeCreatedBy,
    this.goals = const {},
    this.minCapacity,
    this.maxCapacity,
    this.minCurrentUsers,
    this.maxCurrentUsers,
    this.country,
    this.district,
    this.city,
    this.startDate,
    this.endDate,
  });
}
