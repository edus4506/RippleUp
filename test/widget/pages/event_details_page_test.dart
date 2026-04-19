import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/event.dart';
import 'package:t5/data/models/user.dart';
import 'package:t5/viewModels/authViewModel/auth_viewModel.dart';
import 'package:t5/viewModels/event_viewModel.dart';
import 'package:t5/viewModels/user_view_model.dart';
import 'package:t5/views/pages/event_details_page.dart';

class MockAuthViewModel extends Mock implements AuthViewModel {}

class MockEventViewModel extends Mock implements EventViewModel {}

class MockUserViewModel extends Mock implements UserViewModel {}

class MockFirebaseUser extends Mock implements User {}

Event buildEvent({
  String id = 'event-1',
  String idCreator = 'creator-1',
  int currentUsers = 2,
  int maxUsers = 5,
}) {
  return Event(
    id: id,
    title: 'Beach Cleanup',
    description: 'Let us clean the beach together.',
    startDate: DateTime(2026, 4, 20, 10, 0),
    endDate: DateTime(2026, 4, 20, 13, 0),
    maxUsers: maxUsers,
    currentUsers: currentUsers,
    eventStatus: 'PLANNING',
    idCreator: idCreator,
    country: 'Portugal',
    district: 'Porto',
    city: 'Porto',
    objectives: [3, 5, 1],
  );
}

Widget buildTestablePage({
  required AuthViewModel authViewModel,
  required EventViewModel eventViewModel,
  required UserViewModel userViewModel,
  required Event event,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthViewModel>.value(value: authViewModel),
      ChangeNotifierProvider<EventViewModel>.value(value: eventViewModel),
      ChangeNotifierProvider<UserViewModel>.value(value: userViewModel),
    ],
    child: MaterialApp(
      home: EventDetailsPage(event: event),
    ),
  );
}

void main() {
  late MockAuthViewModel mockAuthViewModel;
  late MockEventViewModel mockEventViewModel;
  late MockUserViewModel mockUserViewModel;
  late MockFirebaseUser mockUser;

  setUp(() {
    mockAuthViewModel = MockAuthViewModel();
    mockEventViewModel = MockEventViewModel();
    mockUserViewModel = MockUserViewModel();
    mockUser = MockFirebaseUser();

    when(() => mockAuthViewModel.addListener(any())).thenAnswer((_) {});
    when(() => mockAuthViewModel.removeListener(any())).thenAnswer((_) {});
    when(() => mockEventViewModel.addListener(any())).thenAnswer((_) {});
    when(() => mockEventViewModel.removeListener(any())).thenAnswer((_) {});
    when(() => mockUserViewModel.addListener(any())).thenAnswer((_) {});
    when(() => mockUserViewModel.removeListener(any())).thenAnswer((_) {});

    when(() => mockEventViewModel.isLoading).thenReturn(false);
    when(() => mockEventViewModel.errorMessage).thenReturn(null);

    when(() => mockAuthViewModel.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('user-1');

    when(() => mockUserViewModel.userStream(any())).thenAnswer(
      (_) => Stream.value(
        Users(
          name: 'Eduardo',
          email: 'eduardo@example.com',
          profilePictureUrl: '',
        ),
      ),
    );

    when(() => mockEventViewModel.isUserInEvent(
      eventId: any(named: 'eventId'),
      userId: any(named: 'userId'),
    )).thenAnswer((_) => Stream.value(false));
  });

  testWidgets('shows join button when user can join event', (tester) async {
    final event = buildEvent();

    await tester.pumpWidget(
      buildTestablePage(
        authViewModel: mockAuthViewModel,
        eventViewModel: mockEventViewModel,
        userViewModel: mockUserViewModel,
        event: event,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Entrar no evento'), findsOneWidget);
  });

  testWidgets('shows creator message when logged user is event creator', (tester) async {
    final event = buildEvent(idCreator: 'user-1');

    await tester.pumpWidget(
      buildTestablePage(
        authViewModel: mockAuthViewModel,
        eventViewModel: mockEventViewModel,
        userViewModel: mockUserViewModel,
        event: event,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('És o criador deste evento'), findsOneWidget);
  });

  testWidgets('shows full message when event is full', (tester) async {
    final event = buildEvent(currentUsers: 5, maxUsers: 5);

    await tester.pumpWidget(
      buildTestablePage(
        authViewModel: mockAuthViewModel,
        eventViewModel: mockEventViewModel,
        userViewModel: mockUserViewModel,
        event: event,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Evento cheio'), findsOneWidget);
  });

  testWidgets('shows success snackbar when join succeeds', (tester) async {
    final event = buildEvent();

    when(
      () => mockEventViewModel.joinEvent(
        eventId: any(named: 'eventId'),
        userId: any(named: 'userId'),
      ),
    ).thenAnswer((_) async => true);

    await tester.pumpWidget(
      buildTestablePage(
        authViewModel: mockAuthViewModel,
        eventViewModel: mockEventViewModel,
        userViewModel: mockUserViewModel,
        event: event,
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Entrar no evento'));
    await tester.pump();
    await tester.pumpAndSettle();

    verify(
      () => mockEventViewModel.joinEvent(
        eventId: 'event-1',
        userId: 'user-1',
      ),
    ).called(1);

    expect(find.text('Entraste no evento com sucesso'), findsOneWidget);
  });

  testWidgets('shows error snackbar when join fails', (tester) async {
    final event = buildEvent();

    when(() => mockEventViewModel.errorMessage).thenReturn('Evento cheio');

    when(
      () => mockEventViewModel.joinEvent(
        eventId: any(named: 'eventId'),
        userId: any(named: 'userId'),
      ),
    ).thenAnswer((_) async => false);

    await tester.pumpWidget(
      buildTestablePage(
        authViewModel: mockAuthViewModel,
        eventViewModel: mockEventViewModel,
        userViewModel: mockUserViewModel,
        event: event,
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    verify(
      () => mockEventViewModel.joinEvent(
        eventId: 'event-1',
        userId: 'user-1',
      ),
    ).called(1);

    expect(find.text('Evento cheio'), findsOneWidget);
  });
}