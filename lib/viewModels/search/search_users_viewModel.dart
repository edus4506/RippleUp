import 'package:flutter/material.dart';

import '../../data/models/social/user.dart';
import '../../data/repositories/social/user_repository.dart';

import '../../services/search/user_search_service.dart';

class SearchUsersViewModel extends ChangeNotifier {
  final UserRepository userRepository;

  SearchUsersViewModel(this.userRepository);

  final TextEditingController searchController = TextEditingController();

  List<Users> _allUsers = [];

  List<Users> _filteredUsers = [];

  List<Users> get filteredUsers => _filteredUsers;

  static const int kSearchUsersMaxResults = 7;

  Future<void> loadUsers() async {
    final users = await userRepository.getAllUsers();
    _allUsers = users.whereType<Users>().toList();
    _filteredUsers = _allUsers.take(kSearchUsersMaxResults).toList();
    notifyListeners();
  }

  void updateSearch(String query) {
    final results = UserSearchService.search(_allUsers, query);
    _filteredUsers = results
        .take(kSearchUsersMaxResults)
        .toList(); // ← limita a 7
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
