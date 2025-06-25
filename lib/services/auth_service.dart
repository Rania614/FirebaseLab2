import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Returns the currently signed-in user, or null if no user is signed in.
  User? get currentUser => _auth.currentUser;

  /// Provides a stream of authentication state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Signs up a new user with the provided email and password.
  /// Returns UserCredential on success or throws an error with a user-friendly message.
  Future<UserCredential?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw 'The password is too weak. Please choose a stronger password.';
        case 'email-already-in-use':
          throw 'An account already exists for this email.';
        case 'invalid-email':
          throw 'The email address is not valid.';
        default:
          throw 'Sign-up failed: ${e.message ?? 'An unexpected error occurred.'}';
      }
    } catch (e) {
      throw 'An unexpected error occurred during sign-up: $e';
    }
  }

  /// Signs in a user with the provided email and password.
  /// Returns UserCredential on success or throws an error with a user-friendly message.
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw 'No account found for this email.';
        case 'wrong-password':
          throw 'Incorrect password. Please try again.';
        case 'invalid-email':
          throw 'The email address is not valid.';
        case 'user-disabled':
          throw 'This account has been disabled.';
        default:
          throw 'Login failed: ${e.message ?? 'An unexpected error occurred.'}';
      }
    } catch (e) {
      throw 'An unexpected error occurred during login: $e';
    }
  }

  /// Signs in a user using an authentication credential (e.g., Google).
  /// Returns UserCredential on success or throws an error with a user-friendly message.
  Future<UserCredential?> signInWithCredential(AuthCredential credential) async {
    try {
      final UserCredential result = await _auth.signInWithCredential(credential);
      return result;
    } catch (e) {
      throw 'Failed to sign in with credential: ${e.toString()}';
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Sends a password reset email to the provided email address.
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw 'The email address is not valid.';
        case 'user-not-found':
          throw 'No account found for this email.';
        default:
          throw 'Failed to send password reset email: ${e.message ?? 'An unexpected error occurred.'}';
      }
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }
}