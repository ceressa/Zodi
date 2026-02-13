import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'providers/auth_provider.dart';
import 'pages/daily_comment_page.dart';
import 'pages/analysis_page.dart';
import 'pages/compatibility_page.dart';
import 'pages/discover_page.dart';
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
      title: 'Zodi',
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
    AnalysisPage(),
    CompatibilityPage(),
    DiscoverPage(),
    SettingsPage(),
  ];
  
  @override
  void initState() {
    super.initState();
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
            AppHeader(
              streakCount: _streakData?.currentStreak ?? 0,
              coinCount: 0,
            ),
            Expanded(
              child: _pages[_currentIndex],
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
