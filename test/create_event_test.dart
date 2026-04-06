import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t5/views/pages/home_page.dart';

void main() {
      group('Create Event Tests', () {
            testWidgets('User can create a new event and see it in the feed',
                    (WidgetTester tester) async {
                      await tester.pumpWidget(const MaterialApp(home: HomePage()));
                      await tester.pumpAndSettle();

                      await tester.tap(find.byKey(const Key('create_event_button')));
                      await tester.pumpAndSettle();

                      expect(find.text('Create Event'), findsOneWidget);

                      await tester.enterText(
                            find.byKey(const Key('create_name_field')),
                            'Community Garden',
                      );
                      await tester.enterText(
                            find.byKey(const Key('create_description_field')),
                            'Help build and maintain a local community garden',
                      );
                      await tester.enterText(
                            find.byKey(const Key('create_max_users_field')),
                            '25',
                      );
                      await tester.pumpAndSettle();

                      await tester.tap(find.text('Objective 1').first);
                      await tester.pumpAndSettle();

                      await tester.drag(find.byType(Scrollable).last, const Offset(0, -500));
                      await tester.pumpAndSettle();

                      final countryDropdown =
                      find.byType(DropdownButtonFormField<String>).at(0);
                      await tester.ensureVisible(countryDropdown);
                      await tester.tap(countryDropdown);
                      await tester.pumpAndSettle();
                      await tester.tap(find.text('Portugal').last);
                      await tester.pumpAndSettle();

                      final districtDropdown =
                      find.byType(DropdownButtonFormField<String>).at(1);
                      await tester.ensureVisible(districtDropdown);
                      await tester.tap(districtDropdown);
                      await tester.pumpAndSettle();
                      await tester.tap(find.text('Porto').last);
                      await tester.pumpAndSettle();

                      final cityDropdown =
                      find.byType(DropdownButtonFormField<String>).at(2);
                      await tester.ensureVisible(cityDropdown);
                      await tester.tap(cityDropdown);
                      await tester.pumpAndSettle();
                      await tester.tap(find.text('Matosinhos').last);
                      await tester.pumpAndSettle();

                      await tester.tap(find.byKey(const Key('confirm_create_event_button')));
                      await tester.pumpAndSettle();

                      expect(find.text('Community Garden'), findsOneWidget);
                });

            testWidgets('Create event shows validation error when fields are empty',
                    (WidgetTester tester) async {
                      await tester.pumpWidget(const MaterialApp(home: HomePage()));
                      await tester.pumpAndSettle();

                      await tester.tap(find.byKey(const Key('create_event_button')));
                      await tester.pumpAndSettle();

                      expect(find.text('Create Event'), findsOneWidget);

                      await tester.tap(find.byKey(const Key('confirm_create_event_button')));
                      await tester.pump();

                      expect(find.text('Please fill in all fields correctly'), findsOneWidget);
                      expect(find.text('Create Event'), findsOneWidget);
                });
      });
}