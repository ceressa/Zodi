import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/coin_provider.dart';
import '../services/ad_service.dart';
import '../constants/colors.dart';

/// Kozmik Kehanet — Yapsam mı Yapmasam mı?
/// Kullanıcı sorusunu yazar, Astro Dozi kısa/rastgele cevaplar verir.
class CosmicOracleScreen extends StatefulWidget {
  const CosmicOracleScreen({super.key});

  @override
  State<CosmicOracleScreen> createState() => _CosmicOracleScreenState();
}

class _CosmicOracleScreenState extends State<CosmicOracleScreen>
    with TickerProviderStateMixin {
  final TextEditingController _questionController = TextEditingController();
  final AdService _adService = AdService();
  final Random _random = Random();

  static const int _coinCost = 3;

  bool _isThinking = false;
  bool _hasResult = false;
  String? _resultText;
  String? _resultEmoji;
  Color? _resultColor;
  int? _resultCardIndex;

  // Yanıt havuzu — kısa, eğlenceli, max 3-5 kelime
  static const List<Map<String, dynamic>> _oracleCards = [
    // Evet kartları
    {'text': 'Evet, yürü!', 'emoji': '✅', 'type': 'yes', 'color': 0xFF16A34A},
    {'text': 'Kesinlikle evet!', 'emoji': '🔥', 'type': 'yes', 'color': 0xFF16A34A},
    {'text': 'Yapma da ne yap!', 'emoji': '💪', 'type': 'yes', 'color': 0xFF16A34A},
    {'text': 'Yıldızlar evet diyor', 'emoji': '⭐', 'type': 'yes', 'color': 0xFF16A34A},
    {'text': 'Tam zamanı!', 'emoji': '⏰', 'type': 'yes', 'color': 0xFF16A34A},
    {'text': 'Gözün kapalı yap!', 'emoji': '😎', 'type': 'yes', 'color': 0xFF16A34A},
    {'text': 'Risk al, değer!', 'emoji': '🎯', 'type': 'yes', 'color': 0xFF16A34A},
    {'text': 'Olacak iş, yap!', 'emoji': '🚀', 'type': 'yes', 'color': 0xFF16A34A},
    // Hayır kartları
    {'text': 'Hayır, sakın ha!', 'emoji': '🚫', 'type': 'no', 'color': 0xFFDC2626},
    {'text': 'Şimdi değil!', 'emoji': '⛔', 'type': 'no', 'color': 0xFFDC2626},
    {'text': 'Bi dur bakalım', 'emoji': '✋', 'type': 'no', 'color': 0xFFDC2626},
    {'text': 'Uzak dur bence', 'emoji': '🙅', 'type': 'no', 'color': 0xFFDC2626},
    {'text': 'Kesinlikle hayır!', 'emoji': '❌', 'type': 'no', 'color': 0xFFDC2626},
    {'text': 'Vazgeç, inan bana', 'emoji': '😬', 'type': 'no', 'color': 0xFFDC2626},
    {'text': 'Bu yolu geçtik', 'emoji': '🛑', 'type': 'no', 'color': 0xFFDC2626},
    // Muallak kartlar
    {'text': 'Bi düşünelim...', 'emoji': '🤔', 'type': 'maybe', 'color': 0xFFD97706},
    {'text': 'Benden medet umma', 'emoji': '🤷', 'type': 'maybe', 'color': 0xFFD97706},
    {'text': 'Yarın tekrar sor', 'emoji': '🌙', 'type': 'maybe', 'color': 0xFFD97706},
    {'text': 'Kısmet bakalım...', 'emoji': '🎲', 'type': 'maybe', 'color': 0xFFD97706},
    {'text': 'Yıldızlar kararsız', 'emoji': '💫', 'type': 'maybe', 'color': 0xFFD97706},
    {'text': 'Kozmik belirsizlik', 'emoji': '🌀', 'type': 'maybe', 'color': 0xFFD97706},
    {'text': 'Sen bilirsin...', 'emoji': '😏', 'type': 'maybe', 'color': 0xFFD97706},
    {'text': 'Bana sorma bunu', 'emoji': '🙈', 'type': 'maybe', 'color': 0xFFD97706},
  ];

  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _askOracle({bool withAd = false}) async {
    if (_questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Önce bir soru yaz!'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (!withAd) {
      final coinProvider = context.read<CoinProvider>();
      final success = await coinProvider.spendCoins(_coinCost, 'cosmic_oracle');
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Yetersiz Yıldız Tozu! Bu özellik için $_coinCost Yıldız Tozu gerekli.'),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        return;
      }
    } else {
      final watched = await _adService.showRewardedAd(placement: 'cosmic_oracle');
      if (!watched) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Reklam yüklenemedi. Lütfen biraz sonra tekrar dene.'),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        return;
      }
    }

    setState(() {
      _isThinking = true;
      _hasResult = false;
      _resultText = null;
      _resultEmoji = null;
      _resultColor = null;
    });

    // Düşünme animasyonu — 2-3 saniye beklet dramatik olsun
    final thinkTime = 2000 + _random.nextInt(1500);
    await Future.delayed(Duration(milliseconds: thinkTime));

    // Rastgele kart seç
    final cardIndex = _random.nextInt(_oracleCards.length);
    final card = _oracleCards[cardIndex];

    if (mounted) {
      setState(() {
        _isThinking = false;
        _hasResult = true;
        _resultText = card['text'] as String;
        _resultEmoji = card['emoji'] as String;
        _resultColor = Color(card['color'] as int);
        _resultCardIndex = cardIndex;
      });
    }
  }

  void _resetOracle() {
    setState(() {
      _hasResult = false;
      _resultText = null;
      _resultEmoji = null;
      _resultColor = null;
      _resultCardIndex = null;
      _questionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      appBar: AppBar(
        title: const Text(
          'Kozmik Kehanet',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFFF8F5FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Hero card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6D28D9), Color(0xFF4C1D95)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6D28D9).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text('🔮', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 12),
                  const Text(
                    'Kozmik Kehanet',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Yapsam mı? Yapmasam mı?\nYıldızlara sor, kaderini öğren!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on, size: 16, color: Colors.amber),
                        const SizedBox(width: 6),
                        Text(
                          '$_coinCost Yıldız Tozu',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.03),

            const SizedBox(height: 24),

            if (_isThinking)
              _buildThinkingState()
            else if (_hasResult)
              _buildResultState()
            else
              _buildInputState(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputState() {
    return Column(
      children: [
        // Soru girişi
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '💭 Soruyu yaz',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _questionController,
                maxLines: 3,
                maxLength: 150,
                decoration: InputDecoration(
                  hintText: 'Örn: Bugün ona açılsam mı?',
                  hintStyle: TextStyle(
                    color: AppColors.textDark.withOpacity(0.3),
                    fontSize: 15,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF3F0FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  counterStyle: TextStyle(
                    fontSize: 10,
                    color: AppColors.textDark.withOpacity(0.3),
                  ),
                ),
                style: const TextStyle(fontSize: 15, color: AppColors.textDark),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms),

        const SizedBox(height: 20),

        // Sor butonu — coin
        SizedBox(
          width: double.infinity,
          height: 52,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6D28D9), Color(0xFF4C1D95)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6D28D9).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _askOracle(),
                borderRadius: BorderRadius.circular(16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🔮', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text(
                      'Yıldızlara Sor',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

        const SizedBox(height: 14),

        // Reklam izle alternatifi
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('veya', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => _askOracle(withAd: true),
            icon: const Icon(Icons.play_circle_filled, size: 20),
            label: const Text(
              'Reklam İzle ve Ücretsiz Sor',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6D28D9),
              side: BorderSide(color: const Color(0xFF6D28D9).withOpacity(0.3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThinkingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('🔮', style: TextStyle(fontSize: 64))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.15, 1.15), duration: 800.ms),
          const SizedBox(height: 20),
          const Text(
            'Yıldızlara soruyorum...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"${_questionController.text}"',
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: AppColors.textDark.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: const Color(0xFF6D28D9),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildResultState() {
    return Column(
      children: [
        // Soru
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const Text('💭', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _questionController.text,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textDark.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms),

        const SizedBox(height: 20),

        // Büyük sonuç kartı
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _resultColor!.withOpacity(0.1),
                _resultColor!.withOpacity(0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _resultColor!.withOpacity(0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _resultColor!.withOpacity(0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                _resultEmoji!,
                style: const TextStyle(fontSize: 72),
              ),
              const SizedBox(height: 20),
              Text(
                _resultText!,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: _resultColor,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), duration: 400.ms, curve: Curves.elasticOut),

        const SizedBox(height: 24),

        // Tekrar sor butonu
        SizedBox(
          width: double.infinity,
          height: 52,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6D28D9), Color(0xFF4C1D95)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _resetOracle,
                borderRadius: BorderRadius.circular(16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh_rounded, size: 20, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Başka Bir Şey Sor',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate(delay: 300.ms).fadeIn(duration: 300.ms),
      ],
    );
  }
}
