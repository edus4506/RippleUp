import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:t5/data/models/social/user.dart';
import 'package:t5/viewModels/authenthication/auth_viewModel.dart';
import 'package:t5/viewModels/social/notification_viewModel.dart';
import 'package:t5/viewModels/social/profile_viewModel.dart';
import 'package:t5/views/pages/settings/settings_page.dart';
import 'package:t5/routes/app_routes.dart';

class FakeNotificationViewModel extends Mock
    implements AppNotificationViewModel {}

class MockAuthViewModel extends Mock implements AuthViewModel {}

class MockFirebaseUser extends Mock implements User {}

class FakeProfileViewModel extends ChangeNotifier implements ProfileViewModel {
  @override
  Users? user;

  @override
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
      ChangeNotifierProvider<AppNotificationViewModel>.value(value: notifVm),
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
    when(
      () => notifVm.getNotifications(any()),
    ).thenAnswer((_) => Stream.value([]));
    when(() => notifVm.checkUpcomingEvents(any())).thenAnswer((_) async {});

    profileVm.setUser(
      Users(
        uid: 'user-1',
        name: 'John Doe',
        email: 'john@example.com',
        profilePictureUrl: '',
      ),
    );
  });

  testWidgets('shows Edit Profile option', (tester) async {
    await tester.pumpWidget(
      buildWidget(authVm: authVm, profileVm: profileVm, notifVm: notifVm),
    );
    await tester.pumpAndSettle();
    expect(find.text('Edit Profile'), findsOneWidget);
  });

  testWidgets('shows Password option', (tester) async {
    await tester.pumpWidget(
      buildWidget(authVm: authVm, profileVm: profileVm, notifVm: notifVm),
    );
    await tester.pumpAndSettle();
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('shows Logout option', (tester) async {
    await tester.pumpWidget(
      buildWidget(authVm: authVm, profileVm: profileVm, notifVm: notifVm),
    );
    await tester.pumpAndSettle();
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('shows user name and email', (tester) async {
    await tester.pumpWidget(
      buildWidget(authVm: authVm, profileVm: profileVm, notifVm: notifVm),
    );
    await tester.pumpAndSettle();
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('john@example.com'), findsOneWidget);
  });

  testWidgets('tap Edit Profile navigates to edit profile page', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildWidget(authVm: authVm, profileVm: profileVm, notifVm: notifVm),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Profile'), findsWidgets);
  });

  testWidgets('tap Logout shows confirmation dialog', (tester) async {
    await tester.pumpWidget(
      buildWidget(authVm: authVm, profileVm: profileVm, notifVm: notifVm),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    expect(find.text('Are you sure you want to logout?'), findsOneWidget);
  });
}
