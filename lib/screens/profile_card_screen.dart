import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/colors.dart';
import '../providers/auth_provider.dart';
import '../models/zodiac_sign.dart';
import '../services/share_service.dart';
import '../services/ad_service.dart';
import '../services/usage_limit_service.dart';
import '../widgets/limit_reached_dialog.dart';

class ProfileCardScreen extends StatefulWidget {
  const ProfileCardScreen({super.key});

  @override
  State<ProfileCardScreen> createState() => _ProfileCardScreenState();
}

class _ProfileCardScreenState extends State<ProfileCardScreen> {
  final GlobalKey _cardKey = GlobalKey();
  final AdService _adService = AdService();
  final UsageLimitService _usageLimitService = UsageLimitService();

  // Element bilgileri
  static const Map<String, Map<String, dynamic>> _elementInfo = {
    'Koç': {'element': 'Ateş', 'emoji': '🔥', 'color': Color(0xFFFF4500), 'trait': 'Cesur & Enerjik'},
    'Boğa': {'element': 'Toprak', 'emoji': '🌍', 'color': Color(0xFF8B4513), 'trait': 'Kararlı & Güvenilir'},
    'İkizler': {'element': 'Hava', 'emoji': '💨', 'color': Color(0xFF87CEEB), 'trait': 'Meraklı & İletişimci'},
    'Yengeç': {'element': 'Su', 'emoji': '💧', 'color': Color(0xFF4169E1), 'trait': 'Duygusal & Koruyucu'},
    'Aslan': {'element': 'Ateş', 'emoji': '🔥', 'color': Color(0xFFFF4500), 'trait': 'Karizmatik & Lider'},
    'Başak': {'element': 'Toprak', 'emoji': '🌍', 'color': Color(0xFF8B4513), 'trait': 'Detaycı & Analitik'},
    'Terazi': {'element': 'Hava', 'emoji': '💨', 'color': Color(0xFF87CEEB), 'trait': 'Dengeli & Diplomatik'},
    'Akrep': {'element': 'Su', 'emoji': '💧', 'color': Color(0xFF4169E1), 'trait': 'Tutkulu & Gizemli'},
    'Yay': {'element': 'Ateş', 'emoji': '🔥', 'color': Color(0xFFFF4500), 'trait': 'Maceracı & Özgür'},
    'Oğlak': {'element': 'Toprak', 'emoji': '🌍', 'color': Color(0xFF8B4513), 'trait': 'Disiplinli & Hırslı'},
    'Kova': {'element': 'Hava', 'emoji': '💨', 'color': Color(0xFF87CEEB), 'trait': 'Yenilikçi & Bağımsız'},
    'Balık': {'element': 'Su', 'emoji': '💧', 'color': Color(0xFF4169E1), 'trait': 'Sezgisel & Empatik'},
  };

  String? _risingSign;
  String? _moonSign;

  @override
  void initState() {
    super.initState();
    _loadSignData();
  }

  Future<void> _loadSignData() async {
    // SharedPreferences'tan yükselen ve ay burcu bilgilerini al
    // Bu veriler rising_sign_screen'de hesaplandıktan sonra kaydedilir
    final authProvider = context.read<AuthProvider>();
    // Profil bilgisinden çek (varsa)
    setState(() {
      _risingSign = authProvider.userProfile?.risingSign;
      _moonSign = authProvider.userProfile?.moonSign;
    });
  }

  Future<void> _shareCard() async {
    final authProvider = context.read<AuthProvider>();

    if (authProvider.isPremium) {
      ShareService().shareWidgetAsImage(
        _cardKey,
        text: '✨ Astrolojik Profilim — Astro Dozi\n📱 Sen de profilini oluştur!\n#AstroDozi #AstrolojikProfil',
      );
      return;
    }

    // Free user - check usage limit
    final canShare = await _usageLimitService.canShareProfileCard();
    if (!canShare) {
      if (mounted) {
        LimitReachedDialog.showProfileShareLimit(context, onAdWatched: () {
          ShareService().shareWidgetAsImage(
            _cardKey,
            text: '✨ Astrolojik Profilim — Astro Dozi\n📱 Sen de profilini oluştur!\n#AstroDozi #AstrolojikProfil',
          );
        });
      }
      return;
    }

    // Show rewarded ad before sharing
    final success = await _adService.showRewardedAd(
      placement: 'limit_unlock_profile_share',
    );
    if (success && mounted) {
      await _usageLimitService.incrementProfileShare();
      ShareService().shareWidgetAsImage(
        _cardKey,
        text: '✨ Astrolojik Profilim — Astro Dozi\n📱 Sen de profilini oluştur!\n#AstroDozi #AstrolojikProfil',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final zodiac = authProvider.selectedZodiac ?? ZodiacSign.aries;
    final name = authProvider.userProfile?.name ?? 'Gezgin';
    final elementData = _elementInfo[zodiac.displayName] ?? _elementInfo['Koç']!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0F0C29), const Color(0xFF302B63), const Color(0xFF24243E)]
                : [const Color(0xFFE8D5F5), const Color(0xFFF0E6FF), const Color(0xFFE0D0F0)],
          ),
        ),
        child: SafeArea(
          child: Column(
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
                        'Astrolojik Profilim',
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
                  child: Column(
                    children: [
                      // Profil Kartı
                      RepaintBoundary(
                        key: _cardKey,
                        child: _buildProfileCard(isDark, zodiac, name, elementData),
                      ),

                      const SizedBox(height: 32),

                      // Paylaş butonu
                      Builder(
                        builder: (ctx) {
                          final isPremium = ctx.read<AuthProvider>().isPremium;
                          return Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: AppColors.cosmicGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _shareCard,
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.share, color: Colors.white),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Profilimi Paylaş',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (!isPremium) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.25),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.play_circle_outline, color: Colors.white, size: 14),
                                              SizedBox(width: 3),
                                              Text(
                                                'AD',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ).animate().fadeIn(delay: 600.ms),

                      const SizedBox(height: 16),

                      Text(
                        'Instagram Stories\'da paylaş,\narkadaşlarının da burcunu öğrensin!',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white54 : AppColors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    bool isDark,
    ZodiacSign zodiac,
    String name,
    Map<String, dynamic> elementData,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A0533),
            Color(0xFF2D1B69),
            Color(0xFF0F0C29),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Üst kısım — Zodi branding
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFF5E6B0)],
                ).createShader(bounds),
                child: const Text(
                  'ASTRO DOZI',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 3,
                  ),
                ),
              ),
              Text(
                '✨',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.gold.withOpacity(0.8),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Burç sembolü — büyük
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF9400D3), Color(0xFFFF1493)],
              ),
              border: Border.all(
                color: AppColors.gold.withOpacity(0.6),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentPurple.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Center(
              child: Text(
                zodiac.symbol,
                style: const TextStyle(fontSize: 48),
              ),
            ),
          ).animate().scale(
                begin: const Offset(0.5, 0.5),
                duration: 800.ms,
                curve: Curves.elasticOut,
              ),

          const SizedBox(height: 16),

          // İsim
          Text(
            name.toUpperCase(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 24),

          // Burç bilgileri
          _buildInfoRow('☀️', 'Güneş Burcu', zodiac.displayName),
          if (_risingSign != null)
            _buildInfoRow('⬆️', 'Yükselen', _risingSign!),
          if (_moonSign != null)
            _buildInfoRow('🌙', 'Ay Burcu', _moonSign!),

          const SizedBox(height: 16),

          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.gold.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Element ve özellik
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: (elementData['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (elementData['color'] as Color).withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      elementData['emoji'] as String,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      elementData['element'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accentPurple.withOpacity(0.5),
                  ),
                ),
                child: Text(
                  elementData['trait'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Tarih aralığı
          Text(
            zodiac.dateRange,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.5),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2);
  }

  Widget _buildInfoRow(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
