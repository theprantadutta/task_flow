import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/features/auth/widgets/login_form.dart';

void main() {
  group('LoginForm', () {
    testWidgets('renders email and password fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoginForm(),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Don\'t have an account? Sign up'), findsOneWidget);
      expect(find.text('Sign in with Google'), findsOneWidget);
    });

    testWidgets('shows error when email is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoginForm(),
          ),
        ),
      );

      // Find the login button and tap it
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Expect to see validation error
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('shows error when email is invalid', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoginForm(),
          ),
        ),
      );

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.pump();

      // Find the login button and tap it
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Expect to see validation error
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('shows error when password is too short', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoginForm(),
          ),
        ),
      );

      // Enter valid email
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      
      // Enter short password
      await tester.enterText(find.byType(TextFormField).at(1), '123');
      await tester.pump();

      // Find the login button and tap it
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Expect to see validation error
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });
  });
}