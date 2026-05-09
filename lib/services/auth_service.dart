import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Handles all Firebase Authentication operations.
///
/// Currently uses anonymous sign-in and Google sign-in to establish a unique [uid]
/// for each device. This uid is used by [FirestoreService] to
/// scope data to the individual user.
///
/// The code is structured so that email/password authentication
/// can be added later by extending this service.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// Returns the currently signed-in user, or null.
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes.
  /// Used by StreamProvider in main.dart to gate the UI.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Signs in anonymously. Called on app launch.
  ///
  /// This creates a new anonymous account if one doesn't exist,
  /// or restores the existing anonymous session.
  /// The resulting [User.uid] is the key used for Firestore isolation.
  Future<User?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      return credential.user;
    } on FirebaseAuthException catch (e) {
      // Log the error code for debugging; rethrow so the UI can handle it.
      throw Exception('Anonymous sign-in failed: ${e.code} — ${e.message}');
    }
  }

  /// Signs in with email and password.
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception('Login failed: ${e.message}');
    }
  }

  /// Registers a new user with email and password.
  Future<User?> signUpWithEmail(
      String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Update display name if provided
      if (name.isNotEmpty) {
        await credential.user?.updateDisplayName(name);
      }
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception('Registration failed: ${e.message}');
    }
  }

  /// Signs in with Google using the v7 google_sign_in API.
  ///
  /// In v7, authentication and authorization are separate concerns:
  ///   - authenticate() → identity + idToken
  ///   - authorizationClient.authorizeScopes() → accessToken
  ///
  /// Firebase needs both idToken and accessToken to create a credential.
  Future<User?> signInWithGoogle() async {
    try {
      // Web Implementation: Use Firebase Auth native popup
      if (kIsWeb) {
        debugPrint('AuthService: Starting Web Sign-In Popup');
        final GoogleAuthProvider authProvider = GoogleAuthProvider();
        final UserCredential userCredential =
            await _auth.signInWithPopup(authProvider);
        debugPrint('AuthService: Web Sign-In Popup Success');
        return userCredential.user;
      }

      // Mobile Implementation: Trigger the Google Sign-In flow (identity + idToken)
      debugPrint('AuthService: Starting Mobile Identity Authentication');
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.authenticate();
      
      if (googleUser == null) {
        debugPrint('AuthService: Mobile Identity Authentication Cancelled (null user)');
        return null;
      }
      debugPrint('AuthService: Mobile Identity Authentication Success');

      // Step 2: Get the idToken from authentication
      debugPrint('AuthService: Fetching Tokens');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      debugPrint('AuthService: Tokens Fetched');

      // Step 3: Get the accessToken via authorizationClient
      debugPrint('AuthService: Requesting Authorization Scopes');
      final GoogleSignInClientAuthorization authClient =
          await googleUser.authorizationClient
              .authorizeScopes(<String>['email', 'profile']);
      debugPrint('AuthService: Authorization Scopes Granted');

      // Step 4: Create Firebase credential from Google tokens
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authClient.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 5: Sign in to Firebase with the Google credential
      debugPrint('AuthService: Signing in to Firebase');
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      debugPrint('AuthService: Firebase Sign-In Success');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService: FirebaseAuthException: ${e.code}');
      throw Exception('Google sign-in failed: ${e.code} — ${e.message}');
    } on GoogleSignInException catch (e) {
      debugPrint('AuthService: GoogleSignInException: ${e.code}');
      // Return null if the user canceled the sign-in
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw Exception('Google sign-in failed: ${e.code}');
    } catch (e) {
      debugPrint('AuthService: Generic Error: $e');
      throw Exception('Google sign-in error: $e');
    }
  }

  /// Checks if a link is a valid Firebase sign-in email link.
  bool isSignInWithEmailLink(String emailLink) {
    return _auth.isSignInWithEmailLink(emailLink);
  }

  /// Signs out the current user.
  ///
  /// Google sign-out is wrapped in try-catch because it will fail
  /// if the user signed in anonymously (no Google session to clear).
  /// Firebase sign-out must always run regardless.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore — user may not have a Google session (e.g. anonymous login)
    }
    await _auth.signOut();
  }
}
