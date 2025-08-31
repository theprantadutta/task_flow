import 'package:task_flow/shared/models/user.dart';
import 'package:task_flow/shared/services/auth_service.dart';
import 'package:task_flow/shared/services/user_service.dart';

class AuthRepository {
  final AuthService _authService;
  final UserService _userService;

  AuthRepository({
    required AuthService authService,
    required UserService userService,
  })  : _authService = authService,
        _userService = userService;

  Stream<User?> get user => _authService.user;

  User? get currentUser => _authService.currentUser;

  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final user = await _authService.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );

    if (user != null) {
      // Create user in Firestore
      await _userService.createUser(user);
    }

    return user;
  }

  Future<User?> signInWithGoogle() async {
    final user = await _authService.signInWithGoogle();

    if (user != null) {
      // Check if user exists in Firestore, if not create it
      final existingUser = await _userService.getUser(user.uid);
      if (existingUser == null) {
        await _userService.createUser(user);
      }
    }

    return user;
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }
}