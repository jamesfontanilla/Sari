import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/sari_theme.dart';
import 'onboarding_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  int _messageIndex = 0;
  Timer? _messageTimer;

  static const List<String> messages = [
    "Hi, ako si Sari, gabay mo sa pagtitinda!",
    "Sabihin mo lang, ako na ang magsusulat.",
    "Kunan mo ang paninda, ako na ang bibilang!",
    "Tanungin mo ako kung kumikita ka ngayon.",
    "Gumagana ako kahit walang internet!",
  ];

  @override
  void initState() {
    super.initState();
    // Gentle floating and breathing animation for Sari mascot
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Rotate speech bubble messages
    _messageTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % messages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _messageTimer?.cancel();
    super.dispose();
  }

  void _onStart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background landscape illustration
          Image.asset(
            'assets/sari/bg-welcome.webp',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: SariColors.cream),
          ),

          // Warm translucent gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.55),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // App Brand Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '🏪 Sari',
                              style: SariTheme.wordmark(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: SariColors.orange,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '· AI Tindera',
                              style: SariTheme.body(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: SariColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Speech Bubble with dynamic message
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.15),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: Container(
                      key: ValueKey<int>(_messageIndex),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      constraints: const BoxConstraints(maxWidth: 320),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: SariColors.orangeSoft, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        messages[_messageIndex],
                        textAlign: TextAlign.center,
                        style: SariTheme.heading(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: SariColors.ink,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Animated Floating Mascot
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      final floatOffset = math.sin(_animController.value * 2 * math.pi) * 10;
                      final scale = 1.0 + 0.02 * math.sin(_animController.value * 2 * math.pi);
                      return Transform.translate(
                        offset: Offset(0, floatOffset),
                        child: Transform.scale(
                          scale: scale,
                          child: child,
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/sari/welcome.png',
                      height: 240,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const SariMascot(
                        pose: SariPose.welcome,
                        size: 220,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Simulan CTA Button
                  SariPillButton(
                    onPressed: _onStart,
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                    icon: Icons.arrow_forward_rounded,
                    child: const Text(
                      'Simulan',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
