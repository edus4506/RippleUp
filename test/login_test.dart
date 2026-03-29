import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:t5/main.dart';
import 'package:t5/viewmodels/auth_viewmodel.dart';
import 'package:t5/data/repositories/user_repository.dart';

void main() {
  testWidgets('Login with valid credencials navegates to home', (WidgetTester tester) async {
    
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthViewModel(UserRepository()),
          ),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).at(0),
      'test@test.com',
    );

    await tester.enterText(
      find.byType(TextField).at(1),
      '1234',
    );

    await tester.tap(find.text('ENTRAR'));

    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('Invalid login shows error', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthViewModel(UserRepository()),
          ),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // inserir dados errados
    await tester.enterText(find.byType(TextField).at(0), 'wrong@test.com');
    await tester.enterText(find.byType(TextField).at(1), 'wrong');

    await tester.tap(find.text('ENTRAR'));

    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Credenciais inválidas'), findsOneWidget);
  });

}


