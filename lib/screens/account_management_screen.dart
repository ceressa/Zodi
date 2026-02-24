import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../constants/colors.dart';
import '../theme/cosmic_page_route.dart';
import 'onboarding_screen.dart';
import 'premium_screen.dart';

/// Hesap yönetimi ekranı — profil, premium ve hesap ayarları
class AccountManagementScreen extends StatelessWidget {
  const AccountManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      appBar: AppBar(
        title: const Text(
          'Hesap Yönetimi',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFFF8F5FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hesap Yönetimi',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Profil, üyelik ve hesap ayarlarını buradan yönet.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 32),

            // Profil bilgileri
            _buildSection(
              context,
              isDark: isDark,
              title: 'Profil Bilgileri',
              items: [
                _AccountItem(
                  icon: Icons.person_outline,
                  title: 'Kullanıcı Adı',
                  subtitle: authProvider.userName ?? '-',
                  onTap: null,
                ),
                _AccountItem(
                  icon: Icons.email_outlined,
                  title: 'E-posta',
                  subtitle: authProvider.userEmail ?? '-',
                  onTap: null,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Üyelik
            _buildSection(
              context,
              isDark: isDark,
              title: 'Üyelik',
              items: [
                _AccountItem(
                  icon: Icons.star_outline,
                  title: 'Mevcut Plan',
                  subtitle: authProvider.isPremium
                      ? '${authProvider.currentTierConfig.emoji} ${authProvider.currentTierConfig.displayName}'
                      : 'Standart (Ücretsiz)',
                  onTap: () {
                    Navigator.push(
                      context,
                      CosmicBottomSheetRoute(page: const PremiumScreen()),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Hesap işlemleri
            _buildSection(
              context,
              isDark: isDark,
              title: 'Hesap İşlemleri',
              items: [
                _AccountItem(
                  icon: Icons.delete_forever_outlined,
                  title: 'Hesabı Sil',
                  subtitle: 'Tüm verilerini kalıcı sil',
                  isDestructive: true,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Hesabı Sil'),
                        content: const Text(
                          'Bu işlem geri alınamaz. Tüm verileriniz kalıcı olarak silinecek.\n\nDevam etmek istediğinden emin misin?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('İptal'),
                          ),
                          TextButton(
                            onPressed: () async {
                              // Navigator referansını ÖNCE al — deleteAccount() context'i geçersiz kılabilir
                              final navigator = Navigator.of(context, rootNavigator: true);
                              final messenger = ScaffoldMessenger.of(context);
                              Navigator.pop(dialogContext);
                              try {
                                await authProvider.deleteAccount();
                                navigator.pushAndRemoveUntil(
                                  CosmicFadeRoute(page: const OnboardingScreen()),
                                  (route) => false,
                                );
                              } catch (e) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text('Hesap silinemedi: $e'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'Evet, Hesabımı Sil',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required bool isDark,
    required String title,
    required List<_AccountItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white54 : AppColors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1B4B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              final item = items[i];
              return Column(
                children: [
                  if (i > 0)
                    Divider(
                      height: 1,
                      color: isDark ? Colors.white12 : Colors.grey.shade100,
                    ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: item.onTap,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              color: item.isDestructive
                                  ? Colors.red
                                  : AppColors.accentPurple,
                              size: 22,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: item.isDestructive
                                          ? Colors.red
                                          : (isDark
                                              ? Colors.white
                                              : AppColors.textDark),
                                    ),
                                  ),
                                  Text(
                                    item.subtitle,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white54
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (item.onTap != null)
                              Icon(
                                Icons.chevron_right,
                                color: isDark ? Colors.white30 : Colors.grey.shade400,
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _AccountItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _AccountItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isDestructive = false,
    this.onTap,
  });
}
