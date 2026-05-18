import 'package:flutter_test/flutter_test.dart';

import 'package:t5/services/direct_chat_service.dart';

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
}
