import 'package:flutter/material.dart';
import 'package:t5/data/models/event.dart';
import 'package:t5/data/repositories/event_repository.dart';

class EventViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;

  EventViewModel(this._eventRepository);

  bool isLoading = false;
  String? errorMessage;

  Stream<List<Event>> get eventsStream => _eventRepository.listenToEvents();

  bool hideFullEvents = false;
  Set<int> selectedGoals = {};

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

  Future<bool> leaveEvent({
    required String eventId,
    required String userId,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _eventRepository.leaveEvent(
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

  Stream<bool> isUserInEvent({
    required String eventId,
    required String userId,
  }) {
    return _eventRepository.isUserInEvent(
      eventId: eventId,
      userId: userId,
    );
  }

  Future<bool> deleteEvent(String eventId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _eventRepository.deleteEvent(eventId);

      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<Event>> get filteredEventsStream {
    return _eventRepository.listenToEvents().map((events) {
      return events.where((event) {
        if (hideFullEvents &&
            event.currentUsers >= event.maxUsers) {
          return false;
        }

        if (selectedGoals.isNotEmpty) {
          final eventGoals = event.objectives; 

          final hasMatch = eventGoals.any((goal) =>
              selectedGoals.contains(goal));

          if (!hasMatch) return false;
        }

        return true;
      }).toList();
    });
  }

  void applyFilters({
    required bool hideFull,
    required Set<int> goals,
  }) {
    hideFullEvents = hideFull;
    selectedGoals = goals;
    notifyListeners();
  }
}