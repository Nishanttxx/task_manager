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

  /// Signs in with Google.
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      
      // Get the access token using authorizationClient
      final authClient = await googleUser.authorizationClient.authorizeScopes(['email', 'profile']);
      
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authClient.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception('Google sign-in failed: ${e.code} — ${e.message}');
    } on GoogleSignInException catch (e) {
      // Return null if the user canceled the sign-in
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw Exception('Google sign-in failed: ${e.code}');
    } catch (e) {
      throw Exception('Google sign-in error: $e');
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
