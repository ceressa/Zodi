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
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final selectedZodiac = authProvider.selectedZodiac;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.bgLight,
              AppColors.surfaceLight,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(authProvider, selectedZodiac),
              
              // Main Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: [
                    _buildHomeContent(authProvider),
                    const ExploreScreen(),
                    const MatchScreen(),
                    const StatisticsScreen(),
                    const SettingsScreen(),
                  ],
                ),
              ),
              
              // Bottom Navigation
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AuthProvider authProvider, dynamic selectedZodiac) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Merhaba, ${authProvider.userName?.split(' ').first ?? 'Kullanıcı'}! 👋',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (selectedZodiac != null) ...[
                    Text(
                      selectedZodiac.symbol,
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      selectedZodiac.turkishName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ] else
                    const Text(
                      'Burcunu seç!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                ],
              ).animate().fadeIn(delay: 100.ms),
            ],
          ),
          
          // Streak Badge
          if (_streakData != null && _streakData!.currentStreak > 0)
            CompactStreakBadge(streakData: _streakData!),
        ],
      ),
    );
  }

  Widget _buildHomeContent(AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          
          // Zodi Karakter + Mesaj Hero Kartı
          _buildHeroCard().animate().fadeIn(delay: 200.ms),
          
          const SizedBox(height: 24),
          
          // Hızlı Başla Başlığı
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'HIZLI BAŞLA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Detaylı Analiz ve Burç Uyumu Kartları
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  title: 'Detaylı\nAnaliz',
                  icon: Icons.pie_chart_rounded,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF1493), Color(0xFFFF69B4)],
                  ),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalysisScreen())),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  title: 'Burç\nUyumu',
                  icon: Icons.favorite_rounded,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF00BFFF), Color(0xFF1E90FF)],
                  ),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MatchScreen())),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 300.ms),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE0F2FE), // Açık mavi
            Color(0xFFDDD6FE), // Açık mor
            Color(0xFFFCE7F3), // Açık pembe
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // Zodi Karakteri (Animasyonlu)
          _buildAnimatedCharacter(),
          
          const SizedBox(height: 20),
          
          // Mesaj
          const Text(
            'Bugün sana ne\nsöyleyeyim?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              height: 1.2,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Günlük Falına Bak Butonu
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DailyScreen()),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: AppColors.purpleGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentPurple.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Günlük Falına Bak',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward, color: Colors.white.withOpacity(0.8), size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCharacter() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentBlue.withOpacity(0.3),
                  AppColors.accentPurple.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
            child: Center(
              child: Image.asset(
                'assets/dozi_char.webp',
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback: Emoji karakteri
                  return const Text(
                    '👻',
                    style: TextStyle(fontSize: 80),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Ana Sayfa'},
      {'icon': Icons.explore_rounded, 'label': 'Keşfet'},
      {'icon': Icons.favorite_rounded, 'label': 'Yıldızlar'},
      {'icon': Icons.person_rounded, 'label': 'Profil'},
      {'icon': Icons.sticky_note_2_rounded, 'label': 'Notlar'},
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = _currentIndex == index;
              
              return GestureDetector(
                onTap: () {
                  _pageController.jumpToPage(index);
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [
                              Color(0xFFF3E8FF),
                              Color(0xFFFCE7F3),
                            ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        color: isSelected ? AppColors.accentPurple : AppColors.textMuted,
                        size: isSelected ? 26 : 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppColors.accentPurple : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}