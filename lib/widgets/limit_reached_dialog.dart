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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.purpleGradient,
              ),
              child: const Icon(
                Icons.lock_clock,
                color: Colors.white,
                size: 40,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimary : AppColors.textDark,
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
                color: isDark ? AppColors.textSecondary : AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Premium button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    CosmicBottomSheetRoute(page: const PremiumScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.workspace_premium, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Premium\'a Geç',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Ad option
            if (showAdOption) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final adService = AdService();
                    final success = await adService.showRewardedAd(
                      placement: 'limit_unlock_$feature',
                    );
                    if (success && onAdWatched != null) {
                      onAdWatched!();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentPurple,
                    side: const BorderSide(color: AppColors.accentPurple, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.play_circle_outline, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Reklam İzle & Devam Et',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
                  color: isDark ? AppColors.textSecondary : AppColors.textMuted,
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
