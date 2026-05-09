import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';

/// AuthGate listens to [StreamProvider<User?>] and decides what to show:
///   - null → LoginScreen (user must tap "Get Started" to sign in)
///   - User → HomeScreen
///
/// This is the navigation shell described in the architecture blueprint.
/// Unlike a silent auto-sign-in, this provides a proper welcome screen
/// so the user is aware they are entering the app.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user != null) {
      // User is authenticated → show the main app
      return const HomeScreen();
    }

    // No user → show the sign-in / welcome screen
    return const LoginScreen();
  }
}
