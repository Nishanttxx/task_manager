import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Welcome / Sign-In screen (Step 8 of the PRD — login_screen.dart).
///
/// This is shown to unauthenticated users by [AuthGate].
/// Provides:
///   - App branding with animated gradient icon
///   - Feature highlights so the user knows what the app does
///   - "Get Started" button → triggers anonymous sign-in
///   - Error handling with SnackBar feedback
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isSigningIn = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleGetStarted() async {
    setState(() => _isSigningIn = true);
    try {
      await AuthService().signInAnonymously();
      // AuthGate will automatically navigate to HomeScreen
      // once the auth stream emits a user.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in failed: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
        setState(() => _isSigningIn = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isSigningIn = true);
    try {
      await AuthService().signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-in failed: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
        setState(() => _isSigningIn = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // ── App Icon ──
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF3B82F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withAlpha(80),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.task_alt_rounded,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Title ──
                  const Text(
                    'Task Manager',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Subtitle ──
                  Text(
                    'Organize. Focus. Achieve.',
                    style: TextStyle(
                      color: Colors.white.withAlpha(140),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ── Feature Highlights ──
                  _buildFeatureRow(
                    Icons.checklist_rounded,
                    'Create & manage tasks',
                    'Add, edit, and track your daily tasks',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureRow(
                    Icons.cloud_sync_rounded,
                    'Cloud synced',
                    'Your tasks are stored securely in the cloud',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureRow(
                    Icons.format_quote_rounded,
                    'Daily motivation',
                    'Get inspired with fresh motivational quotes',
                  ),

                  const Spacer(flex: 2),

                  // ── Google Sign In Button ──
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSigningIn ? null : _handleGoogleSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        disabledBackgroundColor: Colors.white.withAlpha(100),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: _isSigningIn
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Color(0xFF0F0F23),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // We use a generic icon here as a placeholder for Google logo
                                Icon(
                                  Icons.login_rounded,
                                  color: Color(0xFF0F0F23),
                                  size: 22,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Sign in with Google',
                                  style: TextStyle(
                                    color: Color(0xFF0F0F23),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Anonymous Sign-In ──
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _isSigningIn ? null : _handleGetStarted,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: const Color(0xFF6C63FF).withAlpha(100)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Continue Anonymously',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF818CF8), size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withAlpha(100),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
