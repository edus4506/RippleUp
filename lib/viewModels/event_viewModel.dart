import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:t5/data/models/event.dart';
import 'package:t5/data/repositories/event_repository.dart';
import 'package:t5/data/repositories/storage_repository.dart';

import 'package:t5/services/event_filter.dart';
import 'package:t5/services/event_filter_service.dart';

class EventViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;
  final StorageRepository _storageRepository;

  EventViewModel(this._eventRepository, this._storageRepository);

  bool isLoading = false;
  String? errorMessage;

  Stream<List<Event>> get eventsStream => _eventRepository.listenToEvents();

  EventFilter _filter = const EventFilter();

  EventFilter get currentFilter => _filter;

  Stream<List<Event>> get filteredEventsStream {
    return eventsStream.map((events) {
      return EventFilterService.apply(events, _filter);
    });
  }

  void applyFilters({
    required bool hideFull,
    required bool showDone,
    required Set<int> goals,
    int? minCapacity,
    int? maxCapacity,
    int? minCurrentUsers,
    int? maxCurrentUsers,
    String? country,
    String? district,
    String? city,
  }) {
    _filter = EventFilter(
      hideFull: hideFull,
      showDone: showDone,
      goals: goals,
      minCapacity: minCapacity,
      maxCapacity: maxCapacity,
      minCurrentUsers: minCurrentUsers,
      maxCurrentUsers: maxCurrentUsers,
      country: country,
      district: district,
      city: city,
    );

    notifyListeners();
  }

  Future<List<String>> uploadEventImages({
    required String eventId,
    required List<XFile> images,
  }) async {
    List<String> urls = [];

    for (int i = 0; i < images.length; i++) {
      final image = images[i];

      final bytes = await image.readAsBytes();

      final url = await _storageRepository.uploadBytes(
        path: '$eventId/image_$i.jpg',
        bytes: bytes,
      );

      urls.add(url);
    }

    return urls;
  }

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

      await _eventRepository.joinEvent(eventId: eventId, userId: userId);

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

      await _eventRepository.leaveEvent(eventId: eventId, userId: userId);

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
    return _eventRepository.isUserInEvent(eventId: eventId, userId: userId);
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
}
