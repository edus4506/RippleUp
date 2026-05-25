import 'package:flutter_test/flutter_test.dart';
import 'package:t5/data/models/social/user.dart';

void main() {
  group('Users.fromMap', () {
    test('parses all fields from a valid map', () {
      const docId = 'user1';
      final map = {
        'name': 'Alice',
        'email': 'alice@test.com',
        'profilePictureUrl': 'https://example.com/pic.jpg',
      };

      final user = Users.fromMap(map, docId);

      expect(user.uid, docId);
      expect(user.name, 'Alice');
      expect(user.email, 'alice@test.com');
      expect(user.profilePictureUrl, 'https://example.com/pic.jpg');
    });

    test('uses Unknown User when name is missing', () {
      final user = Users.fromMap({
        'email': 'x@test.com',
        'profilePictureUrl': '',
      }, 'u1');
      expect(user.name, 'Unknown User');
    });

    test('uses empty string when email is missing', () {
      final user = Users.fromMap({
        'name': 'Bob',
        'profilePictureUrl': '',
      }, 'u1');
      expect(user.email, '');
    });

    test('returns safe fallback when map is null', () {
      final user = Users.fromMap(null, 'unknown-id');
      expect(user.uid, 'unknown-id');
      expect(user.name, 'Unknown User');
      expect(user.email, '');
    });
  });

  group('Users.toMap', () {
    test('includes name, email, and profilePictureUrl', () {
      final user = Users(
        uid: 'u1',
        name: 'Alice',
        email: 'alice@test.com',
        profilePictureUrl: 'pic.jpg',
      );

      final map = user.toMap();

      expect(map['name'], 'Alice');
      expect(map['email'], 'alice@test.com');
      expect(map['profilePictureUrl'], 'pic.jpg');
    });

    test('does not include uid in map', () {
      final user = Users(
        uid: 'u1',
        name: 'Alice',
        email: 'a@t.com',
        profilePictureUrl: '',
      );
      final map = user.toMap();
      expect(map.containsKey('uid'), false);
    });
  });
}
