import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/core/themes/app_theme.dart';
import 'package:task_flow/core/themes/theme_provider.dart';
import 'package:task_flow/features/auth/bloc/auth_bloc.dart';
import 'package:task_flow/features/auth/presentation/screens/auth_screen.dart';
import 'package:task_flow/features/main/presentation/screens/main_screen.dart';
import 'package:task_flow/firebase_options.dart';
import 'package:task_flow/shared/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return RepositoryProvider(
            create: (context) => AuthService(),
            child: BlocProvider(
              create: (context) =>
                  AuthBloc(authService: context.read<AuthService>())
                    ..add(const AuthStarted()),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return MaterialApp(
                    title: 'TaskFlow',
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: themeProvider.themeMode,
                    home: state.status == AuthStatus.authenticated
                        ? const MainScreen()
                        : const AuthScreen(),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
