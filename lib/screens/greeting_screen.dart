import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../constants/colors.dart';

/// Splash'tan ana ekrana geçişte gösterilen karşılama ekranı
class GreetingScreen extends StatefulWidget {
  final Widget nextScreen;

  const GreetingScreen({super.key, required this.nextScreen});

  @override
  State<GreetingScreen> createState() => _GreetingScreenState();
}

class _GreetingScreenState extends State<GreetingScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => widget.nextScreen,
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  String _getGreeting(String? name) {
    final hour = DateTime.now().hour;
    final firstName = name?.split(' ').first ?? '';
    if (hour < 6) return 'İyi geceler${firstName.isNotEmpty ? ', $firstName' : ''}!';
    if (hour < 12) return 'Günaydın${firstName.isNotEmpty ? ', $firstName' : ''}!';
    if (hour < 18) return 'İyi günler${firstName.isNotEmpty ? ', $firstName' : ''}!';
    return 'İyi akşamlar${firstName.isNotEmpty ? ', $firstName' : ''}!';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F5FF),
              Color(0xFFEDE9FE),
              Color(0xFFF5F3FF),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Image.asset(
              'assets/astro_dozi_merhaba.webp',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
                  ),
                ),
                child: const Icon(Icons.auto_awesome, size: 60, color: Colors.white),
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.7, 0.7),
                  end: const Offset(1.0, 1.0),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 32),
            Text(
              _getGreeting(authProvider.userName),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E1B4B),
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 500.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 12),
            Text(
              'Yıldızlar seni bekliyor ✨',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF666387),
                fontWeight: FontWeight.w400,
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 500.ms),
            const Spacer(flex: 2),
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accentPurple.withValues(alpha: 0.5),
              ),
            ).animate().fadeIn(delay: 700.ms, duration: 500.ms),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
