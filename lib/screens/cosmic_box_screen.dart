import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import '../providers/auth_provider.dart';
import '../services/ad_service.dart';
import '../services/share_service.dart';
import '../widgets/share_cards/cosmic_box_share_card.dart';
import '../widgets/sticky_bottom_actions.dart';

class CosmicBoxScreen extends StatefulWidget {
  const CosmicBoxScreen({super.key});

  @override
  State<CosmicBoxScreen> createState() => _CosmicBoxScreenState();
}

class _CosmicBoxScreenState extends State<CosmicBoxScreen>
    with TickerProviderStateMixin {
  final _random = Random();
  final _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  late AnimationController _pulseController;
  late AnimationController _shakeController;

  bool _isOpened = false;
  bool _isOpening = false;
  bool _alreadyOpenedToday = false;
  Map<String, dynamic>? _reward;

  // Ödül havuzu
  static const List<Map<String, dynamic>> _luckyColors = [
    {'name': 'Mor', 'color': Color(0xFF9400D3), 'emoji': '💜'},
    {'name': 'Pembe', 'color': Color(0xFFFF1493), 'emoji': '💗'},
    {'name': 'Mavi', 'color': Color(0xFF00BFFF), 'emoji': '💙'},
    {'name': 'Yeşil', 'color': Color(0xFF00FA9A), 'emoji': '💚'},
    {'name': 'Altın', 'color': Color(0xFFFFD700), 'emoji': '💛'},
    {'name': 'Kırmızı', 'color': Color(0xFFFF4500), 'emoji': '❤️'},
    {'name': 'Turuncu', 'color': Color(0xFFFF8C00), 'emoji': '🧡'},
    {'name': 'Turkuaz', 'color': Color(0xFF40E0D0), 'emoji': '💎'},
  ];

  static const List<Map<String, dynamic>> _luckyStones = [
    {'name': 'Ametist', 'emoji': '🔮', 'power': 'İç huzur ve sezgi'},
    {'name': 'Akuamarin', 'emoji': '💎', 'power': 'Cesaret ve berraklık'},
    {'name': 'Kuvars', 'emoji': '🤍', 'power': 'Enerji ve denge'},
    {'name': 'Yakut', 'emoji': '❤️‍🔥', 'power': 'Tutku ve güç'},
    {'name': 'Zümrüt', 'emoji': '💚', 'power': 'Bolluk ve şifa'},
    {'name': 'Ay Taşı', 'emoji': '🌙', 'power': 'Sezgi ve duygusal denge'},
    {'name': 'Kaplan Gözü', 'emoji': '🐯', 'power': 'Koruma ve odaklanma'},
    {'name': 'Lapis Lazuli', 'emoji': '🔵', 'power': 'Bilgelik ve gerçek'},
  ];

  static const List<String> _miniTarotMessages = [
    'Bugün cesur adımlar at, evren seni destekliyor!',
    'Sabır meyvesini verecek, biraz daha bekle...',
    'Beklenmedik bir haber kapıda, hazırlıklı ol!',
    'İç sesini dinle, cevap zaten içinde gizli.',
    'Bugün yeni bağlantılar kurabilirsin, sosyal ol!',
    'Maddi konularda dikkatli ol, gereksiz harcamalardan kaçın.',
    'Aşk hayatında güzel sürprizler olabilir!',
    'Eski bir arkadaştan haber gelebilir...',
    'Yaratıcılığın tavan yapacak, fırsatları değerlendir!',
    'Bugün kendine zaman ayır, enerjini topla.',
    'Bir karar vermek için doğru zaman geldi!',
    'Sezgilerin çok güçlü, onlara güven.',
  ];

  static const List<String> _dailyAffirmations = [
    'Ben bolluk ve bereket çekiyorum ✨',
    'Evren benim için en iyisini hazırlıyor 🌟',
    'Bugün harika şeyler olacak 💫',
    'Ben güçlüyüm ve her şeyin üstesinden gelirim 💪',
    'Sevgi ve ışık etrafımda 💕',
    'Her an yeni bir başlangıç 🌅',
    'İç huzurum her geçen gün artıyor 🧘',
    'Hayatımdaki güzelliklere şükrediyorum 🙏',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _checkTodayStatus();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _checkTodayStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final lastOpened = prefs.getString('cosmic_box_last_opened');
    if (lastOpened != null) {
      final lastDate = DateTime.parse(lastOpened);
      final now = DateTime.now();
      if (lastDate.year == now.year &&
          lastDate.month == now.month &&
          lastDate.day == now.day) {
        setState(() => _alreadyOpenedToday = true);
      }
    }
  }

  Future<void> _markOpened() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cosmic_box_last_opened', DateTime.now().toIso8601String());
  }

  Map<String, dynamic> _generateReward() {
    final rewardType = _random.nextInt(100);

    if (rewardType < 25) {
      // %25 — Şanslı renk
      final color = _luckyColors[_random.nextInt(_luckyColors.length)];
      return {
        'type': 'color',
        'title': 'Şanslı Rengin',
        'name': color['name'],
        'emoji': color['emoji'],
        'color': color['color'],
        'description': 'Bugün ${color['name']} rengi sana şans getirecek!',
      };
    } else if (rewardType < 50) {
      // %25 — Şanslı taş
      final stone = _luckyStones[_random.nextInt(_luckyStones.length)];
      return {
        'type': 'stone',
        'title': 'Şanslı Taşın',
        'name': stone['name'],
        'emoji': stone['emoji'],
        'description': '${stone['power']} enerjisi bugün seninle!',
      };
    } else if (rewardType < 70) {
      // %20 — Şanslı sayı
      final number = _random.nextInt(99) + 1;
      return {
        'type': 'number',
        'title': 'Şanslı Sayın',
        'name': '$number',
        'emoji': '🔢',
        'description': 'Bugün $number sayısına dikkat et!',
      };
    } else if (rewardType < 85) {
      // %15 — Mini tarot mesajı
      final msg = _miniTarotMessages[_random.nextInt(_miniTarotMessages.length)];
      return {
        'type': 'tarot',
        'title': 'Kozmik Mesajın',
        'name': 'Evrenin Mesajı',
        'emoji': '🎴',
        'description': msg,
      };
    } else {
      // %15 — Günlük afirmasyon
      final affirmation = _dailyAffirmations[_random.nextInt(_dailyAffirmations.length)];
      return {
        'type': 'affirmation',
        'title': 'Günün Afirmasyonu',
        'name': 'Kozmik Enerji',
        'emoji': '🧘',
        'description': affirmation,
      };
    }
  }

  Future<void> _openBox() async {
    if (_isOpening || _isOpened) return;

    setState(() => _isOpening = true);

    // Kutu sallanma animasyonu
    _shakeController.forward(from: 0);

    // 2 saniye bekle (suspense)
    await Future.delayed(const Duration(seconds: 2));

    final reward = _generateReward();

    setState(() {
      _reward = reward;
      _isOpened = true;
      _isOpening = false;
      _alreadyOpenedToday = true;
    });

    _confettiController.play();
    await _markOpened();
  }

  Future<void> _openBoxWithAd() async {
    if (_isOpening) return;

    final adService = AdService();
    final rewarded = await adService.showRewardedAd(placement: 'cosmic_box_extra');

    if (rewarded) {
      setState(() {
        _isOpened = false;
        _alreadyOpenedToday = false;
        _reward = null;
      });
      await _openBox();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reklam yüklenemedi, biraz sonra tekrar dene!'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      bottomNavigationBar: (_isOpened && _reward != null)
          ? StickyBottomActions(
              children: [
                StickyBottomActions.primaryButton(
                  label: 'Paylaş',
                  icon: Icons.share_rounded,
                  gradient: [AppColors.accentPurple, const Color(0xFFA78BFA)],
                  onTap: _shareReward,
                ),
                const SizedBox(width: 12),
                StickyBottomActions.outlineButton(
                  label: 'Bir Tane Daha!',
                  icon: Icons.play_circle_outline,
                  color: AppColors.accentPurple,
                  onTap: _openBoxWithAd,
                ),
              ],
            )
          : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8D5F5), Color(0xFFF0E6FF), Color(0xFFE0D0F0)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Arka plan yıldızları
              ...List.generate(20, (i) {
                return Positioned(
                  left: _random.nextDouble() * MediaQuery.of(context).size.width,
                  top: _random.nextDouble() * MediaQuery.of(context).size.height,
                  child: Text(
                    ['✨', '⭐', '💫', '🌟'][i % 4],
                    style: TextStyle(fontSize: 10 + _random.nextDouble() * 12),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .fadeIn(delay: Duration(milliseconds: i * 200))
                      .then()
                      .fadeOut(delay: Duration(seconds: 2 + _random.nextInt(3))),
                );
              }),

              // Ana içerik
              Column(
                children: [
                  // AppBar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: isDark ? Colors.white : AppColors.textDark,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            'Kozmik Kutu',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.textDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _isOpened ? _buildRewardView(isDark) : _buildBoxView(isDark),
                    ),
                  ),
                ],
              ),

              // Konfeti
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  numberOfParticles: 30,
                  colors: const [
                    AppColors.accentPurple,
                    AppColors.primaryPink,
                    AppColors.accentBlue,
                    AppColors.gold,
                    AppColors.positive,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoxView(bool isDark) {
    final authProvider = context.watch<AuthProvider>();
    final zodiacName = authProvider.selectedZodiac?.displayName ?? 'Gezgin';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),

        Text(
          'Merhaba $zodiacName! 🌟',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ).animate().fadeIn().slideY(begin: -0.3),

        const SizedBox(height: 8),

        Text(
          _alreadyOpenedToday
              ? 'Bugünkü kutunu zaten açtın!'
              : 'Günlük kozmik kutun seni bekliyor',
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white70 : AppColors.textMuted,
          ),
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 48),

        // Kutu animasyonu
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = 1.0 + (_pulseController.value * 0.08);
            return Transform.scale(
              scale: _isOpening ? 1.0 + (_shakeController.value * 0.1) : scale,
              child: child,
            );
          },
          child: GestureDetector(
            onTap: _alreadyOpenedToday ? null : _openBox,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                gradient: _alreadyOpenedToday
                    ? const LinearGradient(
                        colors: [Color(0xFF666666), Color(0xFF999999)],
                      )
                    : AppColors.cosmicGradient,
                borderRadius: BorderRadius.circular(30),
                boxShadow: _alreadyOpenedToday
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.accentPurple.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isOpening ? '✨' : '🎁',
                    style: const TextStyle(fontSize: 64),
                  ),
                  if (_isOpening) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Açılıyor...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ).animate().scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.elasticOut,
            ),

        const SizedBox(height: 32),

        if (!_alreadyOpenedToday && !_isOpening)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              gradient: AppColors.cosmicGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              onTap: _openBox,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Kutunu Aç!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),

        if (_alreadyOpenedToday && !_isOpening) ...[
          const SizedBox(height: 16),

          // Reklam izleyerek ekstra kutu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              gradient: AppColors.purpleGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              onTap: _openBoxWithAd,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_circle_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Reklam İzle + Ekstra Kutu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 24),
          Text(
            'Yarın yeni bir kutu gelecek!',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRewardView(bool isDark) {
    if (_reward == null) return const SizedBox();

    return Column(
      children: [
        const SizedBox(height: 20),

        Text(
          _reward!['emoji'] as String,
          style: const TextStyle(fontSize: 72),
        )
            .animate()
            .scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              duration: 800.ms,
              curve: Curves.elasticOut,
            ),

        const SizedBox(height: 16),

        ShaderMask(
          shaderCallback: (bounds) => AppColors.cosmicGradient.createShader(bounds),
          child: Text(
            _reward!['title'] as String,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ).animate().fadeIn(delay: 300.ms),

        const SizedBox(height: 8),

        Text(
          _reward!['name'] as String,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

        const SizedBox(height: 24),

        // Ödül kartı
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.gold.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              if (_reward!['type'] == 'color')
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _reward!['color'] as Color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_reward!['color'] as Color).withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              Text(
                _reward!['description'] as String,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.5,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3),

        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _shareReward() async {
    if (_reward == null) return;
    final authProvider = context.read<AuthProvider>();
    final zodiac = authProvider.selectedZodiac;

    final card = CosmicBoxShareCard(
      rewardType: _reward!['type'] ?? '',
      rewardTitle: _reward!['title'] ?? '',
      rewardName: _reward!['name'] ?? '',
      rewardEmoji: _reward!['emoji'] ?? '🎁',
      rewardDescription: _reward!['description'] ?? '',
      zodiacSymbol: zodiac?.symbol,
      zodiacName: zodiac?.displayName,
    );

    await ShareService().shareCardWidget(
      context,
      card,
      text: '🎁 Kozmik Kutum — Astro Dozi\n#AstroDozi #KozmikKutu',
    );
  }
}
