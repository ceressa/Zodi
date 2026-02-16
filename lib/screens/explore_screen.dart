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
  late AnimationController _pulseController;
  int _selectedCategory = 0;

  static const _categories = ['Fallar', 'Araçlar', 'Keşif'];

  // Cohesive purple/violet palette — NO random colors
  static const _palettePrimary = Color(0xFF7C3AED);    // violet-600
  static const _paletteSecondary = Color(0xFF8B5CF6);  // violet-500
  static const _paletteTertiary = Color(0xFFA78BFA);   // violet-400
  static const _paletteAccent = Color(0xFF6D28D9);     // violet-700
  static const _paletteDark = Color(0xFF4C1D95);       // violet-900
  static const _paletteWarm = Color(0xFF9333EA);       // purple-600

  static const List<List<_FeatureItem>> _featuresByCategory = [
    // Fallar
    [
      _FeatureItem(icon: Icons.style_rounded, label: 'Tarot', screenIndex: 0),
      _FeatureItem(icon: Icons.coffee_rounded, label: 'Kahve Falı', screenIndex: 1),
      _FeatureItem(icon: Icons.nightlight_round, label: 'Rüya Yorumu', screenIndex: 2),
      _FeatureItem(icon: Icons.date_range_rounded, label: 'Haftalık & Aylık', screenIndex: 3),
    ],
    // Araçlar
    [
      _FeatureItem(icon: Icons.north_rounded, label: 'Yükselen Burç', screenIndex: 4),
      _FeatureItem(icon: Icons.smart_toy_rounded, label: 'AI Sohbet', screenIndex: 5),
      _FeatureItem(icon: Icons.sync_rounded, label: 'Retro Takip', screenIndex: 6),
      _FeatureItem(icon: Icons.public_rounded, label: 'Doğum Haritası', screenIndex: 7),
    ],
    // Keşif
    [
      _FeatureItem(icon: Icons.calendar_month_rounded, label: 'Kozmik Takvim', screenIndex: 8),
      _FeatureItem(icon: Icons.badge_rounded, label: 'Astro Profilim', screenIndex: 9),
      _FeatureItem(icon: Icons.card_giftcard_rounded, label: 'Kozmik Kutu', screenIndex: 10),
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
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === RETRO / KOZMİK UYARI ===
          if (activeRetro.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildAlertBanner(
                icon: Icons.warning_amber_rounded,
                title: '${activeRetro.first.title} Aktif!',
                isDark: isDark,
                isWarning: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RetroScreen()),
                ),
              ),
            ),
          if (todayEvents.isNotEmpty && activeRetro.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildAlertBanner(
                icon: Icons.auto_awesome_rounded,
                title: todayEvents.first.title,
                isDark: isDark,
              ),
            ),

          // === HERO DIAL ===
          _buildHeroDial(context, isDark, zodiac),

          const SizedBox(height: 24),

          // === KATEGORİ SEÇİCİ ===
          _buildCategoryTabs(isDark),

          const SizedBox(height: 16),

          // === ÖZELLİK GRİD ===
          _buildFeatureGrid(context, isDark),

          const SizedBox(height: 24),

          // === GÜNLÜK ENERJİ (varsa) ===
          if (horoscope != null && zodiac != null)
            _buildEnergyCard(isDark, zodiac, horoscope),

          if (horoscope != null && zodiac != null)
            const SizedBox(height: 16),

          // === YAKINDA ===
          _buildComingSoon(isDark),
        ],
      ),
    );
  }

  // ─── ALERT BANNER ───
  Widget _buildAlertBanner({
    required IconData icon,
    required String title,
    required bool isDark,
    bool isWarning = false,
    VoidCallback? onTap,
  }) {
    final color = isWarning ? const Color(0xFFEF4444) : _palettePrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.12 : 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 12),
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
              Icon(Icons.chevron_right_rounded, size: 20, color: color.withOpacity(0.6)),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ─── HERO DIAL ───
  Widget _buildHeroDial(BuildContext context, bool isDark, dynamic zodiac) {
    return Center(
      child: SizedBox(
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Subtle outer ring
            AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) {
                final t = _pulseController.value;
                return Container(
                  width: 180 + (t * 8),
                  height: 180 + (t * 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _palettePrimary.withOpacity(0.08 + t * 0.04),
                      width: 1.5,
                    ),
                  ),
                );
              },
            ),
            // Middle ring
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _palettePrimary.withOpacity(isDark ? 0.12 : 0.08),
                  width: 1,
                ),
              ),
            ),
            // Inner orbit icons
            ..._buildOrbitIcons(60, isDark),
            // Center zodiac
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_paletteSecondary, _palettePrimary],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _palettePrimary.withOpacity(0.35),
                    blurRadius: 28,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  zodiac?.symbol ?? '✦',
                  style: const TextStyle(fontSize: 42, color: Colors.white),
                ),
              ),
            ).animate().scale(
                  begin: const Offset(0.85, 0.85),
                  duration: 500.ms,
                  curve: Curves.easeOutBack,
                ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOrbitIcons(double radius, bool isDark) {
    const orbitItems = [
      Icons.style_rounded,
      Icons.coffee_rounded,
      Icons.nightlight_round,
      Icons.smart_toy_rounded,
      Icons.sync_rounded,
      Icons.public_rounded,
    ];

    return orbitItems.asMap().entries.map((entry) {
      final idx = entry.key;
      final icon = entry.value;
      final angle = (idx * (360 / orbitItems.length) - 90) * (pi / 180);
      final x = cos(angle) * radius;
      final y = sin(angle) * radius;

      return Positioned(
        left: 100 + x - 16, // center offset (200/2 = 100, icon half = 16)
        top: 100 + y - 16,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isDark
                ? _palettePrimary.withOpacity(0.18)
                : _palettePrimary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: isDark
                ? _paletteTertiary
                : _palettePrimary,
          ),
        ).animate(delay: Duration(milliseconds: idx * 60))
            .fadeIn(duration: 400.ms),
      );
    }).toList();
  }

  // ─── CATEGORY TABS ───
  Widget _buildCategoryTabs(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : _palettePrimary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
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
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _palettePrimary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _palettePrimary.withOpacity(0.25),
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
                        : (isDark ? Colors.white38 : AppColors.textMuted),
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

  // ─── FEATURE GRID ───
  Widget _buildFeatureGrid(BuildContext context, bool isDark) {
    final features = _featuresByCategory[_selectedCategory];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
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
          childAspectRatio: 1.55,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) =>
            _buildFeatureTile(context, features[index], isDark, index),
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context,
    _FeatureItem feat,
    bool isDark,
    int index,
  ) {
    // All tiles use the same purple family - differentiated by shade
    final shades = [_palettePrimary, _paletteAccent, _paletteSecondary, _paletteDark];
    final shade = shades[index % shades.length];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? shade.withOpacity(0.15) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? shade.withOpacity(0.2) : _palettePrimary.withOpacity(0.1),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: _palettePrimary.withOpacity(0.06),
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
          splashColor: _palettePrimary.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDark
                            ? shade.withOpacity(0.25)
                            : _palettePrimary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        feat.icon,
                        size: 22,
                        color: isDark ? _paletteTertiary : _palettePrimary,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: isDark
                          ? Colors.white24
                          : _palettePrimary.withOpacity(0.3),
                    ),
                  ],
                ),
                Text(
                  feat.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 50))
        .fadeIn(duration: 350.ms, curve: Curves.easeOut);
  }

  // ─── ENERGY CARD ───
  Widget _buildEnergyCard(bool isDark, dynamic zodiac, dynamic horoscope) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? _palettePrimary.withOpacity(0.1)
              : _palettePrimary.withOpacity(0.06),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: _palettePrimary.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, size: 20, color: _paletteWarm),
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
              _buildMetric(Icons.favorite_rounded, 'Aşk', horoscope.love, isDark),
              const SizedBox(width: 8),
              _buildMetric(Icons.paid_rounded, 'Para', horoscope.money, isDark),
              const SizedBox(width: 8),
              _buildMetric(Icons.fitness_center_rounded, 'Sağlık', horoscope.health, isDark),
              const SizedBox(width: 8),
              _buildMetric(Icons.work_rounded, 'Kariyer', horoscope.career, isDark),
            ],
          ),
          if (horoscope.motto != null && horoscope.motto.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _palettePrimary.withOpacity(isDark ? 0.08 : 0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '"${horoscope.motto}"',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.white60 : AppColors.textMuted,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildMetric(IconData icon, String label, int value, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: _palettePrimary.withOpacity(isDark ? 0.08 : 0.04),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: _paletteSecondary),
            const SizedBox(height: 4),
            Text(
              '%$value',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : _palettePrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── COMING SOON ───
  Widget _buildComingSoon(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : _palettePrimary.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _palettePrimary.withOpacity(isDark ? 0.12 : 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.rocket_launch_rounded,
              size: 20,
              color: isDark ? _paletteTertiary : _palettePrimary,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                Text(
                  'Afirmasyon & Meditasyon',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _palettePrimary.withOpacity(isDark ? 0.12 : 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'YAKINDA',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark ? _paletteTertiary : _palettePrimary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ─── Feature Data Model ───
class _FeatureItem {
  final IconData icon;
  final String label;
  final int screenIndex;

  const _FeatureItem({
    required this.icon,
    required this.label,
    required this.screenIndex,
  });
}
