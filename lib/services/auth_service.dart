
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Current logged-in Firebase user
  User? get currentUser => _auth.currentUser;

  // Monitor login/logout
  Stream<User?> get authStateChanges =>
      _auth.authStateChanges();

  // Call after Firebase.initializeApp()
  Future<void> initialize() async {
    if (kIsWeb) {
      await _auth.setPersistence(Persistence.LOCAL);
    }
  }

  // GOOGLE SIGN-IN
  Future<User?> signInWithGoogle() async {
    try {
      // Preserve an existing authenticated session.
      if (_auth.currentUser != null) {
        return _auth.currentUser;
      }

      // WEB LOGIN
      if (kIsWeb) {
        final provider = GoogleAuthProvider();

        provider.setCustomParameters({
          'prompt': 'select_account',
        });

        final result =
            await _auth.signInWithPopup(provider);

        return result.user;
      }

      // MOBILE LOGIN
      // Clear any previously selected Google SDK account
      // only when starting a fresh login.
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result =
          await _auth.signInWithCredential(credential);

      debugPrint(
        'Signed in: ${result.user?.email}',
      );

      return result.user;
    } catch (e, stackTrace) {
      debugPrint('Google Sign-In Error: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  // MANUAL LOGOUT ONLY
  Future<void> signOut() async {
    try {
      // End Firebase authentication.
      await _auth.signOut();

      // Clear the selected Google account on mobile.
      if (!kIsWeb) {
        try {
          await _googleSignIn.signOut();
        } catch (e) {
          debugPrint('Google session cleanup: $e');
        }
      }

      debugPrint('Manual logout completed');
    } catch (e) {
      debugPrint('Logout failed: $e');
      rethrow;
    }
  }
}
