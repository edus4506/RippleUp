import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/events/event.dart';
import 'package:t5/data/models/events/favorite_event.dart';
import 'package:t5/data/repositories/events/favorite_event_repository.dart';
import 'package:t5/data/models/social/user.dart';
import 'package:t5/routes/app_routes.dart';
import 'package:t5/viewModels/authenthication/auth_viewModel.dart';
import 'package:t5/viewModels/events/event_viewModel.dart';
import 'package:t5/viewModels/events/favorite_event_viewModel.dart';
import 'package:t5/viewModels/social/user_view_model.dart';
import 'package:t5/views/dialogs/event_details_dialog.dart';
import 'package:t5/views/pages/events/edit_event_page.dart';

// ─────────────────────────────────────────────
// Mocks
// ─────────────────────────────────────────────

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

// ─────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────

Event buildEvent({
  String id = 'event-1',
  String idCreator = 'creator-1',
  int currentUsers = 1,
  int maxUsers = 10,
  DateTime? startDate,
  DateTime? endDate,
}) {
  final now = DateTime.now();
  return Event(
    id: id,
    imageUrls: [],
    title: 'Beach Cleanup',
    description: 'Let us clean the beach together.',
    createdAt: now,
    startDate: startDate ?? now.add(const Duration(hours: 24)),
    endDate: endDate ?? now.add(const Duration(hours: 48)),
    maxUsers: maxUsers,
    currentUsers: currentUsers,
    idCreator: idCreator,
    country: 'Portugal',
    district: 'Porto',
    city: 'Porto',
    objectives: [1, 2],
  );
}

/// Wraps [EventDetailsDialog] with all required providers.
Widget buildDialogTestable({
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
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: Scaffold(
        body: Builder(builder: (context) => EventDetailsDialog(event: event)),
      ),
    ),
  );
}

/// Wraps [EditEventPage] with all required providers, simulating navigation
/// from the dialog.
Widget buildEditPageTestable({
  required AuthViewModel auth,
  required EventViewModel eventVm,
  required Event event,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthViewModel>.value(value: auth),
      ChangeNotifierProvider<EventViewModel>.value(value: eventVm),
    ],
    child: MaterialApp(
      home: Scaffold(body: EditEventPage(event: event)),
    ),
  );
}

void _setupCommonMocks({
  required MockAuthViewModel authVm,
  required MockEventViewModel eventVm,
  required MockUserViewModel userVm,
  required MockFirebaseUser user,
  required String uid,
  bool isInEvent = false,
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
  when(() => user.uid).thenReturn(uid);
  when(() => userVm.userStream(any())).thenAnswer(
    (_) => Stream.value(
      Users(
        uid: uid,
        name: 'Test User',
        email: 'test@example.com',
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

// ─────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────

void main() {
  late MockAuthViewModel authVm;
  late MockEventViewModel eventVm;
  late MockUserViewModel userVm;
  late MockFirebaseUser user;

  setUpAll(() {
    registerFallbackValue(buildEvent());
  });

  setUp(() {
    authVm = MockAuthViewModel();
    eventVm = MockEventViewModel();
    userVm = MockUserViewModel();
    user = MockFirebaseUser();
  });

  // ── Scenario: Edit button visibility ──────────────────────────────────────

  /*testWidgets(
    'Edit Event button is visible in the dialog when the user is the owner '
    'and the event is in planning status',
    (tester) async {
      // Given a logged-in user who is the owner of a planning event
      _setupCommonMocks(
        authVm: authVm,
        eventVm: eventVm,
        userVm: userVm,
        user: user,
        uid: 'creator-1',
      );
      final event = buildEvent(idCreator: 'creator-1');

      await tester.pumpWidget(
        buildDialogTestable(
          auth: authVm,
          eventVm: eventVm,
          userVm: userVm,
          event: event,
        ),
      );
      await tester.pumpAndSettle();

      // Then the Edit Event button is shown
      expect(find.text('Edit Event'), findsOneWidget);
    },
  );*/

  // ── Scenario: Non-owner cannot see Edit button ────────────────────────────

  testWidgets(
    'Edit Event button is NOT shown when the logged-in user is not the owner',
    (tester) async {
      // Given a logged-in user who is NOT the owner
      _setupCommonMocks(
        authVm: authVm,
        eventVm: eventVm,
        userVm: userVm,
        user: user,
        uid: 'other-user',
      );
      final event = buildEvent(idCreator: 'creator-1');

      await tester.pumpWidget(
        buildDialogTestable(
          auth: authVm,
          eventVm: eventVm,
          userVm: userVm,
          event: event,
        ),
      );
      await tester.pumpAndSettle();

      // Then the Edit Event button is NOT shown
      expect(find.text('Edit Event'), findsNothing);
    },
  );

  // ── Scenario: Edit button hidden for locked events ────────────────────────

  testWidgets(
    'Edit Event button is NOT shown when the event is ongoing (locked)',
    (tester) async {
      // Given the owner, but the event is already ongoing
      _setupCommonMocks(
        authVm: authVm,
        eventVm: eventVm,
        userVm: userVm,
        user: user,
        uid: 'creator-1',
      );
      final now = DateTime.now();
      final ongoingEvent = buildEvent(
        idCreator: 'creator-1',
        startDate: now.subtract(const Duration(hours: 1)),
        endDate: now.add(const Duration(hours: 1)),
      );

      await tester.pumpWidget(
        buildDialogTestable(
          auth: authVm,
          eventVm: eventVm,
          userVm: userVm,
          event: ongoingEvent,
        ),
      );
      await tester.pumpAndSettle();

      // Then the Edit Event button is NOT shown (event is locked)
      expect(find.text('Edit Event'), findsNothing);
    },
  );

  // ── Scenario: Edit page pre-fills existing data ───────────────────────────

  testWidgets('EditEventPage pre-fills the form with the existing event data', (
    tester,
  ) async {
    // Given a logged-in owner navigates to the EditEventPage
    when(() => authVm.addListener(any())).thenAnswer((_) {});
    when(() => authVm.removeListener(any())).thenAnswer((_) {});
    when(() => eventVm.addListener(any())).thenAnswer((_) {});
    when(() => eventVm.removeListener(any())).thenAnswer((_) {});
    when(() => authVm.currentUser).thenReturn(user);
    when(() => user.uid).thenReturn('creator-1');

    final event = buildEvent(idCreator: 'creator-1');

    await tester.pumpWidget(
      buildEditPageTestable(auth: authVm, eventVm: eventVm, event: event),
    );
    await tester.pumpAndSettle();

    // Then the title field is pre-filled with the event's title
    expect(find.text('Beach Cleanup'), findsOneWidget);
    // And the description field is pre-filled
    expect(find.text('Let us clean the beach together.'), findsOneWidget);
  });

  // ── Scenario: Successful event update ────────────────────────────────────

  /*testWidgets(
    'Tapping Save calls updateEvent on the ViewModel and shows success snackbar',
    (tester) async {
      // Given a logged-in owner on the EditEventPage
      when(() => authVm.addListener(any())).thenAnswer((_) {});
      when(() => authVm.removeListener(any())).thenAnswer((_) {});
      when(() => eventVm.addListener(any())).thenAnswer((_) {});
      when(() => eventVm.removeListener(any())).thenAnswer((_) {});
      when(() => authVm.currentUser).thenReturn(user);
      when(() => user.uid).thenReturn('creator-1');
      when(() => eventVm.isLoading).thenReturn(false);
      when(() => eventVm.errorMessage).thenReturn(null);
      when(
        () => eventVm.uploadEventImages(
          eventId: any(named: 'eventId'),
          images: any(named: 'images'),
        ),
      ).thenAnswer((_) async => []);
      when(() => eventVm.updateEvent(any())).thenAnswer((_) async => true);

      final event = buildEvent(idCreator: 'creator-1');

      await tester.pumpWidget(
        buildEditPageTestable(auth: authVm, eventVm: eventVm, event: event),
      );
      await tester.pumpAndSettle();

      // When the user taps Save without changing anything (data is valid)
      await tester.tap(find.text('Save'));
      await tester.pump();
      await Future.delayed(const Duration(milliseconds: 200));
      await tester.pump();

      // Then updateEvent is called once
      verify(() => eventVm.updateEvent(any())).called(1);
    },
  );*/

  // ── Scenario: Invalid data submission ────────────────────────────────────

  testWidgets('Tapping Save with an empty title shows a validation error '
      'and does NOT call updateEvent', (tester) async {
    // Given a logged-in owner on the EditEventPage
    when(() => authVm.addListener(any())).thenAnswer((_) {});
    when(() => authVm.removeListener(any())).thenAnswer((_) {});
    when(() => eventVm.addListener(any())).thenAnswer((_) {});
    when(() => eventVm.removeListener(any())).thenAnswer((_) {});
    when(() => authVm.currentUser).thenReturn(user);
    when(() => user.uid).thenReturn('creator-1');
    when(() => eventVm.isLoading).thenReturn(false);
    when(() => eventVm.errorMessage).thenReturn(null);

    final event = buildEvent(idCreator: 'creator-1');

    await tester.pumpWidget(
      buildEditPageTestable(auth: authVm, eventVm: eventVm, event: event),
    );
    await tester.pumpAndSettle();

    // When the user clears the title field
    await tester.enterText(find.widgetWithText(TextField, 'Beach Cleanup'), '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Then updateEvent is NOT called
    verifyNever(() => eventVm.updateEvent(any()));
    // And an error snackbar is shown
    expect(find.text('Please fill in all fields correctly'), findsOneWidget);
  });
}
