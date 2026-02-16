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

            // Greeting + zodiac badge
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getGreeting()}, $firstName',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.purple800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$dayName, $dateStr',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.gray600,
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

            const SizedBox(height: 20),

            // Daily horoscope card
            if (_isLoadingHoroscope)
              _buildLoadingCard()
            else if (horoscope != null)
              _buildHoroscopeCard(horoscope)
            else
              _buildFetchCard(authProvider, horoscopeProvider),

            const SizedBox(height: 20),

            // Metrics row
            if (horoscope != null) ...[
              _buildMetricsRow(horoscope),
              const SizedBox(height: 20),
            ],

            // Quick actions
            const Text(
              'Hızlı Erişim',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.purple800,
              ),
            ),
            const SizedBox(height: 12),
            _buildQuickActions(),

            const SizedBox(height: 100),
          ],
        ),
      ),
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
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(24),
          border:
              Border.all(color: AppColors.purple200.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple400.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
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
    final color = value >= 70
        ? AppColors.emerald400
        : value >= 40
            ? AppColors.amber400
            : AppColors.red400;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.purple100),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style:
                  const TextStyle(fontSize: 10, color: AppColors.gray600),
            ),
          ],
        ),
      ),
    );
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
                context, CosmicPageRoute(page: const MatchScreen())),
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
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
