import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FeatureCard extends StatefulWidget {
  final String icon;
  final String title;
  final String desc;
  final Color iconBg;
  final int index;
  final Color ink;
  final Color cream2;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.desc,
    required this.iconBg,
    required this.index,
    required this.ink,
    required this.cream2,
  });

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: 300.ms,
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 24),
        transform: Matrix4.identity()
          ..scale(_isHovered ? 1.03 : 1.0)
          ..translate(0.0, _isHovered ? -8.0 : 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered ? widget.iconBg : widget.cream2,
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.ink.withOpacity(_isHovered ? 0.12 : 0.03),
              blurRadius: _isHovered ? 40 : 20,
              offset: Offset(0, _isHovered ? 20 : 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: AnimatedContainer(
                  duration: 300.ms,
                  width: _isHovered ? 140 : 100,
                  height: _isHovered ? 140 : 100,
                  decoration: BoxDecoration(
                    color: widget.iconBg.withOpacity(_isHovered ? 0.5 : 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: widget.iconBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(widget.icon, style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.title,
                      style: GoogleFonts.syne(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: widget.ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.desc,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        color: widget.ink.withOpacity(0.6),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (400 + (widget.index * 150)).ms, duration: 600.ms).slideX(begin: 0.1, end: 0);
  }
}
