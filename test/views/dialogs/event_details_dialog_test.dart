import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/event.dart';
import 'package:t5/data/models/favorite_userEvent.dart';
import 'package:t5/data/models/user.dart';
import 'package:t5/data/repositories/favorite_repository.dart';
import 'package:t5/viewModels/authViewModel/auth_viewModel.dart';
import 'package:t5/viewModels/event_viewModel.dart';
import 'package:t5/viewModels/favorite_view_model.dart';
import 'package:t5/viewModels/user_view_model.dart';
import 'package:t5/views/dialogs/event_details_dialog.dart';

class MockAuthViewModel extends Mock implements AuthViewModel {}
class MockEventViewModel extends Mock implements EventViewModel {}
class MockUserViewModel extends Mock implements UserViewModel {}
class MockFirebaseUser extends Mock implements User {}
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

Event buildEvent({
  String id = 'event-1',
  String idCreator = 'creator-2',
  int currentUsers = 1,
  int maxUsers = 5,
}) {
  return Event(
    id: id,
    title: 'Beach Cleanup',
    description: 'Let us clean the beach together.',
    createdAt: DateTime.now(),
    startDate: DateTime(2026, 4, 20, 10, 0),
    endDate: DateTime(2026, 4, 20, 13, 0),
    maxUsers: maxUsers,
    currentUsers: currentUsers,
    idCreator: idCreator,
    country: 'Portugal',
    district: 'Porto',
    city: 'Porto',
    objectives: [1, 2],
  );
}

Widget buildTestable({
  required AuthViewModel auth,
  required EventViewModel eventVm,
  required UserViewModel userVm,
  required Event event,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthViewModel>.value(value: auth),
      ChangeNotifierProvider<EventViewModel>.value(value: eventVm),
      ChangeNotifierProvider<UserViewModel>.value(value: userVm),
      ChangeNotifierProvider<FavoriteViewModel>(
        create: (_) => FavoriteViewModel(FakeFavoriteRepository()),
      ),
    ],
    child: MaterialApp(
      home: EventDetailsDialog(event: event),
    ),
  );
}

void main() {
  late MockAuthViewModel authVm;
  late MockEventViewModel eventVm;
  late MockUserViewModel userVm;
  late MockFirebaseUser user;

  setUp(() {
    authVm = MockAuthViewModel();
    eventVm = MockEventViewModel();
    userVm = MockUserViewModel();
    user = MockFirebaseUser();

    when(() => authVm.addListener(any())).thenAnswer((_) {});
    when(() => authVm.removeListener(any())).thenAnswer((_) {});
    when(() => eventVm.addListener(any())).thenAnswer((_) {});
    when(() => eventVm.removeListener(any())).thenAnswer((_) {});
    when(() => userVm.addListener(any())).thenAnswer((_) {});
    when(() => userVm.removeListener(any())).thenAnswer((_) {});

    when(() => eventVm.isLoading).thenReturn(false);
    when(() => eventVm.errorMessage).thenReturn(null);

    when(() => authVm.currentUser).thenReturn(user);
    when(() => user.uid).thenReturn('user-1');

    when(() => userVm.userStream(any())).thenAnswer(
      (_) => Stream.value(
        Users(
          name: 'Eduardo',
          email: 'eduardo@example.com',
          profilePictureUrl: '',
        ),
      ),
    );

    when(() => eventVm.isUserInEvent(
          eventId: any(named: 'eventId'),
          userId: any(named: 'userId'),
        )).thenAnswer((_) => Stream.value(false));
  });

  testWidgets('shows join button', (tester) async {
    final event = buildEvent();

    await tester.pumpWidget(
      buildTestable(
        auth: authVm,
        eventVm: eventVm,
        userVm: userVm,
        event: event,
      ),
    );

    await tester.pumpAndSettle();
    await tester.pump(); // ensures StreamBuilder updates

    expect(find.text('Join'), findsOneWidget);
  });
}