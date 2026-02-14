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
    _adService.loadInterstitialAd();
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

    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isPremium) {
      _adService.trackScreenNavigation();

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
      extendBody: true,
      body: Container(
        color: isDark ? const Color(0xFF1E233F) : const Color(0xFFF7F5FB),
        child: Column(
          children: [
            _buildCustomAppBar(isDark, authProvider),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: const [
                  DailyScreen(),
                  ExploreScreen(),
                  MatchScreen(),
                  StatisticsScreen(showAppBar: false),
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
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2C2854), const Color(0xFF1E2448)]
              : [const Color(0xFFF3EDFF), const Color(0xFFE8E0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : AppColors.accentPurple.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo + "Zodi" text
          Row(
            children: [
              Hero(
                tag: 'logo',
                child: ClipOval(
                  child: Image.asset(
                    'assets/zodi_logo.webp',
                    width: 46,
                    height: 46,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentPurple,
                      ),
                      child: const Icon(Icons.auto_awesome,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Zodi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textDark,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          // Streak Badge (center)
          if (_streakData != null)
            CompactStreakBadge(
              streakData: _streakData!,
              onTap: () {
                // Navigate to statistics tab
                _pageController.animateToPage(3,
                    duration: 300.ms, curve: Curves.easeOutCubic);
              },
            ),

          // Zodiac Badge
          if (authProvider.selectedZodiac != null)
            _buildZodiacBadge(authProvider.selectedZodiac!.symbol, isDark),
        ],
      ),
    );
  }

  Widget _buildZodiacBadge(String symbol, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF7C6BC4), const Color(0xFF6B5DAF)]
              : [const Color(0xFFBAAEF0), const Color(0xFFA899E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withOpacity(isDark ? 0.3 : 0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        symbol,
        style: const TextStyle(fontSize: 22, color: Colors.white),
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
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
          _buildNavItem(0, Icons.home_outlined, Icons.home,
              AppStrings.navHome),
          _buildNavItem(1, Icons.explore_outlined, Icons.explore,
              AppStrings.navExplore),
          _buildNavItem(
              2, Icons.favorite_border, Icons.favorite, AppStrings.navMatch),
          _buildNavItem(3, Icons.bar_chart_outlined, Icons.bar_chart,
              AppStrings.navStatistics),
          _buildNavItem(4, Icons.person_outline, Icons.person,
              AppStrings.navProfile),
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
              size: 26,
            ),
            const SizedBox(height: 4),
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
