import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../constants/astro_data.dart';
import '../providers/auth_provider.dart';
import '../providers/horoscope_provider.dart';
import '../config/fun_feature_config.dart';
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
import 'fun_feature_screen.dart';
import 'match_screen.dart';
import '../theme/cosmic_page_route.dart';
import '../widgets/starter_pack_banner.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool _hasFetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasFetched) {
      _hasFetched = true;
      _ensureDailyHoroscope();
    }
  }

  Future<void> _ensureDailyHoroscope() async {
    final authProvider = context.read<AuthProvider>();
    final horoscopeProvider = context.read<HoroscopeProvider>();

    if (authProvider.selectedZodiac != null &&
        horoscopeProvider.dailyHoroscope == null &&
        !horoscopeProvider.isLoadingDaily) {
      await horoscopeProvider.fetchDailyHoroscope(authProvider.selectedZodiac!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final horoscopeProvider = context.watch<HoroscopeProvider>();
    final zodiac = authProvider.selectedZodiac;
    final horoscope = horoscopeProvider.dailyHoroscope;
    final userName = authProvider.userName ?? '';
    final firstName = userName.split(' ').first;

    final today = DateTime.now();
    final todayEvents = AstroData.getEventsForDay(today);
    final activeRetro = todayEvents
        .where((e) =>
            e.type.name.contains('Retrograde') ||
            e.type.name.contains('retrograde'))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── WELCOME HEADER ───
          _WelcomeHeader(firstName: firstName, zodiac: zodiac),

          const SizedBox(height: 18),

          // ─── RETRO / COSMIC ALERT ───
          if (activeRetro.isNotEmpty)
            _AlertBanner(
              icon: Icons.warning_amber_rounded,
              title: '${activeRetro.first.title} Aktif!',
              subtitle: activeRetro.first.description,
              isWarning: true,
              onTap: () => Navigator.push(
                context,
                CosmicPageRoute(page: const RetroScreen()),
              ),
            ),
          if (todayEvents.isNotEmpty && activeRetro.isEmpty)
            _AlertBanner(
              icon: Icons.auto_awesome_rounded,
              title: '${todayEvents.first.emoji} ${todayEvents.first.title}',
              subtitle: todayEvents.first.description,
              onTap: () => Navigator.push(
                context,
                CosmicPageRoute(page: const CosmicCalendarScreen()),
              ),
            ),

          if (todayEvents.isNotEmpty) const SizedBox(height: 16),

          // ─── DAILY ENERGY MINI CARD ───
          if (horoscope != null && zodiac != null) ...[
            _DailyEnergyCard(horoscope: horoscope, zodiac: zodiac),
            const SizedBox(height: 16),
          ],

          // ─── BAŞLANGIÇ PAKETİ BANNER ───
          if (!authProvider.isPremium)
            const StarterPackBanner(),

          const SizedBox(height: 16),

          // ─── FEATURE SECTIONS ───
          const _SectionTitle(emoji: '🔮', title: 'Fallar'),
          const SizedBox(height: 14),
          _FeatureRow(
            features: [
              _Feature(
                icon: Icons.style_rounded,
                label: 'Tarot',
                subtitle: 'Kartlarını çek',
                gradient: const [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                screen: const TarotScreen(),
              ),
              _Feature(
                icon: Icons.coffee_rounded,
                label: 'Kahve Falı',
                subtitle: 'Fincana bak',
                gradient: const [Color(0xFF92400E), Color(0xFFB45309)],
                screen: const CoffeeFortuneScreen(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _FeatureRow(
            features: [
              _Feature(
                icon: Icons.nightlight_round,
                label: 'Rüya Yorumu',
                subtitle: 'Rüyanı anlat',
                gradient: const [Color(0xFF4C1D95), Color(0xFF5B21B6)],
                screen: const DreamScreen(),
              ),
              _Feature(
                icon: Icons.date_range_rounded,
                label: 'Haftalık & Aylık',
                subtitle: 'Geniş dönem',
                gradient: const [Color(0xFF1E40AF), Color(0xFF1D4ED8)],
                screen: const WeeklyMonthlyScreen(),
              ),
            ],
          ),

          const SizedBox(height: 28),
          const _SectionDivider(),
          const SizedBox(height: 20),
          const _SectionTitle(emoji: '🛠️', title: 'Astroloji Araçları'),
          const SizedBox(height: 14),
          _FeatureRow(
            features: [
              _Feature(
                icon: Icons.north_rounded,
                label: 'Yükselen Burç',
                subtitle: 'Hesapla',
                gradient: const [Color(0xFF059669), Color(0xFF047857)],
                screen: const RisingSignScreen(),
              ),
              _Feature(
                icon: Icons.public_rounded,
                label: 'Doğum Haritası',
                subtitle: 'Gökyüzü haritanı gör',
                gradient: const [Color(0xFF7E22CE), Color(0xFF9333EA)],
                screen: const BirthChartScreen(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _FeatureRow(
            features: [
              _Feature(
                icon: Icons.smart_toy_rounded,
                label: 'AI Astrolog',
                subtitle: 'Sohbet et',
                gradient: const [Color(0xFF0891B2), Color(0xFF0E7490)],
                screen: const ChatbotScreen(),
              ),
              _Feature(
                icon: Icons.sync_rounded,
                label: 'Retro Takip',
                subtitle: 'Gezegen retroları',
                gradient: const [Color(0xFFDC2626), Color(0xFFB91C1C)],
                screen: const RetroScreen(),
              ),
            ],
          ),

          const SizedBox(height: 28),
          const _SectionDivider(),
          const SizedBox(height: 20),
          const _SectionTitle(emoji: '✨', title: 'Keşfet'),
          const SizedBox(height: 14),
          _FeatureRow(
            features: [
              _Feature(
                icon: Icons.calendar_month_rounded,
                label: 'Kozmik Takvim',
                subtitle: 'Gökyüzü olayları',
                gradient: const [Color(0xFF6D28D9), Color(0xFF7C3AED)],
                screen: const CosmicCalendarScreen(),
              ),
              _Feature(
                icon: Icons.badge_rounded,
                label: 'Astro Profilim',
                subtitle: 'Kişisel kartın',
                gradient: const [Color(0xFFBE185D), Color(0xFFDB2777)],
                screen: const ProfileCardScreen(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _FeatureRow(
            features: [
              _Feature(
                icon: Icons.card_giftcard_rounded,
                label: 'Kozmik Kutu',
                subtitle: 'Sürpriz içerik',
                gradient: const [Color(0xFFD97706), Color(0xFFF59E0B)],
                screen: const CosmicBoxScreen(),
              ),
              _Feature(
                icon: Icons.favorite_rounded,
                label: 'Burç Uyumu',
                subtitle: 'Aşk eşleşmesi',
                gradient: const [Color(0xFFE11D48), Color(0xFFF43F5E)],
                screen: const MatchScreen(),
              ),
            ],
          ),

          // ─── FUN FEATURES SECTION ───
          const SizedBox(height: 28),
          const _SectionDivider(),
          const SizedBox(height: 20),
          const _SectionTitle(emoji: '🎭', title: 'Eğlenceli Keşifler'),
          const SizedBox(height: 14),
          ...List.generate(
            (FunFeatureConfig.allFeatures.length / 2).ceil(),
            (rowIndex) {
              final start = rowIndex * 2;
              final features = FunFeatureConfig.allFeatures.skip(start).take(2).toList();
              return Padding(
                padding: EdgeInsets.only(bottom: rowIndex < 3 ? 10 : 0),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: features.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final config = entry.value;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: idx > 0 ? 10 : 0),
                          child: _FunFeatureTile(config: config, index: start + idx),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── WELCOME HEADER ──────────────────────────────────────────

class _WelcomeHeader extends StatelessWidget {
  final String firstName;
  final dynamic zodiac;

  const _WelcomeHeader({required this.firstName, this.zodiac});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'İyi geceler';
    if (hour < 12) return 'Günaydın';
    if (hour < 18) return 'İyi günler';
    return 'İyi akşamlar';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        // Astro Dozi karakter avatarı
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/astro_dozi_hi.webp',
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white54 : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 2),
              if (firstName.isNotEmpty)
                Text(
                  firstName,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        // Burç sembolü pill
        if (zodiac != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF7C3AED).withValues(alpha: 0.30), const Color(0xFF4C1D95).withValues(alpha: 0.30)]
                    : [const Color(0xFFA78BFA).withValues(alpha: 0.15), const Color(0xFF8B5CF6).withValues(alpha: 0.15)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : const Color(0xFF7C3AED).withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(zodiac.symbol, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 4),
                Text(
                  zodiac.displayName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED),
                  ),
                ),
              ],
            ),
          ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ─── SECTION DIVIDER ─────────────────────────────────────────

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            isDark
                ? Colors.white.withValues(alpha: 0.06)
                : const Color(0xFF7C3AED).withValues(alpha: 0.08),
            isDark
                ? Colors.white.withValues(alpha: 0.06)
                : const Color(0xFF7C3AED).withValues(alpha: 0.08),
            Colors.transparent,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }
}

// ─── ALERT BANNER ────────────────────────────────────────────

class _AlertBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isWarning;
  final VoidCallback? onTap;

  const _AlertBanner({
    required this.icon,
    required this.title,
    this.subtitle,
    this.isWarning = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color =
        isWarning ? const Color(0xFFEF4444) : const Color(0xFF7C3AED);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.10 : 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? color.withValues(alpha: 0.20)
                : color.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : const Color(0xFF1E1B4B).withValues(alpha: 0.6),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right_rounded,
                  size: 20, color: color.withValues(alpha: 0.6)),
          ],
        ),
      ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ─── DAILY ENERGY CARD ───────────────────────────────────────

class _DailyEnergyCard extends StatelessWidget {
  final dynamic horoscope;
  final dynamic zodiac;

  const _DailyEnergyCard({required this.horoscope, required this.zodiac});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
      children: [
      Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4C1D95), Color(0xFF7C3AED), Color(0xFFA78BFA)],
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4C1D95).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20),
                  ),
                ),
                child: Center(
                  child: Text(zodiac.symbol, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bugünkü Enerjin',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      zodiac.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.60),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.30),
                  ),
                ),
                child: const Text(
                  '⚡ Enerji',
                  style: TextStyle(fontSize: 12, color: Color(0xFFFBBF24), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Metrics row
          Row(
            children: [
              _EnergyMetric(
                  label: 'Aşk', value: horoscope.love, icon: '💗', color: const Color(0xFFF472B6)),
              const SizedBox(width: 8),
              _EnergyMetric(
                  label: 'Para', value: horoscope.money, icon: '💰', color: const Color(0xFFFBBF24)),
              const SizedBox(width: 8),
              _EnergyMetric(
                  label: 'Sağlık', value: horoscope.health, icon: '💪', color: const Color(0xFF34D399)),
              const SizedBox(width: 8),
              _EnergyMetric(
                  label: 'Kariyer', value: horoscope.career, icon: '🎯', color: const Color(0xFF60A5FA)),
            ],
          ),

          // Motto
          if (horoscope.motto != null && horoscope.motto.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Text('✨', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '"${horoscope.motto}"',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
      // Astro Dozi karakter — sağ alt köşe
      Positioned(
        right: -4,
        bottom: -4,
        child: Opacity(
          opacity: 0.10,
          child: Image.asset(
            'assets/astro_dozi_main.webp',
            width: 90,
            height: 90,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ),
      ],
    ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.03);
  }
}

class _EnergyMetric extends StatelessWidget {
  final String label;
  final int value;
  final String icon;
  final Color color;

  const _EnergyMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.10),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              '%$value',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.50),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SECTION TITLE ───────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String emoji;
  final String title;

  const _SectionTitle({required this.emoji, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Gradient underline
        Container(
          width: 44,
          height: 3,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

// ─── FEATURE ROW ─────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  final List<_Feature> features;

  const _FeatureRow({required this.features});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: features.asMap().entries.map((entry) {
          final idx = entry.key;
          final feat = entry.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: idx > 0 ? 10 : 0),
              child: _FeatureTile(feature: feat, index: idx),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── FEATURE TILE ────────────────────────────────────────────

class _FeatureTile extends StatelessWidget {
  final _Feature feature;
  final int index;

  const _FeatureTile({required this.feature, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF252158)]
              : [Colors.white, const Color(0xFFFAF5FF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : feature.gradient.first.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.white.withValues(alpha: 0.60),
            blurRadius: 6,
            offset: const Offset(-2, -2),
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.30)
                : feature.gradient.first.withValues(alpha: 0.12),
            blurRadius: 15,
            offset: const Offset(4, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (feature.screen == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Bu özellik çok yakında geliyor! 🚀'),
                  backgroundColor: const Color(0xFF7C3AED),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
              return;
            }
            Navigator.push(
              context,
              CosmicPageRoute(page: feature.screen!),
            );
          },
          borderRadius: BorderRadius.circular(24),
          splashColor: feature.gradient.first.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: feature.gradient),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: feature.gradient.first.withValues(alpha: 0.30),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        feature.icon,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  feature.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  feature.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 40))
        .fadeIn(duration: 300.ms, curve: Curves.easeOut);
  }
}

// ─── DATA MODEL ──────────────────────────────────────────────

class _Feature {
  final IconData icon;
  final String label;
  final String subtitle;
  final List<Color> gradient;
  final Widget? screen;

  const _Feature({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    this.screen,
  });
}

// ─── FUN FEATURE TILE ─────────────────────────────────────────

class _FunFeatureTile extends StatelessWidget {
  final FunFeatureConfig config;
  final int index;

  const _FunFeatureTile({required this.config, required this.index});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userTier = authProvider.membershipTier;
    final isLocked = config.requiredTier != null && !config.canAccess(userTier);
    final isIncluded = config.isIncludedInTier(userTier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF252158)]
              : [Colors.white, const Color(0xFFFAF5FF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLocked
              ? (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade300)
              : (isDark ? Colors.white.withValues(alpha: 0.08) : config.gradient.first.withValues(alpha: 0.10)),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.white.withValues(alpha: 0.60),
            blurRadius: 6,
            offset: const Offset(-2, -2),
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.30)
                : config.gradient.first.withValues(alpha: isLocked ? 0.04 : 0.12),
            blurRadius: 15,
            offset: const Offset(4, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            CosmicPageRoute(page: FunFeatureScreen(config: config)),
          ),
          borderRadius: BorderRadius.circular(24),
          splashColor: config.gradient.first.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isLocked
                              ? [Colors.grey.shade400, Colors.grey.shade500]
                              : config.gradient,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: isLocked ? null : [
                          BoxShadow(
                            color: config.gradient.first.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: isLocked
                            ? const Icon(Icons.lock_rounded,
                                size: 18, color: Colors.white)
                            : Text(
                                config.emoji,
                                style: const TextStyle(fontSize: 20),
                              ),
                      ),
                    ),
                    const Spacer(),
                    _buildBadge(isLocked, isIncluded),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  config.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isLocked
                        ? (isDark ? Colors.white38 : Colors.grey.shade500)
                        : (isDark ? Colors.white : const Color(0xFF1E1B4B)),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  config.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 40))
        .fadeIn(duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _buildBadge(bool isLocked, bool isIncluded) {
    if (isLocked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF3E8FF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_rounded, size: 10, color: Color(0xFF7C3AED)),
            SizedBox(width: 3),
            Text(
              'Premium',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Color(0xFF7C3AED),
              ),
            ),
          ],
        ),
      );
    } else if (isIncluded) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Ücretsiz',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Color(0xFF16A34A),
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.monetization_on,
                size: 10, color: Color(0xFFB45309)),
            const SizedBox(width: 3),
            Text(
              '${config.coinCost}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFFB45309),
              ),
            ),
          ],
        ),
      );
    }
  }
}
