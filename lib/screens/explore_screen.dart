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
import 'cosmic_box_screen.dart';
import 'profile_card_screen.dart';
import 'retro_screen.dart';
import 'astro_quiz_screen.dart';
import 'achievement_screen.dart';
import 'cosmic_calendar_screen.dart';
import 'birth_chart_screen.dart';
import 'fun_feature_screen.dart';
import 'personality_quiz_screen.dart';
import 'premium_screen.dart';
import '../theme/cosmic_page_route.dart';
import '../widgets/starter_pack_banner.dart';
import '../widgets/time_based_background.dart';

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

    return TimeBasedBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8, bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── WELCOME HEADER ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _WelcomeHeader(firstName: firstName, zodiac: zodiac),
            ),

            const SizedBox(height: 18),

            // ─── RETRO / COSMIC ALERT ───
            if (activeRetro.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _AlertBanner(
                  icon: Icons.warning_amber_rounded,
                  title: '${activeRetro.first.title} Aktif!',
                  subtitle: activeRetro.first.description,
                  isWarning: true,
                  onTap: () => Navigator.push(
                    context,
                    CosmicPageRoute(page: const RetroScreen()),
                  ),
                ),
              ),
            if (todayEvents.isNotEmpty && activeRetro.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _AlertBanner(
                  icon: Icons.auto_awesome_rounded,
                  title: '${todayEvents.first.emoji} ${todayEvents.first.title}',
                  subtitle: todayEvents.first.description,
                  onTap: () => Navigator.push(
                    context,
                    CosmicPageRoute(page: const CosmicCalendarScreen()),
                  ),
                ),
              ),

            if (todayEvents.isNotEmpty) const SizedBox(height: 16),

            // ─── DAILY ENERGY MINI CARD ───
            if (horoscope != null && zodiac != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _DailyEnergyCard(horoscope: horoscope, zodiac: zodiac),
              ),
              const SizedBox(height: 16),
            ],

            // ─── BAŞLANGIÇ PAKETİ BANNER ───
            if (!authProvider.isPremium)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const StarterPackBanner(),
              ),

            if (!authProvider.isPremium) const SizedBox(height: 16),

            // ─── EĞLENCELİ KEŞİFLER ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const _SectionTitle(emoji: '🎪', title: 'Eğlenceli Keşifler'),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.85,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: _funFeatures.map((fun) {
                  return _FunTile(
                    emoji: fun.emoji,
                    label: fun.label,
                    coinCost: fun.coinCost,
                    gradient: fun.gradient,
                    onTap: () => _onFunFeatureTap(fun.featureId),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 28),

            // ─── ARAÇLAR ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const _SectionTitle(emoji: '🛠️', title: 'Araçlar'),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.95,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: _toolItems.map((tool) {
                  return _CompactToolTile(
                    icon: tool.icon,
                    label: tool.label,
                    gradient: tool.gradient,
                    onTap: () => Navigator.push(
                      context,
                      CosmicPageRoute(page: tool.screen!),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ─── Fun Feature Tap Handler ──────────────────────────────
  void _onFunFeatureTap(String featureId) {
    final config = FunFeatureConfig.getById(featureId);
    if (config == null) return;

    final authProvider = context.read<AuthProvider>();
    final userTier = authProvider.membershipTier;

    // Tier kilidi varsa premium sayfasına yönlendir
    if (!config.canAccess(userTier)) {
      Navigator.push(context, CosmicPageRoute(page: const PremiumScreen()));
      return;
    }

    Navigator.push(
      context,
      CosmicPageRoute(page: FunFeatureScreen(config: config)),
    );
  }

  // ─── FUN FEATURE DATA ─────────────────────────────────────
  static final List<_FunItem> _funFeatures = [
    _FunItem(featureId: 'numerology', emoji: '🔢', label: 'Numeroloji', coinCost: 0, gradient: const [Color(0xFF7C3AED), Color(0xFF6D28D9)]),
    _FunItem(featureId: 'spirit_animal', emoji: '🦋', label: 'Ruh\nHayvanın', coinCost: 0, gradient: const [Color(0xFF059669), Color(0xFF047857)]),
    _FunItem(featureId: 'luck_map', emoji: '🍀', label: 'Şans\nHaritası', coinCost: 0, gradient: const [Color(0xFF16A34A), Color(0xFF15803D)]),
    _FunItem(featureId: 'element_analysis', emoji: '🔥', label: 'Element\nAnalizi', coinCost: 0, gradient: const [Color(0xFFEA580C), Color(0xFFC2410C)]),
    _FunItem(featureId: 'aura', emoji: '✨', label: 'Aura\nAnalizi', coinCost: 0, gradient: const [Color(0xFFDB2777), Color(0xFFBE185D)]),
    _FunItem(featureId: 'chakra', emoji: '🌈', label: 'Çakra\nAnalizi', coinCost: 0, gradient: const [Color(0xFF0891B2), Color(0xFF0E7490)]),
    _FunItem(featureId: 'cosmic_message', emoji: '💫', label: 'Kozmik\nMesaj', coinCost: 0, gradient: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)]),
    _FunItem(featureId: 'life_path', emoji: '🛤️', label: 'Yaşam\nYolu', coinCost: 8, gradient: const [Color(0xFFD97706), Color(0xFFB45309)]),
    _FunItem(featureId: 'astro_career', emoji: '💼', label: 'Astro\nKariyer', coinCost: 8, gradient: const [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
  ];

  // ─── TOOL DATA ────────────────────────────────────────────
  static final List<_Feature> _toolItems = [
    _Feature(
      icon: Icons.date_range_rounded,
      label: 'Haftalık\n& Aylık',
      subtitle: '',
      gradient: const [Color(0xFF1E40AF), Color(0xFF1D4ED8)],
      screen: const WeeklyMonthlyScreen(),
    ),
    _Feature(
      icon: Icons.north_rounded,
      label: 'Yükselen\nBurç',
      subtitle: '',
      gradient: const [Color(0xFF059669), Color(0xFF047857)],
      screen: const RisingSignScreen(),
    ),
    _Feature(
      icon: Icons.public_rounded,
      label: 'Doğum\nHaritası',
      subtitle: '',
      gradient: const [Color(0xFF7E22CE), Color(0xFF9333EA)],
      screen: const BirthChartScreen(),
    ),
    _Feature(
      icon: Icons.sync_rounded,
      label: 'Retro\nTakip',
      subtitle: '',
      gradient: const [Color(0xFFDC2626), Color(0xFFB91C1C)],
      screen: const RetroScreen(),
    ),
    _Feature(
      icon: Icons.calendar_month_rounded,
      label: 'Kozmik\nTakvim',
      subtitle: '',
      gradient: const [Color(0xFF6D28D9), Color(0xFF7C3AED)],
      screen: const CosmicCalendarScreen(),
    ),
    _Feature(
      icon: Icons.badge_rounded,
      label: 'Astro\nProfilim',
      subtitle: '',
      gradient: const [Color(0xFFBE185D), Color(0xFFDB2777)],
      screen: const ProfileCardScreen(),
    ),
    _Feature(
      icon: Icons.card_giftcard_rounded,
      label: 'Kozmik\nKutu',
      subtitle: '',
      gradient: const [Color(0xFFD97706), Color(0xFFF59E0B)],
      screen: const CosmicBoxScreen(),
    ),
    _Feature(
      icon: Icons.quiz_rounded,
      label: 'Astro\nQuiz',
      subtitle: '',
      gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
      screen: const AstroQuizScreen(),
    ),
    _Feature(
      icon: Icons.emoji_events_rounded,
      label: 'Rozetlerim',
      subtitle: '',
      gradient: const [Color(0xFF10B981), Color(0xFF059669)],
      screen: const AchievementScreen(),
    ),
    _Feature(
      icon: Icons.psychology_rounded,
      label: 'Kişilik\nTesti',
      subtitle: '',
      gradient: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
      screen: const PersonalityQuizScreen(isOnboarding: false),
    ),
  ];
}

// ─── DATA MODELS ─────────────────────────────────────────────

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

class _FunItem {
  final String featureId;
  final String emoji;
  final String label;
  final int coinCost;
  final List<Color> gradient;

  const _FunItem({
    required this.featureId,
    required this.emoji,
    required this.label,
    required this.coinCost,
    required this.gradient,
  });
}

// ─── FUN TILE ────────────────────────────────────────────────

class _FunTile extends StatelessWidget {
  final String emoji;
  final String label;
  final int coinCost;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _FunTile({
    required this.emoji,
    required this.label,
    required this.coinCost,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFree = coinCost == 0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: gradient.first.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          splashColor: gradient.first.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Emoji (büyük)
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 6),
                // Başlık
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1B4B),
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Fiyat badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isFree
                        ? const Color(0xFF10B981).withValues(alpha: 0.10)
                        : const Color(0xFFF59E0B).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isFree ? 'Ücretsiz' : '$coinCost ✨',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isFree
                          ? const Color(0xFF059669)
                          : const Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── COMPACT TOOL TILE ──────────────────────────────────────

class _CompactToolTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _CompactToolTile({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: gradient.first.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          splashColor: gradient.first.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.first.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 20, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1B4B),
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── WELCOME HEADER ──────────────────────────────────────────

class _WelcomeHeader extends StatelessWidget {
  final String firstName;
  final dynamic zodiac;

  const _WelcomeHeader({required this.firstName, this.zodiac});

  _TimeGreeting _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) {
      return _TimeGreeting(
        greeting: 'İyi geceler',
        subtitle: 'Yıldızlar seninle parlıyor',
        emoji: '🌙',
        gradientColors: [const Color(0xFF1E1B4B), const Color(0xFF312E81)],
      );
    } else if (hour < 9) {
      return _TimeGreeting(
        greeting: 'Günaydın',
        subtitle: 'Yeni bir gün, yeni enerjiler',
        emoji: '🌅',
        gradientColors: [const Color(0xFFF97316), const Color(0xFFFBBF24)],
      );
    } else if (hour < 12) {
      return _TimeGreeting(
        greeting: 'Günaydın',
        subtitle: 'Bugünün enerjisi seninle',
        emoji: '☀️',
        gradientColors: [const Color(0xFFFBBF24), const Color(0xFFF59E0B)],
      );
    } else if (hour < 15) {
      return _TimeGreeting(
        greeting: 'İyi günler',
        subtitle: 'Öğle enerjisi yükseliyor',
        emoji: '✨',
        gradientColors: [const Color(0xFF7C3AED), const Color(0xFFA78BFA)],
      );
    } else if (hour < 18) {
      return _TimeGreeting(
        greeting: 'İyi günler',
        subtitle: 'Günün ikinci yarısı senin',
        emoji: '🌤️',
        gradientColors: [const Color(0xFF0EA5E9), const Color(0xFF38BDF8)],
      );
    } else if (hour < 21) {
      return _TimeGreeting(
        greeting: 'İyi akşamlar',
        subtitle: 'Akşam huzuru seninle',
        emoji: '🌆',
        gradientColors: [const Color(0xFFDB2777), const Color(0xFFF472B6)],
      );
    } else {
      return _TimeGreeting(
        greeting: 'İyi geceler',
        subtitle: 'Yıldızlar sana fısıldıyor',
        emoji: '🌌',
        gradientColors: [const Color(0xFF4C1D95), const Color(0xFF6D28D9)],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeGreeting = _getTimeGreeting();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            timeGreeting.gradientColors.first,
            timeGreeting.gradientColors.last,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: timeGreeting.gradientColors.first.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/astro_dozi_hi.webp',
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Text(
                  timeGreeting.emoji,
                  style: const TextStyle(fontSize: 28),
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
                  '${timeGreeting.emoji} ${timeGreeting.greeting}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 2),
                if (firstName.isNotEmpty)
                  Text(
                    firstName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Text(
                  timeGreeting.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          if (zodiac != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(zodiac.symbol, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 4),
                  Text(
                    zodiac.displayName,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _TimeGreeting {
  final String greeting;
  final String subtitle;
  final String emoji;
  final List<Color> gradientColors;

  const _TimeGreeting({
    required this.greeting,
    required this.subtitle,
    required this.emoji,
    required this.gradientColors,
  });
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
              color: color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: 0.12),
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
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E1B4B),
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
                            color: const Color(0xFF1E1B4B).withValues(alpha: 0.6),
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
                Row(
                  children: [
                    _EnergyMetric(label: 'Aşk', value: horoscope.love, icon: '💗', color: const Color(0xFFF472B6)),
                    const SizedBox(width: 8),
                    _EnergyMetric(label: 'Para', value: horoscope.money, icon: '💰', color: const Color(0xFFFBBF24)),
                    const SizedBox(width: 8),
                    _EnergyMetric(label: 'Sağlık', value: horoscope.health, icon: '💪', color: const Color(0xFF34D399)),
                    const SizedBox(width: 8),
                    _EnergyMetric(label: 'Kariyer', value: horoscope.career, icon: '🎯', color: const Color(0xFF60A5FA)),
                  ],
                ),
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
                        const Text('✨', style: TextStyle(fontSize: 16)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E1B4B),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
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
