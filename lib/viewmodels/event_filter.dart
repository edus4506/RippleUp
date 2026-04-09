

/*

//probalby will change with the db now instead of using the mock data

import '../data/repositories/event_repositorie.dart';
import '../data/models/event.dart';

class EventFilter {
  final EventRepository repository;

  EventFilter(this.repository);

  List<Event> applyFilters({
    List<Event>? events,
    List<int> objectives = const [],
    String? country,
    String? district,
    String? city,
    int? minCurrentUsers,
    int? maxCurrentUsers,
    int? minMaxUsers,
    int? maxMaxUsers,
    bool showFullEvents = true,
  }) {
    final sourceEvents = events ?? repository.getAllEvents();

    return sourceEvents.where((event) {

      if (objectives.isNotEmpty) {
        final matches = event.objectives.any((obj) => objectives.contains(obj));
        if (!matches) return false;
      }

      if (country != null && event.country != country) return false;
      if (district != null && event.district != district) return false;
      if (city != null && event.city != city) return false;

      if (minCurrentUsers != null && event.currentUsers < minCurrentUsers) return false;
      if (maxCurrentUsers != null && event.currentUsers > maxCurrentUsers) return false;

      if (minMaxUsers != null && event.maxUsers < minMaxUsers) return false;
      if (maxMaxUsers != null && event.maxUsers > maxMaxUsers) return false;

      if (!showFullEvents && event.isFull) return false;

      return true;
    }).toList();
  }
}*/