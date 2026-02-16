import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../constants/colors.dart';
import '../services/activity_log_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with TickerProviderStateMixin {
  String _selectedPlan = 'yearly';
  final ActivityLogService _activityLog = ActivityLogService();
  late final AnimationController _shimmerController;
  late final AnimationController _pulseController;

  // Plan bilgileri: eski fiyat (üstü çizili) + yeni fiyat (indirimli)
  static const List<Map<String, dynamic>> _plans = [
    {
      'key': 'weekly',
      'label': 'Haftalık',
      'oldPrice': '₺49,99',
      'price': '₺29,99',
      'period': '/hafta',
      'discount': '%40',
      'dailyPrice': '₺4,28/gün',
      'color': Color(0xFFFF69B4),
    },
    {
      'key': 'yearly',
      'label': 'Yıllık',
      'oldPrice': '₺1.199,99',
      'price': '₺449,99',
      'period': '/yıl',
      'discount': '%63',
      'dailyPrice': '₺1,23/gün',
      'badge': 'EN UYGUN',
      'savings': '₺750 tasarruf',
      'color': Color(0xFFFFD700),
      'recommended': true,
    },
    {
      'key': 'monthly',
      'label': 'Aylık',
      'oldPrice': '₺149,99',
      'price': '₺99,99',
      'period': '/ay',
      'discount': '%33',
      'dailyPrice': '₺3,33/gün',
      'color': Color(0xFF9400D3),
    },
  ];

  static const List<Map<String, dynamic>> _features = [
    {'icon': Icons.style, 'emoji': '🔮', 'title': 'Sınırsız Tarot Okuma', 'sub': '3 kart yayılımı dahil'},
    {'icon': Icons.coffee, 'emoji': '☕', 'title': 'Sınırsız Kahve Falı', 'sub': 'Detaylı AI yorumları'},
    {'icon': Icons.chat_bubble_outline, 'emoji': '💬', 'title': 'Sınırsız AI Sohbet', 'sub': 'Kişisel astroloji danışmanın'},
    {'icon': Icons.nightlight_round, 'emoji': '🌙', 'title': 'Sınırsız Rüya Yorumu', 'sub': 'Rüyalarının derinliklerine in'},
    {'icon': Icons.calendar_month, 'emoji': '📅', 'title': 'Haftalık & Aylık Yorumlar', 'sub': 'Uzun vadeli kozmik rehberlik'},
    {'icon': Icons.analytics_outlined, 'emoji': '📊', 'title': 'Detaylı Analiz & Raporlar', 'sub': 'Derinlemesine burç analizi'},
    {'icon': Icons.block, 'emoji': '🚫', 'title': 'Reklamsız Deneyim', 'sub': 'Kesintisiz, akıcı kullanım'},
    {'icon': Icons.auto_awesome, 'emoji': '✨', 'title': 'Tüm Premium İçerikler', 'sub': 'Kozmik takvim, profil kartı ve dahası'},
  ];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _selectedPlanData =>
      _plans.firstWhere((p) => p['key'] == _selectedPlan);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        _buildHeroSection(),
                        const SizedBox(height: 28),
                        _buildLimitedOfferBanner(),
                        const SizedBox(height: 24),
                        _buildPlanCards(),
                        const SizedBox(height: 28),
                        _buildFeaturesSection(),
                        const SizedBox(height: 20),
                        _buildGuaranteeSection(),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildBottomPurchaseBar(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF0F5),
              Color(0xFFFFE4EC),
              Color(0xFFFFF5F8),
            ],
          ),
        ),
        child: CustomPaint(
          painter: _StarsPainter(),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: AppColors.textDark, size: 20),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.positive.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: AppColors.positive, size: 16),
                const SizedBox(width: 4),
                Text(
                  '7 gün para iade garantisi',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.positive,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = 1.0 + (_pulseController.value * 0.08);
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFF8C00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.diamond,
                size: 48,
                color: Colors.white,
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 2500.ms, color: Colors.white.withOpacity(0.4)),
          ),
          const SizedBox(height: 20),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF9400D3), Color(0xFFFF1493), Color(0xFFFF8C00)],
            ).createShader(bounds),
            child: const Text(
              'Zodi Premium',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Yıldızların tüm sırlarını aç',
            style: TextStyle(
              fontSize: 17,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 24,
                child: Stack(
                  children: List.generate(3, (i) => Positioned(
                    left: i * 16.0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            [const Color(0xFFFF69B4), const Color(0xFFFF1493)],
                            [const Color(0xFF9400D3), const Color(0xFFBA55D3)],
                            [const Color(0xFFFFD700), const Color(0xFFFFA500)],
                          ][i],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          ['⭐', '🔮', '✨'][i],
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                  )),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '10.000+ mutlu kullanıcı',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1);
  }

  Widget _buildLimitedOfferBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF1493), Color(0xFFFF4500)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF1493).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Lansmana Özel İndirim!',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Tüm planlarda %63\'e varan indirim',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'SINIRLI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFF1493),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      )
          .animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 3000.ms, color: Colors.white.withOpacity(0.15)),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideX(begin: -0.05);
  }

  Widget _buildPlanCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: _plans.asMap().entries.map((entry) {
          final i = entry.key;
          final plan = entry.value;
          final isSelected = _selectedPlan == plan['key'];
          final isRecommended = plan['recommended'] == true;

          return Padding(
            padding: EdgeInsets.only(bottom: i < _plans.length - 1 ? 12 : 0),
            child: _buildPlanCard(plan, isSelected, isRecommended),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: (300 + i * 100).ms)
              .slideX(begin: 0.05);
        }).toList(),
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan, bool isSelected, bool isRecommended) {
    final Color planColor = plan['color'] as Color;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan['key']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.all(isSelected ? 18 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? planColor : Colors.grey.shade200,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: planColor.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? planColor : Colors.grey.shade300,
                      width: 2,
                    ),
                    color: isSelected ? planColor : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan['label'],
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          if (plan['savings'] != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.positive.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                plan['savings'],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.positive,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan['dailyPrice'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan['oldPrice'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Colors.red.shade300,
                        decorationThickness: 2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      plan['price'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? planColor : AppColors.textDark,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF1493).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${plan['discount']} indirim',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFF1493),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (isRecommended)
              Positioned(
                top: -28,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'EN UYGUN FİYAT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat())
                      .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.5)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: AppColors.cosmicGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Premium ile Neler Kazanırsın?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: _features.asMap().entries.map((entry) {
              final i = entry.key;
              final f = entry.value;
              return _buildFeatureChip(f)
                  .animate()
                  .fadeIn(duration: 300.ms, delay: (500 + i * 80).ms)
                  .scale(begin: const Offset(0.9, 0.9), delay: (500 + i * 80).ms);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(Map<String, dynamic> f) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(f['emoji'], style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  f['title'],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  f['sub'],
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuaranteeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.positive.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.positive.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield_outlined, color: AppColors.positive, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Güvenli & Kolay',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'İstediğin zaman iptal et. Ödemen güvende.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 800.ms);
  }

  Widget _buildBottomPurchaseBar() {
    final plan = _selectedPlanData;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    plan['oldPrice'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade400,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Colors.red.shade300,
                      decorationThickness: 2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${plan['price']}${plan['period']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF1493).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      plan['discount'],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFF1493),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9400D3), Color(0xFFFF1493), Color(0xFFFF4500)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF1493).withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        await context.read<AuthProvider>().upgradeToPremium(
                          subscriptionType: _selectedPlan,
                        );
                        final priceStr = plan['price'] as String;
                        final priceValue = double.tryParse(
                          priceStr.replaceAll('₺', '').replaceAll('.', '').replaceAll(',', '.'),
                        ) ?? 0.0;
                        await _activityLog.logPremiumPurchase(priceValue);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Premium (${plan['label']}) aktif edildi! 🎉',
                              ),
                              backgroundColor: AppColors.positive,
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.diamond, color: Colors.white, size: 22),
                            SizedBox(width: 10),
                            Text(
                              'Premium\'a Geç',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
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
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(
                      duration: 2500.ms,
                      color: Colors.white.withOpacity(0.2),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'İstediğin zaman iptal edebilirsin',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    final paint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.15)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final r = 1.0 + random.nextDouble() * 2.0;
      canvas.drawCircle(Offset(x, y), r, paint);
    }

    final glowPaint = Paint()
      ..color = const Color(0xFFFF69B4).withOpacity(0.08)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.5;
      canvas.drawCircle(Offset(x, y), 20 + random.nextDouble() * 30, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
