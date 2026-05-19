import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:t5/views/widgets/bottom_nav.dart';

void main() {
  testWidgets('Bottom nav displays all labels', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNav(
            currentIndex: 0,

            onTap: (_) {},

            onAddPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);

    expect(find.text('Discover'), findsOneWidget);

    expect(find.text('Messages'), findsOneWidget);

    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('Bottom nav displays add button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNav(
            currentIndex: 0,

            onTap: (_) {},

            onAddPressed: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Bottom nav tap changes index callback', (tester) async {
    int tappedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNav(
            currentIndex: 0,

            onTap: (index) {
              tappedIndex = index;
            },

            onAddPressed: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('Messages'));

    expect(tappedIndex, 2);
  });

  testWidgets('Add button callback works', (tester) async {
    bool pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNav(
            currentIndex: 0,

            onTap: (_) {},

            onAddPressed: () {
              pressed = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add));

    expect(pressed, true);
  });

  testWidgets('Bottom nav renders send icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNav(
            currentIndex: 2,

            onTap: (_) {},

            onAddPressed: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.send), findsOneWidget);
  });

  testWidgets('Bottom nav renders profile icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNav(
            currentIndex: 3,

            onTap: (_) {},

            onAddPressed: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.person), findsOneWidget);
  });
}
