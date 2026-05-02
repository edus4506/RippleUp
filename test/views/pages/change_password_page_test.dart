import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t5/views/pages/settings/change_password_page.dart';

Widget buildWidget() {
  return const MaterialApp(home: ChangePasswordPage());
}

void main() {
  testWidgets('Shows all password fields and button', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.text('Current Password'), findsOneWidget);
    expect(find.text('New Password'), findsOneWidget);
    expect(find.text('Confirm New Password'), findsOneWidget);
    expect(find.text('Update Password'), findsOneWidget);
  });

  testWidgets('Shows error when fields are empty', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Update Password'));
    await tester.pumpAndSettle();

    expect(find.text('Please fill in all fields'), findsOneWidget);
  });

  testWidgets('Shows error when new passwords do not match', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Current Password'),
      'current123',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'New Password'),
      'newpass1',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Confirm New Password'),
      'newpass2',
    );

    await tester.tap(find.text('Update Password'));
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('Shows error when new password is too short', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Current Password'),
      'current123',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'New Password'),
      'abc',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Confirm New Password'),
      'abc',
    );

    await tester.tap(find.text('Update Password'));
    await tester.pumpAndSettle();

    expect(
      find.text('Password must be at least 6 characters'),
      findsOneWidget,
    );
  });
}