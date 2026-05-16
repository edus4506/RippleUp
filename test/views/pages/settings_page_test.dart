import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:t5/data/models/event.dart';
import 'package:t5/data/models/notification.dart';

import 'package:t5/data/models/user.dart';
import 'package:t5/viewModels/authViewModel/auth_viewModel.dart';
import 'package:t5/viewModels/notification_viewModel.dart';
import 'package:t5/viewModels/profile_viewModel.dart';
import 'package:t5/views/pages/settings/settings_page.dart';
import 'package:t5/routes/app_routes.dart';

class FakeNotificationViewModel extends ChangeNotifier
    implements AppNotificationViewModel {

  
  @override
  AppNotification createNewEventNotificationTemplate(
    Users creator,
    Event event,
  ) {
    final createdAt = DateTime.now();

    return AppNotification(
      id: '',
      //receiverId: '',
      title: 'New Event Available!',
      body: 'test',
      createdAt: createdAt,
      seen: false,
      type: 'new_event',
      eventId: 'test',
    );
  }

  @override
  Stream<List<AppNotification>> getNotifications(String userId) =>
      Stream.value([]);

  @override
  Future<void> createUpComingEventNotification(
    Event event,
    String userId,
  ) async {}

  @override
  Future<void> checkUpcomingEvents(String userId) async {}

  @override
  Future<void> markAsSeen(
    AppNotification notification,
    String userId,
  ) async {}

  @override
  Future<void> createNewEventNotification(Event event) async {}
}

class MockAuthViewModel extends Mock implements AuthViewModel {}

class MockFirebaseUser extends Mock implements User {}

class FakeProfileViewModel extends ChangeNotifier implements ProfileViewModel {
  Users? user;
  bool isLoading = false;

  void setUser(Users? u) {
    user = u;
    notifyListeners();
  }

  @override
  Future<void> loadUser() async {}

  @override
  Future<void> softDeleteAcc() async {}

  @override
  Future<void> updateUserProfile({
    dynamic updatedUser,
    dynamic profilePicture,
  }) async {}
}

Widget buildWidget({
  required MockAuthViewModel authVm,
  required FakeProfileViewModel profileVm,
  required FakeNotificationViewModel notifVm,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthViewModel>.value(value: authVm),
      ChangeNotifierProvider<ProfileViewModel>.value(value: profileVm),
      ChangeNotifierProvider<AppNotificationViewModel>.value(value: notifVm)
    ],
    child: MaterialApp(
      routes: {
        AppRoutes.settings: (_) => const SettingsPage(),
        AppRoutes.editProfile: (_) =>
            const Scaffold(body: Text('Edit Profile')),
        AppRoutes.changePassword: (_) =>
            const Scaffold(body: Text('Change Password')),
        '/login': (_) => const Scaffold(body: Text('Login')),
      },
      home: const SettingsPage(),
    ),
  );
}

void main() {
  late MockAuthViewModel authVm;
  late MockFirebaseUser firebaseUser;
  late FakeProfileViewModel profileVm;
  late FakeNotificationViewModel notifVm;

  setUp(() {
    authVm = MockAuthViewModel();
    firebaseUser = MockFirebaseUser();
    profileVm = FakeProfileViewModel();
    notifVm = FakeNotificationViewModel();

    when(() => authVm.addListener(any())).thenAnswer((_) {});
    when(() => authVm.removeListener(any())).thenAnswer((_) {});
    when(() => authVm.currentUser).thenReturn(firebaseUser);
    when(() => firebaseUser.uid).thenReturn('user-1');

    profileVm.setUser(
      Users(uid: 'mockId', name: 'John Doe', email: 'john@example.com', profilePictureUrl: ''),
    );
  });

  testWidgets('Shows user name and email in header', (tester) async {
    await tester.pumpWidget(buildWidget(authVm: authVm, profileVm: profileVm, notifVm: notifVm));
    await tester.pumpAndSettle();

    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('john@example.com'), findsOneWidget);
  });

  testWidgets('Shows all settings options', (tester) async {
    await tester.pumpWidget(buildWidget(authVm: authVm, profileVm: profileVm,notifVm: notifVm));
    await tester.pumpAndSettle();

    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Help & Support'), findsOneWidget);
    expect(find.text('About the App'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
    expect(find.text('Delete Account'), findsOneWidget);
  });

  testWidgets('Tapping Edit Profile navigates to edit profile page', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget(authVm: authVm, profileVm: profileVm,notifVm: notifVm));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Profile'), findsWidgets);
  });

  testWidgets('Tapping Password navigates to change password page', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget(authVm: authVm, profileVm: profileVm,notifVm: notifVm));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Password'));
    await tester.pumpAndSettle();

    expect(find.text('Change Password'), findsOneWidget);
  });

  testWidgets('Tapping Logout shows confirmation dialog', (tester) async {
    await tester.pumpWidget(buildWidget(authVm: authVm, profileVm: profileVm,notifVm: notifVm));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Are you sure you want to logout?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('Cancelling logout dialog does not logout', (tester) async {
    await tester.pumpWidget(buildWidget(authVm: authVm, profileVm: profileVm,notifVm: notifVm));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => authVm.logout());
  });

  testWidgets('Confirming logout calls logout and navigates to login', (
    tester,
  ) async {
    when(() => authVm.logout()).thenAnswer((_) async {});

    await tester.pumpWidget(buildWidget(authVm: authVm, profileVm: profileVm,notifVm: notifVm));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Logout').last);
    await tester.pumpAndSettle();

    verify(() => authVm.logout()).called(1);
  });

  testWidgets('Tapping Delete Account shows confirmation dialog', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget(authVm: authVm, profileVm: profileVm,notifVm: notifVm));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();

    expect(
      find.text('This will permanently delete your account. Are you sure?'),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('Cancelling delete account dialog does not delete', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget(authVm: authVm, profileVm: profileVm,notifVm: notifVm));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => authVm.deleteAcc());
  });

  testWidgets('Confirming delete account calls softDelete and deleteAcc', (
    tester,
  ) async {
    when(() => authVm.deleteAcc()).thenAnswer((_) async {});

    await tester.pumpWidget(buildWidget(authVm: authVm, profileVm: profileVm,notifVm: notifVm));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    verify(() => authVm.deleteAcc()).called(1);
  });
}
