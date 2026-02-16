import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/streak_data.dart';
import '../services/streak_service.dart';
import '../providers/auth_provider.dart';
import '../constants/colors.dart';
import '../theme/cosmic_page_route.dart';
import '../widgets/metric_card.dart';
import 'premium_screen.dart';

class StatisticsScreen extends StatefulWidget {
  final bool showAppBar;
  const StatisticsScreen({super.key, this.showAppBar = true});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StreakService _streakService = StreakService();
  bool _isLoading = true;
  StreakData? _streakData;
  UserStatistics? _statistics;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.userId;

      if (userId != null) {
        final streakData = await _streakService.getStreakData(userId);
        final statistics = await _streakService.getStatistics(userId);

        setState(() {
          _streakData = streakData;
          _statistics = statistics;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading statistics: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();

    final body = _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Streak Section
                    _buildSectionTitle('Seri', Icons.local_fire_department),
                    const SizedBox(height: 16),
                    _buildStreakCard(),
                    const SizedBox(height: 32),

                    // Activity Section
                    _buildSectionTitle('Aktivite', Icons.trending_up),
                    const SizedBox(height: 16),
                    _buildActivityCards(),
                    const SizedBox(height: 32),

                    // Feature Usage Section
                    _buildSectionTitle('Özellik Kullanımı', Icons.star),
                    const SizedBox(height: 16),
                    _buildFeatureUsageCards(),
                    const SizedBox(height: 32),

                    // Streak Protection (Premium)
                    if (!authProvider.isPremium) ...[
                      _buildPremiumPrompt(),
                      const SizedBox(height: 32),
                    ],

                    // Milestones
                    _buildSectionTitle('Kilometre Taşları', Icons.emoji_events),
                    const SizedBox(height: 16),
                    _buildMilestones(),
                  ],
                ),
              ),
            );

    if (!widget.showAppBar) return body;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: const Text('İstatistikler'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: body,
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.accentPurple,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard() {
    if (_streakData == null) return const SizedBox();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentPurple.withOpacity(0.2),
            AppColors.accentBlue.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentPurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.local_fire_department,
            size: 64,
            color: _getStreakColor(),
          ),
          const SizedBox(height: 16),
          Text(
            '${_streakData!.currentStreak}',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          Text(
            'Gün Üst Üste',
            style: TextStyle(
              fontSize: 18,
              color: isDark
                  ? Colors.white.withOpacity(0.7)
                  : AppColors.textDark.withOpacity(0.7),
            ),
          ),
          if (_streakData!.protectionActive) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gold, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield, color: AppColors.gold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Serin Korumalı',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityCards() {
    if (_statistics == null) return const SizedBox();

    return Row(
      children: [
        Expanded(
          child: MetricCard(
            label: 'Toplam Gün',
            value: _statistics!.totalDaysActive,
            icon: Icons.calendar_today,
            color: AppColors.accentBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: MetricCard(
            label: 'En Uzun Seri',
            value: _statistics!.longestStreak,
            icon: Icons.emoji_events,
            color: AppColors.gold,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureUsageCards() {
    if (_statistics == null || _statistics!.featureUsageCounts.isEmpty) {
      return _buildEmptyState('Henüz özellik kullanımı yok');
    }

    final features = _statistics!.featureUsageCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: features.take(5).map((entry) {
        return _buildFeatureUsageItem(
          _getFeatureName(entry.key),
          entry.value,
          _getFeatureIcon(entry.key),
        );
      }).toList(),
    );
  }

  Widget _buildFeatureUsageItem(String name, int count, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
          ),
          Text(
            '$count kez',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.accentPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestones() {
    if (_streakData == null) return const SizedBox();

    final milestones = [
      {'days': 7, 'title': 'Hafta Savaşçısı', 'icon': Icons.star},
      {'days': 14, 'title': 'İki Hafta Ustası', 'icon': Icons.stars},
      {'days': 30, 'title': 'Ay Şampiyonu', 'icon': Icons.emoji_events},
      {'days': 60, 'title': 'İki Ay Efsanesi', 'icon': Icons.military_tech},
      {'days': 100, 'title': 'Yüz Gün Kahramanı', 'icon': Icons.workspace_premium},
    ];

    return Column(
      children: milestones.map((milestone) {
        final days = milestone['days'] as int;
        final achieved = _streakData!.longestStreak >= days;

        return _buildMilestoneItem(
          milestone['title'] as String,
          days,
          milestone['icon'] as IconData,
          achieved,
        );
      }).toList(),
    );
  }

  Widget _buildMilestoneItem(
    String title,
    int days,
    IconData icon,
    bool achieved,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: achieved
            ? AppColors.accentPurple.withOpacity(0.1)
            : (isDark ? AppColors.cardDark : AppColors.cardLight),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achieved
              ? AppColors.accentPurple
              : (isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: achieved ? AppColors.gold : Colors.grey,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                Text(
                  '$days gün seri',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? Colors.white.withOpacity(0.7)
                        : AppColors.textDark.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (achieved)
            Icon(Icons.check_circle, color: AppColors.positive, size: 24),
        ],
      ),
    );
  }

  Widget _buildPremiumPrompt() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gold.withOpacity(0.2), AppColors.gold.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold, width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.shield, color: AppColors.gold, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Seri Koruması',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Premium üyelikle serini koruma altına al. Bir gün kaçırsan bile serin devam eder!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, CosmicBottomSheetRoute(page: const PremiumScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Premium\'a Geç'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Color _getStreakColor() {
    if (_streakData == null || _streakData!.currentStreak == 0) {
      return Colors.grey;
    } else if (_streakData!.currentStreak < 7) {
      return AppColors.warning;
    } else if (_streakData!.currentStreak < 30) {
      return AppColors.accentPurple;
    } else {
      return AppColors.gold;
    }
  }

  String _getFeatureName(String key) {
    const names = {
      'viewDailyHoroscope': 'Günlük Burç',
      'checkCompatibility': 'Uyumluluk',
      'readDreamInterpretation': 'Rüya Yorumu',
      'viewNatalChart': 'Doğum Haritası',
      'drawTarotCard': 'Tarot',
      'maintainStreak': 'Seri Devam',
      'shareContent': 'Paylaşım',
    };
    return names[key] ?? key;
  }

  IconData _getFeatureIcon(String key) {
    const icons = {
      'viewDailyHoroscope': Icons.today,
      'checkCompatibility': Icons.favorite,
      'readDreamInterpretation': Icons.nightlight,
      'viewNatalChart': Icons.auto_awesome,
      'drawTarotCard': Icons.style,
      'maintainStreak': Icons.local_fire_department,
      'shareContent': Icons.share,
    };
    return icons[key] ?? Icons.star;
  }
}
