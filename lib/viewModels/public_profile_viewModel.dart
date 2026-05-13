import 'package:flutter/material.dart';
import 'package:t5/data/models/event.dart';
import 'package:t5/data/models/user.dart';
import 'package:t5/data/repositories/event_repository.dart';
import 'package:t5/data/repositories/follow_repository.dart';
import 'package:t5/data/repositories/user_repository.dart';

class PublicProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final EventRepository _eventRepository;
  final FollowRepository _followRepository;

  Users? user;
  List<Event> joinedEvents = [];
  List<Event> createdEvents = [];
  bool isLoading = false;
  String? errorMessage;

  PublicProfileViewModel(
    this._userRepository,
    this._eventRepository,
    this._followRepository,
  );

  Future<void> loadPublicProfile(String uid) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      user = await _userRepository.getUser(uid);

      if (user == null) {
        errorMessage = 'User not found.';
      } else {
        final results = await Future.wait([
          _eventRepository.getJoinedEventsByUser(uid),
          _eventRepository.getCreatedEventsByUser(uid),
        ]);
        joinedEvents = results[0];
        createdEvents = results[1];
      }
    } catch (e) {
      errorMessage = 'Failed to load profile.';
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
