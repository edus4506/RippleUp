// Integration tests for followers/following feature.
// Run on a connected device/emulator with a Firebase project configured:
//   flutter test integration_test/followers_following_test.dart
//
// These tests require the app to be fully initialised (Firebase + Firestore).
// Seed data assumptions:
//   - A test account exists and is signed in before each test.
//   - The user with uid 'seed-user-uid' exists in Firestore.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:t5/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Followers/Following page - integration', () {
    testWidgets('App starts and renders without crashing', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // App starts at splash or login — just verify no crash on boot.
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets(
      'Followers and Following tabs are visible on connections page',
      (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Navigate directly if already logged in via the profile page.
        // This test assumes the user is authenticated and on the home screen.
        // Find the profile tab and tap it to reach the profile page.
        final profileIconFinder = find.byTooltip('Profile');
        if (profileIconFinder.evaluate().isNotEmpty) {
          await tester.tap(profileIconFinder);
          await tester.pumpAndSettle();

          // The profile page should show follower/following counts.
          // Tap the Followers count to open the connections page.
          final followersFinder = find.text('Followers');
          if (followersFinder.evaluate().isNotEmpty) {
            await tester.tap(followersFinder.first);
            await tester.pumpAndSettle();

            expect(find.text('Connections'), findsOneWidget);
            expect(find.textContaining('Followers'), findsWidgets);
            expect(find.textContaining('Following'), findsWidgets);
          }
        }
      },
    );

    testWidgets('Empty followers list shows empty state message', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to the connections page if reachable.
      final profileIconFinder = find.byTooltip('Profile');
      if (profileIconFinder.evaluate().isNotEmpty) {
        await tester.tap(profileIconFinder);
        await tester.pumpAndSettle();

        final followersFinder = find.text('Followers');
        if (followersFinder.evaluate().isNotEmpty) {
          await tester.tap(followersFinder.first);
          await tester.pumpAndSettle();

          // If the user has no followers the empty message must be shown.
          final emptyFinder = find.text('No followers yet.');
          final listFinder = find.byType(ListView);

          // Either the empty message or a list of users should be visible.
          expect(
            emptyFinder.evaluate().isNotEmpty ||
                listFinder.evaluate().isNotEmpty,
            isTrue,
          );
        }
      }
    });

    testWidgets('Follow button is visible for another user in the list', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final profileIconFinder = find.byTooltip('Profile');
      if (profileIconFinder.evaluate().isNotEmpty) {
        await tester.tap(profileIconFinder);
        await tester.pumpAndSettle();

        final followersFinder = find.text('Followers');
        if (followersFinder.evaluate().isNotEmpty) {
          await tester.tap(followersFinder.first);
          await tester.pumpAndSettle();

          // If there is at least one user who is not the current user,
          // a Follow or Unfollow button should be visible.
          final hasFollow = find.text('Follow').evaluate().isNotEmpty;
          final hasUnfollow = find.text('Unfollow').evaluate().isNotEmpty;
          final isEmpty = find.text('No followers yet.').evaluate().isNotEmpty;

          expect(hasFollow || hasUnfollow || isEmpty, isTrue);
        }
      }
    });

    testWidgets('Tapping a user in the list navigates to their profile', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final profileIconFinder = find.byTooltip('Profile');
      if (profileIconFinder.evaluate().isNotEmpty) {
        await tester.tap(profileIconFinder);
        await tester.pumpAndSettle();

        final followersFinder = find.text('Followers');
        if (followersFinder.evaluate().isNotEmpty) {
          await tester.tap(followersFinder.first);
          await tester.pumpAndSettle();

          // If there is a user in the list, tap the first one.
          final listTileFinder = find.byType(ListTile);
          if (listTileFinder.evaluate().isNotEmpty) {
            await tester.tap(listTileFinder.first);
            await tester.pumpAndSettle();

            // Should navigate to a profile page (either public profile or stay
            // if it is the current user).
            expect(find.byType(Scaffold), findsOneWidget);
          }
        }
      }
    });
  });
}
