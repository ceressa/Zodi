import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/horoscope_provider.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../widgets/metric_card.dart';
import '../widgets/animated_card.dart';
import '../widgets/zodi_loading.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/feedback_widget.dart';
import '../services/ad_service.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';
import '../services/share_service.dart';
import '../services/usage_limit_service.dart';
import '../services/activity_log_service.dart';
import '../widgets/share_cards/daily_share_card.dart';
import '../widgets/limit_reached_dialog.dart';

class DailyScreen extends StatefulWidget {
  const DailyScreen({super.key});

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final AdService _adService = AdService();
  final FirebaseService _firebaseService = FirebaseService();
  final StorageService _storageService = StorageService();
  final UsageLimitService _usageLimitService = UsageLimitService();
  final ActivityLogService _activityLog = ActivityLogService();
  late ConfettiController _confettiController;
  late AnimationController _pulseController;
  bool _showTomorrowPreview = false;
  String? _tomorrowPreview;
  DateTime? _sessionStartTime;
  bool _isLoadingTomorrow = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _sessionStartTime = DateTime.now();
    _loadTomorrowPreviewFromCache();
  }

  Future<void> _loadTomorrowPreviewFromCache() async {
    final cache = await _storageService.getTomorrowHoroscope();
    if (cache != null) {
      final cachedDate = cache['date'] as DateTime;
      final today = DateTime.now();
      final tomorrow = DateTime(today.year, today.month, today.day)
          .add(const Duration(days: 1));

      if (cachedDate.year == tomorrow.year &&
          cachedDate.month == tomorrow.month &&
          cachedDate.day == tomorrow.day) {
        final preview = cache['preview'] as String?;
        if (preview != null && preview.isNotEmpty) {
          if (mounted) {
            setState(() {
              _showTomorrowPreview = true;
              _tomorrowPreview = preview;
            });
          }
        }
      } else {
        await _storageService.clearTomorrowCache();
      }
    }
  }

  @override
  void dispose() {
    if (_sessionStartTime != null) {
      final duration = DateTime.now().difference(_sessionStartTime!).inMinutes;
      if (duration > 0) {
        _firebaseService.updateSessionInfo(duration);
      }
    }

    _confettiController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadHoroscope() async {
    final authProvider = context.read<AuthProvider>();
    final horoscopeProvider = context.read<HoroscopeProvider>();

    // Premium değilse limit kontrolü
    if (!authProvider.isPremium) {
      final canView = await _usageLimitService.canViewDailyComment();
      if (!canView) {
        if (mounted) {
          LimitReachedDialog.showDailyCommentLimit(
            context,
            onAdWatched: () {
              // Reklam izlendikten sonra yeniden yükle
              _loadHoroscope();
            },
          );
        }
        return;
      }
    }

    if (authProvider.selectedZodiac != null) {
      final readStartTime = DateTime.now();

      await horoscopeProvider.fetchDailyHoroscope(authProvider.selectedZodiac!);
      _confettiController.play();

      // Premium değilse sayacı artır
      if (!authProvider.isPremium) {
        await _usageLimitService.incrementDailyComment();
        
        // Kalan hakkı göster
        final remaining = await _usageLimitService.getRemainingDailyComments();
        if (mounted && remaining > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bugün için $remaining yorum hakkın kaldı'),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }

      // Log activity
      await _activityLog.logDailyHoroscope(authProvider.selectedZodiac!.name);
      
      if (_firebaseService.isAuthenticated) {
        _firebaseService.incrementFeatureUsage('daily_horoscope');
        _firebaseService.updateConsecutiveDays();
        _firebaseService
            .updateLastViewedZodiacSign(authProvider.selectedZodiac!.name);
        final readDuration = DateTime.now().difference(readStartTime).inSeconds;
        _firebaseService.updateReadingPatterns('daily', readDuration);
        _firebaseService.updatePreferredReadingTime();
        _firebaseService.updateFavoriteTopics('daily_horoscope');
        _firebaseService.updateUserTags();
        _firebaseService.logHoroscopeView(
            authProvider.selectedZodiac!.name, 'daily');
      }
    }
  }

  Future<void> _unlockTomorrowWithAd() async {
    if (_showTomorrowPreview || _isLoadingTomorrow) return;

    try {
      if (!mounted) return;

      setState(() => _isLoadingTomorrow = true);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.accentPurple),
        ),
      );

      final success =
          await _adService.showRewardedAd(placement: 'daily_tomorrow_preview');
      await _firebaseService.logAdWatched(
        'rewarded_tomorrow_preview',
        placement: 'daily_tomorrow_preview',
        outcome: success ? 'success' : _adService.lastRewardedDecision,
        audienceSegment: _adService.audienceSegment,
      );

      if (mounted) Navigator.of(context).pop();

      if (success && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const ZodiLoading(message: 'Yarının ipuçları okunuyor...'),
        );

        final authProvider = context.read<AuthProvider>();
        if (authProvider.selectedZodiac != null) {
          try {
            final horoscopeProvider = context.read<HoroscopeProvider>();
            final preview = await horoscopeProvider
                .fetchTomorrowPreview(authProvider.selectedZodiac!);

            if (mounted) Navigator.of(context).pop();

            setState(() {
              _showTomorrowPreview = true;
              _tomorrowPreview = preview;
              _isLoadingTomorrow = false;
            });

            horoscopeProvider
                .fetchTomorrowHoroscope(
              authProvider.selectedZodiac!,
              preview: preview,
            )
                .then((_) {
              debugPrint('Tomorrow FULL horoscope cached');
            }).catchError((e) {
              debugPrint('Failed to cache tomorrow horoscope: $e');
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Yarınki ipucu kilidi açıldı!'),
                  backgroundColor: AppColors.positive,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
              _confettiController.play();
            }
          } catch (e) {
            if (mounted) Navigator.of(context).pop();

            setState(() {
              _showTomorrowPreview = true;
              _tomorrowPreview =
                  'Yarın senin için harika bir gün olacak! Yeni fırsatlar kapıda bekliyor.';
              _isLoadingTomorrow = false;
            });
          }
        }
      } else if (mounted) {
        setState(() => _isLoadingTomorrow = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Reklam henüz hazır değil. Birkaç saniye sonra tekrar deneyin.'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingTomorrow = false);
        Navigator.of(context, rootNavigator: true)
            .popUntil((route) => route.isFirst);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppColors.negative,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final horoscopeProvider = context.watch<HoroscopeProvider>();

    final bgColor = isDark ? const Color(0xFF1F2338) : const Color(0xFFF4F1F8);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [
                AppColors.accentPurple,
                AppColors.accentBlue,
                AppColors.accentPink,
                AppColors.gold,
              ],
            ),
          ),
          RefreshIndicator(
            onRefresh: _loadHoroscope,
            color: AppColors.accentPurple,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (horoscopeProvider.isLoadingDaily)
                    const ZodiLoading(message: 'Yorum hazırlanıyor...')
                  else if (horoscopeProvider.dailyHoroscope == null)
                    _buildWelcomeSection(isDark, authProvider)
                  else
                    _buildHoroscopeContent(isDark, authProvider, horoscopeProvider),
                  if (horoscopeProvider.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: Text(horoscopeProvider.error ?? AppStrings.error,
                          style: const TextStyle(color: AppColors.negative)),
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(bool isDark, AuthProvider authProvider) {
    final softText = isDark ? AppColors.textSecondary : const Color(0xFF666387);
    final dateStr = DateFormat('d MMMM EEEE', 'tr_TR').format(DateTime.now());

    return Column(
      children: [
        const SizedBox(height: 20),

        // Animated Zodi character with pulse
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = 1.0 + (_pulseController.value * 0.05);
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentPurple.withOpacity(0.15),
                  Colors.transparent,
                ],
                radius: 1.2,
              ),
            ),
            child: Center(
              child: Image.asset(
                'assets/dozi_char.webp',
                width: 120,
                height: 120,
                errorBuilder: (_, __, ___) => Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.accentPurple, AppColors.accentBlue],
                    ),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 48),
                ),
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: -0.1, end: 0, duration: 600.ms),

        const SizedBox(height: 20),

        // Greeting
        Text(
          'Merhaba, ${authProvider.userName ?? "Yıldız Gezgini"}!',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 500.ms),

        const SizedBox(height: 8),

        // Zodiac badge
        if (authProvider.selectedZodiac != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF3D3470), const Color(0xFF2A2D5E)]
                    : [const Color(0xFFE8DFFF), const Color(0xFFD5CCFF)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  authProvider.selectedZodiac!.symbol,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  authProvider.selectedZodiac!.displayName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.accentPurple : const Color(0xFF6B5DAF),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 350.ms, duration: 500.ms)
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),

        const SizedBox(height: 10),

        // Date
        Text(
          dateStr,
          style: TextStyle(
            fontSize: 14,
            color: softText,
          ),
        )
            .animate()
            .fadeIn(delay: 450.ms, duration: 400.ms),

        const SizedBox(height: 32),

        // CTA Button - Stunning gradient
        Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8C79D9), Color(0xFF6B8AE8), Color(0xFFA78BFA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPurple.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _loadHoroscope,
              borderRadius: BorderRadius.circular(18),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    const Text(
                      'Günlük Yorumunu Keşfet',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 550.ms, duration: 500.ms)
            .slideY(begin: 0.2, end: 0, delay: 550.ms, duration: 500.ms),

        const SizedBox(height: 16),

        Text(
          'Tek dokunuşla bugünün yorum akışını başlat',
          style: TextStyle(fontSize: 13, color: softText),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(delay: 650.ms, duration: 400.ms),
      ],
    );
  }

  Widget _buildHoroscopeContent(
      bool isDark, AuthProvider authProvider, HoroscopeProvider horoscopeProvider) {
    final softText = isDark ? AppColors.textSecondary : const Color(0xFF666387);
    final horoscope = horoscopeProvider.dailyHoroscope!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Motto Card
        _buildMottoCard(horoscope.motto),
        const SizedBox(height: 14),

        // Commentary
        AnimatedCard(
          delay: 100.ms,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bugünün Yorumu',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimary
                          : AppColors.textDark)),
              const SizedBox(height: 10),
              Text(horoscope.commentary,
                  style: TextStyle(
                      height: 1.7, color: softText, fontSize: 15)),
              if (!authProvider.isPremium) ...[
                const SizedBox(height: 14),
                const AdBannerWidget(),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Metrics 2x2
        Row(
          children: [
            Expanded(
                child: MetricCard(
                    label: AppStrings.dailyLove,
                    value: horoscope.love,
                    icon: Icons.favorite)),
            const SizedBox(width: 10),
            Expanded(
                child: MetricCard(
                    label: AppStrings.dailyMoney,
                    value: horoscope.money,
                    icon: Icons.attach_money)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: MetricCard(
                    label: AppStrings.dailyHealth,
                    value: horoscope.health,
                    icon: Icons.monitor_heart)),
            const SizedBox(width: 10),
            Expanded(
                child: MetricCard(
                    label: AppStrings.dailyCareer,
                    value: horoscope.career,
                    icon: Icons.work_outline)),
          ],
        ),
        const SizedBox(height: 12),

        // Lucky Color & Number
        AnimatedCard(
          delay: 300.ms,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Icon(Icons.palette_outlined,
                        color: AppColors.accentPurple),
                    const SizedBox(height: 6),
                    Text(AppStrings.dailyLuckyColor,
                        style: TextStyle(fontSize: 12, color: softText)),
                    Text(horoscope.luckyColor,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textDark,
                        )),
                  ],
                ),
              ),
              Container(
                  width: 1,
                  height: 48,
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : const Color(0xFFE6E0F0)),
              Expanded(
                child: Column(
                  children: [
                    Icon(Icons.numbers,
                        color: AppColors.accentPurple),
                    const SizedBox(height: 6),
                    Text(AppStrings.dailyLuckyNumber,
                        style: TextStyle(fontSize: 12, color: softText)),
                    Text('${horoscope.luckyNumber}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textDark,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Paylaş butonu (görsel kart)
        AnimatedCard(
          delay: 350.ms,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.cosmicGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentPurple.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  final card = DailyShareCard(
                    zodiacSymbol: authProvider.selectedZodiac!.symbol,
                    zodiacName: authProvider.selectedZodiac!.displayName,
                    motto: horoscope.motto,
                    commentary: horoscope.commentary,
                    love: horoscope.love,
                    money: horoscope.money,
                    health: horoscope.health,
                    career: horoscope.career,
                    luckyColor: horoscope.luckyColor,
                    luckyNumber: horoscope.luckyNumber,
                  );
                  ShareService().shareCardWidget(
                    context,
                    card,
                    text: '${authProvider.selectedZodiac!.symbol} Günlük Fal — Zodi\n#Zodi #GünlükBurç',
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.share, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Hikaye Olarak Paylaş',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Feedback Card
        AnimatedCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
                backgroundColor: AppColors.accentPurple.withOpacity(0.15),
                child: Icon(Icons.rate_review, color: AppColors.accentPurple)),
            title: Text('Yorumum Nasıldı?',
                style: TextStyle(
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.textDark,
                    fontWeight: FontWeight.w700)),
            subtitle: Text(
                'Geri bildirimini paylaş, deneyimi geliştirelim',
                style: TextStyle(color: softText)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: FeedbackWidget(interactionType: 'daily'),
                ),
              );
            },
          ),
        ),

        // Tomorrow Preview (non-premium)
        if (!authProvider.isPremium) ...[
          const SizedBox(height: 12),
          AnimatedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Yarınki İpucu',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimary
                            : AppColors.textDark)),
                const SizedBox(height: 8),
                Text(
                  _showTomorrowPreview
                      ? (_tomorrowPreview ?? 'Yıldızlar konuşuyor...')
                      : 'Yarının sinyalini şimdi açmak için reklam izle.',
                  style: TextStyle(color: softText, height: 1.45),
                ),
                const SizedBox(height: 12),
                if (!_showTomorrowPreview)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isLoadingTomorrow
                          ? null
                          : _unlockTomorrowWithAd,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accentPurple,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.play_circle_outline),
                      label: Text(_isLoadingTomorrow
                          ? 'Açılıyor...'
                          : 'Reklam İzle & Aç'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMottoCard(String motto) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedCard(
      elevation: 15,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF5B4FA0), const Color(0xFF4A5EB0)]
                : [const Color(0xFF7D88C7), const Color(0xFF8B7FC7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        child: Stack(
          children: [
            Positioned(
              right: -15,
              top: -15,
              child: Icon(
                Icons.format_quote,
                size: 90,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            Column(
              children: [
                const Text(
                  'GÜNÜN MOTTOSU',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  motto,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().scale(delay: 200.ms);
  }
}
