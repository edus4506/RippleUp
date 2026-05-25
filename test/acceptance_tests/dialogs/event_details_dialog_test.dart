import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/events/event.dart';
import 'package:t5/data/models/events/favorite_event.dart';
import 'package:t5/data/models/social/user.dart';
import 'package:t5/data/repositories/events/favorite_event_repository.dart';
import 'package:t5/viewModels/authentication/auth_viewModel.dart';
import 'package:t5/viewModels/events/event_viewModel.dart';
import 'package:t5/viewModels/events/favorite_event_viewModel.dart';
import 'package:t5/viewModels/social/user_view_model.dart';
import 'package:t5/views/dialogs/event_details_dialog.dart';

class MockAuthViewModel extends Mock implements AuthViewModel {}

class MockEventViewModel extends Mock implements EventViewModel {}

class MockUserViewModel extends Mock implements UserViewModel {}

class MockFirebaseUser extends Mock implements User {}

class FakeFavoriteRepository implements FavoriteRepository {
  @override
  Stream<bool> isEventFavorited({
    required String userId,
    required String eventId,
  }) => Stream.value(false);

  @override
  Future<void> addFavorite({
    required String userId,
    required String eventId,
  }) async {}

  @override
  Future<void> removeFavorite({
    required String userId,
    required String eventId,
  }) async {}

  @override
  Stream<List<Favorite>> listenToUserFavorites(String userId) =>
      Stream.value([]);
}

Event buildEvent({
  String id = 'event-1',
  String idCreator = 'creator-2',
  int currentUsers = 1,
  int maxUsers = 5,
}) {
  final now = DateTime.now();
  return Event(
    id: id,
    imageUrls: [],
    title: 'Beach Cleanup',
    description: 'Let us clean the beach together.',
    createdAt: now,
    startDate: now.add(const Duration(hours: 24)),
    endDate: now.add(const Duration(hours: 48)),
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
  final favRepo = FakeFavoriteRepository();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthViewModel>.value(value: auth),
      ChangeNotifierProvider<EventViewModel>.value(value: eventVm),
      ChangeNotifierProvider<UserViewModel>.value(value: userVm),
      Provider<FavoriteRepository>.value(value: favRepo),
      ChangeNotifierProvider<FavoriteViewModel>(
        create: (_) => FavoriteViewModel(favRepo),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Builder(builder: (context) => EventDetailsDialog(event: event)),
      ),
    ),
  );
}

void _setupCommonMocks({
  required MockAuthViewModel authVm,
  required MockEventViewModel eventVm,
  required MockUserViewModel userVm,
  required MockFirebaseUser user,
  bool isInEvent = false,
  String userId = 'user-1',
}) {
  when(() => authVm.addListener(any())).thenAnswer((_) {});
  when(() => authVm.removeListener(any())).thenAnswer((_) {});
  when(() => eventVm.addListener(any())).thenAnswer((_) {});
  when(() => eventVm.removeListener(any())).thenAnswer((_) {});
  when(() => userVm.addListener(any())).thenAnswer((_) {});
  when(() => userVm.removeListener(any())).thenAnswer((_) {});
  when(() => eventVm.isLoading).thenReturn(false);
  when(() => eventVm.errorMessage).thenReturn(null);
  when(() => authVm.currentUser).thenReturn(user);
  when(() => user.uid).thenReturn(userId);
  when(() => userVm.userStream(any())).thenAnswer(
    (_) => Stream.value(
      Users(
        uid: 'mockId',
        name: 'Eduardo',
        email: 'eduardo@example.com',
        profilePictureUrl: '',
      ),
    ),
  );
  when(
    () => eventVm.isUserInEvent(
      eventId: any(named: 'eventId'),
      userId: any(named: 'userId'),
    ),
  ).thenAnswer((_) => Stream.value(isInEvent));
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
  });

  group('EventDetailsDialog rendering', () {
    testWidgets('shows event title in dialog', (tester) async {
      _setupCommonMocks(
        authVm: authVm,
        eventVm: eventVm,
        userVm: userVm,
        user: user,
      );
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
      expect(find.text('Beach Cleanup'), findsOneWidget);
    });

    testWidgets('shows event description', (tester) async {
      _setupCommonMocks(
        authVm: authVm,
        eventVm: eventVm,
        userVm: userVm,
        user: user,
      );
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
      expect(find.textContaining('clean the beach'), findsOneWidget);
    });

    testWidgets('shows location information', (tester) async {
      _setupCommonMocks(
        authVm: authVm,
        eventVm: eventVm,
        userVm: userVm,
        user: user,
      );
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
      expect(find.textContaining('Porto'), findsWidgets);
    });
  });

  group('EventDetailsDialog interactions', () {
    testWidgets('creator is not shown Join or Leave buttons', (tester) async {
      _setupCommonMocks(
        authVm: authVm,
        eventVm: eventVm,
        userVm: userVm,
        user: user,
        userId: 'creator-2',
        isInEvent: false,
      );
      final event = buildEvent(idCreator: 'creator-2');
      await tester.pumpWidget(
        buildTestable(
          auth: authVm,
          eventVm: eventVm,
          userVm: userVm,
          event: event,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Join'), findsNothing);
      expect(find.text('Leave'), findsNothing);
    });
  });
}
