import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t5/data/models/social/notification.dart';
import 'package:t5/data/repositories/events/event_repository.dart';
import 'package:t5/data/repositories/social/follow_repository.dart';
import 'package:t5/data/repositories/social/notification_repository.dart';
import 'package:t5/data/repositories/social/participation_repository.dart';
import 'package:t5/data/repositories/social/user_repository.dart';
import 'package:t5/viewModels/social/notification_viewModel.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

class MockParticipationRepository extends Mock
    implements ParticipationRepository {}

class MockEventRepository extends Mock implements EventRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockFollowRepository extends Mock implements FollowRepository {}

AppNotification _buildNotification() {
  return AppNotification(
    id: 'n1',
    title: 'Test',
    body: 'Body',
    createdAt: DateTime.now(),
    seen: false,
    type: 'direct_message',
  );
}

void main() {
  late MockNotificationRepository mockNotifRepo;
  late MockParticipationRepository mockParticipationRepo;
  late MockEventRepository mockEventRepo;
  late MockUserRepository mockUserRepo;
  late MockFollowRepository mockFollowRepo;
  late AppNotificationViewModel vm;

  setUpAll(() {
    registerFallbackValue(
      AppNotification(
        id: '',
        title: '',
        body: '',
        createdAt: DateTime.now(),
        seen: false,
        type: '',
      ),
    );
  });

  setUp(() {
    mockNotifRepo = MockNotificationRepository();
    mockParticipationRepo = MockParticipationRepository();
    mockEventRepo = MockEventRepository();
    mockUserRepo = MockUserRepository();
    mockFollowRepo = MockFollowRepository();

    vm = AppNotificationViewModel(
      mockNotifRepo,
      mockParticipationRepo,
      mockEventRepo,
      mockUserRepo,
      mockFollowRepo,
    );
  });

  group('AppNotificationViewModel.getNotifications', () {
    test('returns notifications stream', () {
      final notifications = [_buildNotification()];

      when(
        () => mockNotifRepo.listenUserNotifications('u1'),
      ).thenAnswer((_) => Stream.value(notifications));

      final stream = vm.getNotifications('u1');

      expect(stream, emits(notifications));
    });

    test('returns empty notifications stream', () {
      when(
        () => mockNotifRepo.listenUserNotifications('u1'),
      ).thenAnswer((_) => Stream.value([]));

      final stream = vm.getNotifications('u1');

      expect(stream, emits(isEmpty));
    });
  });

  group('AppNotificationViewModel.sortNotifications', () {
    test('sorts notifications by createdAt descending', () {
      final oldest = AppNotification(
        id: 'a',
        title: 'A',
        body: '',
        createdAt: DateTime(2025, 1, 1),
        seen: false,
        type: 'new_event',
      );
      final newest = AppNotification(
        id: 'b',
        title: 'B',
        body: '',
        createdAt: DateTime(2025, 6, 1),
        seen: false,
        type: 'new_event',
      );
      final middle = AppNotification(
        id: 'c',
        title: 'C',
        body: '',
        createdAt: DateTime(2025, 3, 1),
        seen: false,
        type: 'new_event',
      );

      final sorted = vm.sortNotifications([oldest, newest, middle]);

      expect(sorted[0].id, 'b');
      expect(sorted[1].id, 'c');
      expect(sorted[2].id, 'a');
    });

    test('returns empty list when given empty list', () {
      expect(vm.sortNotifications([]), isEmpty);
    });
  });

  group('AppNotificationViewModel.getUnseenNotifications', () {
    test('returns only unseen notifications', () {
      final seen = AppNotification(
        id: 's1',
        title: 'Seen',
        body: '',
        createdAt: DateTime.now(),
        seen: true,
        type: 'new_event',
      );
      final unseen = AppNotification(
        id: 'u1',
        title: 'Unseen',
        body: '',
        createdAt: DateTime.now(),
        seen: false,
        type: 'new_event',
      );

      final result = vm.getUnseenNotifications([seen, unseen]);

      expect(result.length, 1);
      expect(result.first.id, 'u1');
    });

    test('returns empty list when all notifications are seen', () {
      final seen = AppNotification(
        id: 's1',
        title: 'Seen',
        body: '',
        createdAt: DateTime.now(),
        seen: true,
        type: 'new_event',
      );

      final result = vm.getUnseenNotifications([seen]);

      expect(result, isEmpty);
    });

    test('returns all when none are seen', () {
      final notifications = [
        AppNotification(
          id: 'a',
          title: '',
          body: '',
          createdAt: DateTime.now(),
          seen: false,
          type: 'x',
        ),
        AppNotification(
          id: 'b',
          title: '',
          body: '',
          createdAt: DateTime.now(),
          seen: false,
          type: 'x',
        ),
      ];

      expect(vm.getUnseenNotifications(notifications).length, 2);
    });
  });

  group('AppNotificationViewModel.getNotificationIcon', () {
    test('returns event_available icon for new_event type', () {
      expect(vm.getNotificationIcon('new_event'), Icons.event_available);
    });

    test('returns access_time icon for upcoming_event type', () {
      expect(vm.getNotificationIcon('upcoming_event'), Icons.access_time);
    });

    test('returns person_add icon for new_joined_user type', () {
      expect(vm.getNotificationIcon('new_joined_user'), Icons.person_add);
    });

    test('returns person_remove icon for new_left_user type', () {
      expect(vm.getNotificationIcon('new_left_user'), Icons.person_remove);
    });

    test('returns person_add icon for new_follower type', () {
      expect(vm.getNotificationIcon('new_follower'), Icons.person_add);
    });

    test('returns notifications icon for unknown type', () {
      expect(vm.getNotificationIcon('unknown_type'), Icons.notifications);
    });

    test('returns notifications icon for null type', () {
      expect(vm.getNotificationIcon(null), Icons.notifications);
    });
  });

  group('AppNotificationViewModel.markAsSeen', () {
    test('calls updateNotification with seen set to true', () async {
      final notification = _buildNotification();

      when(
        () => mockNotifRepo.updateNotification('u1', any()),
      ).thenAnswer((_) async {});

      await vm.markAsSeen(notification, 'u1');

      final captured = verify(
        () => mockNotifRepo.updateNotification('u1', captureAny()),
      ).captured;

      final updated = captured.first as AppNotification;
      expect(updated.seen, true);
      expect(updated.id, notification.id);
    });
  });
}
