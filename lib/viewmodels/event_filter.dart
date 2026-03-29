import '../data/repositories/event_repositorie.dart';
import '../data/models/event.dart';

class EventFilter {
  final EventRepository repository;

  EventFilter(this.repository);

  List<Event> applyFilters({
    List<int> objectives = const [],
    String? country,
    String? district,
    String? city,
  }) {
    final events = repository.getAllEvents();

    return events.where((event) {
      // 🔹 OBJECTIVES (OR)
      if (objectives.isNotEmpty) {
        bool matches = event.objectives.any(
          (obj) => objectives.contains(obj),
        );
        if (!matches) return false;
      }

      // 🔹 COUNTRY
      if (country != null && event.country != country) {
        return false;
      }

      // 🔹 DISTRICT
      if (district != null && event.district != district) {
        return false;
      }

      // 🔹 CITY
      if (city != null && event.city != city) {
        return false;
      }

      return true;
    }).toList();
  }
}