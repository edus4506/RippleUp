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
}
