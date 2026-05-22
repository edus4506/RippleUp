import 'package:flutter/material.dart';

import '../../data/models/events/event.dart';
import '../../services/search/event_search_service.dart';
import '../events/event_viewModel.dart';

const int kSearchMaxResults = 7;

class SearchViewModel extends ChangeNotifier {
  final EventViewModel eventViewModel;

  SearchViewModel(this.eventViewModel);

  final TextEditingController searchController = TextEditingController();

  String _searchQuery = '';

  void updateSearch(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  List<Event> filterEvents(List<Event> events) {
    final results = EventSearchService.search(events, _searchQuery);
    return results.take(kSearchMaxResults).toList(); // ← limita a 7
  }

  void clearSearch() {
    _searchQuery = '';
    searchController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
