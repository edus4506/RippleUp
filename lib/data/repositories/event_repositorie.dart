import '../models/event.dart';
import 'mock_events.dart';

class EventRepository {
  List<Event> getAllEvents() {
    return List<Event>.from(mockEvents);
  }
}