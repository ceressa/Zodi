import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
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

class DailyScreen extends StatefulWidget {
  const DailyScreen({super.key});

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen>
    with AutomaticKeepAliveClientMixin {
  final AdService _adService = AdService();
  final FirebaseService _firebaseService = FirebaseService();
  final StorageService _storageService = StorageService();
  late ConfettiController _confettiController;
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
    _sessionStartTime = DateTime.now();
    _loadTomorrowPreviewFromCache();
  }

  Future<void> _loadTomorrowPreviewFromCache() async {
    // Storage'dan yarın önizlemesini yükle
    final cache = await _storageService.getTomorrowHoroscope();
    if (cache != null) {
      final cachedDate = cache['date'] as DateTime;
      final today = DateTime.now();
      final tomorrow = DateTime(today.year, today.month, today.day)
          .add(const Duration(days: 1));

      // Eğer cache yarın için geçerliyse
      if (cachedDate.year == tomorrow.year &&
          cachedDate.month == tomorrow.month &&
          cachedDate.day == tomorrow.day) {
        // Önizleme var mı kontrol et
        final preview = cache['preview'] as String?;
        if (preview != null && preview.isNotEmpty) {
          if (mounted) {
            setState(() {
              _showTomorrowPreview = true;
              _tomorrowPreview = preview;
            });
          }
          debugPrint('✅ Loaded tomorrow preview from cache: $preview');
        }
      } else {
        // Eski cache, temizle
        debugPrint('🗑️ Clearing old tomorrow cache');
        await _storageService.clearTomorrowCache();
      }
    }
  }

  @override
  void dispose() {
    // Oturum süresini kaydet
    if (_sessionStartTime != null) {
      final duration = DateTime.now().difference(_sessionStartTime!).inMinutes;
      if (duration > 0) {
        _firebaseService.updateSessionInfo(duration);
      }
    }

    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadHoroscope() async {
    final authProvider = context.read<AuthProvider>();
    final horoscopeProvider = context.read<HoroscopeProvider>();

    if (authProvider.selectedZodiac != null) {
      final readStartTime = DateTime.now();

      await horoscopeProvider.fetchDailyHoroscope(authProvider.selectedZodiac!);
      _confettiController.play();

      // Zengin profil güncellemeleri
      if (_firebaseService.isAuthenticated) {
        // 1. Özellik kullanımını artır
        _firebaseService.incrementFeatureUsage('daily_horoscope');

        // 2. Ardışık gün sayısını güncelle
        _firebaseService.updateConsecutiveDays();

        // 3. Son görüntülenen burcu kaydet
        _firebaseService
            .updateLastViewedZodiacSign(authProvider.selectedZodiac!.name);

        // 4. Okuma desenlerini güncelle (kategori: daily, süre: saniye)
        final readDuration = DateTime.now().difference(readStartTime).inSeconds;
        _firebaseService.updateReadingPatterns('daily', readDuration);

        // 5. Tercih edilen okuma saatini güncelle
        _firebaseService.updatePreferredReadingTime();

        // 6. Favori konuları güncelle
        _firebaseService.updateFavoriteTopics('daily_horoscope');

        // 7. Kullanıcı etiketlerini güncelle
        _firebaseService.updateUserTags();

        // 8. Analytics event
        _firebaseService.logHoroscopeView(
            authProvider.selectedZodiac!.name, 'daily');
      }
    }
  }

  Future<void> _unlockTomorrowWithAd() async {
    // Zaten açılmışsa tekrar açma
    if (_showTomorrowPreview || _isLoadingTomorrow) {
      debugPrint('⚠️ Tomorrow preview already unlocked or loading');
      return;
    }

    try {
      if (!mounted) return;

      setState(() => _isLoadingTomorrow = true);

      // Check if ad is ready first
      if (_adService.lastRewardedDecision == 'not_ready') {
        setState(() => _isLoadingTomorrow = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reklam yükleniyor... Lütfen birkaç saniye bekleyin ve tekrar deneyin.'),
            backgroundColor: AppColors.warning,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // Reklam loading göster
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

      // Reklam loading'i kapat
      if (mounted) Navigator.of(context).pop();

      if (success && mounted) {
        // Şimdi yarın yorumu yükleme göster
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const ZodiLoading(message: 'Yarının ipuçları okunuyor...'),
        );

        final authProvider = context.read<AuthProvider>();
        if (authProvider.selectedZodiac != null) {
          try {
            // 1. Önce kısa önizleme al
            final horoscopeProvider = context.read<HoroscopeProvider>();
            final preview = await horoscopeProvider
                .fetchTomorrowPreview(authProvider.selectedZodiac!);

            // Loading'i kapat
            if (mounted) Navigator.of(context).pop();

            // 2. State'i güncelle
            setState(() {
              _showTomorrowPreview = true;
              _tomorrowPreview = preview;
              _isLoadingTomorrow = false;
            });

            // 3. Arka planda TAM horoscope'u çek ve cache'le (preview ile birlikte)
            horoscopeProvider
                .fetchTomorrowHoroscope(
              authProvider.selectedZodiac!,
              preview: preview,
            )
                .then((_) {
              debugPrint(
                  '✅ Tomorrow FULL horoscope cached silently with preview');
            }).catchError((e) {
              debugPrint('⚠️ Failed to cache tomorrow horoscope: $e');
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('🎉 Yarınki ipucu kilidi açıldı!'),
                  backgroundColor: AppColors.positive,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
              _confettiController.play();
            }
          } catch (e) {
            debugPrint('❌ Error fetching tomorrow preview: $e');

            // Loading'i kapat
            if (mounted) Navigator.of(context).pop();

            setState(() {
              _showTomorrowPreview = true;
              _tomorrowPreview =
                  'Yarın senin için harika bir gün olacak! Yeni fırsatlar kapıda bekliyor. 🌟';
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
      debugPrint('❌ Error in _unlockTomorrowWithAd: $e');

      if (mounted) {
        setState(() => _isLoadingTomorrow = false);
        // Tüm dialog'ları kapat
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
    super.build(context); // AutomaticKeepAliveClientMixin için gerekli
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final horoscopeProvider = context.watch<HoroscopeProvider>();

    final bgColor = isDark ? const Color(0xFF1F2338) : const Color(0xFFF4F1F8);
    final panelColor = isDark ? const Color(0xFF2A2F49) : Colors.white;
    final softText = isDark ? AppColors.textSecondary : const Color(0xFF666387);

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
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 36),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: panelColor,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF41486C)
                            : const Color(0xFFE7E1F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 27,
                          backgroundColor: const Color(0xFFB7A7EB),
                          child: const Icon(Icons.auto_awesome,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Merhaba, ${authProvider.userName ?? "Yıldız Gezgini"}',
                                  style:
                                      TextStyle(fontSize: 13, color: softText)),
                              const SizedBox(height: 3),
                              Text(
                                'Günlük Yorum Merkezi',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? AppColors.textPrimary
                                      : AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (horoscopeProvider.isLoadingDaily)
                    const ZodiLoading(message: 'Yorum hazırlanıyor...')
                  else if (horoscopeProvider.dailyHoroscope == null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: panelColor,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        children: [
                          Image.asset('assets/dozi_char.webp',
                              width: 140, height: 140),
                          const SizedBox(height: 12),
                          Text(
                            'Bugün için yorumunu hemen al',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textPrimary
                                  : AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Tek dokunuşla detaylı günlük akışın gelsin.',
                              style: TextStyle(color: softText)),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            onPressed: _loadHoroscope,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8C79D9),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.play_circle_fill),
                            label: const Text('Günlük Yorumu Başlat'),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    _buildMottoCard(horoscopeProvider.dailyHoroscope!.motto),
                    const SizedBox(height: 14),
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
                          Text(horoscopeProvider.dailyHoroscope!.commentary,
                              style: TextStyle(
                                  height: 1.65, color: softText, fontSize: 15)),
                          if (!authProvider.isPremium) ...[
                            const SizedBox(height: 14),
                            const AdBannerWidget(),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: MetricCard(
                                label: AppStrings.dailyLove,
                                value: horoscopeProvider.dailyHoroscope!.love,
                                icon: Icons.favorite)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: MetricCard(
                                label: AppStrings.dailyMoney,
                                value: horoscopeProvider.dailyHoroscope!.money,
                                icon: Icons.attach_money)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                            child: MetricCard(
                                label: AppStrings.dailyHealth,
                                value: horoscopeProvider.dailyHoroscope!.health,
                                icon: Icons.monitor_heart)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: MetricCard(
                                label: AppStrings.dailyCareer,
                                value: horoscopeProvider.dailyHoroscope!.career,
                                icon: Icons.work_outline)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AnimatedCard(
                      delay: 300.ms,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Icon(Icons.palette_outlined,
                                    color: Color(0xFF8C79D9)),
                                const SizedBox(height: 6),
                                const Text('Şanslı Renk',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF7B7799))),
                                Text(
                                    horoscopeProvider
                                        .dailyHoroscope!.luckyColor,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                          Container(
                              width: 1,
                              height: 48,
                              color: const Color(0xFFE6E0F0)),
                          Expanded(
                            child: Column(
                              children: [
                                const Icon(Icons.numbers,
                                    color: Color(0xFF8C79D9)),
                                const SizedBox(height: 6),
                                const Text('Şanslı Sayı',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF7B7799))),
                                Text(
                                    '${horoscopeProvider.dailyHoroscope!.luckyNumber}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                            backgroundColor: Color(0xFFEDE8FB),
                            child: Icon(Icons.rate_review,
                                color: Color(0xFF8C79D9))),
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
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom),
                              child: FeedbackWidget(interactionType: 'daily'),
                            ),
                          );
                        },
                      ),
                    ),
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
                                  ? (_tomorrowPreview ??
                                      'Yıldızlar konuşuyor...')
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
                                    backgroundColor: const Color(0xFF8C79D9),
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

  // Modern Motto Card Widget
  Widget _buildMottoCard(String motto) {
    return AnimatedCard(
      elevation: 15,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF7D88C7),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                Icons.format_quote,
                size: 100,
                color: Colors.white.withOpacity(0.1),
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
                const SizedBox(height: 15),
                Text(
                  motto,
                  style: const TextStyle(
                    fontSize: 24,
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
