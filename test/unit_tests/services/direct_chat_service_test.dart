import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t5/data/repositories/direct_message_repository.dart';
import 'package:t5/data/repositories/follow_repository.dart';
import 'package:t5/services/direct_chat_service.dart';

class MockFollowRepository extends Mock implements FollowRepository {}

class MockDirectMessageRepository extends Mock
    implements DirectMessageRepository {}

void main() {
  test('generateChatId sorts ids correctly', () {
    final result = DirectChatService.generateChatId('b', 'a');

    expect(result, 'a_b');
  });

  test('generateChatId is consistent', () {
    final first = DirectChatService.generateChatId('user1', 'user2');

    final second = DirectChatService.generateChatId('user2', 'user1');

    expect(first, second);
  });

  test('generateChatId handles equal ids', () {
    final result = DirectChatService.generateChatId('same', 'same');

    expect(result, 'same_same');
  });

  test('generateChatId contains separator', () {
    final result = DirectChatService.generateChatId('a', 'b');

    expect(result.contains('_'), true);
  });

  group('DirectChatService.hasExistingChat', () {
    late MockDirectMessageRepository mockDmRepo;

    setUp(() {
      mockDmRepo = MockDirectMessageRepository();
    });

    test('returns true when chat exists', () async {
      when(
        () => mockDmRepo.chatExists('a_b'),
      ).thenAnswer((_) async => true);

      final result = await DirectChatService.hasExistingChat(
        currentUserId: 'a',
        otherUserId: 'b',
        directMessageRepository: mockDmRepo,
      );

      expect(result, true);
    });

    test('returns false when chat does not exist', () async {
      when(
        () => mockDmRepo.chatExists('a_b'),
      ).thenAnswer((_) async => false);

      final result = await DirectChatService.hasExistingChat(
        currentUserId: 'a',
        otherUserId: 'b',
        directMessageRepository: mockDmRepo,
      );

      expect(result, false);
    });

    test('chat id is the same regardless of argument order', () async {
      when(
        () => mockDmRepo.chatExists('a_b'),
      ).thenAnswer((_) async => true);

      final result = await DirectChatService.hasExistingChat(
        currentUserId: 'b',
        otherUserId: 'a',
        directMessageRepository: mockDmRepo,
      );

      expect(result, true);
    });
  });

  group('DirectChatService.canUsersMessage', () {
    late MockFollowRepository mockFollowRepo;
    late MockDirectMessageRepository mockDmRepo;

    setUp(() {
      mockFollowRepo = MockFollowRepository();
      mockDmRepo = MockDirectMessageRepository();
    });

    test('returns true when both users follow each other', () async {
      when(
        () => mockFollowRepo.isFollowing(followerId: 'u1', followedId: 'u2'),
      ).thenAnswer((_) => Stream.value(true));
      when(
        () => mockFollowRepo.isFollowing(followerId: 'u2', followedId: 'u1'),
      ).thenAnswer((_) => Stream.value(true));

      final result = await DirectChatService.canUsersMessage(
        currentUserId: 'u1',
        otherUserId: 'u2',
        followRepository: mockFollowRepo,
        directMessageRepository: mockDmRepo,
      );

      expect(result, true);
    });

    test('returns true when chat already exists even without mutual follow',
        () async {
      when(
        () => mockFollowRepo.isFollowing(followerId: 'u1', followedId: 'u2'),
      ).thenAnswer((_) => Stream.value(false));
      when(
        () => mockFollowRepo.isFollowing(followerId: 'u2', followedId: 'u1'),
      ).thenAnswer((_) => Stream.value(false));
      when(
        () => mockDmRepo.chatExists(any()),
      ).thenAnswer((_) async => true);

      final result = await DirectChatService.canUsersMessage(
        currentUserId: 'u1',
        otherUserId: 'u2',
        followRepository: mockFollowRepo,
        directMessageRepository: mockDmRepo,
      );

      expect(result, true);
    });

    test('returns false when no follow and no existing chat', () async {
      when(
        () => mockFollowRepo.isFollowing(followerId: 'u1', followedId: 'u2'),
      ).thenAnswer((_) => Stream.value(false));
      when(
        () => mockFollowRepo.isFollowing(followerId: 'u2', followedId: 'u1'),
      ).thenAnswer((_) => Stream.value(false));
      when(
        () => mockDmRepo.chatExists(any()),
      ).thenAnswer((_) async => false);

      final result = await DirectChatService.canUsersMessage(
        currentUserId: 'u1',
        otherUserId: 'u2',
        followRepository: mockFollowRepo,
        directMessageRepository: mockDmRepo,
      );

      expect(result, false);
    });
  });
}
