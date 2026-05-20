import 'package:flutter/material.dart';

import '../../data/models/events/event.dart';

import '../../services/search/event_search_service.dart';

import '../events/event_viewModel.dart';

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
    return EventSearchService.search(events, _searchQuery);
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
