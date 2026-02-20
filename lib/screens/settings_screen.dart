import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/auth_provider.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../services/notification_service.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';
import '../models/user_profile.dart';
import 'premium_screen.dart';
import 'onboarding_screen.dart';
import 'personalization_screen.dart';
import 'edit_birth_info_screen.dart';
import 'birth_chart_screen.dart';
import 'rising_sign_screen.dart';
import 'cosmic_calendar_screen.dart';
import 'retro_screen.dart';
import 'cosmic_box_screen.dart';
import 'profile_card_screen.dart';
import 'feedback_screen.dart';
import 'support_screen.dart';
import 'account_management_screen.dart';
import 'about_screen.dart';
import 'referral_screen.dart';
import '../config/membership_config.dart';
import '../theme/cosmic_page_route.dart';
import '../services/revenue_cat_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  final FirebaseService _firebaseService = FirebaseService();
  final StorageService _storageService = StorageService();

  bool _notificationsEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isLoadingNotifications = false;
  String? _notificationPreview;
  
  UserProfile? _profile;
  bool _isLoadingProfile = true;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
    _loadProfile();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = '${info.version} (${info.buildNumber})';
        });
      }
    } catch (_) {
      setState(() {
        _appVersion = '1.0.0';
      });
    }
  }

  Future<void> _loadNotificationSettings() async {
    final enabled = await _storageService.getNotificationsEnabled();
    final timeString = await _storageService.getNotificationTime();

    setState(() {
      _notificationsEnabled = enabled;
      if (timeString != null) {
        final parts = timeString.split(':');
        if (parts.length == 2) {
          _notificationTime = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 9,
            minute: int.tryParse(parts[1]) ?? 0,
          );
        }
      }
    });
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _firebaseService.getUserProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _toggleNotifications(bool value, AuthProvider authProvider) async {
    try {
      if (value) {
        final granted = await _notificationService.requestPermissions();
        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bildirim izni verilmedi. Lütfen ayarlardan izin verin.'),
                backgroundColor: AppColors.negative,
              ),
            );
          }
          return;
        }

        await _notificationService.scheduleDaily(
          time: _notificationTime,
          zodiacSign: authProvider.selectedZodiac?.displayName ?? 'Koç',
        );

        await _generatePreview(authProvider);
      } else {
        await _notificationService.cancelAll();
        setState(() {
          _notificationPreview = null;
        });
      }

      setState(() {
        _notificationsEnabled = value;
      });

      final timeValue = '${_notificationTime.hour}:${_notificationTime.minute}';

      await _storageService.setNotificationsEnabled(value);
      await _storageService.setNotificationTime(timeValue);
      await _firebaseService.updateNotificationSettings(
        enabled: value,
        time: timeValue,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _notificationsEnabled = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bildirim ayarlanırken sorun oluştu'),
            backgroundColor: AppColors.negative,
          ),
        );
      }
    }
  }

  Future<void> _selectNotificationTime(AuthProvider authProvider) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.accentPurple,
              onPrimary: Colors.white,
              surface: isDark ? AppColors.cardDark : AppColors.cardLight,
              onSurface: isDark ? AppColors.textPrimary : AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _notificationTime) {
      setState(() {
        _notificationTime = picked;
      });

      if (_notificationsEnabled) {
        await _notificationService.cancelAll();
        await _notificationService.scheduleDaily(
          time: _notificationTime,
          zodiacSign: authProvider.selectedZodiac?.displayName ?? 'Koç',
        );
        await _generatePreview(authProvider);
      }

      await _storageService.setNotificationTime(
        '${_notificationTime.hour}:${_notificationTime.minute}',
      );
      await _firebaseService.updateNotificationSettings(
        time: '${_notificationTime.hour}:${_notificationTime.minute}',
      );
    }
  }

  Future<void> _generatePreview(AuthProvider authProvider) async {
    setState(() {
      _isLoadingNotifications = true;
    });

    try {
      final preview = await _notificationService.generateNotificationPreview(
        authProvider.selectedZodiac?.displayName ?? 'Koç',
      );

      setState(() {
        _notificationPreview = preview;
        _isLoadingNotifications = false;
      });
    } catch (e) {
      setState(() {
        _notificationPreview = 'Önizleme yüklenemedi';
        _isLoadingNotifications = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profil',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.textPrimary : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 24),

          // Profile Card
          _buildProfileCard(isDark, authProvider),
          const SizedBox(height: 16),

          // Birth Info Card
          _buildBirthInfoCard(isDark),
          const SizedBox(height: 20),

          // Personalization Card
          _buildPersonalizationCard(isDark),
          const SizedBox(height: 28),

          // Astroloji Araçları
          _buildSectionHeader('Astroloji Araçları', Icons.psychology_rounded, isDark),
          const SizedBox(height: 12),
          _buildAstroToolsSection(isDark),
          const SizedBox(height: 28),

          // Notification Settings
          _buildSectionHeader('Bildirimler', Icons.notifications_outlined, isDark),
          const SizedBox(height: 12),
          _buildNotificationSection(isDark, authProvider),
          const SizedBox(height: 28),

          // General Settings
          _buildSectionHeader('Genel Ayarlar', Icons.settings_outlined, isDark),
          const SizedBox(height: 12),

          // Premium / Üyelik Planları
          _SettingItem(
            icon: Icons.star,
            title: authProvider.isPremium
                ? '${authProvider.currentTierConfig.emoji} ${authProvider.currentTierConfig.displayName} Üyelik'
                : AppStrings.settingsPremium,
            subtitle: authProvider.isPremium
                ? 'Üyelik planını yönet'
                : 'Üyelik planlarını ve Yıldız Tozu paketlerini gör',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: authProvider.isPremium
                    ? LinearGradient(colors: authProvider.currentTierConfig.gradient)
                    : const LinearGradient(colors: [AppColors.accentPurple, AppColors.accentBlue]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                authProvider.isPremium ? 'Yönet' : 'Yükselt',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                CosmicBottomSheetRoute(page: const PremiumScreen()),
              );
            },
          ),
          const SizedBox(height: 12),

          // Abonelik Yönetimi (Customer Center) — sadece premium kullanıcılar
          if (authProvider.isPremium)
            _SettingItem(
              icon: Icons.credit_card,
              title: 'Abonelik Yönetimi',
              subtitle: 'Aboneliğini görüntüle ve yönet',
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
              ),
              onTap: () async {
                await RevenueCatService().presentCustomerCenter();
              },
            ),
          if (authProvider.isPremium) const SizedBox(height: 12),

          // Referral
          _SettingItem(
            icon: Icons.card_giftcard,
            title: 'Arkadaş Davet Et',
            subtitle: 'Davet et, ikiniz de 25 Yıldız Tozu kazanın!',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'YENİ',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReferralScreen()),
              );
            },
          ),
          const SizedBox(height: 12),

          // Share App
          _SettingItem(
            icon: Icons.share,
            title: 'Uygulamayı Paylaş',
            subtitle: 'Arkadaşlarınla paylaş',
            onTap: () {
              Share.share(
                'Astro Dozi ile günlük burç yorumunu, tarot falını ve daha fazlasını keşfet! 🔮✨\nhttps://play.google.com/store/apps/details?id=com.bardino.zodi',
              );
            },
          ),
          const SizedBox(height: 12),

          // Rate App
          _SettingItem(
            icon: Icons.star_rate,
            title: 'Uygulamayı Puanla',
            subtitle: 'Play Store\'da değerlendir',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Play Store\'a yönlendiriliyorsun...'),
                  backgroundColor: AppColors.accentPurple,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Feedback
          _SettingItem(
            icon: Icons.feedback_outlined,
            title: 'Geri Bildirim Gönder',
            subtitle: 'Düşüncelerini bizimle paylaş',
            onTap: () {
              Navigator.push(
                context,
                CosmicPageRoute(page: const FeedbackScreen()),
              );
            },
          ),
          const SizedBox(height: 12),

          // About
          _SettingItem(
            icon: Icons.info_outline,
            title: 'Hakkında',
            subtitle: 'Astro Dozi hakkında bilgi',
            onTap: () {
              Navigator.push(
                context,
                CosmicPageRoute(page: const AboutScreen()),
              );
            },
          ),
          const SizedBox(height: 28),

          // Account & Support Section
          _buildSectionHeader('Hesap & Destek', Icons.person_outline, isDark),
          const SizedBox(height: 12),

          // Account Management
          _SettingItem(
            icon: Icons.manage_accounts,
            title: 'Hesap Yönetimi',
            subtitle: 'Profil, premium ve hesap ayarları',
            onTap: () {
              Navigator.push(
                context,
                CosmicPageRoute(page: const AccountManagementScreen()),
              );
            },
          ),
          const SizedBox(height: 12),

          // Support & FAQ
          _SettingItem(
            icon: Icons.help_outline,
            title: 'Destek & SSS',
            subtitle: 'Yardım al ve sıkça sorulan sorular',
            onTap: () {
              Navigator.push(
                context,
                CosmicPageRoute(page: const SupportScreen()),
              );
            },
          ),
          const SizedBox(height: 12),

          // Logout
          _SettingItem(
            icon: Icons.logout,
            title: AppStrings.settingsLogout,
            subtitle: 'Hesaptan çıkış yap',
            onTap: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  CosmicFadeRoute(page: const OnboardingScreen()),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(bool isDark, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFF3EDFF), const Color(0xFFE8E0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.50),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with gradient border
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accentPurple, AppColors.accentBlue, AppColors.accentPink],
              ),
              shape: BoxShape.circle,
            ),
            child: Container(
              width: 74,
              height: 74,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  authProvider.selectedZodiac?.symbol ?? '⭐',
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authProvider.userName ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  authProvider.userEmail ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textDark.withOpacity(0.5),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    // Zodiac pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentPurple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        authProvider.selectedZodiac?.displayName ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7C6BC4),
                        ),
                      ),
                    ),
                    if (authProvider.isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: authProvider.currentTierConfig.gradient,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              authProvider.currentTierConfig.emoji,
                              style: const TextStyle(fontSize: 10),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              authProvider.currentTierConfig.displayName,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBirthInfoCard(bool isDark) {
    final authProvider = context.read<AuthProvider>();
    final profile = authProvider.userProfile;
    final hasBirthTime = profile != null && profile.birthTime.isNotEmpty;
    final hasBirthPlace = profile != null && profile.birthPlace.isNotEmpty;
    final hasAnyInfo = profile != null || hasBirthTime || hasBirthPlace;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          CosmicPageRoute(page: const EditBirthInfoScreen()),
        );
        _loadProfile();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: hasAnyInfo
                ? isDark
                    ? [const Color(0xFF1E2448), const Color(0xFF2C2854)]
                    : [const Color(0xFFF0EAFF), const Color(0xFFE8E0FF)]
                : isDark
                    ? [const Color(0xFF2A1F3D), const Color(0xFF1E1533)]
                    : [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasAnyInfo
                ? AppColors.accentPurple.withOpacity(0.3)
                : Colors.orange.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: hasAnyInfo
                    ? AppColors.purpleGradient
                    : const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFFF5722)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                hasAnyInfo ? Icons.calendar_month_rounded : Icons.edit_calendar_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Doğum Bilgileri',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (hasAnyInfo && profile != null) ...[
                    _buildBirthInfoRow(
                      Icons.cake_rounded,
                      _formatDate(profile.birthDate),
                      isDark,
                    ),
                    if (hasBirthTime)
                      _buildBirthInfoRow(
                        Icons.access_time_rounded,
                        profile.birthTime,
                        isDark,
                      ),
                    if (hasBirthPlace)
                      _buildBirthInfoRow(
                        Icons.location_on_rounded,
                        profile.birthPlace,
                        isDark,
                      ),
                  ] else
                    Text(
                      'Eğlenceli özellikler için doğum bilgilerini gir',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white54 : AppColors.textMuted,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildBirthInfoRow(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.accentPurple),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : AppColors.textMuted,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildPersonalizationCard(bool isDark) {
    final completionPercentage = _profile?.completionPercentage ?? 0;
    final isComplete = completionPercentage >= 80;
    
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          CosmicPageRoute(page: const PersonalizationScreen()),
        );
        // Geri dönünce profili yeniden yükle
        _loadProfile();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isComplete
                ? [AppColors.positive.withOpacity(0.15), AppColors.positive.withOpacity(0.05)]
                : [AppColors.accentPurple.withOpacity(0.15), AppColors.accentBlue.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isComplete
                ? AppColors.positive.withOpacity(0.3)
                : AppColors.accentPurple.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: isComplete
                    ? LinearGradient(colors: [AppColors.positive, AppColors.positive.withOpacity(0.7)])
                    : AppColors.purpleGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isComplete ? Icons.check_circle : Icons.auto_awesome,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Astro Dozi Seni Tanısın',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isComplete
                        ? 'Profil tamamlandı! ✨ Düzenlemek için dokun.'
                        : 'Daha kişisel yorumlar için bilgilerini güncelle',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: completionPercentage / 100,
                            backgroundColor: isDark ? Colors.white24 : Colors.black12,
                            valueColor: AlwaysStoppedAnimation(
                              isComplete ? AppColors.positive : AppColors.accentPurple,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '%${completionPercentage.toInt()}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isComplete ? AppColors.positive : AppColors.accentPurple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white54 : AppColors.textMuted,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.accentPurple, size: 22),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimary : AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 3,
          margin: const EdgeInsets.only(left: 30),
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

  Widget _buildAstroToolsSection(bool isDark) {
    final tools = [
      _AstroTool(
        icon: Icons.public_rounded,
        emoji: '🌍',
        title: 'Doğum Haritası',
        subtitle: 'Gezegen konumlarını keşfet',
        onTap: () => Navigator.push(
          context,
          CosmicPageRoute(page: const BirthChartScreen()),
        ),
      ),
      _AstroTool(
        icon: Icons.arrow_upward_rounded,
        emoji: '⬆️',
        title: 'Yükselen Burç',
        subtitle: 'Yükselen burcunu hesapla',
        onTap: () => Navigator.push(
          context,
          CosmicPageRoute(page: const RisingSignScreen()),
        ),
      ),
      _AstroTool(
        icon: Icons.calendar_month_rounded,
        emoji: '📅',
        title: 'Kozmik Takvim',
        subtitle: 'Astrolojik olayları takip et',
        onTap: () => Navigator.push(
          context,
          CosmicPageRoute(page: const CosmicCalendarScreen()),
        ),
      ),
      _AstroTool(
        icon: Icons.replay_rounded,
        emoji: '🔄',
        title: 'Retro Takip',
        subtitle: 'Retrograd gezegenleri izle',
        onTap: () => Navigator.push(
          context,
          CosmicPageRoute(page: const RetroScreen()),
        ),
      ),
      _AstroTool(
        icon: Icons.inventory_2_rounded,
        emoji: '📦',
        title: 'Kozmik Kutu',
        subtitle: 'Sürpriz kozmik içerikler',
        onTap: () => Navigator.push(
          context,
          CosmicPageRoute(page: const CosmicBoxScreen()),
        ),
      ),
      _AstroTool(
        icon: Icons.badge_rounded,
        emoji: '🪪',
        title: 'Astro Profil',
        subtitle: 'Astrolojik profil kartını gör',
        onTap: () => Navigator.push(
          context,
          CosmicPageRoute(page: const ProfileCardScreen()),
        ),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
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
              ? Colors.white.withOpacity(0.06)
              : const Color(0xFF7C3AED).withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.white.withOpacity(0.03)
                : Colors.white.withOpacity(0.70),
            blurRadius: 3,
            offset: const Offset(-1, -1),
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.25)
                : Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < tools.length; i++) ...[
            if (i > 0)
              Divider(
                color: AppColors.accentPurple.withOpacity(0.08),
                height: 1,
              ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: tools[i].onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.accentPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            tools[i].emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tools[i].title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textPrimary : AppColors.textDark,
                              ),
                            ),
                            Text(
                              tools[i].subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: isDark ? Colors.white30 : AppColors.textMuted.withOpacity(0.5),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
  }

  Widget _buildNotificationSection(bool isDark, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              ? Colors.white.withOpacity(0.06)
              : const Color(0xFF7C3AED).withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.white.withOpacity(0.03)
                : Colors.white.withOpacity(0.70),
            blurRadius: 3,
            offset: const Offset(-1, -1),
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.25)
                : Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(3, 3),
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
                  color: AppColors.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.notifications, color: AppColors.accentPurple),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Günlük Bildirimler',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimary : AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Her gün burç yorumunu al',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _notificationsEnabled,
                onChanged: (value) => _toggleNotifications(value, authProvider),
                activeColor: AppColors.accentPurple,
              ),
            ],
          ),
          if (_notificationsEnabled) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectNotificationTime(authProvider),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.textPrimary : AppColors.textDark).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: AppColors.accentPurple, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Bildirim Saati',
                      style: TextStyle(
                        color: isDark ? AppColors.textPrimary : AppColors.textDark,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_notificationTime.hour.toString().padLeft(2, '0')}:${_notificationTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentPurple,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: AppColors.accentPurple, size: 20),
                  ],
                ),
              ),
            ),
            if (_notificationPreview != null || _isLoadingNotifications) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.preview, color: AppColors.accentPurple, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _isLoadingNotifications
                          ? Text(
                              'Önizleme yükleniyor...',
                              style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: isDark ? Colors.white70 : AppColors.textMuted,
                              ),
                            )
                          : Text(
                              _notificationPreview ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.textPrimary : AppColors.textDark,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _AstroTool {
  final IconData icon;
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AstroTool({
    required this.icon,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
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
                  ? Colors.white.withOpacity(0.06)
                  : const Color(0xFF7C3AED).withOpacity(0.08),
            ),
            boxShadow: [
              // Claymorphism — light shadow (üst-sol)
              BoxShadow(
                color: isDark
                    ? Colors.white.withOpacity(0.03)
                    : Colors.white.withOpacity(0.70),
                blurRadius: 3,
                offset: const Offset(-1, -1),
              ),
              // Claymorphism — dark shadow (alt-sağ)
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.25)
                    : Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(3, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.accentPurple),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimary : AppColors.textDark,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
