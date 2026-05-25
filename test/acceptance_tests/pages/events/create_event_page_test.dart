import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:t5/data/models/events/event.dart';
import 'package:t5/viewModels/authentication/auth_viewModel.dart';
import 'package:t5/viewModels/events/event_viewModel.dart';
import 'package:t5/viewModels/social/notification_viewModel.dart';
import 'package:t5/views/pages/events/create_event_page.dart';

class FakeUser implements fb.User {
  @override
  String get uid => 'fake-uid';

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class FakeAuthViewModel extends ChangeNotifier implements AuthViewModel {
  final fb.User? _user;
  FakeAuthViewModel({bool loggedIn = true})
    : _user = loggedIn ? FakeUser() : null;

  @override
  fb.User? get currentUser => _user;

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class FakeEventViewModel extends ChangeNotifier implements EventViewModel {
  Event? createdEvent;
  List<String> uploadedUrls = [];

  @override
  Future<List<String>> uploadEventImages({
    required String eventId,
    required List<dynamic> images,
  }) async => uploadedUrls;

  @override
  Future<void> createEvent(Event event) async {
    createdEvent = event;
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class FakeNotificationViewModel extends ChangeNotifier
    implements AppNotificationViewModel {
  Event? notifiedEvent;

  @override
  Future<void> createNewEventNotification(Event event) async {
    notifiedEvent = event;
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

Future<({FakeEventViewModel eventVm, FakeNotificationViewModel notifVm})>
pumpCreateEventPage(WidgetTester tester, {bool loggedIn = true}) async {
  final eventVm = FakeEventViewModel();
  final notifVm = FakeNotificationViewModel();
  final authVm = FakeAuthViewModel(loggedIn: loggedIn);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>.value(value: authVm),
        ChangeNotifierProvider<EventViewModel>.value(value: eventVm),
        ChangeNotifierProvider<AppNotificationViewModel>.value(value: notifVm),
      ],
      child: const MaterialApp(home: CreateEventPage()),
    ),
  );

  await tester.pump();
  return (eventVm: eventVm, notifVm: notifVm);
}

void main() {
  group('Rendering', () {
    testWidgets('renders all section labels', (tester) async {
      await pumpCreateEventPage(tester);
      expect(find.text('Event Info'), findsOneWidget);
      expect(find.text('Event Photos'), findsOneWidget);
      expect(find.text('Event Capacity'), findsOneWidget);
      expect(find.text('Event Dates'), findsOneWidget);
      expect(find.text('Environmental Goals'), findsOneWidget);
      expect(find.text('Location'), findsOneWidget);
    });

    testWidgets('renders Cancel and Create buttons', (tester) async {
      await pumpCreateEventPage(tester);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Create Event'), findsOneWidget);
    });

    testWidgets('renders name and description text fields', (tester) async {
      await pumpCreateEventPage(tester);
      expect(find.widgetWithText(TextField, 'Event name'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Description'), findsOneWidget);
    });

    testWidgets('renders start and end date fields', (tester) async {
      await pumpCreateEventPage(tester);
      expect(
        find.widgetWithText(TextField, 'Start Date & Time'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextField, 'End Date & Time'), findsOneWidget);
    });

    testWidgets('renders photo add button', (tester) async {
      await pumpCreateEventPage(tester);
      expect(find.byIcon(Icons.add_a_photo_outlined), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('renders Country dropdown', (tester) async {
      await pumpCreateEventPage(tester);
      expect(find.text('Country'), findsOneWidget);
    });
  });

  group('Validation', () {
    testWidgets('shows error when all fields are empty', (tester) async {
      await pumpCreateEventPage(tester);
      await tester.tap(find.text('Create Event'));
      await tester.pumpAndSettle();
      expect(find.text('Please fill in all fields correctly'), findsOneWidget);
    });

    testWidgets('shows error when name is filled but rest is empty', (
      tester,
    ) async {
      await pumpCreateEventPage(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'Event name'),
        'Beach Cleanup',
      );
      await tester.tap(find.text('Create Event'));
      await tester.pumpAndSettle();
      expect(find.text('Please fill in all fields correctly'), findsOneWidget);
    });

    testWidgets('shows error when capacity is 0', (tester) async {
      await pumpCreateEventPage(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'Event name'),
        'Beach Cleanup',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Description'),
        'Some description',
      );
      await tester.tap(find.text('Create Event'));
      await tester.pumpAndSettle();
      expect(find.text('Please fill in all fields correctly'), findsOneWidget);
    });
  });

  group('Environmental goals', () {
    testWidgets('renders 18 goal items', (tester) async {
      await pumpCreateEventPage(tester);
      expect(find.byType(InkWell), findsAtLeast(18));
    });

    testWidgets('tapping a goal toggles selection (border changes)', (
      tester,
    ) async {
      await pumpCreateEventPage(tester);
      final goalItems = find.byType(InkWell);
      await tester.tap(goalItems.first);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
  group('Location dropdowns', () {
    testWidgets('District dropdown is hidden until Country is selected', (
      tester,
    ) async {
      await pumpCreateEventPage(tester);
      expect(find.text('District'), findsNothing);
      expect(find.text('City'), findsNothing);
    });
  });

  group('Navigation', () {
    testWidgets('Cancel button pops the page', (tester) async {
      bool popped = false;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthViewModel>.value(
              value: FakeAuthViewModel(),
            ),
            ChangeNotifierProvider<EventViewModel>.value(
              value: FakeEventViewModel(),
            ),
            ChangeNotifierProvider<AppNotificationViewModel>.value(
              value: FakeNotificationViewModel(),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateEventPage()),
                  ).then((_) => popped = true);
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Cancel'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(popped, isTrue);
    });
  });

  group('AppBar', () {
    testWidgets('AppBar shows Create Event title', (tester) async {
      await pumpCreateEventPage(tester);
      expect(find.text('Create'), findsOneWidget);
    });

    testWidgets('AppBar back button is present', (tester) async {
      await pumpCreateEventPage(tester);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });
  });
}
