import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/horoscope_provider.dart';
import '../screens/daily_screen.dart';
import '../screens/tarot_screen.dart';
import '../screens/match_screen.dart';
import '../screens/dream_screen.dart';
import '../screens/weekly_monthly_screen.dart';
import '../screens/analysis_screen.dart';
import '../screens/retro_screen.dart';
import '../screens/cosmic_calendar_screen.dart';
import '../constants/astro_data.dart';
import '../theme/cosmic_page_route.dart';

class DailyCommentPage extends StatefulWidget {
  const DailyCommentPage({super.key});

  @override
  State<DailyCommentPage> createState() => _DailyCommentPageState();
}

class _DailyCommentPageState extends State<DailyCommentPage> {
  bool _isLoadingHoroscope = false;

  @override
  void initState() {
    super.initState();
    _loadDailyHoroscope();
  }

  Future<void> _loadDailyHoroscope() async {
    final authProvider = context.read<AuthProvider>();
    final horoscopeProvider = context.read<HoroscopeProvider>();

    if (authProvider.selectedZodiac != null &&
        horoscopeProvider.dailyHoroscope == null) {
      setState(() => _isLoadingHoroscope = true);
      await horoscopeProvider.fetchDailyHoroscope(authProvider.selectedZodiac!);
      if (mounted) setState(() => _isLoadingHoroscope = false);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'İyi geceler';
    if (hour < 12) return 'Günaydın';
    if (hour < 18) return 'İyi günler';
    return 'İyi akşamlar';
  }

  String _getZodiacEmoji(String? zodiac) {
    const emojis = {
      'aries': '♈', 'taurus': '♉', 'gemini': '♊', 'cancer': '♋',
      'leo': '♌', 'virgo': '♍', 'libra': '♎', 'scorpio': '♏',
      'sagittarius': '♐', 'capricorn': '♑', 'aquarius': '♒', 'pisces': '♓',
    };
    return emojis[zodiac?.toLowerCase()] ?? '✨';
  }

  String _getZodiacTurkish(String? zodiac) {
    const names = {
      'aries': 'Koç', 'taurus': 'Boğa', 'gemini': 'İkizler',
      'cancer': 'Yengeç', 'leo': 'Aslan', 'virgo': 'Başak',
      'libra': 'Terazi', 'scorpio': 'Akrep', 'sagittarius': 'Yay',
      'capricorn': 'Oğlak', 'aquarius': 'Kova', 'pisces': 'Balık',
    };
    return names[zodiac?.toLowerCase()] ?? 'Burç';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final horoscopeProvider = context.watch<HoroscopeProvider>();
    final now = DateTime.now();
    final dayName = DateFormat('EEEE', 'tr_TR').format(now);
    final dateStr = '${now.day} ${DateFormat('MMMM', 'tr_TR').format(now)}';
    final zodiacEmoji = _getZodiacEmoji(authProvider.selectedZodiac?.name);
    final zodiacName = _getZodiacTurkish(authProvider.selectedZodiac?.name);
    final firstName = authProvider.userName?.split(' ').first ?? '';
    final horoscope = horoscopeProvider.dailyHoroscope;

    return RefreshIndicator(
      color: AppColors.purple600,
      onRefresh: () async {
        if (authProvider.selectedZodiac != null) {
          await horoscopeProvider
              .fetchDailyHoroscope(authProvider.selectedZodiac!);
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ─── GREETING HEADER ───
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getGreeting()}, $firstName',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.purple800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$dayName, $dateStr',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.gray600.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purple400.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(zodiacEmoji,
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text(
                        zodiacName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1),

            const SizedBox(height: 24),

            // ─── GÜNLÜK YORUM KARTI ───
            if (_isLoadingHoroscope)
              _buildLoadingCard()
            else if (horoscope != null)
              _buildHoroscopeCard(horoscope)
            else
              _buildFetchCard(authProvider, horoscopeProvider),

            // ─── METRİKLER ───
            if (horoscope != null) ...[
              const SizedBox(height: 16),
              _buildMetricsRow(horoscope),
            ],

            const SizedBox(height: 28),

            // ─── BÖLÜM AYIRICI ───
            _buildSectionDivider(),

            const SizedBox(height: 20),

            // ─── COSMIC ALERT ───
            _buildCosmicAlert(),

            // ─── HAFTALIK & AYLIK ───
            _buildSectionTitle('📅', 'Haftalık & Aylık'),
            const SizedBox(height: 12),
            _buildWeeklyMonthlyChips(),

            const SizedBox(height: 28),

            // ─── BÖLÜM AYIRICI ───
            _buildSectionDivider(),

            const SizedBox(height: 20),

            // ─── DETAYLI ANALİZ ───
            _buildAnalysisSection(),

            const SizedBox(height: 28),

            // ─── BÖLÜM AYIRICI ───
            _buildSectionDivider(),

            const SizedBox(height: 20),

            // ─── HIZLI ERİŞİM ───
            _buildSectionTitle('⚡', 'Hızlı Erişim'),
            const SizedBox(height: 12),
            _buildQuickActions(),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.purple200.withValues(alpha: 0.6),
                  AppColors.purple200.withValues(alpha: 0.6),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.2, 0.8, 1.0],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.purple300.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.purple200.withValues(alpha: 0.6),
                  AppColors.purple200.withValues(alpha: 0.6),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.2, 0.8, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String emoji, String title) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.purple800,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.purple200),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              color: AppColors.purple500,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Yıldızların mesajı geliyor...',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.purple600.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildFetchCard(
      AuthProvider auth, HoroscopeProvider horoscopeProvider) {
    return GestureDetector(
      onTap: () async {
        if (auth.selectedZodiac != null) {
          setState(() => _isLoadingHoroscope = true);
          await horoscopeProvider
              .fetchDailyHoroscope(auth.selectedZodiac!);
          if (mounted) setState(() => _isLoadingHoroscope = false);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0E7FF), Color(0xFFEDE9FE), Color(0xFFFCE7F3)],
          ),
          border: Border.all(color: AppColors.purple200),
        ),
        child: Column(
          children: [
            Text(
              _getZodiacEmoji(auth.selectedZodiac?.name),
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 12),
            const Text(
              'Günlük yorumunu görmek için dokun',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.purple800,
              ),
            ),
            const SizedBox(height: 4),
            const Icon(Icons.touch_app_rounded,
                color: AppColors.purple400, size: 20),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn()
        .scale(begin: const Offset(0.95, 0.95), duration: 400.ms);
  }

  Widget _buildHoroscopeCard(dynamic horoscope) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, CosmicPageRoute(page: const DailyScreen()));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border:
              Border.all(color: AppColors.purple200.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple400.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.8),
              blurRadius: 4,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Günlük Yorum',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.purple800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.purple100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Detay',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.purple600,
                              fontWeight: FontWeight.w600)),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward_ios,
                          size: 10, color: AppColors.purple600),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Motto
            if (horoscope.motto.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.purple100.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '"${horoscope.motto}"',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: AppColors.purple800,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 14),

            // Commentary preview
            Text(
              horoscope.commentary,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.gray700,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 12),

            // Lucky items
            Row(
              children: [
                _luckyChip('🎨', horoscope.luckyColor),
                const SizedBox(width: 8),
                _luckyChip('🔢', '${horoscope.luckyNumber}'),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
  }

  Widget _luckyChip(String emoji, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.purple100.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.purple800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(dynamic horoscope) {
    return Row(
      children: [
        _metricTile('💗', 'Aşk', horoscope.love),
        const SizedBox(width: 8),
        _metricTile('💰', 'Para', horoscope.money),
        const SizedBox(width: 8),
        _metricTile('💪', 'Sağlık', horoscope.health),
        const SizedBox(width: 8),
        _metricTile('💼', 'Kariyer', horoscope.career),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _metricTile(String emoji, String label, int value) {
    // 0-100 değerini 0-5 yıldıza çevir
    final stars = (value / 20).round().clamp(0, 5);
    final color = value >= 70
        ? AppColors.emerald400
        : value >= 40
            ? AppColors.amber400
            : AppColors.red400;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: color.withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => Icon(
                i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 14,
                color: i < stars ? color : color.withValues(alpha: 0.25),
              )),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style:
                  const TextStyle(fontSize: 11, color: AppColors.gray600, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCosmicAlert() {
    final today = DateTime.now();
    final todayEvents = AstroData.getEventsForDay(today);
    final activeRetro = todayEvents
        .where((e) =>
            e.type.name.contains('Retrograde') ||
            e.type.name.contains('retrograde'))
        .toList();

    if (todayEvents.isEmpty) return const SizedBox.shrink();

    final isWarning = activeRetro.isNotEmpty;
    final event = isWarning ? activeRetro.first : todayEvents.first;
    final color = isWarning ? const Color(0xFFEF4444) : const Color(0xFF7C3AED);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          CosmicPageRoute(
            page: isWarning ? const RetroScreen() : const CosmicCalendarScreen(),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Icon(
                isWarning ? Icons.warning_amber_rounded : Icons.auto_awesome_rounded,
                size: 22,
                color: color,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isWarning ? '${event.title} Aktif!' : '${event.emoji} ${event.title}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E1B4B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      event.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF1E1B4B).withValues(alpha: 0.6),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: color.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildWeeklyMonthlyChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              CosmicPageRoute(page: const WeeklyMonthlyScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.purple200.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purple400.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(Icons.date_range_rounded, size: 24, color: AppColors.purple600),
                  SizedBox(height: 8),
                  Text(
                    'Haftalık',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.purple800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              CosmicPageRoute(page: const WeeklyMonthlyScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.purple200.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purple400.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(Icons.calendar_month_rounded, size: 24, color: AppColors.purple600),
                  SizedBox(height: 8),
                  Text(
                    'Aylık',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.purple800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildAnalysisSection() {
    const categories = [
      {'emoji': '💗', 'label': 'Aşk', 'color': Color(0xFFEC4899)},
      {'emoji': '🎯', 'label': 'Kariyer', 'color': Color(0xFF8B5CF6)},
      {'emoji': '💪', 'label': 'Sağlık', 'color': Color(0xFF10B981)},
      {'emoji': '💰', 'label': 'Para', 'color': Color(0xFFF59E0B)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('🔮', 'Detaylı Analiz'),
        const SizedBox(height: 14),
        Row(
          children: categories.asMap().entries.map((entry) {
            final cat = entry.value;
            final color = cat['color'] as Color;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: entry.key == 0 ? 0 : 8,
                ),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    CosmicPageRoute(page: const AnalysisScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: color.withValues(alpha: 0.20),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.10),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(cat['emoji'] as String, style: const TextStyle(fontSize: 20)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat['label'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _quickCard(
            '🃏',
            'Tarot',
            [AppColors.violet400, AppColors.purple400],
            () => Navigator.push(
                context, CosmicPageRoute(page: const TarotScreen())),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickCard(
            '💕',
            'Uyum',
            [AppColors.pink400, AppColors.rose400],
            () => Navigator.push(
                context, CosmicPageRoute(page: const MatchScreen(showAppBar: true))),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickCard(
            '🌙',
            'Rüya',
            [AppColors.indigo400, AppColors.cyan400],
            () => Navigator.push(
                context, CosmicPageRoute(page: const DreamScreen())),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _quickCard(
      String emoji, String label, List<Color> colors, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.30),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
