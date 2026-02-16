import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/astro_data.dart';
import '../providers/auth_provider.dart';
import '../providers/horoscope_provider.dart';
import 'weekly_monthly_screen.dart';
import 'rising_sign_screen.dart';
import 'dream_screen.dart';
import 'tarot_screen.dart';
import 'coffee_fortune_screen.dart';
import 'chatbot_screen.dart';
import 'cosmic_box_screen.dart';
import 'profile_card_screen.dart';
import 'retro_screen.dart';
import 'cosmic_calendar_screen.dart';
import 'birth_chart_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _dialController;
  int _selectedCategory = 0;

  static const _categories = ['Fallar', 'Araçlar', 'Keşif'];

  // Category-based features
  static const List<List<_FeatureItem>> _featuresByCategory = [
    // Fallar
    [
      _FeatureItem(emoji: '🃏', label: 'Tarot', color: Color(0xFF9333EA), screenIndex: 0),
      _FeatureItem(emoji: '☕', label: 'Kahve Falı', color: Color(0xFFD97706), screenIndex: 1),
      _FeatureItem(emoji: '🌙', label: 'Rüya', color: Color(0xFF7C3AED), screenIndex: 2),
      _FeatureItem(emoji: '📅', label: 'Haftalık', color: Color(0xFF2563EB), screenIndex: 3),
    ],
    // Araçlar
    [
      _FeatureItem(emoji: '⬆️', label: 'Yükselen', color: Color(0xFFE91E8C), screenIndex: 4),
      _FeatureItem(emoji: '🔮', label: 'AI Sohbet', color: Color(0xFF1E1B4B), screenIndex: 5),
      _FeatureItem(emoji: '🪐', label: 'Retro', color: Color(0xFF4B0082), screenIndex: 6),
      _FeatureItem(emoji: '🌍', label: 'Doğum Haritası', color: Color(0xFF7C3AED), screenIndex: 7),
    ],
    // Keşif
    [
      _FeatureItem(emoji: '📅', label: 'Takvim', color: Color(0xFF1A237E), screenIndex: 8),
      _FeatureItem(emoji: '✨', label: 'Profilim', color: Color(0xFFD4A800), screenIndex: 9),
      _FeatureItem(emoji: '🎁', label: 'Kozmik Kutu', color: Color(0xFF9333EA), screenIndex: 10),
    ],
  ];

  Widget _getScreen(int index) {
    switch (index) {
      case 0: return const TarotScreen();
      case 1: return const CoffeeFortuneScreen();
      case 2: return const DreamScreen();
      case 3: return const WeeklyMonthlyScreen();
      case 4: return const RisingSignScreen();
      case 5: return const ChatbotScreen();
      case 6: return const RetroScreen();
      case 7: return const BirthChartScreen();
      case 8: return const CosmicCalendarScreen();
      case 9: return const ProfileCardScreen();
      case 10: return const CosmicBoxScreen();
      default: return const TarotScreen();
    }
  }

  @override
  void initState() {
    super.initState();
    _dialController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _dialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final horoscopeProvider = context.watch<HoroscopeProvider>();
    final zodiac = authProvider.selectedZodiac;
    final horoscope = horoscopeProvider.dailyHoroscope;

    final today = DateTime.now();
    final todayEvents = AstroData.getEventsForDay(today);
    final activeRetro = todayEvents.where(
      (e) => e.type.name.contains('Retrograde') || e.type.name.contains('retrograde'),
    ).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === HEADER ===
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Keşfet',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.textPrimary : AppColors.textDark,
                      ),
                    ),
                    if (zodiac != null)
                      Text(
                        '${zodiac.symbol} ${zodiac.displayName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              if (zodiac != null)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.cosmicGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentPurple.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(zodiac.symbol, style: const TextStyle(fontSize: 24)),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // === RETRO UYARI (varsa) ===
          if (activeRetro.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCompactAlert(
                emoji: '⚠️',
                title: '${activeRetro.first.title} Aktif!',
                color: const Color(0xFFFF6347),
                isDark: isDark,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RetroScreen()),
                ),
              ),
            ),

          // === KOZMİK OLAY (retro yoksa) ===
          if (todayEvents.isNotEmpty && activeRetro.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCompactAlert(
                emoji: todayEvents.first.emoji,
                title: todayEvents.first.title,
                color: AppColors.accentPurple,
                isDark: isDark,
              ),
            ),

          // === KOZMIK DIAL HUB ===
          _buildDialHub(context, isDark, zodiac, horoscope),

          const SizedBox(height: 20),

          // === KATEGORİ SEÇİCİ ===
          _buildCategorySelector(isDark),

          const SizedBox(height: 16),

          // === ÖZELLİK GRİD ===
          _buildFeatureGrid(context, isDark),

          const SizedBox(height: 20),

          // === GÜNLÜK ENERJİ ÖZET ===
          if (horoscope != null && zodiac != null)
            _buildEnergyCard(isDark, zodiac, horoscope),

          const SizedBox(height: 16),

          // === YAKINDA ===
          _buildComingSoonBanner(isDark),
        ],
      ),
    );
  }

  Widget _buildCompactAlert({
    required String emoji,
    required String title,
    required Color color,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios, size: 14, color: color),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildDialHub(BuildContext context, bool isDark, dynamic zodiac, dynamic horoscope) {
    final screenW = MediaQuery.of(context).size.width;
    final dialSize = screenW - 40; // full width minus padding

    return Center(
      child: SizedBox(
        width: dialSize,
        height: dialSize * 0.65,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer rotating ring
            AnimatedBuilder(
              animation: _dialController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(dialSize * 0.85, dialSize * 0.85),
                  painter: _DialRingPainter(
                    rotation: _dialController.value * 2 * pi,
                    isDark: isDark,
                  ),
                );
              },
            ),

            // Center zodiac circle
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF9333EA), Color(0xFFFF1493)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9333EA).withOpacity(0.4),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  zodiac?.symbol ?? '✨',
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ).animate().scale(
                  begin: const Offset(0.8, 0.8),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                ),

            // Orbiting feature dots
            ..._buildOrbitingDots(dialSize * 0.35, isDark),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOrbitingDots(double radius, bool isDark) {
    final features = [
      ('🃏', const Color(0xFF9333EA)),
      ('☕', const Color(0xFFD97706)),
      ('🌙', const Color(0xFF7C3AED)),
      ('🔮', const Color(0xFF1E1B4B)),
      ('⬆️', const Color(0xFFE91E8C)),
      ('🪐', const Color(0xFF4B0082)),
    ];

    return features.asMap().entries.map((entry) {
      final idx = entry.key;
      final feat = entry.value;
      final angle = (idx * (360 / features.length) - 90) * (pi / 180);
      final x = cos(angle) * radius;
      final y = sin(angle) * (radius * 0.6);

      return Positioned(
        left: (MediaQuery.of(context).size.width - 40) / 2 + x - 20,
        top: (MediaQuery.of(context).size.width - 40) * 0.65 / 2 + y - 20,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? feat.$2.withOpacity(0.3)
                : feat.$2.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: feat.$2.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(feat.$1, style: const TextStyle(fontSize: 18)),
          ),
        ).animate(delay: Duration(milliseconds: idx * 80))
            .fadeIn(duration: 500.ms),
      );
    }).toList();
  }

  Widget _buildCategorySelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: _categories.asMap().entries.map((entry) {
          final idx = entry.key;
          final label = entry.value;
          final isSelected = _selectedCategory == idx;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = idx),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.cosmicGradient : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.accentPurple.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white54 : AppColors.textMuted),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context, bool isDark) {
    final features = _featuresByCategory[_selectedCategory];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: GridView.builder(
        key: ValueKey(_selectedCategory),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feat = features[index];
          return _buildFeatureTile(context, feat, isDark, index);
        },
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context,
    _FeatureItem feat,
    bool isDark,
    int index,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            feat.color,
            feat.color.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: feat.color.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => _getScreen(feat.screenIndex)),
          ),
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.white.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(feat.emoji, style: const TextStyle(fontSize: 28)),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ],
                ),
                Text(
                  feat.label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 60))
        .fadeIn(duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildEnergyCard(bool isDark, dynamic zodiac, dynamic horoscope) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: AppColors.accentPurple.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(zodiac.symbol, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Bugünkü Enerjin',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildMiniMetric('💕', horoscope.love, const Color(0xFFFF1493)),
              const SizedBox(width: 8),
              _buildMiniMetric('💰', horoscope.money, const Color(0xFFFFD700)),
              const SizedBox(width: 8),
              _buildMiniMetric('💪', horoscope.health, const Color(0xFF00FA9A)),
              const SizedBox(width: 8),
              _buildMiniMetric('💼', horoscope.career, const Color(0xFF00BFFF)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.accentPurple.withOpacity(isDark ? 0.1 : 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '"${horoscope.motto}"',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: isDark
                    ? Colors.white.withOpacity(0.7)
                    : AppColors.textDark.withOpacity(0.7),
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildMiniMetric(String emoji, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              '%$value',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🚀', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yakında',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                Text(
                  'Günlük Afirmasyon & Meditasyon',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'YAKINDA',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}

// === Dial ring painter ===
class _DialRingPainter extends CustomPainter {
  final double rotation;
  final bool isDark;

  _DialRingPainter({required this.rotation, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer dashed ring
    final dashPaint = Paint()
      ..color = (isDark ? Colors.white : AppColors.accentPurple).withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const dashCount = 36;
    for (var i = 0; i < dashCount; i++) {
      final angle = rotation + (i * 2 * pi / dashCount);
      final start = Offset(
        center.dx + cos(angle) * (radius - 8),
        center.dy + sin(angle) * (radius - 8),
      );
      final end = Offset(
        center.dx + cos(angle) * radius,
        center.dy + sin(angle) * radius,
      );
      canvas.drawLine(start, end, dashPaint);
    }

    // Inner ring
    final innerPaint = Paint()
      ..color = (isDark ? Colors.white : AppColors.accentPurple).withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.7, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _DialRingPainter oldDelegate) =>
      oldDelegate.rotation != rotation;
}

// === Feature data model ===
class _FeatureItem {
  final String emoji;
  final String label;
  final Color color;
  final int screenIndex;

  const _FeatureItem({
    required this.emoji,
    required this.label,
    required this.color,
    required this.screenIndex,
  });
}
