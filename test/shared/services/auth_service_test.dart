import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/shared/services/auth_service.dart';

void main() {
  group('AuthService', () {
    test('can be instantiated', () {
      final authService = AuthService();
      expect(authService, isNotNull);
    });
  });
}