import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../models/user_profile.dart';
import '../services/user_history_service.dart';
import '../services/firebase_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/animated_card.dart';

class ProfileSetupScreen extends StatefulWidget {
  final VoidCallback onComplete;
  
  const ProfileSetupScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  final List<String> _selectedInterests = [];
  
  final UserHistoryService _historyService = UserHistoryService();

  final List<String> _availableInterests = [
    'Aşk ve İlişkiler',
    'Kariyer',
    'Para ve Finans',
    'Sağlık',
    'Aile',
    'Arkadaşlık',
    'Rüya Yorumu',
    'Uyumluluk',
    'Kişisel Gelişim',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _birthPlaceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accentPurple,
              onPrimary: Colors.white,
              surface: AppColors.cardDark,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accentPurple,
              onPrimary: Colors.white,
              surface: AppColors.cardDark,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _birthTime = picked);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _birthDate == null || _birthTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm zorunlu alanları doldurun')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final birthTimeStr = '${_birthTime!.hour.toString().padLeft(2, '0')}:${_birthTime!.minute.toString().padLeft(2, '0')}';
    
    // UserProfile oluştur ve local storage'a kaydet
    final profile = UserProfile(
      userId: FirebaseService().currentUser?.uid ?? '',
      name: _nameController.text,
      email: _emailController.text,
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
      birthDate: _birthDate!,
      birthTime: birthTimeStr,
      birthPlace: _birthPlaceController.text,
      zodiacSign: authProvider.selectedZodiac?.name ?? '',
      interests: _selectedInterests,
    );

    await _historyService.saveUserProfile(profile);
    
    // AuthProvider üzerinden Firebase'e de kaydet
    await authProvider.updateProfile(
      name: _nameController.text,
      birthDate: _birthDate!,
      birthTime: birthTimeStr,
      birthPlace: _birthPlaceController.text,
    );
    
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColors.bgDark, AppColors.cardDark]
                : [AppColors.bgLight, AppColors.surfaceLight],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Astro Dozi Seni Tanısın',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.textPrimary : AppColors.textDark,
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Sana özel yorumlar yapabilmem için biraz bilgiye ihtiyacım var',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  
                  const SizedBox(height: 32),
                  
                  // Basic Info
                  AnimatedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Temel Bilgiler',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimary : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDecoration('İsim', Icons.person, isDark),
                          validator: (v) => v?.isEmpty ?? true ? 'İsim gerekli' : null,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _emailController,
                          decoration: _inputDecoration('E-posta', Icons.email, isDark),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v?.isEmpty ?? true ? 'E-posta gerekli' : null,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Birth Info
                  AnimatedCard(
                    delay: 100.ms,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Doğum Bilgileri',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimary : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        InkWell(
                          onTap: _selectDate,
                          child: _buildInfoTile(
                            Icons.calendar_today,
                            'Doğum Tarihi',
                            _birthDate == null
                                ? 'Seç'
                                : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                            isDark,
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        InkWell(
                          onTap: _selectTime,
                          child: _buildInfoTile(
                            Icons.access_time,
                            'Doğum Saati',
                            _birthTime == null
                                ? 'Seç'
                                : '${_birthTime!.hour.toString().padLeft(2, '0')}:${_birthTime!.minute.toString().padLeft(2, '0')}',
                            isDark,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _birthPlaceController,
                          decoration: _inputDecoration('Doğum Yeri', Icons.location_on, isDark),
                          validator: (v) => v?.isEmpty ?? true ? 'Doğum yeri gerekli' : null,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Interests
                  AnimatedCard(
                    delay: 200.ms,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'İlgi Alanların',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimary : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hangi konularda yorum almak istersin?',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _availableInterests.map((interest) {
                            final isSelected = _selectedInterests.contains(interest);
                            return FilterChip(
                              label: Text(interest),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedInterests.add(interest);
                                  } else {
                                    _selectedInterests.remove(interest);
                                  }
                                });
                              },
                              selectedColor: AppColors.accentPurple.withOpacity(0.3),
                              checkmarkColor: AppColors.accentPurple,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? AppColors.accentPurple
                                    : (isDark ? AppColors.textSecondary : AppColors.textMuted),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Save Button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: AppColors.cosmicGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _saveProfile,
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Devam Et',
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
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.accentPurple),
      filled: true,
      fillColor: (isDark ? AppColors.textPrimary : AppColors.textDark).withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: (isDark ? AppColors.textPrimary : AppColors.textDark).withOpacity(0.1),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: (isDark ? AppColors.textPrimary : AppColors.textDark).withOpacity(0.1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accentPurple, width: 2),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.textPrimary : AppColors.textDark).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? AppColors.textPrimary : AppColors.textDark).withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentPurple, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textPrimary : AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
