import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_service.dart';
import '../services/streak_service.dart';
import '../app.dart';
import 'onboarding_screen.dart';
import 'greeting_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final StreakService _streakService = StreakService();
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _navigateAfterDelay();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 3500));
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final firebaseUser = FirebaseService().currentUser;

    if (firebaseUser != null) {
      await _streakService.recordDailyVisit(firebaseUser.uid);
    }

    Widget nextScreen;
    if (firebaseUser != null) {
      await authProvider.login(
          firebaseUser.displayName ?? 'Gezgin', firebaseUser.email ?? '');
      if (authProvider.hasSelectedZodiac) {
        nextScreen = GreetingScreen(nextScreen: const MainShell());
      } else {
        nextScreen = const OnboardingScreen();
      }
    } else {
      nextScreen = authProvider.isAuthenticated
          ? (authProvider.hasSelectedZodiac
              ? GreetingScreen(nextScreen: const MainShell())
              : const OnboardingScreen())
          : const OnboardingScreen();
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            // Fade + Scale geçiş — splash'tan içeri zoom efekti
            final fadeAnim = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            );
            final scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );
            return FadeTransition(
              opacity: fadeAnim,
              child: ScaleTransition(
                scale: scaleAnim,
                child: child,
              ),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildSplashDesign(),
    );
  }

  Widget _buildSplashDesign() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8F5FF), // Açık lavanta
            Color(0xFFEDE9FE), // Yumuşak mor
            Color(0xFFF5F3FF), // En açık
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Arka plan dekoratif parçacıklar
          ..._buildStarParticles(),

          // Ortadaki logo + karakter bölümü
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // Halo efekti + Logo+Karakter
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                      blurRadius: 80,
                      spreadRadius: 30,
                    ),
                    BoxShadow(
                      color: const Color(0xFFA78BFA).withValues(alpha: 0.08),
                      blurRadius: 120,
                      spreadRadius: 50,
                    ),
                  ],
                ),
                child: Center(
                  child: Hero(
                    tag: 'logo',
                    child: Image.asset(
                      'assets/astro_dozi_logo_char.webp',
                      width: 240,
                      height: 240,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => _buildFallbackLogo(),
                    ),
                  ),
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    duration: 800.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 600.ms),

              const Spacer(flex: 2),

              // Alt kısım — Bardino Logo
              Opacity(
                opacity: 0.7,
                child: Image.asset(
                  'assets/bardino_logo.webp',
                  height: 52,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Text(
                    'Bardino Technology',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF1E1B4B).withValues(alpha: 0.4),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms, duration: 600.ms),

              const SizedBox(height: 24),

              // Loading indicator
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: const Color(0xFFA78BFA).withValues(alpha: 0.5),
                ),
              ).animate().fadeIn(delay: 1000.ms, duration: 600.ms),

              const SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStarParticles() {
    final particles = <Widget>[];
    final size = MediaQuery.of(context).size;

    final starPositions = [
      Offset(size.width * 0.15, size.height * 0.12),
      Offset(size.width * 0.85, size.height * 0.08),
      Offset(size.width * 0.08, size.height * 0.35),
      Offset(size.width * 0.92, size.height * 0.28),
      Offset(size.width * 0.25, size.height * 0.72),
      Offset(size.width * 0.78, size.height * 0.65),
      Offset(size.width * 0.5, size.height * 0.15),
      Offset(size.width * 0.65, size.height * 0.82),
      Offset(size.width * 0.12, size.height * 0.58),
      Offset(size.width * 0.88, size.height * 0.48),
      Offset(size.width * 0.35, size.height * 0.88),
      Offset(size.width * 0.55, size.height * 0.25),
    ];

    for (int i = 0; i < starPositions.length; i++) {
      final pos = starPositions[i];
      final starSize = 2.0 + (i % 3) * 1.5;

      particles.add(
        Positioned(
          left: pos.dx,
          top: pos.dy,
          child: Container(
            width: starSize,
            height: starSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFA78BFA).withValues(alpha: 0.2 + (i % 4) * 0.10),
            ),
          )
              .animate(
                onPlay: (c) => c.repeat(reverse: true),
                delay: Duration(milliseconds: i * 200),
              )
              .fadeIn(duration: 1500.ms)
              .then()
              .fadeOut(duration: 1500.ms),
        ),
      );
    }

    return particles;
  }

  Widget _buildFallbackLogo() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
        ),
      ),
      child: const Icon(Icons.auto_awesome, size: 80, color: Colors.white),
    );
  }
}
