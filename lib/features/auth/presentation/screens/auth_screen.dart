import 'package:flutter/material.dart';
import 'package:task_flow/features/auth/widgets/login_form.dart';
import 'package:task_flow/features/auth/widgets/signup_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isLogin ? buildLoginSection() : buildSignupSection(),
        ),
      ),
    );
  }

  Widget buildLoginSection() {
    return Column(
      children: [
        const Expanded(child: LoginForm()),
        TextButton(
          onPressed: _toggleAuthMode,
          child: const Text('Don\'t have an account? Sign up'),
        ),
      ],
    );
  }

  Widget buildSignupSection() {
    return Column(
      children: [
        const Expanded(child: SignupForm()),
        TextButton(
          onPressed: _toggleAuthMode,
          child: const Text('Already have an account? Login'),
        ),
      ],
    );
  }
}