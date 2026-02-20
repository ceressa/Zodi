import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'providers/auth_provider.dart';
import 'providers/coin_provider.dart';
import 'config/membership_config.dart';
import 'pages/daily_comment_page.dart';
import 'pages/fallar_page.dart';
import 'pages/chatbot_page.dart';
import 'pages/settings_page.dart';
import 'widgets/app_header.dart';
import 'widgets/bottom_nav.dart';
import 'services/streak_service.dart';
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

  final _pages = const [
    DailyCommentPage(),
    FallarPage(),
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

    await coinProvider.loadBalance();

    if (!mounted) return;

    // Show initial balance snackbar for new users
    if (coinProvider.initialBonusAwarded > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.card_giftcard_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Hoş geldin! 🎉 +${coinProvider.initialBonusAwarded} Yıldız Tozu hediye!',
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
    if (mounted && coinProvider.lastDailyBonus > 0) {
      // Small delay to not overlap with initial bonus
      await Future.delayed(Duration(milliseconds: coinProvider.initialBonusAwarded > 0 ? 2000 : 0));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Günlük bonus: +${coinProvider.lastDailyBonus} Yıldız Tozu!',
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
                  _buildSummaryRow('🌈 Aura Okuma', '8 ✨'),
                  _buildSummaryRow('📊 Detaylı Analiz', '10 ✨'),
                  _buildSummaryRow('🔢 Numeroloji', '5 ✨'),
                  _buildSummaryRow('🕰️ Geçmiş Yaşam', '12 ✨'),
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
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
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
        bottomNavigationBar: BottomNav(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
        ),
      ),
    );
  }
}
