import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'providers/auth_provider.dart';
import 'providers/coin_provider.dart';
import 'pages/daily_comment_page.dart';
import 'pages/fallar_page.dart';
import 'pages/chatbot_page.dart';
import 'pages/settings_page.dart';
import 'widgets/app_header.dart';
import 'widgets/bottom_nav.dart';
import 'services/streak_service.dart';
import 'models/streak_data.dart';

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
                'Hoş geldin! 🎉 +${coinProvider.initialBonusAwarded} Altın hediye!',
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
                'Günlük bonus: +${coinProvider.lastDailyBonus} Altın!',
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
