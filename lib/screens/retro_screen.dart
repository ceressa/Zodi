import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/colors.dart';
import '../providers/auth_provider.dart';
import '../services/ad_service.dart';
import '../services/usage_limit_service.dart';
import '../widgets/limit_reached_dialog.dart';
import '../theme/cosmic_page_route.dart';
import 'premium_screen.dart';

class RetroScreen extends StatefulWidget {
  const RetroScreen({super.key});

  @override
  State<RetroScreen> createState() => _RetroScreenState();
}

class _RetroScreenState extends State<RetroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotateController;
  final AdService _adService = AdService();
  final UsageLimitService _usageLimitService = UsageLimitService();
  bool _analysisUnlocked = false;

  // 2025-2026 retro dönemleri (gerçek tarihler)
  static final List<_RetroPeriod> _retroPeriods = [
    // Merkür Retroları 2025
    _RetroPeriod(
      planet: 'Merkür',
      emoji: '☿️',
      startDate: DateTime(2025, 3, 15),
      endDate: DateTime(2025, 4, 7),
      color: const Color(0xFFFF8C00),
      description: 'İletişim sorunları, teknoloji aksaklıkları, eski sevgililer geri dönebilir!',
      tips: ['Yeni sözleşme imzalama', 'Eski ilişkilere dikkat', 'Teknoloji yedekle'],
    ),
    _RetroPeriod(
      planet: 'Merkür',
      emoji: '☿️',
      startDate: DateTime(2025, 7, 18),
      endDate: DateTime(2025, 8, 11),
      color: const Color(0xFFFF8C00),
      description: 'Yaz ortasında iletişim karmaşası. Tatil planlarını çift kontrol et!',
      tips: ['Seyahat planlarını erken yap', 'Mesajlaşmada dikkatli ol', 'Eski projeler gözden geçir'],
    ),
    _RetroPeriod(
      planet: 'Merkür',
      emoji: '☿️',
      startDate: DateTime(2025, 11, 9),
      endDate: DateTime(2025, 11, 29),
      color: const Color(0xFFFF8C00),
      description: 'Yıl sonu öncesi son Merkür retrosu. Mali kararları ertele!',
      tips: ['Büyük alışverişleri ertele', 'İmzalar çift kontrol', 'Yedekleme yap'],
    ),
    // Venüs Retrosu 2025
    _RetroPeriod(
      planet: 'Venüs',
      emoji: '♀️',
      startDate: DateTime(2025, 3, 2),
      endDate: DateTime(2025, 4, 13),
      color: const Color(0xFFFF1493),
      description: 'Aşk hayatında büyük dönüşüm! Eski ilişkiler gündeme gelebilir.',
      tips: ['Yeni ilişkiye başlama', 'Estetik işlemleri ertele', 'Eski sevgililere dikkat'],
    ),
    // Mars Retrosu 2025 (aslında Ocak'ta bitiyor ama bilgi için)
    _RetroPeriod(
      planet: 'Mars',
      emoji: '♂️',
      startDate: DateTime(2025, 12, 6),
      endDate: DateTime(2026, 2, 24),
      color: const Color(0xFFFF4500),
      description: 'Enerji düşüklüğü ve motivasyon kaybı. Sabırlı ol!',
      tips: ['Ağır egzersizleri azalt', 'Tartışmalardan kaçın', 'Sabırlı ol'],
    ),
    // Jüpiter Retrosu 2025
    _RetroPeriod(
      planet: 'Jüpiter',
      emoji: '♃',
      startDate: DateTime(2025, 11, 11),
      endDate: DateTime(2026, 3, 11),
      color: const Color(0xFF9400D3),
      description: 'İç büyüme ve felsefik sorgulamalar dönemi.',
      tips: ['İç dünyaya dön', 'Eğitim planlarını gözden geçir', 'Manevi gelişime odaklan'],
    ),
    // Satürn Retrosu 2025
    _RetroPeriod(
      planet: 'Satürn',
      emoji: '♄',
      startDate: DateTime(2025, 7, 13),
      endDate: DateTime(2025, 11, 28),
      color: const Color(0xFF4B0082),
      description: 'Sorumlulukları yeniden değerlendirme zamanı.',
      tips: ['Kariyer hedeflerini gözden geçir', 'Sınırlarını belirle', 'Disiplin konularını sor'],
    ),
    // Merkür Retroları 2026
    _RetroPeriod(
      planet: 'Merkür',
      emoji: '☿️',
      startDate: DateTime(2026, 2, 26),
      endDate: DateTime(2026, 3, 20),
      color: const Color(0xFFFF8C00),
      description: '2026 ilk Merkür retrosu! Yeni yıl planlarını test edecek.',
      tips: ['Kontratları ertele', 'İletişimde net ol', 'Yedekleme yap'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _rotateController.dispose();
    super.dispose();
  }

  List<_RetroPeriod> get _upcomingRetros {
    final now = DateTime.now();
    return _retroPeriods
        .where((r) => r.endDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  _RetroPeriod? get _activeRetro {
    final now = DateTime.now();
    try {
      return _retroPeriods.firstWhere(
        (r) => r.startDate.isBefore(now) && r.endDate.isAfter(now),
      );
    } catch (_) {
      return null;
    }
  }

  _RetroPeriod? get _nextRetro {
    final now = DateTime.now();
    final upcoming = _retroPeriods
        .where((r) => r.startDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    return upcoming.isNotEmpty ? upcoming.first : null;
  }

  int get _daysUntilNextRetro {
    final next = _nextRetro;
    if (next == null) return 0;
    return next.startDate.difference(DateTime.now()).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final active = _activeRetro;
    final next = _nextRetro;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0F0C29), const Color(0xFF1A0533), const Color(0xFF24243E)]
                : [const Color(0xFFE8D5F5), const Color(0xFFF5E6FF), const Color(0xFFE0D0F0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(isDark),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Aktif retro uyarısı
                      if (active != null) _buildActiveRetroCard(active, isDark),

                      // Sayaç
                      if (active == null && next != null)
                        _buildCountdownCard(next, isDark),

                      const SizedBox(height: 24),

                      // Gezegen animasyonu
                      _buildPlanetAnimation(isDark),

                      const SizedBox(height: 24),

                      // Yaklaşan retrolar listesi
                      Text(
                        'Yaklaşan Retrolar',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),

                      ..._upcomingRetros.asMap().entries.map(
                            (entry) => _buildRetroListItem(
                              entry.value,
                              isDark,
                              entry.key,
                            ),
                          ),

                      if (_upcomingRetros.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              'Şu an yaklaşan retro yok! 🎉',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.white54 : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // === KİŞİSEL RETRO ANALİZİ (PREMIUM/AD GATE) ===
                      _buildPersonalAnalysisSection(isDark),
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

  Widget _buildAppBar(bool isDark) {
    return Padding(
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
              'Retro Takip',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.share,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
            onPressed: _shareRetroStatus,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRetroCard(_RetroPeriod retro, bool isDark) {
    final remainingDays = retro.endDate.difference(DateTime.now()).inDays;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [retro.color, retro.color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: retro.color.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${retro.planet} Retrosu AKTİF!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            retro.description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Bitimine $remainingDays gün kaldı',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // İpuçları
          ...retro.tips.map((tip) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildCountdownCard(_RetroPeriod next, bool isDark) {
    final days = _daysUntilNextRetro;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A0533), const Color(0xFF2D1B69)]
              : [Colors.white, const Color(0xFFF3E8FF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: next.color.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: next.color.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            next.emoji,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 8),
          Text(
            'Sonraki: ${next.planet} Retrosu',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [next.color, AppColors.gold],
            ).createShader(bounds),
            child: Text(
              '$days',
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            'gün kaldı',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${next.startDate.day}.${next.startDate.month}.${next.startDate.year} - ${next.endDate.day}.${next.endDate.month}.${next.endDate.year}',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : AppColors.textMuted,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildPlanetAnimation(bool isDark) {
    return SizedBox(
      height: 120,
      child: AnimatedBuilder(
        animation: _rotateController,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Güneş merkez
              const Text('☀️', style: TextStyle(fontSize: 32)),
              // Gezegen yörüngeleri
              ...['☿️', '♀️', '♂️', '♃', '♄'].asMap().entries.map((e) {
                final radius = 35.0 + e.key * 18;
                final speed = 1.0 + e.key * 0.3;
                final angle = _rotateController.value * 2 * pi * speed;
                return Positioned(
                  left: MediaQuery.of(context).size.width / 2 -
                      24 +
                      cos(angle) * radius,
                  top: 60 + sin(angle) * (radius * 0.4),
                  child: Text(
                    e.value,
                    style: TextStyle(fontSize: 14 + e.key * 1.5),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRetroListItem(_RetroPeriod retro, bool isDark, int index) {
    final now = DateTime.now();
    final isActive = retro.startDate.isBefore(now) && retro.endDate.isAfter(now);
    final isPast = retro.endDate.isBefore(now);
    final daysUntil = retro.startDate.difference(now).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(isActive ? 0.15 : 0.05)
            : Colors.white.withOpacity(isActive ? 1 : 0.7),
        borderRadius: BorderRadius.circular(16),
        border: isActive
            ? Border.all(color: retro.color, width: 2)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: retro.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(retro.emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${retro.planet} Retrosu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                Text(
                  '${retro.startDate.day}.${retro.startDate.month} - ${retro.endDate.day}.${retro.endDate.month}.${retro.endDate.year}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isActive
                  ? retro.color.withOpacity(0.2)
                  : (isPast
                      ? Colors.grey.withOpacity(0.2)
                      : AppColors.positive.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isActive
                  ? 'AKTİF'
                  : (isPast ? 'Bitti' : '$daysUntil gün'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive
                    ? retro.color
                    : (isPast ? Colors.grey : AppColors.positive),
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 100)).fadeIn().slideX(begin: 0.2);
  }

  Widget _buildPersonalAnalysisSection(bool isDark) {
    final authProvider = context.read<AuthProvider>();
    final isPremium = authProvider.isPremium;
    final active = _activeRetro;
    final zodiac = authProvider.selectedZodiac;

    if (isPremium || _analysisUnlocked) {
      // Unlocked content
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1A0533), const Color(0xFF2D1B69)]
                : [Colors.white, const Color(0xFFF3E8FF)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.gold.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🔮', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Text(
                  'Kişisel Retro Analizi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                const Spacer(),
                if (isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (zodiac != null && active != null) ...[
              _buildAnalysisItem(
                '💫',
                '${zodiac.displayName} & ${active.planet} Retrosu',
                'Bu retro döneminde ${zodiac.displayName} burcu için özellikle dikkatli olunması gereken alanlar var. Duygusal kararlar vermekten kaçın.',
                isDark,
              ),
              const SizedBox(height: 12),
              _buildAnalysisItem(
                '⚡',
                'Enerji Tavsiyesi',
                'Retro enerjisini lehine çevirmek için geçmişe dönük projeleri tamamlamaya odaklan. Yeni başlangıçları retro sonrasına ertele.',
                isDark,
              ),
              const SizedBox(height: 12),
              _buildAnalysisItem(
                '🛡️',
                'Korunma Rehberi',
                'Bu dönemde kristal taşlardan ametist ve labradorit seni koruyabilir. Mor ve lacivert tonları tercih et.',
                isDark,
              ),
            ] else ...[
              _buildAnalysisItem(
                '💫',
                'Retro Hazırlık Rehberi',
                'Bir sonraki retroya hazırlanmak için şimdiden projelerini gözden geçir ve önemli kararlarını tamamla.',
                isDark,
              ),
              const SizedBox(height: 12),
              _buildAnalysisItem(
                '🌟',
                'Genel Retro Enerjisi',
                zodiac != null
                    ? '${zodiac.displayName} burcu olarak retro dönemlerinde iç sesinizi dinlemeniz özellikle önemli.'
                    : 'Retro dönemlerinde iç sesinizi dinlemeniz özellikle önemli.',
                isDark,
              ),
            ],
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
    }

    // Locked gate
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A0533).withOpacity(0.8), const Color(0xFF2D1B69).withOpacity(0.8)]
              : [Colors.white.withOpacity(0.9), const Color(0xFFF3E8FF).withOpacity(0.9)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.accentPurple.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          const Text('🔒', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'Kişisel Retro Analizi',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Retro dönemlerinin sana özel etkisini,\nkorunma tavsiyelerini ve enerji rehberini gör!',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white60 : AppColors.textMuted,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Reklam İzle butonu
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final canView = await _usageLimitService.canViewRetroAnalysis();
                if (!canView) {
                  if (mounted) {
                    LimitReachedDialog.showRetroLimit(context, onAdWatched: () {
                      setState(() => _analysisUnlocked = true);
                    });
                  }
                  return;
                }
                final success = await _adService.showRewardedAd(
                  placement: 'limit_unlock_retro_analysis',
                );
                if (success && mounted) {
                  await _usageLimitService.incrementRetroAnalysis();
                  setState(() => _analysisUnlocked = true);
                }
              },
              icon: const Icon(Icons.play_circle_outline, size: 22),
              label: const Text('Reklam İzle & Kilidi Aç'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accentPurple,
                side: BorderSide(color: AppColors.accentPurple.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Premium butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, CosmicBottomSheetRoute(page: const PremiumScreen()));
              },
              icon: const Icon(Icons.diamond, size: 20),
              label: const Text('Premium ile Sınırsız Aç'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildAnalysisItem(String emoji, String title, String desc, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : AppColors.accentPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _shareRetroStatus() {
    final active = _activeRetro;
    final next = _nextRetro;

    String text;
    if (active != null) {
      final remaining = active.endDate.difference(DateTime.now()).inDays;
      text = '''
⚠️ ${active.planet} Retrosu AKTİF! — Zodi

${active.description}

⏱ Bitimine $remaining gün kaldı!

📱 Retro takvimine Zodi'den bak!
🔮 #Zodi #${active.planet}Retrosu #Retro
''';
    } else if (next != null) {
      text = '''
🪐 Sonraki Retro: ${next.planet} — Zodi

${next.planet} Retrosu'na $_daysUntilNextRetro gün kaldı!
📅 ${next.startDate.day}.${next.startDate.month}.${next.startDate.year}

📱 Retro takvimine Zodi'den bak!
🔮 #Zodi #RetroSayacı
''';
    } else {
      text = 'Şu an yaklaşan retro yok! 🎉 Zodi ile takip et!';
    }

    Share.share(text);
  }
}

class _RetroPeriod {
  final String planet;
  final String emoji;
  final DateTime startDate;
  final DateTime endDate;
  final Color color;
  final String description;
  final List<String> tips;

  const _RetroPeriod({
    required this.planet,
    required this.emoji,
    required this.startDate,
    required this.endDate,
    required this.color,
    required this.description,
    required this.tips,
  });
}
