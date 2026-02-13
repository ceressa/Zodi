import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../services/ad_service.dart';
import '../services/streak_service.dart';
import '../services/firebase_service.dart';
import '../models/streak_data.dart';
import '../widgets/compact_streak_badge.dart';
import 'daily_screen.dart';
import 'analysis_screen.dart';
import 'match_screen.dart';
import 'explore_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  final AdService _adService = AdService();
  final StreakService _streakService = StreakService();
  final FirebaseService _firebaseService = FirebaseService();
  StreakData? _streakData;

  @override
  void initState() {
    super.initState();
    // İlk interstitial ad'i yükle
    _adService.loadInterstitialAd();
    // Streak verilerini yükle
    _loadStreakData();
  }

  Future<void> _loadStreakData() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.userId;

    if (userId != null) {
      final streakData = await _streakService.getStreakData(userId);
      if (mounted) {
        setState(() {
          _streakData = streakData;
        });
      }
    }
  }

  void _onPageChanged(int index) async {
    setState(() => _currentIndex = index);

    // Premium değilse reklam göster
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isPremium) {
      // Ekran navigasyonunu kaydet
      _adService.trackScreenNavigation();

      // Gerekirse interstitial göster
      final shown = await _adService.showInterstitialIfNeeded();
      await _firebaseService.logAdWatched(
        'interstitial_navigation',
        placement: 'home_tab_navigation',
        outcome: shown ? 'shown' : _adService.lastInterstitialDecision,
        audienceSegment: _adService.audienceSegment,
      );
      if (shown) {
        await _firebaseService.logAdWatched(
          'interstitial_navigation',
          placement: 'home_tab_navigation',
          outcome: 'shown',
          audienceSegment: _adService.audienceSegment,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      extendBody: true, // Alt menünün arkasının görünmesi için
      body: Container(
        color: isDark ? const Color(0xFF1E233F) : const Color(0xFFF7F5FB),
        child: Column(
          children: [
            // Custom App Bar
            _buildCustomAppBar(isDark, authProvider),

            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: const [
                  DailyScreen(),
                  AnalysisScreen(),
                  MatchScreen(),
                  ExploreScreen(),
                  SettingsScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  Widget _buildCustomAppBar(bool isDark, AuthProvider authProvider) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 15,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C3256) : const Color(0xFFFFFFFF),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.16)
                : const Color(0x22BDA7F8),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Hero(
            tag: 'logo',
            child: ClipOval(
              child: Image.asset(
                'assets/zodi_logo.webp',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentPurple,
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 24),
                ),
              ),
            ),
          ),

          // Streak Badge (ortada)
          if (_streakData != null)
            CompactStreakBadge(
              streakData: _streakData!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StatisticsScreen(),
                  ),
                );
              },
            ),

          // Burç Badge
          if (authProvider.selectedZodiac != null)
            _buildZodiacBadge(authProvider.selectedZodiac!.symbol, isDark),
        ],
      ),
    );
  }

  Widget _buildZodiacBadge(String symbol, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF8C79D9) : const Color(0xFFB7A7EB),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withOpacity(isDark ? 0.3 : 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        symbol,
        style: const TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xD9262B4E) : const Color(0xEFFFFBFF),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? const Color(0x336D77A8) : const Color(0x33C4B5FD),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.18)
                : const Color(0x1FA78BFA),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.auto_awesome_outlined, Icons.auto_awesome,
              AppStrings.navDaily),
          _buildNavItem(1, Icons.pie_chart_outline, Icons.pie_chart,
              AppStrings.navAnalysis),
          _buildNavItem(
              2, Icons.favorite_border, Icons.favorite, AppStrings.navMatch),
          _buildNavItem(3, Icons.explore_outlined, Icons.explore, 'Keşfet'),
          _buildNavItem(4, Icons.person_outline, Icons.person, 'Profil'),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label) {
    bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(index,
            duration: 300.ms, curve: Curves.easeOutCubic);
      },
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.accentPurple.withOpacity(0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive
                  ? AppColors.accentPurple
                  : Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textTertiary
                      : const Color(0xFF7C83A3),
              size: 28,
            ),
            const SizedBox(height: 6),
            if (isActive)
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: AppColors.accentPurple),
              ).animate().scale(),
          ],
        ),
      ),
    );
  }
}
