import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../services/notification_service.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';
import 'premium_screen.dart';
import 'onboarding_screen.dart';
import 'theme_customization_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    // Load from local storage
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

  Future<void> _toggleNotifications(bool value, AuthProvider authProvider) async {
    if (value) {
      // Request permissions first
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

      // Schedule notification
      await _notificationService.scheduleDaily(
        time: _notificationTime,
        zodiacSign: authProvider.selectedZodiac?.displayName ?? 'Koç',
      );

      // Generate preview
      await _generatePreview(authProvider);
    } else {
      // Cancel notifications
      await _notificationService.cancelAll();
      setState(() {
        _notificationPreview = null;
      });
    }

    setState(() {
      _notificationsEnabled = value;
    });

    // Save to storage and Firebase
    await _storageService.setNotificationsEnabled(value);
    await _firebaseService.updateNotificationSettings(
      enabled: value,
      time: '${_notificationTime.hour}:${_notificationTime.minute}',
    );
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

      // Reschedule if notifications are enabled
      if (_notificationsEnabled) {
        await _notificationService.cancelAll();
        await _notificationService.scheduleDaily(
          time: _notificationTime,
          zodiacSign: authProvider.selectedZodiac?.displayName ?? 'Koç',
        );
        
        // Regenerate preview
        await _generatePreview(authProvider);
      }

      // Save to storage and Firebase
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
            AppStrings.settingsTitle,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.textPrimary : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 24),
          
          // User Info
          Container(
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
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accentPurple, AppColors.accentBlue],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      authProvider.selectedZodiac?.symbol ?? '⭐',
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authProvider.userName ?? '',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimary : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authProvider.userEmail ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                      if (authProvider.isPremium) ...[
                        const SizedBox(height: 8),
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
                              Icon(Icons.star, color: AppColors.gold, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Premium',
                                style: TextStyle(
                                  fontSize: 12,
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
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Notification Settings Section
          Text(
            'Bildirimler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimary : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          
          // Notification Toggle
          _SettingItem(
            icon: Icons.notifications_outlined,
            title: 'Günlük Bildirimler',
            subtitle: _notificationsEnabled 
                ? 'Günlük falın için bildirim al' 
                : 'Bildirimler kapalı',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) => _toggleNotifications(value, authProvider),
              activeColor: AppColors.accentPurple,
            ),
          ),
          
          // Time Picker (only show if notifications enabled)
          if (_notificationsEnabled) ...[
            const SizedBox(height: 12),
            _SettingItem(
              icon: Icons.access_time,
              title: 'Bildirim Saati',
              subtitle: '${_notificationTime.hour.toString().padLeft(2, '0')}:${_notificationTime.minute.toString().padLeft(2, '0')}',
              onTap: () => _selectNotificationTime(authProvider),
            ),
            
            // Notification Preview
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (isDark ? AppColors.textPrimary : AppColors.textDark).withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.preview_outlined,
                        color: AppColors.accentPurple,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Bildirim Önizlemesi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimary : AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black : Colors.white).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.accentPurple, AppColors.accentBlue],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text('🌟', style: TextStyle(fontSize: 16)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Zodi',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '🌟 Günlük Falın Hazır!',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.textPrimary : AppColors.textDark,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_isLoadingNotifications)
                          const Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.accentPurple,
                              ),
                            ),
                          )
                        else if (_notificationPreview != null)
                          Text(
                            _notificationPreview!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textMuted : AppColors.textDark.withOpacity(0.7),
                            ),
                          )
                        else
                          Text(
                            '${authProvider.selectedZodiac?.displayName ?? 'Koç'} burcu için bugünün falı seni bekliyor. Zodi ne diyor bakalım?',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textMuted : AppColors.textDark.withOpacity(0.7),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Her gün ${_notificationTime.hour.toString().padLeft(2, '0')}:${_notificationTime.minute.toString().padLeft(2, '0')}\'da bu şekilde bildirim alacaksın',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Other Settings Section
          Text(
            'Genel Ayarlar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimary : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          
          // Settings Items
          _SettingItem(
            icon: Icons.palette_outlined,
            title: AppStrings.settingsTheme,
            subtitle: themeProvider.isDarkMode ? 'Karanlık' : 'Aydınlık',
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (_) => themeProvider.toggleTheme(),
              activeColor: AppColors.accentPurple,
            ),
          ),
          const SizedBox(height: 12),
          
          _SettingItem(
            icon: Icons.color_lens_outlined,
            title: 'Tema Özelleştirme',
            subtitle: 'Burç teması ve animasyonlar',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ThemeCustomizationScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          
          _SettingItem(
            icon: Icons.auto_awesome,
            title: AppStrings.settingsChangeSign,
            subtitle: authProvider.selectedZodiac?.displayName ?? '',
            onTap: () async {
              await authProvider.clearZodiac();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          
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
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (isDark ? AppColors.textPrimary : AppColors.textDark).withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accentPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.accentPurple, size: 20),
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
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimary : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
