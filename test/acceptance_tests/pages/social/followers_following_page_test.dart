import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/models/social/user.dart';
import 'package:t5/data/repositories/social/follow_repository.dart';
import 'package:t5/data/repositories/social/user_repository.dart';
import 'package:t5/views/pages/social/followers_following_page.dart';

class MockFollowRepository extends Mock implements FollowRepository {}

class MockUserRepository extends Mock implements UserRepository {}

Users _user(String name) => Users(
  uid: 'mockId',
  name: name,
  email: '$name@test.com',
  profilePictureUrl: '',
);

const String _targetUid = 'target-uid';
const String _currentUid = 'current-uid';
const String _otherUid = 'other-uid';

Widget _buildPage(
  MockFollowRepository followRepo,
  MockUserRepository userRepo, {
  int initialTab = 0,
  String? currentUserId = _currentUid,
}) {
  return MultiProvider(
    providers: [
      Provider<FollowRepository>.value(value: followRepo),
      Provider<UserRepository>.value(value: userRepo),
    ],
    child: MaterialApp(
      home: FollowersFollowingPage(
        userId: _targetUid,
        initialTab: initialTab,
        currentUserId: currentUserId,
      ),
    ),
  );
}

void _stubEmpty(MockFollowRepository followRepo, MockUserRepository userRepo) {
  when(() => followRepo.getFollowerIds(_targetUid)).thenAnswer((_) async => []);
  when(
    () => followRepo.getFollowingIds(_targetUid),
  ).thenAnswer((_) async => []);
  when(() => userRepo.getUsersByIds(any())).thenAnswer((_) async => {});
}

void _stubWithUsers(
  MockFollowRepository followRepo,
  MockUserRepository userRepo, {
  List<String> followerIds = const [],
  List<String> followingIds = const [],
  Map<String, Users> usersMap = const {},
}) {
  when(
    () => followRepo.getFollowerIds(_targetUid),
  ).thenAnswer((_) async => followerIds);
  when(
    () => followRepo.getFollowingIds(_targetUid),
  ).thenAnswer((_) async => followingIds);
  when(() => userRepo.getUsersByIds(any())).thenAnswer((_) async => usersMap);
}

void main() {
  late MockFollowRepository followRepo;
  late MockUserRepository userRepo;

  setUp(() {
    followRepo = MockFollowRepository();
    userRepo = MockUserRepository();
  });

  group('FollowersFollowingPage - tabs', () {
    testWidgets('shows Followers and Following tabs', (tester) async {
      _stubEmpty(followRepo, userRepo);

      await tester.pumpWidget(_buildPage(followRepo, userRepo));
      await tester.pumpAndSettle();

      expect(find.text('Followers (0)'), findsOneWidget);
      expect(find.text('Following (0)'), findsOneWidget);
    });

    testWidgets('shows tab counts based on loaded data', (tester) async {
      _stubWithUsers(
        followRepo,
        userRepo,
        followerIds: [_otherUid],
        followingIds: [],
        usersMap: {_otherUid: _user('Alice')},
      );
      when(
        () => followRepo.isFollowing(
          followerId: _currentUid,
          followedId: _otherUid,
        ),
      ).thenAnswer((_) => Stream.value(false));

      await tester.pumpWidget(_buildPage(followRepo, userRepo));
      await tester.pumpAndSettle();

      expect(find.text('Followers (1)'), findsOneWidget);
      expect(find.text('Following (0)'), findsOneWidget);
    });

    testWidgets('starts on the correct tab when initialTab=1', (tester) async {
      _stubWithUsers(
        followRepo,
        userRepo,
        followerIds: [],
        followingIds: [_otherUid],
        usersMap: {_otherUid: _user('Bob')},
      );
      when(
        () => followRepo.isFollowing(
          followerId: _currentUid,
          followedId: _otherUid,
        ),
      ).thenAnswer((_) => Stream.value(false));

      await tester.pumpWidget(_buildPage(followRepo, userRepo, initialTab: 1));
      await tester.pumpAndSettle();

      expect(find.text('Bob'), findsOneWidget);
    });
  });

  group('FollowersFollowingPage - empty states', () {
    testWidgets('shows empty message for followers tab when no followers', (
      tester,
    ) async {
      _stubEmpty(followRepo, userRepo);

      await tester.pumpWidget(_buildPage(followRepo, userRepo));
      await tester.pumpAndSettle();

      expect(find.text('No followers yet.'), findsOneWidget);
    });

    testWidgets('shows empty message for following tab when not following', (
      tester,
    ) async {
      _stubEmpty(followRepo, userRepo);

      await tester.pumpWidget(_buildPage(followRepo, userRepo, initialTab: 1));
      await tester.pumpAndSettle();

      expect(find.text('Not following anyone yet.'), findsOneWidget);
    });
  });

  group('FollowersFollowingPage - user list', () {
    testWidgets('displays follower names', (tester) async {
      _stubWithUsers(
        followRepo,
        userRepo,
        followerIds: [_otherUid],
        usersMap: {_otherUid: _user('Alice')},
      );
      when(
        () => followRepo.isFollowing(
          followerId: _currentUid,
          followedId: _otherUid,
        ),
      ).thenAnswer((_) => Stream.value(false));

      await tester.pumpWidget(_buildPage(followRepo, userRepo));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('displays multiple followers', (tester) async {
      const uid2 = 'uid-2';
      _stubWithUsers(
        followRepo,
        userRepo,
        followerIds: [_otherUid, uid2],
        usersMap: {_otherUid: _user('Alice'), uid2: _user('Bob')},
      );
      when(
        () => followRepo.isFollowing(
          followerId: _currentUid,
          followedId: _otherUid,
        ),
      ).thenAnswer((_) => Stream.value(false));
      when(
        () => followRepo.isFollowing(followerId: _currentUid, followedId: uid2),
      ).thenAnswer((_) => Stream.value(false));

      await tester.pumpWidget(_buildPage(followRepo, userRepo));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('shows error message when load fails', (tester) async {
      when(
        () => followRepo.getFollowerIds(_targetUid),
      ).thenThrow(Exception('network error'));
      when(
        () => followRepo.getFollowingIds(_targetUid),
      ).thenThrow(Exception('network error'));

      await tester.pumpWidget(_buildPage(followRepo, userRepo));
      await tester.pumpAndSettle();

      expect(find.text('Failed to load data.'), findsOneWidget);
    });
  });

  group('FollowersFollowingPage - follow button', () {
    testWidgets('shows Follow button for another user', (tester) async {
      _stubWithUsers(
        followRepo,
        userRepo,
        followerIds: [_otherUid],
        usersMap: {_otherUid: _user('Alice')},
      );
      when(
        () => followRepo.isFollowing(
          followerId: _currentUid,
          followedId: _otherUid,
        ),
      ).thenAnswer((_) => Stream.value(false));

      await tester.pumpWidget(_buildPage(followRepo, userRepo));
      await tester.pumpAndSettle();

      expect(find.text('Follow'), findsOneWidget);
    });

    testWidgets('shows Unfollow button when already following', (tester) async {
      _stubWithUsers(
        followRepo,
        userRepo,
        followerIds: [_otherUid],
        usersMap: {_otherUid: _user('Alice')},
      );
      when(
        () => followRepo.isFollowing(
          followerId: _currentUid,
          followedId: _otherUid,
        ),
      ).thenAnswer((_) => Stream.value(true));

      await tester.pumpWidget(_buildPage(followRepo, userRepo));
      await tester.pumpAndSettle();

      expect(find.text('Unfollow'), findsOneWidget);
    });

    testWidgets('does not show follow button for the current user', (
      tester,
    ) async {
      _stubWithUsers(
        followRepo,
        userRepo,
        followerIds: [_currentUid],
        usersMap: {_currentUid: _user('Me')},
      );

      await tester.pumpWidget(_buildPage(followRepo, userRepo));
      await tester.pumpAndSettle();

      expect(find.text('Follow'), findsNothing);
      expect(find.text('Unfollow'), findsNothing);
    });

    testWidgets('does not show follow button when not logged in', (
      tester,
    ) async {
      _stubWithUsers(
        followRepo,
        userRepo,
        followerIds: [_otherUid],
        usersMap: {_otherUid: _user('Alice')},
      );

      await tester.pumpWidget(
        _buildPage(followRepo, userRepo, currentUserId: null),
      );
      await tester.pumpAndSettle();

      expect(find.text('Follow'), findsNothing);
    });

    

    testWidgets('tapping Unfollow calls unfollow on the repository', (
      tester,
    ) async {
      _stubWithUsers(
        followRepo,
        userRepo,
        followerIds: [_otherUid],
        usersMap: {_otherUid: _user('Alice')},
      );
      when(
        () => followRepo.isFollowing(
          followerId: _currentUid,
          followedId: _otherUid,
        ),
      ).thenAnswer((_) => Stream.value(true));
      when(
        () =>
            followRepo.unfollow(followerId: _currentUid, followedId: _otherUid),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(_buildPage(followRepo, userRepo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Unfollow'));
      await tester.pump();

      verify(
        () =>
            followRepo.unfollow(followerId: _currentUid, followedId: _otherUid),
      ).called(1);
    });
  });
}
