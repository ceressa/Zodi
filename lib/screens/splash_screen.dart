import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_service.dart';
import '../services/streak_service.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../app.dart'; // Yeni app.dart
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _videoController;
  bool _showVideo = true;
  final StreakService _streakService = StreakService();

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _navigateAfterDelay();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset('assets/zodi_splash.mp4');
      await _videoController!.initialize();
      await _videoController!.setLooping(false);
      await _videoController!.setVolume(0.0); // Sesi kapat
      await _videoController!.play();
      
      if (mounted) {
        setState(() {});
      }
      
      // Video bitince logo'ya geç
      _videoController!.addListener(() {
        if (_videoController!.value.position >= _videoController!.value.duration) {
          if (mounted) {
            setState(() {
              _showVideo = false;
            });
          }
        }
      });
    } catch (e) {
      print('Video yüklenemedi: $e');
      setState(() {
        _showVideo = false;
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 3500));
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final firebaseUser = FirebaseService().currentUser;
    
    // Record daily visit for streak tracking
    if (firebaseUser != null) {
      await _streakService.recordDailyVisit(firebaseUser.uid);
    }
    
    Widget nextScreen;
    if (firebaseUser != null) {
      await authProvider.login(firebaseUser.displayName ?? 'Gezgin', firebaseUser.email ?? '');
      nextScreen = authProvider.hasSelectedZodiac ? const MainShell() : const OnboardingScreen();
    } else {
      nextScreen = authProvider.isAuthenticated 
          ? (authProvider.hasSelectedZodiac ? const MainShell() : const OnboardingScreen())
          : const OnboardingScreen();
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Colors.white, // Beyaz arka plan
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video veya Logo
          if (_showVideo && _videoController != null && _videoController!.value.isInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            )
          else
            _buildLogoScreen(isDark),
        ],
      ),
    );
  }

  Widget _buildLogoScreen(bool isDark) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white, // Beyaz arka plan
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo - Sadece logo, metin yok
              Container(
                padding: const EdgeInsets.all(20),
                child: Image.asset(
                  'assets/zodi_logo.webp',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => _buildFallbackLogo(),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2.seconds, curve: Curves.easeInOut)
              .shimmer(delay: 1.seconds, duration: 2.seconds, color: Colors.white24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackLogo() {
    return Container(
      width: 180,
      height: 180,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.purpleGradient,
      ),
      child: const Icon(Icons.auto_awesome, size: 80, color: Colors.white),
    );
  }
}