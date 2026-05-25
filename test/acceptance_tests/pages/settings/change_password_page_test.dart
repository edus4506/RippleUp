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

  
  
}
