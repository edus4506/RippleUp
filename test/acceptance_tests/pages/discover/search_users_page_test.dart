import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/social/user.dart';
import 'package:t5/data/repositories/social/user_repository.dart';
import 'package:t5/viewModels/search/search_users_viewModel.dart';
import 'package:t5/views/pages/discover/search_users_page.dart';

class MockUserRepository extends Mock implements UserRepository {}

Users _user(String id, String name) =>
    Users(uid: id, name: name, email: '$name@test.com', profilePictureUrl: '');

Widget _buildWidget(SearchUsersViewModel vm) {
  return ChangeNotifierProvider<SearchUsersViewModel>.value(
    value: vm,
    child: const MaterialApp(home: SearchUsersPage()),
  );
}

void main() {
  late MockUserRepository mockRepo;
  late SearchUsersViewModel vm;

  setUp(() {
    mockRepo = MockUserRepository();
    vm = SearchUsersViewModel(mockRepo);
  });

  group('SearchUsersPage rendering', () {
    testWidgets('shows search text field', (tester) async {
      when(() => mockRepo.getAllUsers()).thenAnswer((_) async => []);

      await tester.pumpWidget(_buildWidget(vm));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows user list after loading', (tester) async {
      when(
        () => mockRepo.getAllUsers(),
      ).thenAnswer((_) async => [_user('1', 'Alice'), _user('2', 'Bob')]);

      await tester.pumpWidget(_buildWidget(vm));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('shows person icon for each user', (tester) async {
      when(
        () => mockRepo.getAllUsers(),
      ).thenAnswer((_) async => [_user('1', 'Alice')]);

      await tester.pumpWidget(_buildWidget(vm));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person), findsWidgets);
    });
  });

  group('SearchUsersPage search interaction', () {
    testWidgets('shows all users when search is cleared', (tester) async {
      when(
        () => mockRepo.getAllUsers(),
      ).thenAnswer((_) async => [_user('1', 'Alice'), _user('2', 'Bob')]);

      await tester.pumpWidget(_buildWidget(vm));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Alice');
      await tester.pump();

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });
  });
}
