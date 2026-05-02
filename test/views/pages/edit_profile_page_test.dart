import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:t5/data/models/user.dart';
import 'package:t5/viewModels/profile_viewModel.dart';
import 'package:t5/views/pages/settings/edit_profile_page.dart';

class FakeProfileViewModel extends ChangeNotifier implements ProfileViewModel {
  Users? user;
  bool isLoading = false;
  bool updateCalled = false;

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
  }) async {
    updateCalled = true;
  }
}

Widget buildWidget(FakeProfileViewModel profileVm) {
  return ChangeNotifierProvider<ProfileViewModel>.value(
    value: profileVm,
    child: const MaterialApp(home: EditProfilePage()),
  );
}

void main() {
  late FakeProfileViewModel profileVm;

  setUp(() {
    profileVm = FakeProfileViewModel();
    profileVm.setUser(
      Users(name: 'John Doe', email: 'john@example.com', profilePictureUrl: ''),
    );
  });

  testWidgets('Shows name and email fields', (tester) async {
    await tester.pumpWidget(buildWidget(profileVm));
    await tester.pumpAndSettle();

    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
  });

  testWidgets('Name field is pre-filled with current name', (tester) async {
    await tester.pumpWidget(buildWidget(profileVm));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'John Doe'), findsOneWidget);
  });

  testWidgets('Email field shows current email and is disabled', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget(profileVm));
    await tester.pumpAndSettle();

    final emailField = tester.widget<TextField>(
      find.widgetWithText(TextField, 'john@example.com'),
    );
    expect(emailField.enabled, false);
  });

  testWidgets('Shows loading indicator when isLoading is true', (tester) async {
    profileVm.isLoading = true;

    await tester.pumpWidget(buildWidget(profileVm));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Tapping Save Changes calls updateUserProfile', (tester) async {
    await tester.pumpWidget(buildWidget(profileVm));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(profileVm.updateCalled, true);
  });

  testWidgets('Shows snackbar after saving profile', (tester) async {
    await tester.pumpWidget(buildWidget(profileVm));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(find.text('Profile updated'), findsOneWidget);
  });
}
