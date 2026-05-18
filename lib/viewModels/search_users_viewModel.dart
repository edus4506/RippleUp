import 'package:flutter/material.dart';

import '../../data/models/user.dart';
import '../../data/repositories/user_repository.dart';

import '../services/user_search_service.dart';

class SearchUsersViewModel extends ChangeNotifier {
  final UserRepository userRepository;

  SearchUsersViewModel(this.userRepository);

  final TextEditingController searchController = TextEditingController();

  List<Users> _allUsers = [];

  List<Users> _filteredUsers = [];

  List<Users> get filteredUsers => _filteredUsers;

  Future<void> loadUsers() async {
    final users = await userRepository.getAllUsers();

    _allUsers = users.whereType<Users>().toList();

    _filteredUsers = _allUsers;

    notifyListeners();
  }

  void updateSearch(String query) {
    _filteredUsers = UserSearchService.search(_allUsers, query);

    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
