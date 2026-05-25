import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:t5/data/models/events/event.dart';
import 'package:t5/data/repositories/events/event_repository.dart';
import 'package:t5/services/storage/storage_service.dart';

import 'package:t5/data/models/events/event_filter.dart';
import 'package:t5/services/filters/event_filter_service.dart';
import 'package:t5/services/search/event_search_service.dart';

class EventViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;
  final StorageRepository _storageRepository;

  EventViewModel(this._eventRepository, this._storageRepository);

  bool isLoading = false;
  String? errorMessage;

  Stream<List<Event>> get eventsStream => _eventRepository.listenToEvents();

  Stream<List<Event>> get recentEventsStream =>
      _eventRepository.listenToRecentEvents();

  EventFilter _filter = const EventFilter();

  EventFilter get currentFilter => _filter;

  // =========================
  // SEARCH STATE
  // =========================

  bool _isSearching = false;

  String _searchQuery = '';

  Timer? _debounce;

  bool get isSearching => _isSearching;

  String get searchQuery => _searchQuery;

  void startSearch() {
    _isSearching = true;
    notifyListeners();
  }

  void stopSearch() {
    _isSearching = false;
    _searchQuery = '';

    _debounce?.cancel();

    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchQuery = query;
      notifyListeners();
    });
  }

  // =========================
  // EVENTS STREAM
  // =========================

  Stream<List<Event>> get filteredEventsStream {
    return eventsStream.map((events) {
      // SEARCH MODE
      if (_isSearching) {
        return EventSearchService.search(events, _searchQuery);
      }

      // NORMAL FILTER MODE
      return EventFilterService.apply(events, _filter);
    });
  }

  // =========================
  // FILTERS
  // =========================

  void applyFilters({
    required bool hideFull,
    required bool showDone,
    required bool canJoin,
    String? excludeCreatedBy,
    required Set<int> goals,
    int? minCapacity,
    int? maxCapacity,
    int? minCurrentUsers,
    int? maxCurrentUsers,
    String? country,
    String? district,
    String? city,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    _filter = EventFilter(
      hideFull: hideFull,
      showDone: showDone,
      canJoin: canJoin,
      excludeCreatedBy: excludeCreatedBy,
      goals: goals,
      minCapacity: minCapacity,
      maxCapacity: maxCapacity,
      minCurrentUsers: minCurrentUsers,
      maxCurrentUsers: maxCurrentUsers,
      country: country,
      district: district,
      city: city,
      startDate: startDate,
      endDate: endDate,
    );

    notifyListeners();
    refreshPaged();
  }

  void resetFilters() {
    _filter = const EventFilter();
    notifyListeners();
    refreshPaged();
  }

  // =========================
  // IMAGES
  // =========================

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

  // =========================
  // CREATE EVENT
  // =========================

  Future<void> createEvent(Event event) async {
    await _eventRepository.createEvent(event);
  }

  // =========================
  // UPDATE EVENT
  // =========================

  Future<bool> updateEvent(Event event) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _eventRepository.updateEvent(event);

      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');

      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // JOIN EVENT
  // =========================

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

  // =========================
  // LEAVE EVENT
  // =========================

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

  // =========================
  // USER IN EVENT
  // =========================

  Stream<bool> isUserInEvent({
    required String eventId,
    required String userId,
  }) {
    return _eventRepository.isUserInEvent(eventId: eventId, userId: userId);
  }

  // =========================
  // DELETE EVENT
  // =========================

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

  // =========================
  // PAGINAÇÃO
  // =========================

  List<Event> _pagedEvents = [];
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  List<Event> get pagedEvents => _pagedEvents;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  /// Carrega a primeira página (ou reinicia se [reset] for true).
  Future<void> loadFirstPage() async {
    _pagedEvents = [];
    _lastDoc = null;
    _hasMore = true;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _eventRepository.fetchEventsPaged();
      _pagedEvents = EventFilterService.apply(result.events, _filter);
      _lastDoc = result.lastDoc;
      _hasMore = result.hasMore;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega a próxima página e adiciona à lista existente.
  Future<void> loadMoreEvents() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _eventRepository.fetchEventsPaged(
        startAfter: _lastDoc,
      );
      final filtered = EventFilterService.apply(result.events, _filter);
      _pagedEvents = [..._pagedEvents, ...filtered];
      _lastDoc = result.lastDoc;
      _hasMore = result.hasMore;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Chama quando filtros/pesquisa mudam — reinicia a paginação.
  void refreshPaged() => loadFirstPage();

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
