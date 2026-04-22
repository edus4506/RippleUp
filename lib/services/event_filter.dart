class EventFilter {
  final bool hideFull;
  final Set<int> goals;

  final int? minCapacity;
  final int? maxCapacity;

  final int? minCurrentUsers;
  final int? maxCurrentUsers;

  final String? country;
  final String? district;
  final String? city;

  const EventFilter({
    required this.hideFull,
    required this.goals,
    this.minCapacity,
    this.maxCapacity,
    this.minCurrentUsers,
    this.maxCurrentUsers,
    this.country,
    this.district,
    this.city,
  });
}