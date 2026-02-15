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

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final horoscopeProvider = context.watch<HoroscopeProvider>();
    final zodiac = authProvider.selectedZodiac;
    final horoscope = horoscopeProvider.dailyHoroscope;

    // Bugünkü astrolojik olaylar
    final today = DateTime.now();
    final todayEvents = AstroData.getEventsForDay(today);
    final activeRetro = todayEvents.where(
      (e) => e.type.name.contains('Retrograde') || e.type.name.contains('retrograde'),
    ).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
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
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.textPrimary : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (zodiac != null)
                      Text(
                        '${zodiac.symbol} ${zodiac.displayName} — Kozmik rehberin hazır',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                        ),
                      )
                    else
                      Text(
                        'Tüm özellikler ve fallar',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              // Profil avatar
              if (zodiac != null)
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppColors.cosmicGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentPurple.withOpacity(0.3),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(zodiac.symbol, style: const TextStyle(fontSize: 28)),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // === RETRO / KOZMİK UYARI BANNER ===
          if (activeRetro.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF6347).withOpacity(0.15),
                    const Color(0xFFFF6347).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFF6347).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF6347).withOpacity(0.15),
                    ),
                    child: const Center(
                      child: Text('⚠️', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${activeRetro.first.title} Aktif!',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          activeRetro.first.description.length > 60
                              ? '${activeRetro.first.description.substring(0, 60)}...'
                              : activeRetro.first.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RetroScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6347).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Detay',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6347),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .shimmer(duration: 2000.ms, color: const Color(0xFFFF6347).withOpacity(0.05)),

          if (activeRetro.isNotEmpty) const SizedBox(height: 16),

          // === BUGÜNKÜ KOZMİK OLAYLAR (retro yoksa da göster) ===
          if (todayEvents.isNotEmpty && activeRetro.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentPurple.withOpacity(0.1),
                    AppColors.primaryPink.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.accentPurple.withOpacity(0.15),
                ),
              ),
              child: Row(
                children: [
                  Text(todayEvents.first.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todayEvents.first.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          todayEvents.first.description.length > 55
                              ? '${todayEvents.first.description.substring(0, 55)}...'
                              : todayEvents.first.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideX(begin: -0.05, duration: 400.ms),

          if (todayEvents.isNotEmpty && activeRetro.isEmpty) const SizedBox(height: 16),

          // === MİNİ GÜNLÜK ÖZET (Horoscope yüklüyse) ===
          if (horoscope != null && zodiac != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentPurple.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık
                  Row(
                    children: [
                      Text(zodiac.symbol, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Text(
                        'Bugünkü Enerjin',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPink.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Bugün',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryPink,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 4 Mini metrik
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

                  const SizedBox(height: 14),

                  // Motto
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.accentPurple.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '"${horoscope.motto}"',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textDark.withOpacity(0.7),
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, duration: 400.ms),

          if (horoscope != null && zodiac != null) const SizedBox(height: 16),

          // === HIZLI ERİŞİM GRID ===
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  context: context,
                  emoji: '🃏',
                  label: 'Tarot',
                  color: const Color(0xFF9333EA),
                  screen: const TarotScreen(),
                  delay: 0,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickAction(
                  context: context,
                  emoji: '☕',
                  label: 'Kahve',
                  color: const Color(0xFFD97706),
                  screen: const CoffeeFortuneScreen(),
                  delay: 50,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickAction(
                  context: context,
                  emoji: '🌙',
                  label: 'Rüya',
                  color: const Color(0xFF7C3AED),
                  screen: const DreamScreen(),
                  delay: 100,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickAction(
                  context: context,
                  emoji: '🔮',
                  label: 'Sohbet',
                  color: const Color(0xFF1E1B4B),
                  screen: const ChatbotScreen(),
                  delay: 150,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // === KOZMİK KUTU BANNER ===
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.cosmicGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentPurple.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CosmicBoxScreen()),
                ),
                borderRadius: BorderRadius.circular(20),
                splashColor: Colors.white.withOpacity(0.15),
                highlightColor: Colors.white.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Text('🎁', style: TextStyle(fontSize: 40)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Günlük Kozmik Kutu',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bugünkü şansını keşfet!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'ÜCRETSİZ',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, curve: Curves.easeOut)
              .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut)
              .scale(begin: const Offset(0.95, 0.95), duration: 400.ms),

          const SizedBox(height: 24),

          // ===== FALLAR BÖLÜMÜ =====
          _buildSectionTitle('Fallar', isDark),
          const SizedBox(height: 12),

          _buildFeatureCard(
            context: context,
            icon: Icons.calendar_month,
            title: 'Haftalık & Aylık Fal',
            subtitle: 'Daha uzun vadeli tahminler',
            gradient: AppColors.blueGradient,
            delay: 0,
            screen: const WeeklyMonthlyScreen(),
          ),
          const SizedBox(height: 12),

          _buildFeatureCard(
            context: context,
            emoji: '🃏',
            title: 'Tarot Falı',
            subtitle: 'Günlük kart çek, geleceğini keşfet',
            gradient: const LinearGradient(
              colors: [Color(0xFF6B46C1), Color(0xFF9333EA)],
            ),
            delay: 100,
            screen: const TarotScreen(),
          ),
          const SizedBox(height: 12),

          _buildFeatureCard(
            context: context,
            emoji: '☕',
            title: 'Kahve Falı',
            subtitle: 'Fincanını çek, AI analiz etsin!',
            gradient: const LinearGradient(
              colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
            ),
            delay: 200,
            screen: const CoffeeFortuneScreen(),
          ),
          const SizedBox(height: 12),

          _buildFeatureCard(
            context: context,
            emoji: '🌙',
            title: 'Rüya Yorumu',
            subtitle: 'Rüyanı anlat, Zodi yorumlasın',
            gradient: AppColors.purpleGradient,
            delay: 300,
            screen: const DreamScreen(),
          ),

          const SizedBox(height: 24),

          // ===== ARAÇLAR BÖLÜMÜ =====
          _buildSectionTitle('Araçlar', isDark),
          const SizedBox(height: 12),

          _buildFeatureCard(
            context: context,
            icon: Icons.auto_awesome,
            title: 'Yükselen Burç',
            subtitle: 'Gerçek kişiliğini keşfet',
            gradient: AppColors.pinkGradient,
            delay: 0,
            screen: const RisingSignScreen(),
          ),
          const SizedBox(height: 12),

          _buildFeatureCard(
            context: context,
            emoji: '🔮',
            title: 'Zodi AI Chatbot',
            subtitle: 'Kozmik danışmanına sor!',
            gradient: const LinearGradient(
              colors: [Color(0xFF0F0C29), Color(0xFF302B63)],
            ),
            delay: 100,
            screen: const ChatbotScreen(),
          ),
          const SizedBox(height: 12),

          _buildFeatureCard(
            context: context,
            emoji: '🪐',
            title: 'Retro Takip',
            subtitle: 'Gezegen retrolarını takip et',
            gradient: const LinearGradient(
              colors: [Color(0xFF4B0082), Color(0xFF9400D3)],
            ),
            delay: 200,
            screen: const RetroScreen(),
          ),
          const SizedBox(height: 12),

          _buildFeatureCard(
            context: context,
            emoji: '✨',
            title: 'Astrolojik Profilim',
            subtitle: 'Paylaşılabilir profil kartı oluştur',
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
            ),
            delay: 300,
            screen: const ProfileCardScreen(),
          ),
          const SizedBox(height: 12),

          _buildFeatureCard(
            context: context,
            emoji: '📅',
            title: 'Kozmik Takvim',
            subtitle: 'Astroloji & güzellik takvimi',
            gradient: const LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF7C4DFF)],
            ),
            delay: 400,
            screen: const CosmicCalendarScreen(),
            badge: 'YENİ',
          ),

          const SizedBox(height: 32),

          // ===== YAKINDA BÖLÜMÜ =====
          _buildSectionTitle('Yakında', isDark),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentPurple.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _ComingSoonItem(
                  icon: '🧘',
                  title: 'Günlük Afirmasyon',
                  description: 'Burca özel olumlamalar',
                  isDark: isDark,
                ),
                Divider(height: 24, color: AppColors.primaryPink.withOpacity(0.15)),
                _ComingSoonItem(
                  icon: '🎵',
                  title: 'Meditasyon',
                  description: 'Burca özel rahatlatıcı sesler',
                  isDark: isDark,
                ),
              ],
            ),
          )
              .animate(delay: 300.ms)
              .fadeIn(duration: 400.ms, curve: Curves.easeOut)
              .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut),
        ],
      ),
    );
  }

  // === Bölüm başlığı ===
  Widget _buildSectionTitle(String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            gradient: AppColors.cosmicGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimary : AppColors.textDark,
          ),
        ),
      ],
    );
  }

  // === Mini metrik göstergesi ===
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

  // === Hızlı erişim butonu ===
  Widget _buildQuickAction({
    required BuildContext context,
    required String emoji,
    required String label,
    required Color color,
    required Widget screen,
    required int delay,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.9, 0.9), duration: 300.ms);
  }

  // === Feature card ===
  Widget _buildFeatureCard({
    required BuildContext context,
    IconData? icon,
    String? emoji,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required int delay,
    required Widget screen,
    String? badge,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
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
            MaterialPageRoute(builder: (_) => screen),
          ),
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.white.withOpacity(0.15),
          highlightColor: Colors.white.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: icon != null
                      ? Icon(icon, color: Colors.white, size: 28)
                      : Text(emoji!, style: const TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                badge,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.gold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut)
        .scale(begin: const Offset(0.95, 0.95), duration: 400.ms);
  }
}

class _ComingSoonItem extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final bool isDark;

  const _ComingSoonItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 32)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimary : AppColors.textDark,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Yakında',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.warning,
            ),
          ),
        ),
      ],
    );
  }
}
