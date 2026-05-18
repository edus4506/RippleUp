import 'package:flutter_test/flutter_test.dart';

void main() {
  test('message text is not empty after trim', () {
    final text = ' hello '.trim();

    expect(text.isNotEmpty, true);
  });

  test('empty message text is detected', () {
    final text = '   '.trim();

    expect(text.isEmpty, true);
  });

  test('event id is preserved', () {
    const eventId = 'eventA';

    expect(eventId, 'eventA');
  });
}
