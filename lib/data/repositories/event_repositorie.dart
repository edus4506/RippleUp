import 'mock_events.dart';
import '../models/event.dart';

class EventRepository {
  List<Event> getAllEvents() {
    return mockEvents;
  }
}