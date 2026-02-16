import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
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
import '../theme/cosmic_page_route.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

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
          // ─── WELCOME HEADER WITH LOGO ───
          _WelcomeHeader(firstName: firstName, zodiac: zodiac),

          const SizedBox(height: 18),

          // ─── RETRO / COSMIC ALERT ───
          if (activeRetro.isNotEmpty)
            _AlertBanner(
              icon: Icons.warning_amber_rounded,
              title: '${activeRetro.first.title} Aktif!',
              isWarning: true,
              onTap: () => Navigator.push(
                context,
                CosmicPageRoute(page: const RetroScreen()),
              ),
            ),
          if (todayEvents.isNotEmpty && activeRetro.isEmpty)
            _AlertBanner(
              icon: Icons.auto_awesome_rounded,
              title: todayEvents.first.title,
            ),

          if (todayEvents.isNotEmpty) const SizedBox(height: 16),

          // ─── DAILY ENERGY MINI CARD ───
          if (horoscope != null && zodiac != null) ...[
            _DailyEnergyCard(horoscope: horoscope, zodiac: zodiac),
            const SizedBox(height: 22),
          ],

          // ─── FEATURE SECTIONS ───
          const _SectionTitle(emoji: '🔮', title: 'Fallar & Kehanetler'),
          const SizedBox(height: 12),
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

          const SizedBox(height: 24),
          const _SectionTitle(emoji: '🛠️', title: 'Astroloji Araçları'),
          const SizedBox(height: 12),
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

          const SizedBox(height: 24),
          const _SectionTitle(emoji: '✨', title: 'Keşfet'),
          const SizedBox(height: 12),
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
          Row(
            children: [
              Expanded(
                child: _FeatureTile(
                  feature: _Feature(
                    icon: Icons.card_giftcard_rounded,
                    label: 'Kozmik Kutu',
                    subtitle: 'Sürpriz içerik',
                    gradient: const [Color(0xFFD97706), Color(0xFFF59E0B)],
                    screen: const CosmicBoxScreen(),
                  ),
                  index: 0,
                ),
              ),
              const SizedBox(width: 10),
              // Coming Soon placeholder
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.rocket_launch_rounded,
                        size: 24,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Yakında',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 50.ms),
              ),
            ],
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
    return Row(
      children: [
        // Zodi Logo
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/zodi_logo.webp',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white),
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
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  if (firstName.isNotEmpty)
                    Flexible(
                      child: Text(
                        firstName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E1B4B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (zodiac != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      zodiac.symbol,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ─── ALERT BANNER ────────────────────────────────────────────

class _AlertBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isWarning;
  final VoidCallback? onTap;

  const _AlertBanner({
    required this.icon,
    required this.title,
    this.isWarning = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isWarning ? const Color(0xFFEF4444) : const Color(0xFF7C3AED);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E1B4B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right_rounded,
                  size: 20, color: color.withValues(alpha: 0.6)),
          ],
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4C1D95).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Text(zodiac.symbol, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Bugünkü Enerjin',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '⚡',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Metrics row
          Row(
            children: [
              _EnergyMetric(
                  label: 'Aşk', value: horoscope.love, icon: '💗'),
              const SizedBox(width: 8),
              _EnergyMetric(
                  label: 'Para', value: horoscope.money, icon: '💰'),
              const SizedBox(width: 8),
              _EnergyMetric(
                  label: 'Sağlık', value: horoscope.health, icon: '💪'),
              const SizedBox(width: 8),
              _EnergyMetric(
                  label: 'Kariyer', value: horoscope.career, icon: '🎯'),
            ],
          ),

          // Motto
          if (horoscope.motto != null && horoscope.motto.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '"${horoscope.motto}"',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.03);
  }
}

class _EnergyMetric extends StatelessWidget {
  final String label;
  final int value;
  final String icon;

  const _EnergyMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              '%$value',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
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
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E1B4B),
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
    return Row(
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
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: feature.gradient.first.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: feature.gradient.first.withValues(alpha: 0.08),
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
            CosmicPageRoute(page: feature.screen),
          ),
          borderRadius: BorderRadius.circular(20),
          splashColor: feature.gradient.first.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: feature.gradient),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        feature.icon,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                    Text(
                      feature.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
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
  final Widget screen;

  const _Feature({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.screen,
  });
}
