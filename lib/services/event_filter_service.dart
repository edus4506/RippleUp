import 'package:t5/data/models/event.dart';
import 'package:t5/data/models/event_status.dart';
import 'event_filter.dart';

class EventFilterService {
  static List<Event> apply(List<Event> events, EventFilter filter) {
    return events.where((event) {
      if (filter.hideFull && event.currentUsers >= event.maxUsers) {
        return false;
      }

      if (!filter.showDone && event.status == EventStatus.done) {
        return false;
      }

      if (filter.goals.isNotEmpty) {
        final hasMatch = event.objectives.any(
          (goal) => filter.goals.contains(goal),
        );
        if (!hasMatch) return false;
      }

      if (filter.minCapacity != null && event.maxUsers < filter.minCapacity!) {
        return false;
      }

      if (filter.maxCapacity != null && event.maxUsers > filter.maxCapacity!) {
        return false;
      }

      if (filter.minCurrentUsers != null &&
          event.currentUsers < filter.minCurrentUsers!) {
        return false;
      }

      if (filter.maxCurrentUsers != null &&
          event.currentUsers > filter.maxCurrentUsers!) {
        return false;
      }

      if (filter.country != null && event.country != filter.country) {
        return false;
      }

      if (filter.district != null && event.district != filter.district) {
        return false;
      }

      if (filter.city != null && event.city != filter.city) {
        return false;
      }

      return true;
    }).toList();
  }
}
