import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'widgets/auth_gate.dart';

/// Task Manager App — Entry Point
///
/// Architecture (Phase 1 — Foundational Configuration):
///   1. Initialize Firebase using auto-generated [DefaultFirebaseOptions]
///   2. Wrap the app in a [StreamProvider<User?>] that listens to
///      [FirebaseAuth.authStateChanges()], injecting auth state globally
///   3. [AuthGate] decides what to render based on auth state:
///      - null → loading spinner + triggers anonymous sign-in
///      - User → HomeScreen
///
/// IMPORTANT — Firebase API keys:
/// The API keys embedded in [firebase_options.dart] are PUBLIC identifiers,
/// NOT secrets. They identify your Firebase project to Google services.
/// Security is enforced via Firebase Authentication + Firestore Security Rules,
/// NOT by hiding API keys. This is by design — see:
/// https://firebase.google.com/docs/projects/api-keys
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GoogleSignIn.instance.initialize();
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamProvider<User?> injects auth state into the entire widget tree.
    // This is Step 6 in the architecture blueprint.
    return StreamProvider<User?>.value(
      value: FirebaseAuth.instance.authStateChanges(),
      initialData: null,
      child: MaterialApp(
        title: 'Task Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F0F23),
          primaryColor: const Color(0xFF6C63FF),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF6C63FF),
            secondary: Color(0xFF818CF8),
            surface: Color(0xFF1A1A2E),
            error: Color(0xFFEF4444),
          ),
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0F0F23),
            elevation: 0,
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: const Color(0xFF1A1A2E),
            contentTextStyle: const TextStyle(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}
