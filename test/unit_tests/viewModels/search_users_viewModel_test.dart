import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t5/data/models/user.dart';
import 'package:t5/data/repositories/user_repository.dart';
import 'package:t5/viewModels/search_users_viewModel.dart';

class MockUserRepository extends Mock implements UserRepository {}

Users _user(String id, String name) => Users(
  uid: id,
  name: name,
  email: '$name@test.com',
  profilePictureUrl: '',
);

void main() {
  late MockUserRepository mockRepo;
  late SearchUsersViewModel vm;

  setUp(() {
    mockRepo = MockUserRepository();
    vm = SearchUsersViewModel(mockRepo);
  });

  group('SearchUsersViewModel.loadUsers', () {
    test('populates filteredUsers with all users from repository', () async {
      when(
        () => mockRepo.getAllUsers(),
      ).thenAnswer((_) async => [_user('1', 'Ana'), _user('2', 'Bruno')]);

      await vm.loadUsers();

      expect(vm.filteredUsers.length, 2);
      expect(
        vm.filteredUsers.map((u) => u.name),
        containsAll(['Ana', 'Bruno']),
      );
    });

    test('filteredUsers is empty when repository returns empty list', () async {
      when(() => mockRepo.getAllUsers()).thenAnswer((_) async => []);

      await vm.loadUsers();

      expect(vm.filteredUsers, isEmpty);
    });

    test('null entries from repository are ignored', () async {
      when(
        () => mockRepo.getAllUsers(),
      ).thenAnswer((_) async => [_user('1', 'Ana'), null]);

      await vm.loadUsers();

      expect(vm.filteredUsers.length, 1);
    });

    test('notifies listeners after loading', () async {
      when(
        () => mockRepo.getAllUsers(),
      ).thenAnswer((_) async => [_user('1', 'Ana')]);

      int count = 0;
      vm.addListener(() => count++);

      await vm.loadUsers();

      expect(count, greaterThanOrEqualTo(1));
    });
  });

  group('SearchUsersViewModel.updateSearch', () {
    setUp(() async {
      when(() => mockRepo.getAllUsers()).thenAnswer(
        (_) async => [
          _user('1', 'Ana Silva'),
          _user('2', 'Bruno Costa'),
          _user('3', 'Carlos Ana'),
        ],
      );
      await vm.loadUsers();
    });

    test('empty query returns all users', () {
      vm.updateSearch('');

      expect(vm.filteredUsers.length, 3);
    });

    test('filters users by name', () {
      vm.updateSearch('Bruno');

      expect(vm.filteredUsers.length, 1);
      expect(vm.filteredUsers.first.name, 'Bruno Costa');
    });

    test('search is case-insensitive', () {
      vm.updateSearch('ana');

      expect(vm.filteredUsers.length, 2);
    });

    test('returns empty list when no match', () {
      vm.updateSearch('zzznomatch');

      expect(vm.filteredUsers, isEmpty);
    });

    test('notifies listeners on search update', () {
      int count = 0;
      vm.addListener(() => count++);

      vm.updateSearch('Ana');

      expect(count, greaterThanOrEqualTo(1));
    });
  });
}
