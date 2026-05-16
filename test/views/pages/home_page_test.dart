import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/event.dart';
import 'package:t5/data/models/favorite_userEvent.dart';
import 'package:t5/data/models/notification.dart';
import 'package:t5/data/models/user.dart';
import 'package:t5/data/repositories/event_repository.dart';
import 'package:t5/data/repositories/favorite_repository.dart';
import 'package:t5/viewModels/authViewModel/auth_viewModel.dart';
import 'package:t5/viewModels/event_viewModel.dart';
import 'package:t5/viewModels/favorite_view_model.dart';
import 'package:t5/viewModels/notification_viewModel.dart';
import 'package:t5/views/pages/home_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:t5/views/widgets/bottom_nav.dart';


// ================= FAKE REPOSITORY =================

class FakeEventRepository implements EventRepository {
  @override
  Future<Event> getEventById(String eventId) async {
    return Event(
      id: eventId,
      title: 'Event',
      description: '',
      createdAt: DateTime.now(),
      startDate: DateTime.now().add(const Duration(hours: 24)),
      endDate: DateTime.now().add(const Duration(days: 2)),
      maxUsers: 10,
      currentUsers: 0,
      idCreator: 'creator',
      country: 'PT',
      district: 'Porto',
      city: 'Porto',
      objectives: [],
    );
  }

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
  }) => Stream.value(false);

  @override
  Stream<List<Event>> listenToEvents() => const Stream.empty();
}


// ================= FAKE NOTIFICATION VIEWMODEL =================

class FakeNotificationViewModel extends ChangeNotifier
    implements AppNotificationViewModel {

  @override
  Stream<List<AppNotification>> getNotifications(String userId) =>
      Stream.value([]);

  @override
  Future<void> checkUpcomingEvents(String userId) async {}

  @override
  Future<void> markAsSeen(
    AppNotification notification,
    String userId,
  ) async {}

  @override
  Future<void> createUpComingEventNotification(
    Event event,
    String userId,
  ) async {}

  @override
  Future<void> createNewEventNotification(Event event) async {}

  @override
  AppNotification createNewEventNotificationTemplate(
    Users creator,
    Event event,
  ) {
    return AppNotification(
      id: '',
      title: 'test',
      body: 'test',
      createdAt: DateTime.now(),
      seen: false,
      type: 'new_event',
      eventId: event.id,
    );
  }
}


// ================= FAKE FAVORITES =================

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


// ================= MOCKS =================

class MockAuthViewModel extends Mock implements AuthViewModel {}

class MockFirebaseUser extends Mock implements User {}


// ================= TESTS =================

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

        // ✅ FIX PRINCIPAL
        ChangeNotifierProvider<AppNotificationViewModel>.value(
          value: FakeNotificationViewModel(),
        ),
      ],
      child: const MaterialApp(home: HomePage()),
    );
  }

  testWidgets('Filter button is visible on first tab', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.filter_list), findsOneWidget);
  });

  testWidgets('Bottom navigation exists', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(AppBottomNav), findsOneWidget);
  });
}