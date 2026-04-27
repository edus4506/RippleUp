/*import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:t5/main.dart' as app;

void main() {
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

      testWidgets('full activity shows full message and blocks join',
              (WidgetTester tester) async {
                app.main();
                await tester.pumpAndSettle();

                expect(find.text('ENTRAR'), findsOneWidget);
                await tester.tap(find.text('ENTRAR'));
                await tester.pumpAndSettle();

                final fullEventTile = find.byKey(const Key('event_1'));
                expect(fullEventTile, findsOneWidget);

                await tester.tap(fullEventTile);
                await tester.pumpAndSettle();

                final dialogFinder = find.byType(AlertDialog);
                expect(dialogFinder, findsOneWidget);

                expect(
                      find.descendant(
                            of: dialogFinder,
                            matching: find.text('Beach Cleanup'),
                      ),
                      findsOneWidget,
                );

                expect(
                      find.descendant(
                            of: dialogFinder,
                            matching: find.text('Participants: 100/100'),
                      ),
                      findsOneWidget,
                );

                expect(find.byKey(const Key('full_badge')), findsOneWidget);
                expect(find.byKey(const Key('full_message')), findsOneWidget);

                final joinButtonFinder = find.byKey(const Key('join_button'));
                expect(joinButtonFinder, findsOneWidget);

                final ElevatedButton joinButton =
                tester.widget<ElevatedButton>(joinButtonFinder);

                expect(joinButton.onPressed, isNull);
          });
}*/
