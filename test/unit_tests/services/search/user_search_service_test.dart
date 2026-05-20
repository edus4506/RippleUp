import 'package:flutter_test/flutter_test.dart';

import 'package:t5/data/models/social/user.dart';

import 'package:t5/services/search/user_search_service.dart';

void main() {
  final users = [
    Users(
      uid: '1',
      name: 'John Doe',
      email: 'john@gmail.com',
      profilePictureUrl: '',
    ),

    Users(
      uid: '2',
      name: 'Maria Silva',
      email: 'maria@gmail.com',
      profilePictureUrl: '',
    ),

    Users(
      uid: '3',
      name: 'Joana Costa',
      email: 'joana@gmail.com',
      profilePictureUrl: '',
    ),
  ];

  test('Returns all users when query is empty', () {
    final result = UserSearchService.search(users, '');

    expect(result.length, 3);
  });

  test('Finds user by exact name', () {
    final result = UserSearchService.search(users, 'John Doe');

    expect(result.isNotEmpty, true);

    expect(result.first.name, 'John Doe');
  });

  test('Finds users by partial match', () {
    final result = UserSearchService.search(users, 'jo');

    expect(result.length, 2);
  });

  test('Finds user by email', () {
    final result = UserSearchService.search(users, 'maria@gmail.com');

    expect(result.first.name, 'Maria Silva');
  });

  test('Returns empty list when no user matches', () {
    final result = UserSearchService.search(users, 'xyz123');

    expect(result.isEmpty, true);
  });
}
