import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/shared/models/user.dart';

void main() {
  group('User', () {
    test('can be instantiated with required parameters', () {
      final user = User(
        uid: 'test-uid',
        email: 'test@example.com',
      );

      expect(user.uid, 'test-uid');
      expect(user.email, 'test@example.com');
      expect(user.displayName, isNull);
      expect(user.photoURL, isNull);
    });

    test('can be instantiated with all parameters', () {
      final user = User(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: 'https://example.com/photo.jpg',
      );

      expect(user.uid, 'test-uid');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.photoURL, 'https://example.com/photo.jpg');
    });

    test('fromJson creates User from JSON', () {
      final json = {
        'uid': 'test-uid',
        'email': 'test@example.com',
        'displayName': 'Test User',
        'photoURL': 'https://example.com/photo.jpg',
      };

      final user = User.fromJson(json);

      expect(user.uid, 'test-uid');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.photoURL, 'https://example.com/photo.jpg');
    });

    test('toJson converts User to JSON', () {
      final user = User(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: 'https://example.com/photo.jpg',
      );

      final json = user.toJson();

      expect(json['uid'], 'test-uid');
      expect(json['email'], 'test@example.com');
      expect(json['displayName'], 'Test User');
      expect(json['photoURL'], 'https://example.com/photo.jpg');
    });

    test('copyWith creates a new User with updated values', () {
      final user = User(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: 'https://example.com/photo.jpg',
      );

      final updatedUser = user.copyWith(
        displayName: 'Updated User',
        photoURL: 'https://example.com/new-photo.jpg',
      );

      expect(updatedUser.uid, 'test-uid');
      expect(updatedUser.email, 'test@example.com');
      expect(updatedUser.displayName, 'Updated User');
      expect(updatedUser.photoURL, 'https://example.com/new-photo.jpg');
    });
  });
}