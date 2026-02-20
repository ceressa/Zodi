import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/horoscope_provider.dart';
import '../providers/coin_provider.dart';
import '../constants/colors.dart';
import '../widgets/animated_card.dart';
import '../widgets/metric_card.dart';
import '../services/ad_service.dart';
import '../screens/premium_screen.dart';
import '../theme/cosmic_page_route.dart';
import '../services/activity_log_service.dart';
import '../services/share_service.dart';
import '../widgets/share_cards/weekly_share_card.dart';

class WeeklyMonthlyScreen extends StatefulWidget {
  const WeeklyMonthlyScreen({super.key});

  @override
  State<WeeklyMonthlyScreen> createState() => _WeeklyMonthlyScreenState();
}

class _WeeklyMonthlyScreenState extends State<WeeklyMonthlyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AdService _adService = AdService();
  final ActivityLogService _activityLog = ActivityLogService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Haftalık veya aylık veri yükle — premium değilse gate dialog göster
  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final horoscopeProvider = context.read<HoroscopeProvider>();

    if (authProvider.selectedZodiac == null) return;

    final isWeekly = _tabController.index == 0;

    if (!authProvider.isPremium) {
      // Free kullanıcı — gentle gate: seçenek sun
      final unlocked = await _showContentGateDialog(isWeekly: isWeekly);
      if (!unlocked) return; // Kullanıcı vazgeçti
    }

    if (isWeekly) {
      try {
        await horoscopeProvider.fetchWeeklyHoroscope(authProvider.selectedZodiac!);
        await _activityLog.logWeeklyHoroscope(authProvider.selectedZodiac!.name);
      } catch (e) {
        debugPrint('❌ Weekly load error: $e');
      }
    } else {
      try {
        await horoscopeProvider.fetchMonthlyHoroscope(authProvider.selectedZodiac!);
        await _activityLog.logMonthlyHoroscope(authProvider.selectedZodiac!.name);
      } catch (e) {
        debugPrint('❌ Monthly load error: $e');
      }
    }
  }

  /// Gentle gate dialog — reklam izle veya Yıldız Tozu harca
  /// Returns true if content unlocked, false if user cancelled
  Future<bool> _showContentGateDialog({required bool isWeekly}) async {
    const int coinCost = 5;
    final coinProvider = context.read<CoinProvider>();
    final canAfford = coinProvider.canAfford(coinCost);
    final label = isWeekly ? 'Haftalık' : 'Aylık';

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.accentPurple, size: 28),
            const SizedBox(width: 10),
            Text('$label Yorum'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label burç yorumuna erişmek için aşağıdaki seçeneklerden birini kullanabilirsin:',
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            // Seçenek 1: Reklam izle
            _buildGateOption(
              icon: Icons.play_circle_filled,
              iconColor: Colors.green,
              label: 'Reklam İzle',
              subtitle: 'Kısa bir reklam izleyerek ücretsiz oku',
              onTap: () => Navigator.pop(ctx, 'ad'),
            ),
            const SizedBox(height: 12),
            // Seçenek 2: Yıldız Tozu harca
            _buildGateOption(
              icon: Icons.auto_awesome,
              iconColor: const Color(0xFFD97706),
              label: '$coinCost Yıldız Tozu',
              subtitle: canAfford
                  ? 'Bakiye: ${coinProvider.balance} ✨'
                  : 'Yetersiz bakiye (${coinProvider.balance} ✨)',
              onTap: canAfford ? () => Navigator.pop(ctx, 'coin') : null,
              isDisabled: !canAfford,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: const Text('Geri Dön'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx, 'premium');
            },
            child: const Text(
              'Premium\'a Geç',
              style: TextStyle(
                color: AppColors.accentPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == null || result == 'cancel') return false;

    if (result == 'premium') {
      if (mounted) {
        Navigator.push(
          context,
          CosmicBottomSheetRoute(page: const PremiumScreen()),
        );
      }
      return false;
    }

    if (result == 'ad') {
      final placement = isWeekly ? 'weekly_unlock' : 'monthly_unlock';
      final watched = await _adService.showRewardedAd(placement: placement);
      if (!watched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Reklam yüklenemedi, biraz sonra tekrar dene!'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return false;
      }
      return true;
    }

    if (result == 'coin') {
      final spent = await coinProvider.spendCoins(
        coinCost,
        isWeekly ? 'weekly_horoscope' : 'monthly_horoscope',
      );
      if (spent) {
        _activityLog.logCoinSpent(coinCost, isWeekly ? 'weekly_horoscope' : 'monthly_horoscope');
        return true;
      }
      return false;
    }

    return false;
  }

  Widget _buildGateOption({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String subtitle,
    required VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDisabled
                  ? Colors.grey.shade300
                  : AppColors.accentPurple.withOpacity(0.3),
            ),
            color: isDisabled
                ? Colors.grey.shade50
                : AppColors.accentPurple.withOpacity(0.05),
          ),
          child: Row(
            children: [
              Icon(icon, color: isDisabled ? Colors.grey : iconColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDisabled ? Colors.grey : const Color(0xFF1E1B4B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDisabled ? Colors.grey : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isDisabled)
                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final horoscopeProvider = context.watch<HoroscopeProvider>();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      body: Column(
        children: [
          // Header with tabs
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 24,
              right: 24,
              bottom: 0,
            ),
            decoration: BoxDecoration(
              color: AppColors.cardLight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDark ? AppColors.textPrimary : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Detaylı Fallar',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.textPrimary : AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  onTap: (_) => _loadData(),
                  indicatorColor: AppColors.accentPurple,
                  labelColor: AppColors.accentPurple,
                  unselectedLabelColor: AppColors.textMuted,
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: const [
                    Tab(text: 'Haftalık'),
                    Tab(text: 'Aylık'),
                  ],
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildWeeklyView(horoscopeProvider, isDark),
                _buildMonthlyView(horoscopeProvider, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyView(HoroscopeProvider provider, bool isDark) {
    if (provider.isLoadingWeekly) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accentPurple),
      );
    }

    if (provider.weeklyHoroscope == null) {
      return Center(
        child: Text(
          'Haftalık fal yüklenemedi',
          style: TextStyle(
            color: isDark ? AppColors.textSecondary : AppColors.textMuted,
          ),
        ),
      );
    }

    final weekly = provider.weeklyHoroscope!;

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.accentPurple,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Week range
            AnimatedCard(
              gradient: AppColors.purpleGradient,
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    weekly.weekRange,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Summary
            AnimatedCard(
              delay: 100.ms,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Haftanın Özeti',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimary : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    weekly.summary,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Categories
            AnimatedCard(
              delay: 200.ms,
              child: Column(
                children: [
                  _buildCategoryItem(Icons.favorite, 'Aşk', weekly.love, isDark),
                  const Divider(height: 24),
                  _buildCategoryItem(Icons.work, 'Kariyer', weekly.career, isDark),
                  const Divider(height: 24),
                  _buildCategoryItem(Icons.favorite_border, 'Sağlık', weekly.health, isDark),
                  const Divider(height: 24),
                  _buildCategoryItem(Icons.attach_money, 'Para', weekly.money, isDark),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Highlights
            if (weekly.highlights.isNotEmpty)
              AnimatedCard(
                delay: 300.ms,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.gold, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Öne Çıkanlar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimary : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...weekly.highlights.map((h) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('✨ ', style: TextStyle(fontSize: 16)),
                          Expanded(
                            child: Text(
                              h,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Warnings
            if (weekly.warnings.isNotEmpty)
              AnimatedCard(
                delay: 400.ms,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Dikkat Et',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimary : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...weekly.warnings.map((w) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('⚠️ ', style: TextStyle(fontSize: 16)),
                          Expanded(
                            child: Text(
                              w,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),

          // ─── Paylaş Butonu ───
          const SizedBox(height: 20),
          _buildWeeklyShareButton(weekly),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyShareButton(dynamic weekly) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _shareWeekly(weekly),
          borderRadius: BorderRadius.circular(16),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.share_rounded, size: 18, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Haftalık Yorumu Paylaş',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Future<void> _shareWeekly(dynamic weekly) async {
    final authProvider = context.read<AuthProvider>();
    final zodiac = authProvider.selectedZodiac;

    final card = WeeklyShareCard(
      weekRange: weekly.weekRange,
      summary: weekly.summary,
      love: weekly.love,
      career: weekly.career,
      health: weekly.health,
      money: weekly.money,
      highlights: List<String>.from(weekly.highlights ?? []),
      zodiacSymbol: zodiac?.symbol,
      zodiacName: zodiac?.displayName,
    );

    await ShareService().shareCardWidget(
      context,
      card,
      text: '${zodiac?.symbol ?? ''} Haftalık Burç Yorumum — Astro Dozi\n#AstroDozi #HaftalıkBurç',
    );
  }

  Widget _buildMonthlyView(HoroscopeProvider provider, bool isDark) {
    if (provider.isLoadingMonthly) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accentPurple),
      );
    }

    if (provider.monthlyHoroscope == null) {
      return Center(
        child: Text(
          'Aylık fal yüklenemedi',
          style: TextStyle(
            color: isDark ? AppColors.textSecondary : AppColors.textMuted,
          ),
        ),
      );
    }

    final monthly = provider.monthlyHoroscope!;

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.accentPurple,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month
            AnimatedCard(
              gradient: AppColors.cosmicGradient,
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    monthly.month,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Scores
            Row(
              children: [
                Expanded(
                  child: AnimatedCard(
                    delay: 100.ms,
                    child: MetricCard(
                      label: 'Aşk',
                      value: monthly.loveScore,
                      icon: Icons.favorite,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedCard(
                    delay: 150.ms,
                    child: MetricCard(
                      label: 'Kariyer',
                      value: monthly.careerScore,
                      icon: Icons.work,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: AnimatedCard(
                    delay: 200.ms,
                    child: MetricCard(
                      label: 'Sağlık',
                      value: monthly.healthScore,
                      icon: Icons.favorite_border,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedCard(
                    delay: 250.ms,
                    child: MetricCard(
                      label: 'Para',
                      value: monthly.moneyScore,
                      icon: Icons.attach_money,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Overview
            AnimatedCard(
              delay: 300.ms,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Genel Bakış',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimary : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    monthly.overview,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Detailed categories
            AnimatedCard(
              delay: 400.ms,
              child: Column(
                children: [
                  _buildCategoryItem(Icons.favorite, 'Aşk Hayatı', monthly.love, isDark),
                  const Divider(height: 24),
                  _buildCategoryItem(Icons.work, 'Kariyer', monthly.career, isDark),
                  const Divider(height: 24),
                  _buildCategoryItem(Icons.favorite_border, 'Sağlık', monthly.health, isDark),
                  const Divider(height: 24),
                  _buildCategoryItem(Icons.attach_money, 'Finans', monthly.money, isDark),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Key dates
            if (monthly.keyDates.isNotEmpty)
              AnimatedCard(
                delay: 500.ms,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.event, color: AppColors.accentBlue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Önemli Tarihler',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimary : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...monthly.keyDates.map((d) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('📅 ', style: TextStyle(fontSize: 16)),
                          Expanded(
                            child: Text(
                              d,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Opportunities
            if (monthly.opportunities.isNotEmpty)
              AnimatedCard(
                delay: 600.ms,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb, color: AppColors.gold, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Fırsatlar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimary : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...monthly.opportunities.map((o) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('💡 ', style: TextStyle(fontSize: 16)),
                          Expanded(
                            child: Text(
                              o,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),

          // ─── Paylaş Butonu ───
          const SizedBox(height: 20),
          _buildMonthlyShareButton(monthly),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyShareButton(dynamic monthly) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _shareMonthly(monthly),
          borderRadius: BorderRadius.circular(16),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.share_rounded, size: 18, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Aylık Yorumu Paylaş',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Future<void> _shareMonthly(dynamic monthly) async {
    final authProvider = context.read<AuthProvider>();
    final zodiac = authProvider.selectedZodiac;

    // Monthly için weekly share card'ı kullanabiliriz — alanları uyumlu
    final card = WeeklyShareCard(
      weekRange: monthly.month,
      summary: monthly.overview,
      love: monthly.love,
      career: monthly.career,
      health: monthly.health,
      money: monthly.money,
      highlights: List<String>.from(monthly.keyDates ?? []),
      zodiacSymbol: zodiac?.symbol,
      zodiacName: zodiac?.displayName,
    );

    await ShareService().shareCardWidget(
      context,
      card,
      text: '${zodiac?.symbol ?? ''} Aylık Burç Yorumum — Astro Dozi\n#AstroDozi #AylıkBurç',
    );
  }

  Widget _buildCategoryItem(IconData icon, String title, String content, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.accentPurple, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimary : AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: isDark ? AppColors.textSecondary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
