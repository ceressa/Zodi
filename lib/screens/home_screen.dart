import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/coin_provider.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../config/membership_config.dart';
import '../theme/curved_clipper.dart';
import '../services/ad_service.dart';
import '../services/streak_service.dart';
import '../services/firebase_service.dart';
import '../services/activity_log_service.dart';
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
  DateTime? _lastBackPress;
  bool _isFabLoading = false;

  @override
  void initState() {
    super.initState();
    _adService.loadInterstitialAd();
    _adService.loadRewardedAd();
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // Diğer tab'lardaysa Explore'a dön
        if (_currentIndex != 0) {
          _pageController.animateToPage(0,
              duration: 300.ms, curve: Curves.easeOutCubic);
          return;
        }

        // Explore tab'ındaysa çift basış ile çık
        final now = DateTime.now();
        if (_lastBackPress != null &&
            now.difference(_lastBackPress!) < const Duration(seconds: 2)) {
          SystemNavigator.pop();
          return;
        }

        _lastBackPress = now;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Çıkmak için tekrar geri bas'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          ),
        );
      },
      child: Scaffold(
        body: Container(
          color: isDark ? const Color(0xFF0F0A2E) : const Color(0xFFF8F5FF),
          child: Stack(
            children: [
              // === Ana içerik: AppBar + PageView ===
              Column(
                children: [
                  _buildCustomAppBar(isDark, authProvider),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      physics: const BouncingScrollPhysics(),
                      children: const [
                        ExploreScreen(),
                        DailyScreen(),
                        MatchScreen(),
                        StatisticsScreen(showAppBar: false),
                        SettingsScreen(),
                      ],
                    ),
                  ),
                ],
              ),

              // === Bottom Navigation — overlay ===
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomNav(isDark),
              ),

              // === FAB — overlay ===
              if (_buildEarnGoldFab(authProvider) != null)
                Positioned(
                  right: 16,
                  bottom: 90,
                  child: _buildEarnGoldFab(authProvider)!,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(bool isDark, AuthProvider authProvider) {
    return ClipPath(
      clipper: CurvedBottomClipper(),
      child: Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 30,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF0F0A2E)]
              : [const Color(0xFFF8F5FF), const Color(0xFFEDE9FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : const Color(0xFF7C3AED).withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo only — markalaştırılmış
          Hero(
            tag: 'logo',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/astro_dozi_logo.webp',
                width: 46,
                height: 46,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                    ),
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 22),
                ),
              ),
            ),
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
    ),
    );
  }

  Widget _buildZodiacBadge(String symbol, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF7C3AED).withOpacity(0.4), const Color(0xFF4C1D95).withOpacity(0.4)]
                  : [const Color(0xFFA78BFA).withOpacity(0.25), const Color(0xFF8B5CF6).withOpacity(0.25)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(isDark ? 0.15 : 0.3),
              width: 1.5,
            ),
          ),
          child: Text(
            symbol,
            style: const TextStyle(fontSize: 22, color: Colors.white),
          ),
        ),
      ),
    );
  }

  /// Altın kazan FAB — reklam izle, coin kazan
  Widget? _buildEarnGoldFab(AuthProvider authProvider) {
    // Elmas ve üstü kullanıcılar için reklam kapalı, FAB gösterme
    final tier = authProvider.membershipTier;
    if (tier == MembershipTier.elmas || tier == MembershipTier.platinyum) {
      return null;
    }

    final coinProvider = context.watch<CoinProvider>();
    final rewardAmount = coinProvider.adRewardAmount;

    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            // Claymorphism — light shadow (üst-sol)
            BoxShadow(
              color: Colors.white.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(-2, -2),
            ),
            // Claymorphism — dark shadow (alt-sağ)
            BoxShadow(
              color: const Color(0xFFD97706).withOpacity(0.45),
              blurRadius: 14,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: _isFabLoading ? null : _onFabTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isFabLoading)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  else
                    const Icon(Icons.monetization_on_rounded,
                        color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    _isFabLoading ? 'İzleniyor...' : '+$rewardAmount 🪙',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().scale(
        delay: 500.ms,
        duration: 400.ms,
        curve: Curves.elasticOut,
      );
  }

  Future<void> _onFabTap() async {
    if (_isFabLoading) return;

    setState(() => _isFabLoading = true);

    try {
      final rewarded = await _adService.showRewardedAd(placement: 'fab_earn_gold');

      if (rewarded && mounted) {
        final coinProvider = context.read<CoinProvider>();
        await coinProvider.earnFromAd();
        ActivityLogService().logCoinEarned(coinProvider.adRewardAmount, 'fab_earn_gold');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    '+${coinProvider.adRewardAmount} altın kazandın!',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFD97706),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Reklam yüklenemedi, biraz sonra tekrar dene!'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ FAB ad error: $e');
    } finally {
      if (mounted) setState(() => _isFabLoading = false);
      // Yeni reklam yükle
      _adService.loadRewardedAd();
    }
  }

  Widget _buildBottomNav(bool isDark) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding > 0 ? bottomPadding : 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E1B4B).withOpacity(0.80)
                  : Colors.white.withOpacity(0.70),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.10)
                    : Colors.white.withOpacity(0.50),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.20)
                      : const Color(0xFF7C3AED).withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.grid_view_outlined, Icons.grid_view_rounded,
              AppStrings.navHome),
          _buildNavItem(1, Icons.wb_sunny_outlined, Icons.wb_sunny_rounded,
              AppStrings.navDaily),
          _buildNavItem(
              2, Icons.favorite_outline_rounded, Icons.favorite_rounded, AppStrings.navMatch),
          _buildNavItem(3, Icons.insights_outlined, Icons.insights_rounded,
              AppStrings.navStatistics),
          _buildNavItem(4, Icons.person_outline_rounded, Icons.person_rounded,
              AppStrings.navProfile),
        ],
      ),
          ),
        ),
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
