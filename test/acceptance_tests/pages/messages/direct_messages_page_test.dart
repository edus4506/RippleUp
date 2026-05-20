import 'package:flutter_test/flutter_test.dart';

import 'package:t5/views/pages/messages/direct_messages_page.dart';

void main() {
  test('formatRelativeTime returns now', () {
    final result = formatRelativeTime(DateTime.now());

    expect(result, 'now');
  });

  test('formatRelativeTime returns minutes', () {
    final result = formatRelativeTime(
      DateTime.now().subtract(const Duration(minutes: 5)),
    );

    expect(result, '5m ago');
  });

  test('formatRelativeTime returns hours', () {
    final result = formatRelativeTime(
      DateTime.now().subtract(const Duration(hours: 2)),
    );

    expect(result, '2h ago');
  });

  test('formatRelativeTime returns days', () {
    final result = formatRelativeTime(
      DateTime.now().subtract(const Duration(days: 3)),
    );

    expect(result, '3d ago');
  });
}
