import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'providers/auth_provider.dart';
import 'providers/coin_provider.dart';
import 'config/membership_config.dart';
import 'pages/daily_comment_page.dart';
import 'pages/fallar_page.dart';
import 'pages/kesfet_page.dart';
import 'pages/chatbot_page.dart';
import 'pages/settings_page.dart';
import 'widgets/app_header.dart';
import 'widgets/bottom_nav.dart';
import 'services/streak_service.dart';
import 'services/ad_service.dart';
import 'services/firebase_service.dart';
import 'services/activity_log_service.dart';
import 'models/streak_data.dart';
import 'screens/premium_screen.dart';
import 'theme/cosmic_page_route.dart';

class ZodiApp extends StatelessWidget {
  const ZodiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Astro Dozi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  StreakData? _streakData;
  final StreakService _streakService = StreakService();
  final AdService _adService = AdService();
  final FirebaseService _firebaseService = FirebaseService();
  bool _isFabLoading = false;

  final _pages = const [
    DailyCommentPage(),
    FallarPage(),
    KesfetPage(),
    ChatbotPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadStreakData();
    _loadCoinData();
  }

  Future<void> _loadCoinData() async {
    final authProvider = context.read<AuthProvider>();
    final coinProvider = context.read<CoinProvider>();

    // Set tier on coin provider for tier-aware bonuses
    coinProvider.setTier(authProvider.membershipTier);

    // Firebase'den coin bakiyesini al (senkronizasyon için)
    int? firebaseBalance;
    try {
      final profile = authProvider.userProfile;
      if (profile != null) {
        firebaseBalance = profile.coinBalance;
      }
    } catch (e) {
      debugPrint('⚠️ Firebase coin read error: $e');
    }

    await coinProvider.loadBalance(firebaseBalance: firebaseBalance);

    if (!mounted) return;

    // Bonus mesajları sadece bir kez gösterilir (consumeBonusMessage sonrası tekrar gösterilmez)
    final initialBonus = coinProvider.initialBonusAwarded;
    final dailyBonus = coinProvider.lastDailyBonus;

    // Show initial balance snackbar for new users
    if (initialBonus > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.card_giftcard_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Hoş geldin! 🎉 +$initialBonus Yıldız Tozu hediye!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF7C3AED),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
    }

    // Show daily bonus snackbar
    if (mounted && dailyBonus > 0) {
      // Small delay to not overlap with initial bonus
      await Future.delayed(Duration(milliseconds: initialBonus > 0 ? 2000 : 0));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Günlük bonus: +$dailyBonus Yıldız Tozu!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF7C3AED),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    // Mesajları tüket — widget tekrar mount edilse bile gösterilmez
    coinProvider.consumeBonusMessage();
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

  /// Yıldız Tozu özet bottom sheet — bakiye + harcama rehberi + satın al
  void _showCoinSummarySheet(CoinProvider coinProvider, AuthProvider authProvider) {
    final tierConfig = MembershipTierConfig.getConfig(authProvider.membershipTier);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8F5FF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: Color(0xFFD97706), size: 24),
                SizedBox(width: 10),
                Text(
                  'Yıldız Tozu',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Balance card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD97706).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Mevcut Bakiye',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${coinProvider.balance} ✨',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Earning summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kazanım Bilgileri',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E1B4B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow('🎁 Günlük Bonus', '+${tierConfig.dailyBonus}/gün'),
                  _buildSummaryRow('📺 Reklam Ödülü', '+${tierConfig.adReward}/reklam'),
                  _buildSummaryRow('🔥 Streak Bonus (7 gün)', '+15'),
                  _buildSummaryRow('📦 Üyelik', tierConfig.displayName),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Feature costs
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Harcama Rehberi',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E1B4B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow('🔮 Tarot Falı', '5 ✨'),
                  _buildSummaryRow('💕 Burç Uyumu', '5 ✨'),
                  _buildSummaryRow('📊 Detaylı Analiz', '10 ✨'),
                  _buildSummaryRow('🛤️ Yaşam Yolu', '8 ✨'),
                  _buildSummaryRow('🕰️ Geçmiş Yaşam', '15 ✨'),
                  _buildSummaryRow('🎨 Ruh Eşi Çizimi', '100 ✨'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Buy button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    CosmicBottomSheetRoute(page: const PremiumScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Yıldız Tozu Satın Al',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E1B4B),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // === Ana içerik ===
            Column(
              children: [
                Consumer2<CoinProvider, AuthProvider>(
                  builder: (context, coinProvider, authProvider, _) => AppHeader(
                    streakCount: _streakData?.currentStreak ?? 0,
                    coinCount: coinProvider.balance,
                    zodiacSymbol: authProvider.selectedZodiac?.symbol,
                    userName: authProvider.userName,
                    onCoinTap: () => _showCoinSummarySheet(coinProvider, authProvider),
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey<int>(_currentIndex),
                      child: _pages[_currentIndex],
                    ),
                  ),
                ),
              ],
            ),

            // === FAB — Yıldız Tozu kazan (Settings hariç) ===
            if (_currentIndex != 4 && _buildEarnGoldFab(authProvider) != null)
              Positioned(
                right: 16,
                bottom: 90,
                child: _buildEarnGoldFab(authProvider)!,
              ),
          ],
        ),
        bottomNavigationBar: BottomNav(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
        ),
      ),
    );
  }

  /// Yıldız Tozu kazan FAB — reklam izle, Yıldız Tozu kazan
  Widget? _buildEarnGoldFab(AuthProvider authProvider) {
    // Platinyum kullanıcılar için reklam kapalı, FAB gösterme
    final tier = authProvider.membershipTier;
    if (tier == MembershipTier.platinyum) {
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
          BoxShadow(
            color: Colors.white.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(-2, -2),
          ),
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
                    '+${coinProvider.adRewardAmount} Yıldız Tozu kazandın!',
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
            backgroundColor: Colors.orange.shade700,
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
      _adService.loadRewardedAd();
    }
  }
}
