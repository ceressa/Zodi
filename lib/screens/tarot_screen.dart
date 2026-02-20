import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/colors.dart';
import '../providers/auth_provider.dart';
import '../services/tarot_service.dart';
import '../services/gemini_service.dart';
import '../services/firebase_service.dart';
import '../services/ad_service.dart';
import '../services/share_service.dart';
import '../models/tarot_card.dart';
import '../widgets/tarot_card_widget.dart';
import '../widgets/candy_loading.dart';
import '../widgets/premium_lock_overlay.dart';
import '../widgets/share_cards/tarot_share_card.dart';
import '../services/activity_log_service.dart';
import '../providers/coin_provider.dart';
import '../theme/cosmic_page_route.dart';
import 'premium_screen.dart';

class TarotScreen extends StatefulWidget {
  const TarotScreen({super.key});

  @override
  State<TarotScreen> createState() => _TarotScreenState();
}

class _TarotScreenState extends State<TarotScreen> {
  late TarotService _tarotService;
  final FirebaseService _firebaseService = FirebaseService();
  final AdService _adService = AdService();
  final ActivityLogService _activityLog = ActivityLogService();
  TarotReading? _dailyReading;
  TarotReading? _threeCardReading;
  bool _isLoadingDaily = false;
  bool _isLoadingThree = false;
  String? _error;
  int _selectedTab = 0; // 0: Günlük, 1: Üç Kart
  bool _threeCardUnlockedByAd = false;
  bool _didAutoLoadOnce = false;

  static const _loadingMessages = [
    'Kartlar karılıyor...',
    'Yıldızlara danışılıyor...',
    'Kozmik enerjiler okunuyor...',
    'Evrenin mesajı çözülüyor...',
    'Kaderin sayfaları açılıyor...',
    'Astral düzlemde aranıyor...',
    'Gizemli güçler toplanıyor...',
    'Ruhani bağlantı kuruluyor...',
  ];

  String get _randomLoadingMessage {
    return _loadingMessages[DateTime.now().millisecond % _loadingMessages.length];
  }

  @override
  void initState() {
    super.initState();
    _tarotService = TarotService(
      geminiService: GeminiService(),
      firebaseService: _firebaseService,
    );
    _adService.loadRewardedAd();
    // Otomatik yükleme yok — kullanıcı butona basacak
  }

  Future<void> _loadDailyCard() async {
    _didAutoLoadOnce = true;
    final authProvider = context.read<AuthProvider>();
    if (authProvider.userId == null || authProvider.userProfile == null) return;

    setState(() {
      _isLoadingDaily = true;
      _error = null;
    });

    try {
      final reading = await _tarotService.getDailyCard(
        authProvider.userId!,
        authProvider.selectedZodiac?.name ?? authProvider.userProfile!.zodiacSign,
      );

      if (mounted) {
        setState(() {
          _dailyReading = reading;
          _isLoadingDaily = false;
        });
        if (reading.cards.isNotEmpty) {
          await _activityLog.logTarotReading(reading.cards.first.name, reading.cards.first.number);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Tarot kartı çekilirken bir hata oluştu';
          _isLoadingDaily = false;
        });
      }
    }
  }


  bool _canAccessThreeCard(AuthProvider authProvider) {
    return authProvider.isPremium || _threeCardUnlockedByAd;
  }

  Future<void> _unlockThreeCardWithAd() async {
    if (_threeCardUnlockedByAd || _isLoadingThree) {
      return;
    }

    // Check if ad is ready first
    if (_adService.lastRewardedDecision == 'not_ready') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reklam yükleniyor... Lütfen birkaç saniye bekleyin ve tekrar deneyin.'),
          backgroundColor: AppColors.warning,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.accentPurple),
      ),
    );

    final success = await _adService.showRewardedAd(placement: 'tarot_three_card_unlock');
    await _firebaseService.logAdWatched(
      'rewarded_tarot_three_card_unlock',
      placement: 'tarot_three_card_unlock',
      outcome: success ? 'success' : _adService.lastRewardedDecision,
      audienceSegment: _adService.audienceSegment,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }

    if (!mounted) return;

    if (success) {
      setState(() {
        _threeCardUnlockedByAd = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Üç Kart yayılımı bu oturum için açıldı ✨'),
          backgroundColor: AppColors.positive,
        ),
      );
      await _loadThreeCardSpread();
    } else {
      final message = _adService.lastRewardedDecision == 'not_ready'
          ? 'Reklam henüz hazır değil. Lütfen birkaç saniye bekleyin.'
          : 'Reklam tamamlanamadı. Lütfen tekrar deneyin.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.negative,
        ),
      );
    }
  }

  Future<void> _loadThreeCardSpread() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.userId == null || authProvider.userProfile == null) return;

    if (!_canAccessThreeCard(authProvider)) {
      _showPremiumDialog();
      return;
    }

    setState(() {
      _isLoadingThree = true;
      _error = null;
    });

    try {
      final reading = await _tarotService.getThreeCardSpread(
        authProvider.userId!,
        authProvider.selectedZodiac?.name ?? authProvider.userProfile!.zodiacSign,
      );

      if (mounted) {
        setState(() {
          _threeCardReading = reading;
          _isLoadingThree = false;
        });
        if (reading.cards.isNotEmpty) {
          await _activityLog.logTarotReading(reading.cards.first.name, reading.cards.first.number);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Tarot yayılımı oluşturulurken bir hata oluştu';
          _isLoadingThree = false;
        });
      }
    }
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Özellik'),
        content: const Text(
          'Üç kart yayılımı premium kullanıcılar için özel bir özelliktir. '
          'Premium üyeliğe geçerek bu ve daha fazla özelliğe erişebilirsiniz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, CosmicBottomSheetRoute(page: const PremiumScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPurple,
            ),
            child: const Text('Premium\'a Geç'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareReading(TarotReading reading) async {
    try {
      final authProvider = context.read<AuthProvider>();
      final zodiac = authProvider.selectedZodiac;
      final isThree = reading.cards.length > 1;

      final card = TarotShareCard(
        cardName: reading.cards.first.name,
        interpretation: reading.interpretation,
        zodiacSymbol: zodiac?.symbol,
        zodiacName: zodiac?.displayName,
        isThreeCard: isThree,
        threeCardNames: isThree
            ? reading.cards.map((c) => c.name).toList()
            : null,
      );

      await ShareService().shareCardWidget(
        context,
        card,
        text: '🔮 Astro Dozi Tarot Falım\n#AstroDozi #Tarot',
      );

      // Analytics
      _firebaseService.analytics.logEvent(
        name: 'tarot_shared',
        parameters: {
          'card_count': reading.cards.length,
          'reading_type': reading.cards.length == 1 ? 'daily' : 'three_card',
          'share_type': 'visual_card',
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Paylaşım başarısız: $e'),
            backgroundColor: AppColors.negative,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppColors.textDark,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tarot Falı',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.bgDark, AppColors.cardDark.withValues(alpha: 0.5)]
                : [AppColors.bgLight, AppColors.surfaceLight],
          ),
        ),
        child: Column(
        children: [
          // Tab seçici
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    'Günlük Kart',
                    0,
                    Icons.auto_awesome,
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      _buildTabButton(
                        'Üç Kart',
                        1,
                        Icons.view_carousel,
                      ),
                      if (!authProvider.isPremium)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // İçerik
          Expanded(
            child: _selectedTab == 0
                ? _buildDailyCardView()
                : _buildThreeCardView(),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index, IconData icon) {
    final isSelected = _selectedTab == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedTab = index);
        final authProvider = context.read<AuthProvider>();
        if (index == 1 &&
            _threeCardReading == null &&
            !_isLoadingThree &&
            _canAccessThreeCard(authProvider)) {
          _loadThreeCardSpread();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentPurple.withValues(alpha:0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? AppColors.accentPurple
                  : (isDark ? AppColors.textSecondary : AppColors.textMuted),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColors.accentPurple
                    : (isDark ? AppColors.textSecondary : AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _unlockDailyWithAd() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.accentPurple),
      ),
    );

    final success = await _adService.showRewardedAd(placement: 'tarot_daily');
    await _firebaseService.logAdWatched(
      'rewarded_tarot_daily',
      placement: 'tarot_daily',
      outcome: success ? 'success' : _adService.lastRewardedDecision,
      audienceSegment: _adService.audienceSegment,
    );

    if (mounted) Navigator.of(context).pop();

    if (success && mounted) {
      _loadDailyCard();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reklam tamamlanamadı. Lütfen tekrar deneyin.'),
          backgroundColor: AppColors.negative,
        ),
      );
    }
  }

  Widget _buildDailyCardView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();

    if (_isLoadingDaily) {
      return Center(
        child: CandyLoading(
          message: _randomLoadingMessage,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.warning),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.purpleGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _loadDailyCard,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text('Tekrar Dene', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Henüz kart çekilmemiş — gate ekranı göster
    if (_dailyReading == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppColors.cosmicGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentPurple.withValues(alpha:0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.style_rounded, size: 56, color: Colors.white),
              ),
              const SizedBox(height: 28),
              const Text(
                'Günlük Tarot Kartın',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                'Bugün yıldızlar senin için\nhangi mesajı taşıyor?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),

              // Premium kullanıcılar ücretsiz çeker
              if (authProvider.isPremium) ...[
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: AppColors.cosmicGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentPurple.withValues(alpha:0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _loadDailyCard,
                      borderRadius: BorderRadius.circular(18),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                            SizedBox(width: 10),
                            Text('Kartını Çek', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Coin ile çek butonu
                Consumer<CoinProvider>(
                  builder: (context, coinProvider, _) {
                    const tarotCost = 5;
                    final canAfford = coinProvider.canAfford(tarotCost);

                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: AppColors.cosmicGradient,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentPurple.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: canAfford
                              ? () async {
                                  final success = await coinProvider.spendCoins(tarotCost, 'tarot_daily');
                                  if (success) _loadDailyCard();
                                }
                              : null,
                          borderRadius: BorderRadius.circular(18),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.monetization_on_rounded, color: Colors.amber, size: 22),
                                const SizedBox(width: 10),
                                Text(
                                  '$tarotCost Altın ile Çek',
                                  style: TextStyle(
                                    color: canAfford ? Colors.white : Colors.white54,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Reklam ile çek butonu
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF374151), Color(0xFF4B5563)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _unlockDailyWithAd,
                      borderRadius: BorderRadius.circular(18),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_circle_outline_rounded, color: Colors.white70, size: 22),
                            SizedBox(width: 10),
                            Text('Reklam İzle & Çek', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 16)),
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
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Bugünün Kartın',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bugün senin için özel bir mesaj var',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSecondary : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 32),

          // Kart
          TarotCardWidget(
            card: _dailyReading!.cards.first,
            showFlipAnimation: true,
          ),

          const SizedBox(height: 32),

          // Yorum
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.cardDark
                  : AppColors.cardLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.accentPurple.withValues(alpha:0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: AppColors.gold,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Astro Dozi\'nin Yorumu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _dailyReading!.interpretation,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Paylaş butonu
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.purpleGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppColors.accentPurple.withValues(alpha:0.3), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _shareReading(_dailyReading!),
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.share, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Paylaş', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreeCardView() {
    final authProvider = context.watch<AuthProvider>();

    if (!_canAccessThreeCard(authProvider)) {
      return PremiumLockOverlay(
        title: 'Üç Kart Yayılımı',
        description:
            'Geçmiş, şimdi ve gelecek için üç kart çekerek daha detaylı bir okuma yapın.',
        onUnlock: () => Navigator.push(context, CosmicBottomSheetRoute(page: const PremiumScreen())),
        onWatchAd: _unlockThreeCardWithAd,
      );
    }

    if (_isLoadingThree) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CandyLoading(message: 'Kartlar karılıyor...'),
          ],
        ),
      );
    }

    if (_threeCardReading == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.view_carousel,
              size: 80,
              color: AppColors.accentPurple,
            ),
            const SizedBox(height: 24),
            const Text(
              'Üç Kart Yayılımı',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_threeCardUnlockedByAd)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Reklam ile açıldı (oturumluk erişim)',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ),
            const SizedBox(height: 8),
            const Text(
              'Geçmiş, şimdi ve gelecek için\nüç kart çekin',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.cosmicGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.accentPurple.withValues(alpha:0.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _loadThreeCardSpread,
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('Kartları Çek', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Üç Kart Yayılımı',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),

          // Üç kart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Geçmiş',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Transform.scale(
                      scale: 0.7,
                      child: TarotCardWidget(
                        card: _threeCardReading!.cards[0],
                        showFlipAnimation: true,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Şimdi',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Transform.scale(
                      scale: 0.7,
                      child: TarotCardWidget(
                        card: _threeCardReading!.cards[1],
                        showFlipAnimation: true,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Gelecek',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Transform.scale(
                      scale: 0.7,
                      child: TarotCardWidget(
                        card: _threeCardReading!.cards[2],
                        showFlipAnimation: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Yorum
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.cardDark
                  : AppColors.cardLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.accentPurple.withValues(alpha:0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: AppColors.gold,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Astro Dozi\'nin Yorumu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _threeCardReading!.interpretation,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Paylaş butonu
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.purpleGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppColors.accentPurple.withValues(alpha:0.3), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _shareReading(_threeCardReading!),
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.share, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Paylaş', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
