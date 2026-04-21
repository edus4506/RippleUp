import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/event.dart';
import 'package:t5/data/models/favorite_userEvent.dart';
import 'package:t5/data/repositories/event_repository.dart';
import 'package:t5/data/repositories/favorite_repository.dart';
import 'package:t5/viewModels/authViewModel/auth_viewModel.dart';
import 'package:t5/viewModels/event_viewModel.dart';
import 'package:t5/viewModels/favorite_view_model.dart';
import 'package:t5/views/pages/home_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:t5/views/widgets/bottom_nav.dart';

class FakeEventRepository implements EventRepository {
  @override
  Future<void> createEvent(Event event) async {}

  @override
  Future<void> deleteEvent(String eventId) async {}

  @override
  Future<void> joinEvent({
    required String eventId,
    required String userId,
  }) async {}

  @override
  Future<void> leaveEvent({
    required String eventId,
    required String userId,
  }) async {}

  @override
  Stream<bool> isUserInEvent({
    required String eventId,
    required String userId,
  }) {
    return Stream.value(false);
  }

  @override
  Stream<List<Event>> listenToEvents() {
    return const Stream.empty();
  }
}

class FakeFavoriteRepository implements FavoriteRepository {
  @override
  Stream<bool> isEventFavorited({required String userId, required String eventId}) =>
      Stream.value(false);
  @override
  Future<void> addFavorite({required String userId, required String eventId}) async {}
  @override
  Future<void> removeFavorite({required String userId, required String eventId}) async {}
  @override
  Stream<List<Favorite>> listenToUserFavorites(String userId) => Stream.value([]);
}

class MockAuthViewModel extends Mock implements AuthViewModel {}
class MockFirebaseUser extends Mock implements User {}

void main() {
  late MockAuthViewModel authVm;
  late MockFirebaseUser firebaseUser;

  setUp(() {
    authVm = MockAuthViewModel();
    firebaseUser = MockFirebaseUser();

    when(() => authVm.addListener(any())).thenAnswer((_) {});
    when(() => authVm.removeListener(any())).thenAnswer((_) {});
    when(() => authVm.currentUser).thenReturn(firebaseUser);
    when(() => firebaseUser.uid).thenReturn('user-1');
  });

  Widget buildApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>.value(value: authVm),
        ChangeNotifierProvider(
          create: (_) => EventViewModel(FakeEventRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoriteViewModel(FakeFavoriteRepository()),
        ),
      ],
      child: const MaterialApp(
        home: HomePage(),
      ),
    );
  }

  testWidgets('Filter button is visible on first tab', (tester) async {
    await tester.pumpWidget(buildApp());

    expect(find.byIcon(Icons.filter_list), findsOneWidget);
  });

  testWidgets('Bottom navigation exists', (tester) async {
    await tester.pumpWidget(buildApp());

    expect(find.byType(AppBottomNav), findsOneWidget);
  });
}