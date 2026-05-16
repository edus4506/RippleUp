import 'package:flutter/material.dart';
import 'package:t5/data/models/user.dart';
import 'package:t5/data/repositories/follow_repository.dart';
import 'package:t5/data/repositories/user_repository.dart';

class FollowersFollowingViewModel extends ChangeNotifier {
  final FollowRepository _followRepository;
  final UserRepository _userRepository;

  List<MapEntry<String, Users>> followers = [];
  List<MapEntry<String, Users>> following = [];
  bool isLoading = false;
  String? errorMessage;

  FollowersFollowingViewModel(this._followRepository, this._userRepository);

  Future<void> load(String userId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _followRepository.getFollowerIds(userId),
        _followRepository.getFollowingIds(userId),
      ]);

      final followerIds = results[0];
      final followingIds = results[1];

      final allIds = {...followerIds, ...followingIds}.toList();
      final usersMap = await _userRepository.getUsersByIds(allIds);

      final fallback = Users(
        uid: 'mockId',
        name: 'Unknown',
        email: '',
        profilePictureUrl: '',
      );

      followers = followerIds
          .map((id) => MapEntry(id, usersMap[id] ?? fallback))
          .toList();
      following = followingIds
          .map((id) => MapEntry(id, usersMap[id] ?? fallback))
          .toList();
    } catch (_) {
      errorMessage = 'Failed to load data.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Stream<bool> isFollowing({
    required String followerId,
    required String followedId,
  }) {
    return _followRepository.isFollowing(
      followerId: followerId,
      followedId: followedId,
    );
  }

  Future<void> toggleFollow({
    required String followerId,
    required String followedId,
    required bool currentlyFollowing,
  }) async {
    if (currentlyFollowing) {
      await _followRepository.unfollow(
        followerId: followerId,
        followedId: followedId,
      );
    } else {
      await _followRepository.follow(
        followerId: followerId,
        followedId: followedId,
      );
    }
  }
}
