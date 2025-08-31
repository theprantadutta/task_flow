import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:task_flow/shared/models/user.dart' as local_user;
import 'package:task_flow/shared/services/base_service.dart';
import 'package:task_flow/core/utils/logger.dart';

class AuthService extends BaseService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<local_user.User?> get user {
    return auth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;
      return local_user.User(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        photoURL: firebaseUser.photoURL,
      );
    });
  }

  local_user.User? get currentUser {
    final firebaseUser = auth.currentUser;
    if (firebaseUser == null) return null;
    return local_user.User(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
    );
  }

  Future<local_user.User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      Logger.info('User signed in: ${credential.user?.email}');
      
      return local_user.User(
        uid: credential.user!.uid,
        email: credential.user!.email ?? '',
        displayName: credential.user!.displayName,
        photoURL: credential.user!.photoURL,
      );
    } on FirebaseAuthException catch (e) {
      Logger.error('Sign in error: ${e.message}');
      rethrow;
    } catch (e) {
      Logger.error('Unexpected sign in error: $e');
      rethrow;
    }
  }

  Future<local_user.User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update the user's display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user!.updateDisplayName(displayName);
      }
      
      Logger.info('User signed up: ${credential.user?.email}');
      
      return local_user.User(
        uid: credential.user!.uid,
        email: credential.user!.email ?? '',
        displayName: displayName ?? credential.user!.displayName,
        photoURL: credential.user!.photoURL,
      );
    } on FirebaseAuthException catch (e) {
      Logger.error('Sign up error: ${e.message}');
      rethrow;
    } catch (e) {
      Logger.error('Unexpected sign up error: $e');
      rethrow;
    }
  }

  Future<local_user.User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }
      
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final userCredential = await auth.signInWithCredential(credential);
      
      Logger.info('User signed in with Google: ${userCredential.user?.email}');
      
      return local_user.User(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email ?? '',
        displayName: userCredential.user!.displayName,
        photoURL: userCredential.user!.photoURL,
      );
    } on FirebaseAuthException catch (e) {
      Logger.error('Google sign in error: ${e.message}');
      rethrow;
    } catch (e) {
      Logger.error('Unexpected Google sign in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await auth.signOut();
      Logger.info('User signed out');
    } catch (e) {
      Logger.error('Sign out error: $e');
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      Logger.info('Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      Logger.error('Password reset error: ${e.message}');
      rethrow;
    } catch (e) {
      Logger.error('Unexpected password reset error: $e');
      rethrow;
    }
  }
}