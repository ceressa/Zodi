import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/horoscope_provider.dart';
import '../constants/colors.dart';
import '../widgets/animated_card.dart';
import '../widgets/metric_card.dart';
import '../services/ad_service.dart';
import '../screens/premium_screen.dart';
import '../theme/cosmic_page_route.dart';
import '../services/activity_log_service.dart';
import '../services/usage_limit_service.dart';
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
  final UsageLimitService _usageLimitService = UsageLimitService();

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

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final horoscopeProvider = context.read<HoroscopeProvider>();

    if (authProvider.selectedZodiac == null) return;

    if (_tabController.index == 0) {
      // Haftalık — premium değilse interstitial göster
      if (!authProvider.isPremium) {
        await _adService.showInterstitialAd();
      }
      try {
        await horoscopeProvider.fetchWeeklyHoroscope(authProvider.selectedZodiac!);
        await _activityLog.logWeeklyHoroscope(authProvider.selectedZodiac!.name);
      } catch (e) {
        debugPrint('❌ Weekly load error: $e');
      }
    } else {
      // Aylık — limit kontrolü
      if (!authProvider.isPremium) {
        final canView = await _usageLimitService.canViewMonthlyHoroscope();
        if (!canView) {
          // Limit dolmuş — reklam izle dialog'u göster
          if (mounted) {
            _showMonthlyLimitDialog();
          }
          return;
        }
        await _usageLimitService.incrementMonthlyView();
      }
      try {
        await horoscopeProvider.fetchMonthlyHoroscope(authProvider.selectedZodiac!);
        await _activityLog.logMonthlyHoroscope(authProvider.selectedZodiac!.name);
      } catch (e) {
        debugPrint('❌ Monthly load error: $e');
      }
    }
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Özellik'),
        content: const Text('Haftalık ve aylık yorumlar premium kullanıcılar için özel bir özelliktir. Reklam izleyerek veya premium üyelikle erişebilirsin.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                CosmicBottomSheetRoute(page: const PremiumScreen()),
              );
            },
            child: const Text('Premium\'a Geç'),
          ),
        ],
      ),
    );
  }

  void _showMonthlyLimitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.lock_clock, color: AppColors.accentPurple, size: 28),
            SizedBox(width: 10),
            Text('Günlük Limit'),
          ],
        ),
        content: const Text(
          'Bugünkü ücretsiz aylık yorum hakkın doldu.\n\nReklam izleyerek tekrar erişebilir veya Premium üyelikle sınırsız erişim kazanabilirsin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kapat'),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              final watched = await _adService.showRewardedAd(placement: 'monthly_unlock');
              if (watched && mounted) {
                // Reklam izlendi — limiti sıfırla ve veri yükle
                setState(() {});
                _loadMonthlyAfterAd();
              }
            },
            icon: const Icon(Icons.play_circle_filled, size: 20),
            label: const Text('Reklam İzle'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                CosmicBottomSheetRoute(page: const PremiumScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Premium\'a Geç'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadMonthlyAfterAd() async {
    final authProvider = context.read<AuthProvider>();
    final horoscopeProvider = context.read<HoroscopeProvider>();
    if (authProvider.selectedZodiac != null) {
      try {
        await horoscopeProvider.fetchMonthlyHoroscope(authProvider.selectedZodiac!);
        await _activityLog.logMonthlyHoroscope(authProvider.selectedZodiac!.name);
      } catch (e) {
        debugPrint('❌ Monthly load error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final horoscopeProvider = context.watch<HoroscopeProvider>();
    
    return Scaffold(
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
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
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
