import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../screens/premium_screen.dart';
import '../services/ad_service.dart';
import '../theme/cosmic_page_route.dart';

/// Limit aşıldığında gösterilen dialog - Reklam veya Premium seçeneği
class LimitReachedDialog extends StatelessWidget {
  final String title;
  final String message;
  final String feature;
  final VoidCallback? onAdWatched;
  final bool showAdOption;

  const LimitReachedDialog({
    super.key,
    required this.title,
    required this.message,
    required this.feature,
    this.onAdWatched,
    this.showAdOption = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Astro Dozi karakter
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.20),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/astro_dozi_hi.webp',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
                      ),
                    ),
                    child: const Icon(Icons.lock_clock, color: Colors.white, size: 40),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: isDark ? Colors.white54 : AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Premium button — gradient
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.cosmicGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.20),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        CosmicBottomSheetRoute(page: const PremiumScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.workspace_premium, size: 20, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Premium\'a Geç',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Ad option — ince, şık
            if (showAdOption) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFFA78BFA).withValues(alpha: 0.25)
                          : const Color(0xFF7C3AED).withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                    color: isDark
                        ? const Color(0xFF1E1B4B).withValues(alpha: 0.3)
                        : const Color(0xFFF8F5FF),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                        final adService = AdService();
                        final success = await adService.showRewardedAd(
                          placement: 'limit_unlock_$feature',
                        );
                        if (success && onAdWatched != null) {
                          onAdWatched!();
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_circle_outline_rounded,
                              size: 20,
                              color: isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Reklam İzle & Devam Et',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Close button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Kapat',
                style: TextStyle(
                  color: isDark ? Colors.white38 : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Günlük yorum limiti dialog
  static void showDailyCommentLimit(BuildContext context, {VoidCallback? onAdWatched}) {
    showDialog(
      context: context,
      builder: (_) => LimitReachedDialog(
        title: 'Günlük Limit Doldu',
        message: 'Bugün için günlük yorum hakkın bitti. Premium üyelikle sınırsız yorum okuyabilir veya reklam izleyerek devam edebilirsin.',
        feature: 'daily_comment',
        onAdWatched: onAdWatched,
      ),
    );
  }

  /// Kozmik takvim limiti dialog
  static void showCalendarLimit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const LimitReachedDialog(
        title: 'Premium Özellik',
        message: 'Tam ay takvimi premium kullanıcılar için özel. İlk 4 gün (bugün + 3 gün) ücretsiz, tüm ay için premium üyelik gerekli.',
        feature: 'calendar',
        showAdOption: false,
      ),
    );
  }

  /// Retro analizi limiti dialog
  static void showRetroLimit(BuildContext context, {VoidCallback? onAdWatched}) {
    showDialog(
      context: context,
      builder: (_) => LimitReachedDialog(
        title: 'Retro Analizi Limiti',
        message: 'Günde 1 kişisel retro analizi ücretsiz. Daha fazlası için premium üyelik veya reklam izle.',
        feature: 'retro_analysis',
        onAdWatched: onAdWatched,
      ),
    );
  }

  /// Yükselen burç detay limiti dialog
  static void showRisingSignLimit(BuildContext context, {VoidCallback? onAdWatched}) {
    showDialog(
      context: context,
      builder: (_) => LimitReachedDialog(
        title: 'Detaylı Yorum Limiti',
        message: 'Günde 2 detaylı yükselen burç yorumu ücretsiz. Sınırsız erişim için premium üyelik veya reklam izle.',
        feature: 'rising_sign_detail',
        onAdWatched: onAdWatched,
      ),
    );
  }

  /// Profil kartı paylaşım limiti dialog
  static void showProfileShareLimit(BuildContext context, {VoidCallback? onAdWatched}) {
    showDialog(
      context: context,
      builder: (_) => LimitReachedDialog(
        title: 'Paylaşım Limiti',
        message: 'Günde 3 profil kartı paylaşımı ücretsiz. Sınırsız paylaşım için premium üyelik veya reklam izle.',
        feature: 'profile_share',
        onAdWatched: onAdWatched,
      ),
    );
  }
}
