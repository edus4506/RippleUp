import 'package:flutter/material.dart';
import 'package:t5/data/models/event.dart';
import 'package:t5/data/repositories/event_repository.dart';

class EventViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;

  EventViewModel(this._eventRepository);

  bool isLoading = false;
  String? errorMessage;

  Stream<List<Event>> get eventsStream => _eventRepository.listenToEvents();

  Future<void> createEvent(Event event) async {
    await _eventRepository.createEvent(event);
  }

  Future<bool> joinEvent({
    required String eventId,
    required String userId,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _eventRepository.joinEvent(
        eventId: eventId,
        userId: userId,
      );

      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}