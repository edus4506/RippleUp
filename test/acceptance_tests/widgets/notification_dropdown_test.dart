import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/social/notification.dart';
import 'package:t5/data/repositories/events/event_repository.dart';
import 'package:t5/data/repositories/social/follow_repository.dart';
import 'package:t5/data/repositories/social/notification_repository.dart';
import 'package:t5/data/repositories/social/participation_repository.dart';
import 'package:t5/data/repositories/social/user_repository.dart';
import 'package:t5/viewModels/authentication/auth_viewModel.dart';
import 'package:t5/viewModels/social/notification_viewModel.dart';
import 'package:t5/views/widgets/top_bar_tabs/notification_dropdown.dart';

class MockAuthViewModel extends Mock implements AuthViewModel {}

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

class MockParticipationRepository extends Mock
    implements ParticipationRepository {}

class MockEventRepository extends Mock implements EventRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockFollowRepository extends Mock implements FollowRepository {}

class MockFirebaseUser extends Mock implements User {}

AppNotification _buildNotification({
  String id = 'n1',
  bool seen = false,
  String type = 'new_event',
}) => AppNotification(
  id: id,
  title: 'Test Notification',
  body: 'Notification body',
  createdAt: DateTime.now(),
  seen: seen,
  type: type,
);

Widget _buildWidget({
  required MockAuthViewModel authVm,
  required AppNotificationViewModel notifVm,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthViewModel>.value(value: authVm),
      ChangeNotifierProvider<AppNotificationViewModel>.value(value: notifVm),
    ],
    child: MaterialApp(
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: AppBar(actions: [NotificationDropdown()]),
        ),
        body: SizedBox(),
      ),
    ),
  );
}

void main() {
  late MockAuthViewModel authVm;
  late MockFirebaseUser firebaseUser;
  late MockNotificationRepository mockNotifRepo;
  late MockParticipationRepository mockParticipationRepo;
  late MockEventRepository mockEventRepo;
  late MockUserRepository mockUserRepo;
  late MockFollowRepository mockFollowRepo;
  late AppNotificationViewModel notifVm;

  setUp(() {
    authVm = MockAuthViewModel();
    firebaseUser = MockFirebaseUser();
    mockNotifRepo = MockNotificationRepository();
    mockParticipationRepo = MockParticipationRepository();
    mockEventRepo = MockEventRepository();
    mockUserRepo = MockUserRepository();
    mockFollowRepo = MockFollowRepository();

    when(() => authVm.addListener(any())).thenAnswer((_) {});
    when(() => authVm.removeListener(any())).thenAnswer((_) {});
    when(() => authVm.currentUser).thenReturn(firebaseUser);
    when(() => firebaseUser.uid).thenReturn('u1');
    when(
      () => mockParticipationRepo.getParticipationsByUser(any()),
    ).thenAnswer((_) async => []);

    notifVm = AppNotificationViewModel(
      mockNotifRepo,
      mockParticipationRepo,
      mockEventRepo,
      mockUserRepo,
      mockFollowRepo,
    );
  });

  group('NotificationDropdown', () {
    testWidgets('shows notification bell icon', (tester) async {
      when(
        () => mockNotifRepo.listenUserNotifications('u1'),
      ).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(_buildWidget(authVm: authVm, notifVm: notifVm));
      await tester.pump();

      expect(find.byIcon(Icons.notifications_rounded), findsOneWidget);
    });

    testWidgets('shows badge when there are unseen notifications', (
      tester,
    ) async {
      when(
        () => mockNotifRepo.listenUserNotifications('u1'),
      ).thenAnswer((_) => Stream.value([_buildNotification(seen: false)]));

      await tester.pumpWidget(_buildWidget(authVm: authVm, notifVm: notifVm));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('shows no badge when all notifications are seen', (
      tester,
    ) async {
      when(
        () => mockNotifRepo.listenUserNotifications('u1'),
      ).thenAnswer((_) => Stream.value([_buildNotification(seen: true)]));

      await tester.pumpWidget(_buildWidget(authVm: authVm, notifVm: notifVm));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsNothing);
    });

    testWidgets('shows No notifications when dropdown is empty', (
      tester,
    ) async {
      when(
        () => mockNotifRepo.listenUserNotifications('u1'),
      ).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(_buildWidget(authVm: authVm, notifVm: notifVm));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.notifications_rounded));
      await tester.pumpAndSettle();

      expect(find.text('No notifications'), findsOneWidget);
    });
  });

  group('AppNotificationViewModel.sortNotifications', () {
    test('sorts notifications by createdAt descending', () {
      final older = AppNotification(
        id: 'old',
        title: 'Old',
        body: '',
        createdAt: DateTime(2025, 1, 1),
        seen: false,
        type: 'new_event',
      );
      final newer = AppNotification(
        id: 'new',
        title: 'New',
        body: '',
        createdAt: DateTime(2025, 6, 1),
        seen: false,
        type: 'new_event',
      );
      final sorted = notifVm.sortNotifications([older, newer]);
      expect(sorted.first.id, 'new');
      expect(sorted.last.id, 'old');
    });
  });

  group('AppNotificationViewModel.getUnseenNotifications', () {
    test('returns only unseen notifications', () {
      final notifications = [
        _buildNotification(id: 'n1', seen: false),
        _buildNotification(id: 'n2', seen: true),
        _buildNotification(id: 'n3', seen: false),
      ];
      final unseen = notifVm.getUnseenNotifications(notifications);
      expect(unseen.length, 2);
      expect(unseen.every((n) => !n.seen), true);
    });

    test('returns empty list when all notifications are seen', () {
      final notifications = [
        _buildNotification(seen: true),
        _buildNotification(seen: true),
      ];
      final unseen = notifVm.getUnseenNotifications(notifications);
      expect(unseen, isEmpty);
    });
  });

  group('AppNotificationViewModel.getNotificationIcon', () {
    test('new_event returns event_available icon', () {
      expect(notifVm.getNotificationIcon('new_event'), Icons.event_available);
    });

    test('upcoming_event returns access_time icon', () {
      expect(notifVm.getNotificationIcon('upcoming_event'), Icons.access_time);
    });

    test('new_follower returns person_add icon', () {
      expect(notifVm.getNotificationIcon('new_follower'), Icons.person_add);
    });

    test('unknown type returns notifications icon', () {
      expect(notifVm.getNotificationIcon('unknown_type'), Icons.notifications);
    });

    test('null type returns notifications icon', () {
      expect(notifVm.getNotificationIcon(null), Icons.notifications);
    });
  });
}
