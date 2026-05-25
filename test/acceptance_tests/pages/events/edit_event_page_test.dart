import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/events/event.dart';
import 'package:t5/viewModels/authentication/auth_viewModel.dart';
import 'package:t5/viewModels/events/event_viewModel.dart';
import 'package:t5/views/pages/events/edit_event_page.dart';

class MockAuthViewModel extends Mock implements AuthViewModel {}

class MockEventViewModel extends Mock implements EventViewModel {}

class MockFirebaseUser extends Mock implements User {}

class FakeEvent extends Fake implements Event {}

Event buildEvent() {
  final now = DateTime.now();

  return Event(
    id: 'event-1',
    imageUrls: [],
    title: 'Beach Cleanup',
    description: 'Clean the beach together',
    createdAt: now,
    startDate: now.add(const Duration(days: 1)),
    endDate: now.add(const Duration(days: 2)),
    maxUsers: 10,
    currentUsers: 2,
    idCreator: 'creator-1',
    country: 'Portugal',
    district: 'Porto',
    city: 'Porto',
    objectives: const [1, 2],
  );
}

Widget buildTestable({
  required AuthViewModel authVm,
  required EventViewModel eventVm,
  required Event event,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthViewModel>.value(value: authVm),
      ChangeNotifierProvider<EventViewModel>.value(value: eventVm),
    ],
    child: MaterialApp(home: EditEventPage(event: event)),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeEvent());
  });

  late MockAuthViewModel authVm;
  late MockEventViewModel eventVm;
  late MockFirebaseUser user;

  setUp(() {
    authVm = MockAuthViewModel();
    eventVm = MockEventViewModel();
    user = MockFirebaseUser();

    when(() => authVm.addListener(any())).thenAnswer((_) {});
    when(() => authVm.removeListener(any())).thenAnswer((_) {});

    when(() => eventVm.addListener(any())).thenAnswer((_) {});
    when(() => eventVm.removeListener(any())).thenAnswer((_) {});

    when(() => authVm.currentUser).thenReturn(user);

    when(() => user.uid).thenReturn('creator-1');

    when(
      () => eventVm.uploadEventImages(
        eventId: any(named: 'eventId'),
        images: any(named: 'images'),
      ),
    ).thenAnswer((_) async => []);

    when(() => eventVm.updateEvent(any())).thenAnswer((_) async => true);

    when(() => eventVm.errorMessage).thenReturn(null);
  });

  group('EditEventPage rendering', () {
    testWidgets('shows page title', (tester) async {
      await tester.pumpWidget(
        buildTestable(authVm: authVm, eventVm: eventVm, event: buildEvent()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Edit Event'), findsOneWidget);
    });

    testWidgets('shows event name field', (tester) async {
      await tester.pumpWidget(
        buildTestable(authVm: authVm, eventVm: eventVm, event: buildEvent()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Event name'), findsOneWidget);
    });

    testWidgets('shows description field', (tester) async {
      await tester.pumpWidget(
        buildTestable(authVm: authVm, eventVm: eventVm, event: buildEvent()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('shows save button', (tester) async {
      await tester.pumpWidget(
        buildTestable(authVm: authVm, eventVm: eventVm, event: buildEvent()),
      );

      await tester.pumpAndSettle();

      expect(find.widgetWithText(ElevatedButton, 'Save'), findsOneWidget);
    });

    testWidgets('shows cancel button', (tester) async {
      await tester.pumpWidget(
        buildTestable(authVm: authVm, eventVm: eventVm, event: buildEvent()),
      );

      await tester.pumpAndSettle();

      expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsOneWidget);
    });

    testWidgets('shows environmental goals section', (tester) async {
      await tester.pumpWidget(
        buildTestable(authVm: authVm, eventVm: eventVm, event: buildEvent()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Environmental Goals'), findsOneWidget);
    });

    testWidgets('shows location section', (tester) async {
      await tester.pumpWidget(
        buildTestable(authVm: authVm, eventVm: eventVm, event: buildEvent()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Location'), findsOneWidget);
    });

    testWidgets('shows event capacity section', (tester) async {
      await tester.pumpWidget(
        buildTestable(authVm: authVm, eventVm: eventVm, event: buildEvent()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Event Capacity'), findsOneWidget);
    });

    testWidgets('shows event photos section', (tester) async {
      await tester.pumpWidget(
        buildTestable(authVm: authVm, eventVm: eventVm, event: buildEvent()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Event Photos'), findsOneWidget);
    });

    testWidgets('shows existing event data', (tester) async {
      await tester.pumpWidget(
        buildTestable(authVm: authVm, eventVm: eventVm, event: buildEvent()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Beach Cleanup'), findsOneWidget);
      expect(find.text('Clean the beach together'), findsOneWidget);
    });

    testWidgets('shows add photo icon', (tester) async {
      await tester.pumpWidget(
        buildTestable(authVm: authVm, eventVm: eventVm, event: buildEvent()),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add_a_photo), findsOneWidget);
    });

    testWidgets('shows date fields', (tester) async {
      await tester.pumpWidget(
        buildTestable(authVm: authVm, eventVm: eventVm, event: buildEvent()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Start Date'), findsOneWidget);
      expect(find.text('End Date'), findsOneWidget);
    });

    testWidgets('shows dropdown fields', (tester) async {
      await tester.pumpWidget(
        buildTestable(authVm: authVm, eventVm: eventVm, event: buildEvent()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Country'), findsOneWidget);
      expect(find.text('District'), findsOneWidget);
      expect(find.text('City'), findsOneWidget);
    });

    testWidgets('allows editing event name', (tester) async {
      await tester.pumpWidget(
        buildTestable(authVm: authVm, eventVm: eventVm, event: buildEvent()),
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Updated Event');

      await tester.pumpAndSettle();

      expect(find.text('Updated Event'), findsOneWidget);
    });

    testWidgets('shows validation snackbar with empty fields', (tester) async {
      await tester.pumpWidget(
        buildTestable(authVm: authVm, eventVm: eventVm, event: buildEvent()),
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));

      await tester.pump();

      expect(find.text('Please fill in all fields correctly'), findsOneWidget);
    });
  });
}
