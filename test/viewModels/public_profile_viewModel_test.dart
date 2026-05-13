import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t5/data/models/event.dart';
import 'package:t5/data/models/user.dart';
import 'package:t5/data/repositories/event_repository.dart';
import 'package:t5/data/repositories/follow_repository.dart';
import 'package:t5/data/repositories/user_repository.dart';
import 'package:t5/viewModels/public_profile_viewModel.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockEventRepository extends Mock implements EventRepository {}

class MockFollowRepository extends Mock implements FollowRepository {}

Users buildUser() =>
    Users(name: 'Alice', email: 'alice@test.com', profilePictureUrl: '');

Event buildEvent(String id) {
  final now = DateTime.now();
  return Event(
    id: id,
    title: 'Event $id',
    description: '',
    createdAt: now,
    startDate: now.add(const Duration(hours: 1)),
    endDate: now.add(const Duration(hours: 2)),
    maxUsers: 10,
    currentUsers: 1,
    idCreator: 'u1',
    country: 'PT',
    district: 'Porto',
    city: 'Porto',
    objectives: const [],
    imageUrls: const [],
  );
}

void main() {
  late MockUserRepository mockUserRepo;
  late MockEventRepository mockEventRepo;
  late MockFollowRepository mockFollowRepo;
  late PublicProfileViewModel viewModel;

  setUp(() {
    mockUserRepo = MockUserRepository();
    mockEventRepo = MockEventRepository();
    mockFollowRepo = MockFollowRepository();
    viewModel = PublicProfileViewModel(
      mockUserRepo,
      mockEventRepo,
      mockFollowRepo,
    );
  });

  group('PublicProfileViewModel.loadPublicProfile', () {
    test('initial state is empty and not loading', () {
      expect(viewModel.user, isNull);
      expect(viewModel.joinedEvents, isEmpty);
      expect(viewModel.createdEvents, isEmpty);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, isNull);
    });

    test('sets user and events on success', () async {
      when(
        () => mockUserRepo.getUser('u1'),
      ).thenAnswer((_) async => buildUser());
      when(
        () => mockEventRepo.getJoinedEventsByUser('u1'),
      ).thenAnswer((_) async => [buildEvent('j1')]);
      when(
        () => mockEventRepo.getCreatedEventsByUser('u1'),
      ).thenAnswer((_) async => [buildEvent('c1'), buildEvent('c2')]);

      await viewModel.loadPublicProfile('u1');

      expect(viewModel.user?.name, 'Alice');
      expect(viewModel.joinedEvents.length, 1);
      expect(viewModel.createdEvents.length, 2);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, isNull);
    });

    test('sets errorMessage when user is not found', () async {
      when(() => mockUserRepo.getUser('unknown')).thenAnswer((_) async => null);

      await viewModel.loadPublicProfile('unknown');

      expect(viewModel.user, isNull);
      expect(viewModel.errorMessage, isNotNull);
      expect(viewModel.isLoading, false);
    });

    test('sets errorMessage when repository throws', () async {
      when(
        () => mockUserRepo.getUser(any()),
      ).thenThrow(Exception('Network error'));

      await viewModel.loadPublicProfile('u1');

      expect(viewModel.errorMessage, isNotNull);
      expect(viewModel.isLoading, false);
    });

    test('isLoading is false after load completes', () async {
      when(
        () => mockUserRepo.getUser('u1'),
      ).thenAnswer((_) async => buildUser());
      when(
        () => mockEventRepo.getJoinedEventsByUser('u1'),
      ).thenAnswer((_) async => []);
      when(
        () => mockEventRepo.getCreatedEventsByUser('u1'),
      ).thenAnswer((_) async => []);

      await viewModel.loadPublicProfile('u1');

      expect(viewModel.isLoading, false);
    });
  });

  group('PublicProfileViewModel.isFollowing', () {
    test('emits false when not following', () async {
      when(
        () => mockFollowRepo.isFollowing(followerId: 'me', followedId: 'u1'),
      ).thenAnswer((_) => Stream.value(false));

      final result = await viewModel
          .isFollowing(followerId: 'me', followedId: 'u1')
          .first;

      expect(result, false);
    });

    test('emits true when already following', () async {
      when(
        () => mockFollowRepo.isFollowing(followerId: 'me', followedId: 'u1'),
      ).thenAnswer((_) => Stream.value(true));

      final result = await viewModel
          .isFollowing(followerId: 'me', followedId: 'u1')
          .first;

      expect(result, true);
    });
  });

  group('PublicProfileViewModel.toggleFollow', () {
    test('calls follow when not currently following', () async {
      when(
        () => mockFollowRepo.follow(followerId: 'me', followedId: 'u1'),
      ).thenAnswer((_) async {});

      await viewModel.toggleFollow(
        followerId: 'me',
        followedId: 'u1',
        currentlyFollowing: false,
      );

      verify(
        () => mockFollowRepo.follow(followerId: 'me', followedId: 'u1'),
      ).called(1);
      verifyNever(
        () => mockFollowRepo.unfollow(
          followerId: any(named: 'followerId'),
          followedId: any(named: 'followedId'),
        ),
      );
    });

    test('calls unfollow when currently following', () async {
      when(
        () => mockFollowRepo.unfollow(followerId: 'me', followedId: 'u1'),
      ).thenAnswer((_) async {});

      await viewModel.toggleFollow(
        followerId: 'me',
        followedId: 'u1',
        currentlyFollowing: true,
      );

      verify(
        () => mockFollowRepo.unfollow(followerId: 'me', followedId: 'u1'),
      ).called(1);
      verifyNever(
        () => mockFollowRepo.follow(
          followerId: any(named: 'followerId'),
          followedId: any(named: 'followedId'),
        ),
      );
    });
  });
}
