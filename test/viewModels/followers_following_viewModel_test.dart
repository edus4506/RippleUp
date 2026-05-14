import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t5/data/models/user.dart';
import 'package:t5/data/repositories/follow_repository.dart';
import 'package:t5/data/repositories/user_repository.dart';
import 'package:t5/viewModels/followers_following_viewModel.dart';

class MockFollowRepository extends Mock implements FollowRepository {}

class MockUserRepository extends Mock implements UserRepository {}

Users _user(String name) =>
    Users(name: name, email: '$name@test.com', profilePictureUrl: '');

void main() {
  late MockFollowRepository mockFollowRepo;
  late MockUserRepository mockUserRepo;
  late FollowersFollowingViewModel vm;

  setUp(() {
    mockFollowRepo = MockFollowRepository();
    mockUserRepo = MockUserRepository();
    vm = FollowersFollowingViewModel(mockFollowRepo, mockUserRepo);
  });

  group('FollowersFollowingViewModel - initial state', () {
    test('followers and following start empty', () {
      expect(vm.followers, isEmpty);
      expect(vm.following, isEmpty);
    });

    test('isLoading starts false', () {
      expect(vm.isLoading, false);
    });

    test('errorMessage starts null', () {
      expect(vm.errorMessage, isNull);
    });
  });

  group('FollowersFollowingViewModel.load', () {
    test('populates followers and following on success', () async {
      when(
        () => mockFollowRepo.getFollowerIds('u1'),
      ).thenAnswer((_) async => ['f1', 'f2']);
      when(
        () => mockFollowRepo.getFollowingIds('u1'),
      ).thenAnswer((_) async => ['g1']);
      when(() => mockUserRepo.getUsersByIds(['f1', 'f2', 'g1'])).thenAnswer(
        (_) async => {
          'f1': _user('Follower1'),
          'f2': _user('Follower2'),
          'g1': _user('Following1'),
        },
      );

      await vm.load('u1');

      expect(vm.followers.length, 2);
      expect(vm.followers.map((e) => e.value.name), ['Follower1', 'Follower2']);
      expect(vm.following.length, 1);
      expect(vm.following.first.value.name, 'Following1');
      expect(vm.errorMessage, isNull);
    });

    test('handles empty followers and following', () async {
      when(
        () => mockFollowRepo.getFollowerIds('u1'),
      ).thenAnswer((_) async => []);
      when(
        () => mockFollowRepo.getFollowingIds('u1'),
      ).thenAnswer((_) async => []);
      when(() => mockUserRepo.getUsersByIds([])).thenAnswer((_) async => {});

      await vm.load('u1');

      expect(vm.followers, isEmpty);
      expect(vm.following, isEmpty);
      expect(vm.errorMessage, isNull);
    });

    test('sets errorMessage when repository throws', () async {
      when(
        () => mockFollowRepo.getFollowerIds(any()),
      ).thenThrow(Exception('network error'));
      when(
        () => mockFollowRepo.getFollowingIds(any()),
      ).thenThrow(Exception('network error'));

      await vm.load('u1');

      expect(vm.errorMessage, isNotNull);
      expect(vm.followers, isEmpty);
      expect(vm.following, isEmpty);
    });

    test('isLoading is false after load completes', () async {
      when(
        () => mockFollowRepo.getFollowerIds('u1'),
      ).thenAnswer((_) async => []);
      when(
        () => mockFollowRepo.getFollowingIds('u1'),
      ).thenAnswer((_) async => []);
      when(() => mockUserRepo.getUsersByIds([])).thenAnswer((_) async => {});

      await vm.load('u1');

      expect(vm.isLoading, false);
    });

    test('isLoading is false even when an error occurs', () async {
      when(
        () => mockFollowRepo.getFollowerIds(any()),
      ).thenThrow(Exception('fail'));
      when(
        () => mockFollowRepo.getFollowingIds(any()),
      ).thenThrow(Exception('fail'));

      await vm.load('u1');

      expect(vm.isLoading, false);
    });

    test('uses fallback user when uid is missing from usersMap', () async {
      when(
        () => mockFollowRepo.getFollowerIds('u1'),
      ).thenAnswer((_) async => ['unknown-uid']);
      when(
        () => mockFollowRepo.getFollowingIds('u1'),
      ).thenAnswer((_) async => []);
      when(
        () => mockUserRepo.getUsersByIds(['unknown-uid']),
      ).thenAnswer((_) async => {});

      await vm.load('u1');

      expect(vm.followers.length, 1);
      expect(vm.followers.first.value.name, 'Unknown');
    });

    test('notifies listeners when loading starts and ends', () async {
      when(
        () => mockFollowRepo.getFollowerIds('u1'),
      ).thenAnswer((_) async => []);
      when(
        () => mockFollowRepo.getFollowingIds('u1'),
      ).thenAnswer((_) async => []);
      when(() => mockUserRepo.getUsersByIds([])).thenAnswer((_) async => {});

      int notifyCount = 0;
      vm.addListener(() => notifyCount++);

      await vm.load('u1');

      expect(notifyCount, greaterThanOrEqualTo(2));
    });
  });

  group('FollowersFollowingViewModel.isFollowing', () {
    test('emits false when not following', () async {
      when(
        () => mockFollowRepo.isFollowing(followerId: 'me', followedId: 'u1'),
      ).thenAnswer((_) => Stream.value(false));

      final result = await vm
          .isFollowing(followerId: 'me', followedId: 'u1')
          .first;

      expect(result, false);
    });

    test('emits true when already following', () async {
      when(
        () => mockFollowRepo.isFollowing(followerId: 'me', followedId: 'u1'),
      ).thenAnswer((_) => Stream.value(true));

      final result = await vm
          .isFollowing(followerId: 'me', followedId: 'u1')
          .first;

      expect(result, true);
    });
  });

  group('FollowersFollowingViewModel.toggleFollow', () {
    test('calls follow when not currently following', () async {
      when(
        () => mockFollowRepo.follow(followerId: 'me', followedId: 'u1'),
      ).thenAnswer((_) async {});

      await vm.toggleFollow(
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

      await vm.toggleFollow(
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
