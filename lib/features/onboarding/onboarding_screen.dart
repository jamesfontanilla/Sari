import 'package:flutter/material.dart';
import '../../core/database/database_helper.dart';
import '../../core/theme/sari_theme.dart';
import '../../main.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isReplay;
  const OnboardingScreen({super.key, this.isReplay = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  static const List<Map<String, dynamic>> steps = [
    {
      'pose': SariPose.listening,
      'title': 'Sabihin lang',
      'body': 'Magsalita ka lang, ako na ang magsusulat ng benta at utang.',
      'example': '“Si Juan, utang 150 — sardinas at bigas”',
    },
    {
      'pose': SariPose.scanning,
      'title': 'Kunan ang shelf',
      'body': 'Itapat ang camera sa paninda o resibo. Ako na ang bibilang sa istante.',
      'example': 'Sardines ×5 · Noodles ×8 · Tansan ×12',
    },
    {
      'pose': SariPose.insights,
      'title': 'Tanungin mo ako',
      'body': 'Kumikita ba ako? Sino may utang? Sagot ko agad nang 100% offline.',
      'example': 'Gumagana kahit walang internet ✈️',
    },
  ];

  Future<void> _complete() async {
    await DatabaseHelper.instance.setOnboarded(true);
    if (!mounted) return;

    if (widget.isReplay) {
      Navigator.pop(context);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (ctx) => const MainNavigationShell()),
        (route) => false,
      );
    }
  }

  void _next() {
    if (_currentStep < steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentStep == steps.length - 1;

    return Scaffold(
      backgroundColor: SariColors.cream,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: SariColors.cream,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _complete,
            child: const Text(
              'Laktawan',
              style: TextStyle(
                color: SariColors.muted,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // PageView with steps
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: steps.length,
                onPageChanged: (idx) => setState(() => _currentStep = idx),
                itemBuilder: (ctx, i) {
                  final s = steps[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Mascot with subtle shadow
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0x1278481E),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: SariMascot(
                            pose: s['pose'] as SariPose,
                            size: 210,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Title
                        Text(
                          s['title'] as String,
                          style: SariTheme.heading(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: SariColors.ink,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Body
                        Text(
                          s['body'] as String,
                          textAlign: TextAlign.center,
                          style: SariTheme.body(
                            fontSize: 15,
                            color: SariColors.muted,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Example Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: SariColors.border),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A78481E),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            s['example'] as String,
                            textAlign: TextAlign.center,
                            style: SariTheme.body(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: SariColors.orangeDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Foot navigation (Dots + Next Button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  // Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      steps.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentStep == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentStep == index ? SariColors.orange : SariColors.border,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Pill CTA Button
                  SariPillButton(
                    onPressed: _next,
                    icon: isLast ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                    child: Text(
                      isLast ? 'Tara na!' : 'Susunod',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
