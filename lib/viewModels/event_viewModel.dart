import 'package:flutter/material.dart';
import '../data/models/event.dart';
import '../data/repositories/event_repository.dart';

class EventViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;

  EventViewModel(this._eventRepository);

  Stream<List<Event>> get eventsStream => _eventRepository.listenToEvents();

  Future<void> createEvent(Event event) async {
    await _eventRepository.createEvent(event);
  }
}

