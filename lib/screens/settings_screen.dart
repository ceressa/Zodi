import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../services/notification_service.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';
import '../models/user_profile.dart';
import 'premium_screen.dart';
import 'onboarding_screen.dart';
import 'personalization_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
    _loadProfile();
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
    final themeProvider = context.watch<ThemeProvider>();

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
          const SizedBox(height: 20),

          // Personalization Card - Yeni eklenen kart!
          _buildPersonalizationCard(isDark),
          const SizedBox(height: 28),

          // Notification Settings
          _buildSectionHeader('Bildirimler', Icons.notifications_outlined, isDark),
          const SizedBox(height: 12),
          _buildNotificationSection(isDark, authProvider),
          const SizedBox(height: 28),

          // General Settings
          _buildSectionHeader('Genel Ayarlar', Icons.settings_outlined, isDark),
          const SizedBox(height: 12),

          // Premium
          if (!authProvider.isPremium)
            _SettingItem(
              icon: Icons.star,
              title: AppStrings.settingsPremium,
              subtitle: 'Tüm özelliklerin kilidini aç',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accentPurple, AppColors.accentBlue],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Yükselt',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PremiumScreen()),
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
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
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
          colors: isDark
              ? [const Color(0xFF2C2854), const Color(0xFF1E2448)]
              : [const Color(0xFFF3EDFF), const Color(0xFFE8E0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withOpacity(isDark ? 0.15 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with gradient border
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accentPurple, AppColors.accentBlue, AppColors.accentPink],
              ),
              shape: BoxShape.circle,
            ),
            child: Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
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
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  authProvider.userEmail ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white.withOpacity(0.6)
                        : AppColors.textDark.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
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
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.accentPurple : const Color(0xFF7C6BC4),
                        ),
                      ),
                    ),
                    if (authProvider.isPremium) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.accentPurple, AppColors.accentBlue],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: AppColors.gold, size: 12),
                            SizedBox(width: 3),
                            Text(
                              'Premium',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizationCard(bool isDark) {
    final completionPercentage = _profile?.completionPercentage ?? 0;
    final isComplete = completionPercentage >= 80;
    
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PersonalizationScreen()),
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
                    'Zodi Seni Tanısın',
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
    return Row(
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
    );
  }

  Widget _buildNotificationSection(bool isDark, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? AppColors.textPrimary : AppColors.textDark).withOpacity(0.1),
        ),
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
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (isDark ? AppColors.textPrimary : AppColors.textDark).withOpacity(0.1),
            ),
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
