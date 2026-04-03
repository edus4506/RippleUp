class Event {
  final int id;
  final String name;
  final String description;
  final int currentUsers;
  final int maxUsers;
  final List<int> objectives;
  final String country;
  final String district;
  final String city;

  const Event({
    required this.id,
    required this.name,
    required this.description,
    required this.currentUsers,
    required this.maxUsers,
    required this.objectives,
    required this.country,
    required this.district,
    required this.city,
  });

  bool get isFull => currentUsers >= maxUsers;
}