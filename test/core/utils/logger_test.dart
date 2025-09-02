import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/core/utils/logger.dart';

void main() {
  group('Logger', () {
    test('debug method prints message in debug mode', () {
      // This test is a bit tricky to verify since we can't easily capture console output
      // But we can at least verify that the method doesn't throw an exception
      expect(() {
        Logger.debug('Test debug message');
      }, returnsNormally);
    });

    test('info method prints message in debug mode', () {
      expect(() {
        Logger.info('Test info message');
      }, returnsNormally);
    });

    test('error method prints message in debug mode', () {
      expect(() {
        Logger.error('Test error message');
      }, returnsNormally);
    });
  });
}