import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:t5/viewModels/authenthication/auth_viewModel.dart';
import 'package:t5/views/pages/authentication/login_page.dart';

class MockAuthViewModel extends Mock implements AuthViewModel {}

class MockFirebaseUser extends Mock implements User {}

Widget buildWidget(MockAuthViewModel authVm) {
  return ChangeNotifierProvider<AuthViewModel>.value(
    value: authVm,
    child: MaterialApp(
      routes: {
        '/register': (_) => const Scaffold(body: Text('Register')),
        '/home': (_) => const Scaffold(body: Text('Home')),
      },
      home: const LoginPage(),
    ),
  );
}

void main() {
  late MockAuthViewModel authVm;

  setUp(() {
    authVm = MockAuthViewModel();
    when(() => authVm.addListener(any())).thenAnswer((_) {});
    when(() => authVm.removeListener(any())).thenAnswer((_) {});
    when(() => authVm.isLoading).thenReturn(false);
    when(() => authVm.errorMessage).thenReturn(null);
    when(() => authVm.currentUser).thenReturn(null);
  });

  testWidgets('shows Email and Password fields and Sign in button', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget(authVm));
    expect(find.widgetWithText(TextField, 'your@email.com'), findsOneWidget);
    expect(find.widgetWithText(TextField, '••••••••'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('shows error message from AuthViewModel', (tester) async {
    when(() => authVm.errorMessage).thenReturn('Invalid credentials');
    await tester.pumpWidget(buildWidget(authVm));
    expect(find.text('Invalid credentials'), findsOneWidget);
  });

  testWidgets('Sign in button is disabled while loading', (tester) async {
    when(() => authVm.isLoading).thenReturn(true);
    await tester.pumpWidget(buildWidget(authVm));
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('tap Sign in calls vm.login with entered credentials', (
    tester,
  ) async {
    when(() => authVm.login(any(), any())).thenAnswer((_) async {});
    await tester.pumpWidget(buildWidget(authVm));
    await tester.enterText(
      find.widgetWithText(TextField, 'your@email.com'),
      'a@b.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, '••••••••'),
      'secret',
    );
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    verify(() => authVm.login('a@b.com', 'secret')).called(1);
  });
}
