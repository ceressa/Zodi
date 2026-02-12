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
import '../services/streak_service.dart';
import '../models/streak_data.dart';
import 'statistics_screen.dart';

class DailyScreen extends StatefulWidget {
  const DailyScreen({super.key});

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> with AutomaticKeepAliveClientMixin {
  final AdService _adService = AdService();
  final FirebaseService _firebaseService = FirebaseService();
  final StorageService _storageService = StorageService();
  final StreakService _streakService = StreakService();
  late ConfettiController _confettiController;
  bool _showTomorrowPreview = false;
  String? _tomorrowPreview;
  bool _hasLoadedOnce = false;
  DateTime? _sessionStartTime;
  bool _isLoadingTomorrow = false;
  StreakData? _streakData;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _sessionStartTime = DateTime.now();
    _loadTomorrowPreviewFromCache();
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

  Future<void> _loadTomorrowPreviewFromCache() async {
    // Storage'dan yarın önizlemesini yükle
    final cache = await _storageService.getTomorrowHoroscope();
    if (cache != null) {
      final cachedDate = cache['date'] as DateTime;
      final today = DateTime.now();
      final tomorrow = DateTime(today.year, today.month, today.day).add(const Duration(days: 1));
      
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
        _firebaseService.updateLastViewedZodiacSign(authProvider.selectedZodiac!.name);
        
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
        _firebaseService.logHoroscopeView(authProvider.selectedZodiac!.name, 'daily');
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
      
      // Reklam loading göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.accentPurple),
        ),
      );
      
      final success = await _adService.showRewardedAd(placement: 'daily_tomorrow_preview');
      await _firebaseService.logAdWatched(
        'rewarded_tomorrow_preview',
        placement: 'daily_tomorrow_preview',
        outcome: success ? 'success' : 'failed',
        audienceSegment: _adService.audienceSegment,
      );

      // Reklam loading'i kapat
      if (mounted) Navigator.of(context).pop();
      
      if (success && mounted) {
        // Şimdi yarın yorumu yükleme göster
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const ZodiLoading(message: 'Yarının ipuçları okunuyor...'),
        );
        
        final authProvider = context.read<AuthProvider>();
        if (authProvider.selectedZodiac != null) {
          try {
            // 1. Önce kısa önizleme al
            final horoscopeProvider = context.read<HoroscopeProvider>();
            final preview = await horoscopeProvider.fetchTomorrowPreview(authProvider.selectedZodiac!);
            
            // Loading'i kapat
            if (mounted) Navigator.of(context).pop();
            
            // 2. State'i güncelle
            setState(() {
              _showTomorrowPreview = true;
              _tomorrowPreview = preview;
              _isLoadingTomorrow = false;
            });
            
            // 3. Arka planda TAM horoscope'u çek ve cache'le (preview ile birlikte)
            horoscopeProvider.fetchTomorrowHoroscope(
              authProvider.selectedZodiac!,
              preview: preview,
            ).then((_) {
              debugPrint('✅ Tomorrow FULL horoscope cached silently with preview');
            }).catchError((e) {
              debugPrint('⚠️ Failed to cache tomorrow horoscope: $e');
            });
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('🎉 Yarınki ipucu kilidi açıldı!'),
                  backgroundColor: AppColors.positive,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              _tomorrowPreview = 'Yarın senin için harika bir gün olacak! Yeni fırsatlar kapıda bekliyor. 🌟';
              _isLoadingTomorrow = false;
            });
          }
        }
      } else if (mounted) {
        setState(() => _isLoadingTomorrow = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Reklam henüz hazır değil. Birkaç saniye sonra tekrar deneyin.'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error in _unlockTomorrowWithAd: $e');
      
      if (mounted) {
        setState(() => _isLoadingTomorrow = false);
        // Tüm dialog'ları kapat
        Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppColors.negative,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _navigateToPremium() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Premium özellikler yakında!'),
        backgroundColor: AppColors.gold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin için gerekli
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final horoscopeProvider = context.watch<HoroscopeProvider>();
    
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [AppColors.bgDark, AppColors.cardDark]
                    : [AppColors.bgLight, AppColors.surfaceLight],
              ),
            ),
          ),
          
          // Confetti
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
          
          // Content
          RefreshIndicator(
            onRefresh: _loadHoroscope,
            color: AppColors.accentPurple,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  
                  // Header with animation
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppColors.purpleGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentPurple.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Merhaba, ${authProvider.userName ?? ""}',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                              ),
                            ),
                            Text(
                              AppStrings.dailyTitle,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.textPrimary : AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideX(begin: -0.2, end: 0),
                  
                  const SizedBox(height: 24),
                  
                  if (horoscopeProvider.isLoadingDaily)
                    const ZodiLoading(message: 'Yıldızlar okunuyor...')
                  else if (horoscopeProvider.dailyHoroscope == null)
                    // İlk yükleme - kullanıcı butona bassın
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentPurple.withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/dozi_char.webp',
                              fit: BoxFit.contain,
                            ),
                          )
                          .animate(onPlay: (controller) => controller.repeat(reverse: true))
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.05, 1.05),
                            duration: 2.seconds,
                            curve: Curves.easeInOut,
                          ),
                          
                          const SizedBox(height: 32),
                          
                          Text(
                            'Merhaba ${authProvider.userName}!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimary : AppColors.textDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          Text(
                            'Bugün senin için ne var?\nYıldızları okumaya hazır mısın?',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 40),
                          
                          Container(
                            decoration: BoxDecoration(
                              gradient: AppColors.purpleGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentPurple.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _loadHoroscope,
                                borderRadius: BorderRadius.circular(20),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                                      SizedBox(width: 12),
                                      Text(
                                        'Yorumuma Bak',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                          .animate(onPlay: (controller) => controller.repeat())
                          .shimmer(delay: 2.seconds, duration: 1.5.seconds),
                        ],
                      ),
                    )
                  else ...[
                    // Motto Card - Modern Design
                    _buildMottoCard(horoscopeProvider.dailyHoroscope!.motto),
                    
                    const SizedBox(height: 24),
                    
                    // Commentary Card
                    AnimatedCard(
                      delay: 100.ms,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: AppColors.purpleGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.auto_stories, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Bugünün Yorumu',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.textPrimary : AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Yorumun ilk %70'i
                          Builder(
                            builder: (context) {
                              final commentary = horoscopeProvider.dailyHoroscope!.commentary;
                              final splitPoint = (commentary.length * 0.7).round();
                              final firstPart = commentary.substring(0, splitPoint);
                              final secondPart = commentary.substring(splitPoint);
                              
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    firstPart,
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 1.7,
                                      color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                                    ),
                                  ),
                                  
                                  // Banner Ad - Yorum ortasında (premium değilse)
                                  if (!authProvider.isPremium) ...[
                                    const SizedBox(height: 20),
                                    const AdBannerWidget(),
                                    const SizedBox(height: 20),
                                  ] else ...[
                                    const SizedBox(height: 8),
                                  ],
                                  
                                  Text(
                                    secondPart,
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 1.7,
                                      color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Metrics Grid
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedCard(
                            delay: 200.ms,
                            child: MetricCard(
                              label: AppStrings.dailyLove,
                              value: horoscopeProvider.dailyHoroscope!.love,
                              icon: Icons.favorite,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AnimatedCard(
                            delay: 250.ms,
                            child: MetricCard(
                              label: AppStrings.dailyMoney,
                              value: horoscopeProvider.dailyHoroscope!.money,
                              icon: Icons.attach_money,
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
                            delay: 300.ms,
                            child: MetricCard(
                              label: AppStrings.dailyHealth,
                              value: horoscopeProvider.dailyHoroscope!.health,
                              icon: Icons.favorite_border,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AnimatedCard(
                            delay: 350.ms,
                            child: MetricCard(
                              label: AppStrings.dailyCareer,
                              value: horoscopeProvider.dailyHoroscope!.career,
                              icon: Icons.work_outline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Lucky Items
                    AnimatedCard(
                      delay: 400.ms,
                      gradient: AppColors.goldGradient,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Icon(Icons.palette, color: Colors.white, size: 32),
                                const SizedBox(height: 8),
                                const Text(
                                  'Şanslı Renk',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  horoscopeProvider.dailyHoroscope!.luckyColor,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 60,
                            color: Colors.white30,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                const Icon(Icons.stars, color: Colors.white, size: 32),
                                const SizedBox(height: 8),
                                const Text(
                                  'Şanslı Sayı',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${horoscopeProvider.dailyHoroscope!.luckyNumber}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Feedback Button
                    AnimatedCard(
                      delay: 425.ms,
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => Padding(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: FeedbackWidget(interactionType: 'daily'),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.accentPurple.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.rate_review,
                                  color: AppColors.accentPurple,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Yorumum Nasıldı?',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppColors.textPrimary : AppColors.textDark,
                                      ),
                                    ),
                                    Text(
                                      'Geri bildirimini paylaş, seni daha iyi tanıyayım',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Tomorrow Preview Card
                    if (!authProvider.isPremium)
                      AnimatedCard(
                        delay: 450.ms,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.pinkGradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.wb_sunny, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Yarınki İpucu',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.textPrimary : AppColors.textDark,
                                  ),
                                ),
                                const Spacer(),
                                if (!_showTomorrowPreview)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.warning.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.lock, size: 16, color: AppColors.warning),
                                        SizedBox(width: 4),
                                        Text(
                                          'Kilitli',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.warning,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _showTomorrowPreview
                                  ? (_tomorrowPreview ?? 'Yıldızlar konuşuyor...')
                                  : 'Yarın için küçük bir ipucu almak ister misin?\n✨ Merak etme, yarın geldiğinde tam yorumunu göreceksin!',
                              style: TextStyle(
                                fontSize: 15,
                                color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (!_showTomorrowPreview) ...[
                              const SizedBox(height: 20),
                              // Modern Ad Button
                              _buildAdButton(),
                              const SizedBox(height: 12),
                              // Premium Button
                              Container(
                                decoration: BoxDecoration(
                                  gradient: AppColors.goldGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _navigateToPremium,
                                    borderRadius: BorderRadius.circular(12),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 14),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.workspace_premium, color: Colors.white, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Premium Ol',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    
                  ],
                  
                  if (horoscopeProvider.error != null)
                    Center(
                      child: AnimatedCard(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 60,
                              color: AppColors.negative,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Bir hata oluştu',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textPrimary : AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              horoscopeProvider.error ?? AppStrings.error,
                              style: TextStyle(
                                color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.purpleGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _loadHoroscope,
                                  borderRadius: BorderRadius.circular(12),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    child: Text(
                                      AppStrings.retry,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 40),
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
      gradient: AppColors.cosmicGradient,
      elevation: 15,
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Column(
              children: [
                const Text(
                  "GÜNÜN MOTTOSU",
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
          ),
        ],
      ),
    ).animate().scale(delay: 200.ms);
  }

  // Modern Ad Button Widget
  Widget _buildAdButton() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppColors.purpleGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _unlockTomorrowWithAd,
          borderRadius: BorderRadius.circular(20),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_circle_fill, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Yarın Seni Ne Bekliyor?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(delay: 3.seconds, duration: 1.5.seconds);
  }
}
