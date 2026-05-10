import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'widgets/auth_gate.dart';
import 'widgets/alarm_observer.dart';

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
import 'package:alarm/alarm.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Alarm Service (Native only)
  if (!kIsWeb) {
    await Alarm.init();
  }

  // Initialize Google Sign-In
  try {
    await GoogleSignIn.instance.initialize(
      clientId: kIsWeb ? '1006338958836-jivo74os1gudbkbt9c688f82sp9j56c1.apps.googleusercontent.com' : null,
    );
  } catch (e) {
    debugPrint('GoogleSignIn initialization failed: $e');
  }

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
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF7F4EF),
          primaryColor: const Color(0xFF0F0E0D),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFD9440F),
            primary: const Color(0xFF0F0E0D),
            secondary: const Color(0xFFD9440F),
            surface: Colors.white,
            onSurface: const Color(0xFF0F0E0D),
          ),
          textTheme: GoogleFonts.dmSansTextTheme().copyWith(
            displayLarge: GoogleFonts.syne(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F0E0D),
            ),
            headlineMedium: GoogleFonts.syne(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F0E0D),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF7F4EF),
            elevation: 0,
            iconTheme: IconThemeData(color: Color(0xFF0F0E0D)),
            titleTextStyle: TextStyle(
              color: Color(0xFF0F0E0D),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          timePickerTheme: TimePickerThemeData(
            hourMinuteTextStyle: GoogleFonts.dmSans(
              fontSize: 48,
              fontWeight: FontWeight.w700,
            ),
            dialHandColor: const Color(0xFFD9440F),
            dialTextStyle: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        home: const AlarmObserver(child: AuthGate()),
      ),
    );
  }
}
