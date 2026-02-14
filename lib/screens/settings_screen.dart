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

  // Personal info fields
  String? _relationshipStatus;
  String? _partnerName;
  String? _currentCity;
  List<String> _interests = [];
  bool _isLoadingProfile = true;

  final TextEditingController _partnerNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  static const List<String> _turkishCities = [
    'Adana', 'Adıyaman', 'Afyonkarahisar', 'Ağrı', 'Aksaray', 'Amasya',
    'Ankara', 'Antalya', 'Ardahan', 'Artvin', 'Aydın', 'Balıkesir',
    'Bartın', 'Batman', 'Bayburt', 'Bilecik', 'Bingöl', 'Bitlis',
    'Bolu', 'Burdur', 'Bursa', 'Çanakkale', 'Çankırı', 'Çorum',
    'Denizli', 'Diyarbakır', 'Düzce', 'Edirne', 'Elazığ', 'Erzincan',
    'Erzurum', 'Eskişehir', 'Gaziantep', 'Giresun', 'Gümüşhane',
    'Hakkari', 'Hatay', 'Iğdır', 'Isparta', 'İstanbul', 'İzmir',
    'Kahramanmaraş', 'Karabük', 'Karaman', 'Kars', 'Kastamonu',
    'Kayseri', 'Kırıkkale', 'Kırklareli', 'Kırşehir', 'Kilis',
    'Kocaeli', 'Konya', 'Kütahya', 'Malatya', 'Manisa', 'Mardin',
    'Mersin', 'Muğla', 'Muş', 'Nevşehir', 'Niğde', 'Ordu', 'Osmaniye',
    'Rize', 'Sakarya', 'Samsun', 'Şanlıurfa', 'Siirt', 'Sinop',
    'Sivas', 'Şırnak', 'Tekirdağ', 'Tokat', 'Trabzon', 'Tunceli',
    'Uşak', 'Van', 'Yalova', 'Yozgat', 'Zonguldak',
  ];

  static const List<String> _interestOptions = [
    'Kariyer', 'Aşk', 'Sağlık', 'Para', 'Eğitim', 'Seyahat',
  ];

  static const Map<String, String> _relationshipLabels = {
    'single': 'Bekar',
    'relationship': 'Sevgilisi var',
    'engaged': 'Nişanlı',
    'married': 'Evli',
    'separated': 'Ayrılmış',
  };

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
    _loadPersonalInfo();
  }

  @override
  void dispose() {
    _partnerNameController.dispose();
    _cityController.dispose();
    super.dispose();
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

  Future<void> _loadPersonalInfo() async {
    try {
      final profile = await _firebaseService.getUserProfile();
      if (profile != null && mounted) {
        setState(() {
          _relationshipStatus = profile.relationshipStatus;
          _partnerName = profile.partnerName;
          _currentCity = profile.currentCity;
          _interests = List<String>.from(profile.interests);
          _partnerNameController.text = profile.partnerName ?? '';
          _cityController.text = profile.currentCity ?? '';
          _isLoadingProfile = false;
        });
      } else {
        setState(() => _isLoadingProfile = false);
      }
    } catch (e) {
      setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _savePersonalInfo() async {
    try {
      await _firebaseService.updateRelationshipInfo(
        relationshipStatus: _relationshipStatus,
        partnerName: _partnerName,
        currentCity: _currentCity,
      );
      await _firebaseService.updateInterests(_interests);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Bilgilerin kaydedildi'),
            backgroundColor: AppColors.positive,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kaydetme sırasında bir hata oluştu'),
            backgroundColor: AppColors.negative,
          ),
        );
      }
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
            content: Text('Bildirim ayarlanırken sorun oluştu: ${e.toString().length > 80 ? e.toString().substring(0, 80) : e}'),
            backgroundColor: AppColors.negative,
            action: SnackBarAction(
              label: 'Tekrar Dene',
              textColor: Colors.white,
              onPressed: () => _toggleNotifications(true, authProvider),
            ),
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

          // Profile Card - Enhanced
          _buildProfileCard(isDark, authProvider),
          const SizedBox(height: 28),

          // Personal Info Hub
          _buildSectionHeader('Kişisel Bilgiler', Icons.person_outline, isDark),
          const SizedBox(height: 12),
          _buildPersonalInfoSection(isDark),
          const SizedBox(height: 28),

          // Interests
          _buildSectionHeader('İlgi Alanları', Icons.interests, isDark),
          const SizedBox(height: 12),
          _buildInterestsSection(isDark),
          const SizedBox(height: 28),

          // Notification Settings
          _buildSectionHeader('Bildirimler', Icons.notifications_outlined, isDark),
          const SizedBox(height: 12),
          _buildNotificationSection(isDark, authProvider),
          const SizedBox(height: 28),

          // General Settings
          _buildSectionHeader('Genel Ayarlar', Icons.settings_outlined, isDark),
          const SizedBox(height: 12),

          // Theme Toggle
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

  Widget _buildPersonalInfoSection(bool isDark) {
    if (_isLoadingProfile) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: AppColors.accentPurple),
        ),
      );
    }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Relationship Status
          _buildDropdownField(
            label: 'İlişki Durumu',
            value: _relationshipStatus,
            items: _relationshipLabels.entries
                .map((e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() => _relationshipStatus = value);
            },
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          // Partner Name
          _buildTextField(
            label: 'Sevdiğin Kişinin Adı',
            hint: 'Opsiyonel',
            controller: _partnerNameController,
            onChanged: (value) => _partnerName = value.isEmpty ? null : value,
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          // City
          _buildCityAutocomplete(isDark),
          const SizedBox(height: 20),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _savePersonalInfo,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Kaydet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white.withOpacity(0.7) : AppColors.textDark.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : const Color(0xFFF5F1FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.accentPurple.withOpacity(0.2),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                'Seçiniz',
                style: TextStyle(
                  color: isDark ? AppColors.textMuted : AppColors.textDark.withOpacity(0.4),
                ),
              ),
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: AppColors.accentPurple),
              dropdownColor: isDark ? AppColors.cardDark : Colors.white,
              items: items,
              onChanged: onChanged,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white.withOpacity(0.7) : AppColors.textDark.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? AppColors.textMuted : AppColors.textDark.withOpacity(0.4),
            ),
            filled: true,
            fillColor: isDark ? AppColors.surfaceDark : const Color(0xFFF5F1FF),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.accentPurple.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.accentPurple.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accentPurple),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCityAutocomplete(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yaşadığın Şehir',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white.withOpacity(0.7) : AppColors.textDark.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 6),
        Autocomplete<String>(
          initialValue: TextEditingValue(text: _currentCity ?? ''),
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return _turkishCities.where((city) =>
                city.toLowerCase().contains(textEditingValue.text.toLowerCase()));
          },
          onSelected: (String selection) {
            setState(() => _currentCity = selection);
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: (value) => _currentCity = value.isEmpty ? null : value,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: 'Şehir seçiniz',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.textMuted : AppColors.textDark.withOpacity(0.4),
                ),
                filled: true,
                fillColor: isDark ? AppColors.surfaceDark : const Color(0xFFF5F1FF),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.accentPurple.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.accentPurple.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.accentPurple),
                ),
                suffixIcon: Icon(Icons.location_on_outlined, color: AppColors.accentPurple.withOpacity(0.5)),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                color: isDark ? AppColors.cardDark : Colors.white,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200, maxWidth: 300),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        title: Text(
                          option,
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.textDark,
                          ),
                        ),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInterestsSection(bool isDark) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hangi konular seni ilgilendiriyor?',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white.withOpacity(0.7) : AppColors.textDark.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _interestOptions.map((interest) {
              final isSelected = _interests.contains(interest);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _interests.remove(interest);
                    } else {
                      _interests.add(interest);
                    }
                  });
                  _savePersonalInfo();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accentPurple.withOpacity(0.2)
                        : (isDark ? AppColors.surfaceDark : const Color(0xFFF5F1FF)),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accentPurple
                          : AppColors.accentPurple.withOpacity(0.2),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    interest,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? AppColors.accentPurple
                          : (isDark ? Colors.white.withOpacity(0.7) : AppColors.textDark.withOpacity(0.6)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection(bool isDark, AuthProvider authProvider) {
    return Column(
      children: [
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
        const SizedBox(height: 12),
        _SettingItem(
          icon: Icons.access_time,
          title: 'Bildirim Saati',
          subtitle: '${_notificationTime.hour.toString().padLeft(2, '0')}:${_notificationTime.minute.toString().padLeft(2, '0')}',
          onTap: () => _selectNotificationTime(authProvider),
        ),
        if (_notificationsEnabled) ...[
          const SizedBox(height: 12),
          _buildNotificationPreview(isDark, authProvider),
        ],
      ],
    );
  }

  Widget _buildNotificationPreview(bool isDark, AuthProvider authProvider) {
    return Container(
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
              Icon(Icons.preview_outlined, color: AppColors.accentPurple, size: 20),
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
                          const Text('Zodi',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
