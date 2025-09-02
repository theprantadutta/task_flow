import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/core/themes/theme_provider.dart';

void main() {
  group('ThemeProvider', () {
    late ThemeProvider themeProvider;

    setUp(() {
      themeProvider = ThemeProvider();
    });

    test('initial theme mode is system', () {
      expect(themeProvider.themeMode, ThemeMode.system);
    });

    test('toggleTheme switches between dark and light mode', () async {
      // Initially system mode
      expect(themeProvider.themeMode, ThemeMode.system);
      
      // Toggle to dark mode
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.dark);
      
      // Toggle to light mode
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.light);
      
      // Toggle back to dark mode
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.dark);
    });

    test('setThemeMode updates theme mode', () {
      themeProvider.setThemeMode(ThemeMode.light);
      expect(themeProvider.themeMode, ThemeMode.light);
      
      themeProvider.setThemeMode(ThemeMode.dark);
      expect(themeProvider.themeMode, ThemeMode.dark);
      
      themeProvider.setThemeMode(ThemeMode.system);
      expect(themeProvider.themeMode, ThemeMode.system);
    });

    test('isDarkMode returns correct value', () {
      // Test with system mode (depends on platform brightness)
      themeProvider.setThemeMode(ThemeMode.system);
      // We can't easily test this without mocking platform brightness
      
      // Test with dark mode
      themeProvider.setThemeMode(ThemeMode.dark);
      expect(themeProvider.isDarkMode, isTrue);
      
      // Test with light mode
      themeProvider.setThemeMode(ThemeMode.light);
      expect(themeProvider.isDarkMode, isFalse);
    });
  });
}