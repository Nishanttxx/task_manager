import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';
import '../widgets/feature_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoginTab = true;
  bool _isSigningIn = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  static const Color ink = Color(0xFF0F0E0D);
  static const Color cream = Color(0xFFF7F4EF);
  static const Color cream2 = Color(0xFFEDE9E2);
  static const Color accent = Color(0xFFD9440F);
  static const Color green = Color(0xFF1D7A4F);
  static const Color greenLight = Color(0xFFE3F5EC);

  void _scrollToAuth() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleGoogleSignIn() async {
    debugPrint('Google Sign-In started');
    setState(() => _isSigningIn = true);
    try {
      await AuthService()
          .signInWithGoogle()
          .timeout(const Duration(seconds: 20), onTimeout: () {
        debugPrint('Google Sign-In timed out');
        throw 'Connection timeout. Please try again.';
      });
      debugPrint('Google Sign-In process finished');
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-in failed: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        debugPrint('Resetting loading state');
        setState(() => _isSigningIn = false);
      }
    }
  }

  Future<void> _handleEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || (!_isLoginTab && name.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isSigningIn = true);
    try {
      if (_isLoginTab) {
        await AuthService().signInWithEmail(email, password);
      } else {
        await AuthService().signUpWithEmail(email, password, name);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    }
  }

  Future<void> _handleAnonymousSignIn() async {
    setState(() => _isSigningIn = true);
    try {
      await AuthService().signInAnonymously();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in failed: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _buildNavBar(),
                _buildHero(),
                _buildFeatures(),
                _buildHowItWorks(),
                _buildAuthSection(),
                _buildFooter(),
              ],
            ),
          ),
          if (_isSigningIn)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: accent),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'TaskFlow',
                style: GoogleFonts.syne(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _scrollToAuth,
            style: ElevatedButton.styleFrom(
              backgroundColor: ink,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Text(
              'Get started',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: greenLight,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, size: 8, color: green),
                const SizedBox(width: 8),
                Text(
                  'Now on Android & iOS',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          RichText(
            text: TextSpan(
              style: GoogleFonts.syne(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: ink,
                height: 1.1,
              ),
              children: const [
                TextSpan(text: 'Manage tasks.\n'),
                TextSpan(
                  text: 'Get things done.',
                  style: TextStyle(color: accent),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 20),
          Text(
            'A beautifully simple task manager with Firebase-powered sync, motivational quotes, and everything your team needs to stay on top of work.',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              color: ink.withOpacity(0.6),
              height: 1.6,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 800.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 36),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _scrollToAuth,
                icon: const Icon(Icons.star, size: 16),
                label: const Text('Start for free'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
               .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2.seconds, curve: Curves.easeInOut),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _handleGoogleSignIn,
                icon: Image.network(
                  'https://www.gstatic.com/images/branding/product/2x/googleg_48dp.png',
                  height: 18,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_circle, size: 18),
                ),
                label: const Text('Google'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ink,
                  side: const BorderSide(color: cream2, width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 400.ms, duration: 800.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          Text(
            'No credit card required · Free forever for personal use',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: ink.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 48),
          _buildHeroVisual(),
        ],
      ),
    );
  }

  Widget _buildHeroVisual() {
    return SizedBox(
      height: 400,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5), duration: 3.seconds, curve: Curves.easeInOut),

          // Phone Mockup
          Container(
            width: 200,
            height: 380,
            decoration: BoxDecoration(
              color: ink,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: ink.withOpacity(0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1917),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'My Tasks',
                      style: GoogleFonts.syne(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [accent, Color(0xFFF5A623)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '✦ Daily Inspiration',
                          style: GoogleFonts.dmSans(
                            color: Colors.white70,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '"The secret of getting ahead is getting started."',
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMockTask('Review design specs', true),
                  _buildMockTask('Submit internship code', false),
                  _buildMockTask('Write README.md', false),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 600.ms, duration: 1.seconds).slideY(begin: 0.1, end: 0),

          // Floating Card 1
          Positioned(
            right: 10,
            top: 40,
            child: _buildFloatingCard(
              'Tasks completed',
              '12',
              '↑ 3 today',
              green,
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .moveY(begin: 0, end: -15, duration: 2.seconds, curve: Curves.easeInOut),
          ),

          // Floating Card 2
          Positioned(
            left: 10,
            bottom: 60,
            child: _buildFloatingCard(
              'Active Projects',
              '07',
              'Keep it up!',
              accent,
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .moveY(begin: 0, end: 15, duration: 2.5.seconds, curve: Curves.easeInOut),
          ),
        ],
      ),
    );
  }

  Widget _buildMockTask(String title, bool isDone) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
              color: isDone ? green : Colors.transparent,
            ),
            child: isDone ? const Icon(Icons.check, size: 8, color: Colors.white) : null,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.dmSans(
              color: isDone ? Colors.white38 : Colors.white,
              fontSize: 10,
              decoration: isDone ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingCard(String label, String stat, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ink.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(fontSize: 10, color: ink.withOpacity(0.5)),
          ),
          const SizedBox(height: 4),
          Text(
            stat,
            style: GoogleFonts.syne(fontSize: 22, fontWeight: FontWeight.w700, color: ink),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: GoogleFonts.dmSans(fontSize: 10, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHAT\'S INSIDE',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.w500,
              color: ink.withOpacity(0.4),
            ),
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
          const SizedBox(height: 16),
          Text(
            'Everything you need\nto stay productive',
            style: GoogleFonts.syne(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: ink,
              height: 1.1,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.2, end: 0),
          const SizedBox(height: 48),
          FeatureCard(
            icon: '🔐',
            title: 'Secure Authentication',
            desc: 'Sign up, log in, or continue with Google — powered by Firebase Authentication.',
            iconBg: const Color(0xFFFFE8E0),
            index: 0,
            ink: ink,
            cream2: cream2,
          ),
          FeatureCard(
            icon: '✅',
            title: 'Full Task Control',
            desc: 'Add, edit, delete, and mark tasks complete. Stored in Cloud Firestore.',
            iconBg: const Color(0xFFE3F5EC),
            index: 1,
            ink: ink,
            cream2: cream2,
          ),
          FeatureCard(
            icon: '💬',
            title: 'Daily Motivation',
            desc: 'A fresh motivational quote greets you every session from a live REST API.',
            iconBg: const Color(0xFFE0F2FF),
            index: 2,
            ink: ink,
            cream2: cream2,
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Container(
      width: double.infinity,
      color: ink,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOW IT WORKS',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.4),
            ),
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
          const SizedBox(height: 16),
          Text(
            'Four steps to\na clearer day',
            style: GoogleFonts.syne(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.1,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.2, end: 0),
          const SizedBox(height: 48),
          _buildStep(
            '01',
            'Create an account',
            'Sign up with email or Google. Fast & frictionless.',
            0,
          ),
          _buildStep(
            '02',
            'Add your tasks',
            'Capture tasks with title, description, and due date.',
            1,
          ),
          _buildStep(
            '03',
            'Stay on track',
            'Edit, prioritize, and mark tasks complete.',
            2,
          ),
          _buildStep(
            '04',
            'Get inspired',
            'A daily motivational quote sets the tone.',
            3,
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String num, String title, String desc, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            num,
            style: GoogleFonts.syne(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.syne(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.5),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (200 + (index * 100)).ms, duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildAuthSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ready to start getting things done?',
            style: GoogleFonts.syne(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: ink,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Join thousands of people who use TaskFlow to stay organised, focused, and motivated every single day.',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              color: ink.withOpacity(0.6),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 40),
          _buildAuthCard().animate().fadeIn(delay: 400.ms, duration: 800.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildAuthCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cream2),
        boxShadow: [
          BoxShadow(
            color: ink.withOpacity(0.05),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: cream,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: [
                _buildTabButton('Log in', _isLoginTab, () => setState(() => _isLoginTab = true)),
                _buildTabButton('Sign up', !_isLoginTab, () => setState(() => _isLoginTab = false)),
              ],
            ),
          ),
          const SizedBox(height: 28),
          if (!_isLoginTab)
            _buildTextField('Full name', 'Your name', _nameController),
          const SizedBox(height: 14),
          _buildTextField('Email', 'you@example.com', _emailController),
          const SizedBox(height: 14),
          _buildTextField('Password', '••••••••', _passwordController, obscure: true),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSigningIn ? null : _handleEmailAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: ink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                _isLoginTab ? 'Log in with email' : 'Create account',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: Divider(color: cream2)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('or', style: GoogleFonts.dmSans(fontSize: 12, color: ink.withOpacity(0.4))),
              ),
              const Expanded(child: Divider(color: cream2)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _handleGoogleSignIn,
              icon: Image.network(
                'https://www.gstatic.com/images/branding/product/2x/googleg_48dp.png',
                height: 18,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_circle, size: 18),
              ),
              label: Text(_isLoginTab ? 'Continue with Google' : 'Sign up with Google'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ink,
                side: const BorderSide(color: cream2, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _handleAnonymousSignIn,
              style: TextButton.styleFrom(
                backgroundColor: cream,
                foregroundColor: ink.withValues(alpha: 0.8),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                'Explore without account →',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: ink.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: active ? ink : ink.withOpacity(0.4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: ink.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: ink.withValues(alpha: 0.3)),
            filled: true,
            fillColor: cream,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: cream2, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: cream2, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: ink, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: ink,
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Text(
            'TaskFlow',
            style: GoogleFonts.syne(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Built with Flutter · Firebase · ♥',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '© 2025 TaskFlow. All rights reserved.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
