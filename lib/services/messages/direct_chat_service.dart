import 'package:t5/data/repositories/social/follow_repository.dart';
import 'package:t5/data/repositories/messages/direct_message_repository.dart';

class DirectChatService {
  static String generateChatId(String userA, String userB) {
    final ids = [userA, userB]..sort();

    return '${ids[0]}_${ids[1]}';
  }

  static Future<bool> canUsersMessage({
    required String currentUserId,
    required String otherUserId,
    required FollowRepository followRepository,
    required DirectMessageRepository directMessageRepository,
  }) async {
    final currentFollowing = await followRepository
        .isFollowing(followerId: currentUserId, followedId: otherUserId)
        .first;

    final otherFollowing = await followRepository
        .isFollowing(followerId: otherUserId, followedId: currentUserId)
        .first;

    if (currentFollowing && otherFollowing) {
      return true;
    }

    final chatId = generateChatId(currentUserId, otherUserId);

    return await directMessageRepository.chatExists(chatId);
  }

  static Future<bool> hasExistingChat({
    required String currentUserId,
    required String otherUserId,
    required DirectMessageRepository directMessageRepository,
  }) async {
    final chatId = generateChatId(currentUserId, otherUserId);

    return await directMessageRepository.chatExists(chatId);
  }
}
