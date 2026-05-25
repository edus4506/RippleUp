import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:t5/viewModels/authentication/auth_viewModel.dart';
import 'package:t5/views/pages/authentication/register_page.dart';

class MockAuthViewModel extends Mock implements AuthViewModel {}

Widget buildTestable(AuthViewModel authVm) {
  return ChangeNotifierProvider<AuthViewModel>.value(
    value: authVm,
    child: const MaterialApp(home: RegisterPage()),
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

  group('RegisterPage rendering', () {
    testWidgets('shows create account title', (tester) async {
      await tester.pumpWidget(buildTestable(authVm));

      await tester.pumpAndSettle();

      expect(find.text('Create account'), findsWidgets);
    });

    testWidgets('shows join the community subtitle', (tester) async {
      await tester.pumpWidget(buildTestable(authVm));

      await tester.pumpAndSettle();

      expect(find.text('Join the community'), findsOneWidget);
    });

    testWidgets('shows full name field', (tester) async {
      await tester.pumpWidget(buildTestable(authVm));

      await tester.pumpAndSettle();

      expect(find.text('FULL NAME'), findsOneWidget);
    });

    testWidgets('shows email field', (tester) async {
      await tester.pumpWidget(buildTestable(authVm));

      await tester.pumpAndSettle();

      expect(find.text('EMAIL'), findsOneWidget);
    });

    testWidgets('shows password field', (tester) async {
      await tester.pumpWidget(buildTestable(authVm));

      await tester.pumpAndSettle();

      expect(find.text('PASSWORD'), findsOneWidget);
    });

    testWidgets('shows text fields', (tester) async {
      await tester.pumpWidget(buildTestable(authVm));

      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(3));
    });

    testWidgets('shows create account button', (tester) async {
      await tester.pumpWidget(buildTestable(authVm));

      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(ElevatedButton, 'Create account'),
        findsOneWidget,
      );
    });

    testWidgets('shows camera icon', (tester) async {
      await tester.pumpWidget(buildTestable(authVm));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      await tester.pumpWidget(buildTestable(authVm));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });

    testWidgets('shows visibility off icon initially', (tester) async {
      await tester.pumpWidget(buildTestable(authVm));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('toggles password visibility icon', (tester) async {
      await tester.pumpWidget(buildTestable(authVm));

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('shows error message when present', (tester) async {
      when(() => authVm.errorMessage).thenReturn('Registration failed');

      await tester.pumpWidget(buildTestable(authVm));

      await tester.pumpAndSettle();

      expect(find.text('Registration failed'), findsOneWidget);
    });

    testWidgets('shows snackbar when no profile photo selected', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestable(authVm));

      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create account'));

      await tester.pump();

      expect(find.text('Please choose a profile photo'), findsOneWidget);
    });
  });
}
