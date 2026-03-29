import 'package:flutter_test/flutter_test.dart';
import 'package:t5/main.dart';

void main() {
  testWidgets('App starts on login page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('ENTRAR'), findsOneWidget);
  });
}