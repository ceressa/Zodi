import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_service.dart';
import '../services/activity_log_service.dart';
import '../models/zodiac_sign.dart';
import '../constants/colors.dart';
import '../theme/cosmic_page_route.dart';
import '../app.dart';
import 'welcome_screen.dart';
import 'greeting_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final _nameController = TextEditingController();
  final _nameFocus = FocusNode();
  DateTime? _birthDate;
  ZodiacSign? _calculatedZodiac;
  int _currentStep = 0;
  static const int _totalSteps = 5;
  late ConfettiController _confettiController;
  bool _isLoading = false;
  bool _nameValid = false;

  // Personalizasyon (Step 4)
  String? _selectedGender;
  String? _selectedRelationship;
  String? _selectedLifePhase;

  // Doğum detayları
  TimeOfDay? _birthTime;
  final _birthPlaceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _nameController.addListener(() {
      final valid = _nameController.text.trim().isNotEmpty;
      if (valid != _nameValid) {
        setState(() => _nameValid = valid);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _nameFocus.dispose();
    _confettiController.dispose();
    _birthPlaceController.dispose();
    super.dispose();
  }

  void _nextStep() {
    FocusScope.of(context).unfocus();
    if (_currentStep < _totalSteps - 1) {
      int nextStep = _currentStep + 1;

      // Doğum tarihi adımından (step 2) sonra:
      // Auth zaten yapıldıysa Step 3 (Auth) atla → direkt personalizasyona
      if (nextStep == 3 && FirebaseService().isAuthenticated) {
        // Burç bilgisini ve ismi Firebase'e kaydet
        _saveUserDataToFirebase();
        nextStep = 4; // Personalizasyon adımına atla
      }

      setState(() => _currentStep = nextStep);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _saveUserDataToFirebase() async {
    if (!FirebaseService().isAuthenticated) return;
    try {
      final uid = FirebaseService().currentUser!.uid;

      // Önce mevcut veriyi kontrol et — varsa üstüne yazma
      final existingDoc = await FirebaseService()
          .firestore
          .collection('users')
          .doc(uid)
          .get();
      final existingData = existingDoc.data() ?? {};

      final updates = <String, dynamic>{};

      // İsim: sadece boşsa veya yoksa yaz
      if (_nameController.text.trim().isNotEmpty &&
          (existingData['name'] == null ||
              (existingData['name'] as String).isEmpty)) {
        updates['name'] = _nameController.text.trim();
      }

      // Doğum tarihi: sadece yoksa yaz
      if (_birthDate != null && existingData['birthDate'] == null) {
        updates['birthDate'] = _birthDate!.toIso8601String();
      }

      // Burç: sadece yoksa yaz
      if (_calculatedZodiac != null &&
          (existingData['zodiacSign'] == null ||
              (existingData['zodiacSign'] as String).isEmpty)) {
        await context.read<AuthProvider>().selectZodiac(_calculatedZodiac!);
      }

      if (updates.isNotEmpty) {
        await FirebaseService()
            .firestore
            .collection('users')
            .doc(uid)
            .set(updates, SetOptions(merge: true));
      }
    } catch (_) {}
  }

  ZodiacSign _calculateZodiacSign(DateTime birthDate) {
    final month = birthDate.month;
    final day = birthDate.day;
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19))
      return ZodiacSign.aries;
    else if ((month == 4 && day >= 20) || (month == 5 && day <= 20))
      return ZodiacSign.taurus;
    else if ((month == 5 && day >= 21) || (month == 6 && day <= 20))
      return ZodiacSign.gemini;
    else if ((month == 6 && day >= 21) || (month == 7 && day <= 22))
      return ZodiacSign.cancer;
    else if ((month == 7 && day >= 23) || (month == 8 && day <= 22))
      return ZodiacSign.leo;
    else if ((month == 8 && day >= 23) || (month == 9 && day <= 22))
      return ZodiacSign.virgo;
    else if ((month == 9 && day >= 23) || (month == 10 && day <= 22))
      return ZodiacSign.libra;
    else if ((month == 10 && day >= 23) || (month == 11 && day <= 21))
      return ZodiacSign.scorpio;
    else if ((month == 11 && day >= 22) || (month == 12 && day <= 21))
      return ZodiacSign.sagittarius;
    else if ((month == 12 && day >= 22) || (month == 1 && day <= 19))
      return ZodiacSign.capricorn;
    else if ((month == 1 && day >= 20) || (month == 2 && day <= 18))
      return ZodiacSign.aquarius;
    else
      return ZodiacSign.pisces;
  }

  bool _isOnZodiacBoundary(DateTime birthDate) {
    final month = birthDate.month;
    final day = birthDate.day;
    final boundaries = [
      (3, 21), (4, 19), (4, 20), (5, 20),
      (5, 21), (6, 20), (6, 21), (7, 22),
      (7, 23), (8, 22), (8, 23), (9, 22),
      (9, 23), (10, 22), (10, 23), (11, 21),
      (11, 22), (12, 21), (12, 22), (1, 19),
      (1, 20), (2, 18), (2, 19), (3, 20),
    ];
    for (final boundary in boundaries) {
      if (month == boundary.$1 && (day - boundary.$2).abs() <= 2) return true;
    }
    return false;
  }

  String _getZodiacMessage(ZodiacSign sign, String name) {
    final messages = {
      ZodiacSign.aries: 'Ateşli, cesur ve lider ruhlu! 🔥',
      ZodiacSign.taurus: 'Kararlı, sadık ve güvenilir! 🌸',
      ZodiacSign.gemini: 'Meraklı, çok yönlü ve sosyal! 💫',
      ZodiacSign.cancer: 'Duygusal, koruyucu ve sezgisel! 🌙',
      ZodiacSign.leo: 'Karizmatik, cömert ve lider! 👑',
      ZodiacSign.virgo: 'Zeki, analitik ve mükemmeliyetçi! ✨',
      ZodiacSign.libra: 'Dengeli, adil ve diplomatik! ⚖️',
      ZodiacSign.scorpio: 'Gizemli, tutkulu ve kararlı! 🦂',
      ZodiacSign.sagittarius: 'Özgür ruhlu, maceraperest! 🏹',
      ZodiacSign.capricorn: 'Disiplinli, azimli ve güçlü! 🏔️',
      ZodiacSign.aquarius: 'Özgün, vizyoner ve bağımsız! 💧',
      ZodiacSign.pisces: 'Hayalperest, empatik ve sanatçı! 🐟',
    };
    return messages[sign] ?? '🌟';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFE4EC),
                    Color(0xFFFFCCE2),
                    Color(0xFFFFB6C1),
                  ],
                ),
              ),
            ),
            // Decorative circles
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryPink.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentPurple.withOpacity(0.06),
                ),
              ),
            ),
            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                colors: const [
                  AppColors.accentPurple,
                  AppColors.primaryPink,
                  AppColors.accentPink,
                  AppColors.gold,
                ],
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: List.generate(_totalSteps, (index) {
                        final isActive = index <= _currentStep;
                        return Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            height: 4,
                            margin:
                                EdgeInsets.only(right: index < _totalSteps - 1 ? 8 : 0),
                            decoration: BoxDecoration(
                              gradient: isActive
                                  ? AppColors.pinkGradient
                                  : null,
                              color: isActive
                                  ? null
                                  : AppColors.primaryPink.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildWelcomeStep(),
                        _buildNameStep(),
                        _buildBirthDateStep(),
                        _buildAuthStep(),
                        _buildPersonalizationStep(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Global loading overlay
            if (_isLoading)
              Container(
                color: Colors.black38,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: AppColors.primaryPink,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Giriş yapılıyor...',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ===================== STEP 1: WELCOME =====================
  Widget _buildWelcomeStep() {
    final screenHeight = MediaQuery.of(context).size.height;
    final logoSize = (screenHeight * 0.25).clamp(140.0, 220.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          // Big beautiful logo with glow
          Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPink.withOpacity(0.25),
                  blurRadius: 60,
                  spreadRadius: 15,
                ),
                BoxShadow(
                  color: AppColors.accentPurple.withOpacity(0.15),
                  blurRadius: 80,
                  spreadRadius: 20,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/astro_dozi_logo.webp',
                width: logoSize,
                height: logoSize,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: logoSize,
                  height: logoSize,
                  decoration: const BoxDecoration(
                    gradient: AppColors.cosmicGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome,
                      size: 80, color: Colors.white),
                ),
              ),
            ),
          )
              .animate()
              .scale(
                  duration: 1000.ms,
                  begin: const Offset(0.3, 0.3),
                  curve: Curves.elasticOut)
              .shimmer(duration: 2500.ms, delay: 800.ms),
          SizedBox(height: screenHeight * 0.03),
          Text(
            'Yıldızlar senin için\nkonuşuyor ✨',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark.withOpacity(0.7),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
          const Spacer(flex: 2),
          // CTA Button
          _buildPrimaryButton('Hadi Başlayalım! 🚀', _nextStep)
              .animate()
              .fadeIn(delay: 700.ms, duration: 500.ms)
              .slideY(begin: 0.3, end: 0, delay: 700.ms),
          const SizedBox(height: 12),
          // Already a member — skip onboarding
          _buildSecondaryButton('Zaten üyeyim, giriş yap', _handleAlreadyMember)
              .animate()
              .fadeIn(delay: 900.ms),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  // ===================== STEP 2: NAME =====================
  Widget _buildNameStep() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top content
                  Column(
                    children: [
                      const SizedBox(height: 40),
                      ClipOval(
                        child: Image.asset(
                          'assets/astro_dozi_main.webp',
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Text('👋',
                                  style: TextStyle(fontSize: 70)),
                        ),
                      ).animate().scale(duration: 500.ms),
                      const SizedBox(height: 28),
                      Text(
                        'Sana nasıl hitap edeyim?',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 36),
                      // Input field — white bg, dark text, pink accent
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryPink.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _nameController,
                          focusNode: _nameFocus,
                          textAlign: TextAlign.center,
                          textCapitalization: TextCapitalization.words,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Örn: Ayşe',
                            hintStyle: TextStyle(
                              color: AppColors.textDark.withOpacity(0.2),
                              fontWeight: FontWeight.w400,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: AppColors.primaryPink.withOpacity(0.4),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 24),
                          ),
                          onSubmitted: (_) {
                            if (_nameController.text.trim().isNotEmpty) {
                              FocusScope.of(context).unfocus();
                              Future.delayed(
                                  const Duration(milliseconds: 150),
                                  _nextStep);
                            }
                          },
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.15),
                    ],
                  ),
                  // Bottom button
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 24),
                    child: AnimatedOpacity(
                      opacity: _nameValid ? 1.0 : 0.35,
                      duration: const Duration(milliseconds: 300),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        transform: Matrix4.identity()
                          ..scale(_nameValid ? 1.0 : 0.97),
                        transformAlignment: Alignment.center,
                        child: _buildPrimaryButton(
                          'Devam Et',
                          _nameValid
                              ? () {
                                  FocusScope.of(context).unfocus();
                                  Future.delayed(
                                      const Duration(milliseconds: 150),
                                      _nextStep);
                                }
                              : () {
                                  // Shake or do nothing
                                },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ===================== STEP 3: BIRTH DATE =====================
  Widget _buildBirthDateStep() {
    final isOnBoundary =
        _birthDate != null && _isOnZodiacBoundary(_birthDate!);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top content
                  Column(
                    children: [
                      const SizedBox(height: 40),
                      const Text('🎂', style: TextStyle(fontSize: 70))
                          .animate()
                          .scale(duration: 500.ms),
                      const SizedBox(height: 24),
                      Text(
                        'Doğum tarihin ne?',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 8),
                      Text(
                        'Burcunu hesaplayalım',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textDark.withOpacity(0.5),
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 32),
                      if (_birthDate != null &&
                          _calculatedZodiac != null) ...[
                        // Zodiac result card
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 28, horizontal: 24),
                          decoration: BoxDecoration(
                            gradient: AppColors.cosmicGradient,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primaryPink.withOpacity(0.3),
                                blurRadius: 25,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(_calculatedZodiac!.symbol,
                                  style: const TextStyle(fontSize: 56)),
                              const SizedBox(height: 10),
                              Text(
                                _calculatedZodiac!.turkishName,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getZodiacMessage(_calculatedZodiac!,
                                    _nameController.text.trim()),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .scale(
                                begin: const Offset(0.85, 0.85),
                                duration: 500.ms,
                                curve: Curves.easeOutBack),
                        if (isOnBoundary) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.warning.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline,
                                    color: AppColors.warning, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Burç geçiş tarihinde doğdun! Farklıysa değiştirebilirsin.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textDark
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate(delay: 400.ms).fadeIn(),
                        ],
                      ],
                    ],
                  ),
                  // Bottom buttons
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 24),
                    child: _birthDate == null
                        ? Column(
                            children: [
                              _buildPrimaryButton(
                                  'Doğum Gününü Seç 📅', _showMonthDayPicker),
                              const SizedBox(height: 12),
                              _buildSecondaryButton(
                                'Şimdilik Atla',
                                () {
                                  // Burç seçtirip devam et
                                  _showZodiacPicker(skipMode: true);
                                },
                              ),
                            ],
                          )
                        : isOnBoundary
                            ? Column(
                                children: [
                                  _buildPrimaryButton(
                                      'Doğru, Devam Et ✓', _nextStep),
                                  const SizedBox(height: 12),
                                  _buildSecondaryButton(
                                      'Burcumu Değiştir', _showZodiacPicker),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildPrimaryButton(
                                      'Devam Et ✓', _nextStep),
                                  const SizedBox(height: 12),
                                  _buildSecondaryButton(
                                    'Tarihi Değiştir',
                                    _showMonthDayPicker,
                                  ),
                                ],
                              ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ===================== STEP 4: AUTH =====================
  Widget _buildAuthStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 3),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPink.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Center(
              child: Text('🔐', style: TextStyle(fontSize: 50)),
            ),
          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 28),
          Text(
            'Son adım!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            'Hesabını oluşturmak için giriş yap',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textDark.withOpacity(0.5),
            ),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 40),
          _buildGoogleButton()
              .animate()
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.2),
          if (Platform.isIOS) ...[
            const SizedBox(height: 14),
            _buildAppleButton()
                .animate()
                .fadeIn(delay: 500.ms)
                .slideY(begin: 0.2),
          ],
          const Spacer(flex: 3),
          Text(
            'Giriş yaparak Gizlilik Politikası ve\nKullanım Koşullarını kabul etmiş olursun',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textDark.withOpacity(0.3),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 600.ms),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  // ===================== PICKERS =====================
  void _showMonthDayPicker() {
    int selectedMonth = _birthDate?.month ?? 1;
    int selectedDay = _birthDate?.day ?? 1;
    final monthScrollController =
        FixedExtentScrollController(initialItem: selectedMonth - 1);
    final dayScrollController =
        FixedExtentScrollController(initialItem: selectedDay - 1);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final daysInMonth = _getDaysInMonth(selectedMonth);
          if (selectedDay > daysInMonth) {
            selectedDay = daysInMonth;
          }

          return Container(
            height: 420,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Doğum Gününü Seç',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Stack(
                    children: [
                      // Selected row highlight
                      Center(
                        child: Container(
                          height: 50,
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPink.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          // Month picker
                          Expanded(
                            child: ListWheelScrollView.useDelegate(
                              controller: monthScrollController,
                              itemExtent: 50,
                              perspective: 0.005,
                              diameterRatio: 1.5,
                              physics: const FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (index) {
                                setModalState(() {
                                  selectedMonth = index + 1;
                                });
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                builder: (context, index) {
                                  final months = [
                                    'Ocak', 'Şubat', 'Mart', 'Nisan',
                                    'Mayıs', 'Haziran', 'Temmuz', 'Ağustos',
                                    'Eylül', 'Ekim', 'Kasım', 'Aralık'
                                  ];
                                  final isSelected =
                                      selectedMonth == index + 1;
                                  return Center(
                                    child: AnimatedDefaultTextStyle(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      style: TextStyle(
                                        fontSize: isSelected ? 20 : 16,
                                        color: isSelected
                                            ? AppColors.primaryPink
                                            : AppColors.textDark
                                                .withOpacity(0.25),
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                      ),
                                      child: Text(months[index]),
                                    ),
                                  );
                                },
                                childCount: 12,
                              ),
                            ),
                          ),
                          // Day picker
                          Expanded(
                            child: ListWheelScrollView.useDelegate(
                              controller: dayScrollController,
                              itemExtent: 50,
                              perspective: 0.005,
                              diameterRatio: 1.5,
                              physics: const FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (index) {
                                setModalState(() {
                                  selectedDay = index + 1;
                                });
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                builder: (context, index) {
                                  final isSelected = selectedDay == index + 1;
                                  return Center(
                                    child: AnimatedDefaultTextStyle(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      style: TextStyle(
                                        fontSize: isSelected ? 20 : 16,
                                        color: isSelected
                                            ? AppColors.primaryPink
                                            : AppColors.textDark
                                                .withOpacity(0.25),
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                      ),
                                      child: Text('${index + 1}'),
                                    ),
                                  );
                                },
                                childCount: daysInMonth,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: _buildPrimaryButton('Tamam', () {
                    Navigator.pop(context);
                    final birthDate =
                        DateTime(2000, selectedMonth, selectedDay);
                    setState(() {
                      _birthDate = birthDate;
                      _calculatedZodiac = _calculateZodiacSign(birthDate);
                    });
                    _confettiController.play();
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showZodiacPicker({bool skipMode = false}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.55,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primaryPink.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Burcunu Seç',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: ZodiacSign.values.length,
                itemBuilder: (context, index) {
                  final sign = ZodiacSign.values[index];
                  final isSelected = sign == _calculatedZodiac;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _calculatedZodiac = sign);
                      Navigator.pop(context);
                      if (skipMode) {
                        _nextStep();
                      } else {
                        _confettiController.play();
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient:
                            isSelected ? AppColors.pinkGradient : null,
                        color: isSelected
                            ? null
                            : AppColors.primaryPink.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryPink
                              : AppColors.primaryPink.withOpacity(0.1),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(sign.symbol,
                              style: const TextStyle(fontSize: 30)),
                          const SizedBox(height: 4),
                          Text(
                            sign.turkishName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== STEP 5: PERSONALIZATION =====================
  Widget _buildPersonalizationStep() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 32),
                      ClipOval(
                        child: Image.asset(
                          'assets/astro_dozi_main.webp',
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Text('💫', style: TextStyle(fontSize: 50)),
                        ),
                      ).animate().scale(duration: 500.ms),
                      const SizedBox(height: 16),
                      Text(
                        'Seni biraz tanıyayım!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 6),
                      Text(
                        'Daha isabetli yorumlar için bilgilerini tamamla',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textDark.withOpacity(0.5),
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 24),

                      // — Doğum Saati & Yeri Kartı —
                      _buildInfoCard(
                        icon: '🕐',
                        title: 'Doğum Detayları',
                        subtitle: 'Doğum haritası ve yükselen burç için gerekli',
                        delay: 350,
                        child: Column(
                          children: [
                            // Doğum Saati
                            GestureDetector(
                              onTap: _showBirthTimePicker,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: _birthTime != null
                                      ? AppColors.primaryPink.withOpacity(0.06)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _birthTime != null
                                        ? AppColors.primaryPink.withOpacity(0.3)
                                        : AppColors.primaryPink.withOpacity(0.12),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      color: _birthTime != null
                                          ? AppColors.primaryPink
                                          : AppColors.textDark.withOpacity(0.3),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _birthTime != null
                                          ? '${_birthTime!.hour.toString().padLeft(2, '0')}:${_birthTime!.minute.toString().padLeft(2, '0')}'
                                          : 'Doğum saatini seç',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: _birthTime != null
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: _birthTime != null
                                            ? AppColors.textDark
                                            : AppColors.textDark.withOpacity(0.35),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (_birthTime != null)
                                      Icon(Icons.check_circle,
                                          color: AppColors.primaryPink, size: 18)
                                    else
                                      Icon(Icons.chevron_right,
                                          color: AppColors.textDark.withOpacity(0.2),
                                          size: 20),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Doğum Yeri
                            Container(
                              decoration: BoxDecoration(
                                color: _birthPlaceController.text.isNotEmpty
                                    ? AppColors.primaryPink.withOpacity(0.06)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _birthPlaceController.text.isNotEmpty
                                      ? AppColors.primaryPink.withOpacity(0.3)
                                      : AppColors.primaryPink.withOpacity(0.12),
                                ),
                              ),
                              child: TextField(
                                controller: _birthPlaceController,
                                textCapitalization: TextCapitalization.words,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Doğum yerini yaz (örn: İstanbul)',
                                  hintStyle: TextStyle(
                                    color: AppColors.textDark.withOpacity(0.3),
                                    fontWeight: FontWeight.w400,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.location_on_rounded,
                                    color: _birthPlaceController.text.isNotEmpty
                                        ? AppColors.primaryPink
                                        : AppColors.textDark.withOpacity(0.3),
                                    size: 20,
                                  ),
                                  suffixIcon: _birthPlaceController.text.isNotEmpty
                                      ? const Icon(Icons.check_circle,
                                          color: AppColors.primaryPink, size: 18)
                                      : null,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 0),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // — Cinsiyet Kartı —
                      _buildSelectionCard(
                        icon: '👤',
                        title: 'Cinsiyet',
                        delay: 450,
                        options: const [
                          ('kadın', 'Kadın', '👩'),
                          ('erkek', 'Erkek', '👨'),
                          ('belirtilmemiş', 'Belirtmek İstemiyorum', '🤷'),
                        ],
                        selectedValue: _selectedGender,
                        onSelected: (val) =>
                            setState(() => _selectedGender = val),
                      ),

                      const SizedBox(height: 14),

                      // — İlişki Durumu Kartı —
                      _buildSelectionCard(
                        icon: '💕',
                        title: 'İlişki Durumu',
                        delay: 550,
                        options: const [
                          ('single', 'Bekar', '💔'),
                          ('dating', 'Flört', '💕'),
                          ('relationship', 'İlişkide', '💑'),
                          ('married', 'Evli', '💒'),
                          ('complicated', 'Karmaşık', '🤷'),
                        ],
                        selectedValue: _selectedRelationship,
                        onSelected: (val) =>
                            setState(() => _selectedRelationship = val),
                      ),

                      const SizedBox(height: 14),

                      // — Hayat Evresi Kartı —
                      _buildSelectionCard(
                        icon: '🌱',
                        title: 'Hayat Evresi',
                        delay: 650,
                        options: const [
                          ('exploring', 'Keşfediyorum', '🔭'),
                          ('building', 'İnşa Ediyorum', '🏗️'),
                          ('established', 'Yerleştim', '🏡'),
                          ('transitioning', 'Değişim Var', '🦋'),
                        ],
                        selectedValue: _selectedLifePhase,
                        onSelected: (val) =>
                            setState(() => _selectedLifePhase = val),
                      ),
                    ],
                  ),

                  // Bottom buttons
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 24),
                    child: Column(
                      children: [
                        _buildPrimaryButton(
                          'Tamamla ve Başla! ✨',
                          _completeOnboardingWithPersonalization,
                        ),
                        const SizedBox(height: 12),
                        _buildSecondaryButton(
                          'Atla, Sonra Yaparım',
                          _completeOnboardingSkipPersonalization,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showBirthTimePicker() {
    showTimePicker(
      context: context,
      initialTime: _birthTime ?? const TimeOfDay(hour: 12, minute: 0),
      helpText: 'Doğum saatini seç',
      cancelText: 'İptal',
      confirmText: 'Tamam',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryPink,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    ).then((picked) {
      if (picked != null) {
        setState(() => _birthTime = picked);
      }
    });
  }

  /// Kart bazlı bilgi girişi (doğum saati/yeri gibi custom content)
  Widget _buildInfoCard({
    required String icon,
    required String title,
    String? subtitle,
    required int delay,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPink.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textDark.withOpacity(0.4),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.08);
  }

  /// Kart bazlı seçim sorusu (cinsiyet, ilişki, hayat evresi)
  Widget _buildSelectionCard({
    required String icon,
    required String title,
    required int delay,
    required List<(String key, String label, String emoji)> options,
    required String? selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPink.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Grid-like layout for options
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((opt) {
              final isSelected = selectedValue == opt.$1;
              return GestureDetector(
                onTap: () => onSelected(opt.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.pinkGradient : null,
                    color: isSelected
                        ? null
                        : AppColors.primaryPink.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : AppColors.primaryPink.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(opt.$3, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        opt.$2,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textDark.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.08);
  }

  Future<void> _completeOnboardingWithPersonalization() async {
    // Personalizasyon bilgilerini kaydet
    if (FirebaseService().isAuthenticated) {
      final updates = <String, dynamic>{};
      if (_selectedGender != null) updates['gender'] = _selectedGender;
      if (_selectedRelationship != null) {
        updates['relationshipStatus'] = _selectedRelationship;
      }
      if (_selectedLifePhase != null) updates['lifePhase'] = _selectedLifePhase;

      // Doğum saati
      if (_birthTime != null) {
        updates['birthTime'] =
            '${_birthTime!.hour.toString().padLeft(2, '0')}:${_birthTime!.minute.toString().padLeft(2, '0')}';
      }

      // Doğum yeri
      if (_birthPlaceController.text.trim().isNotEmpty) {
        updates['birthPlace'] = _birthPlaceController.text.trim();
      }

      if (updates.isNotEmpty) {
        try {
          await FirebaseService()
              .firestore
              .collection('users')
              .doc(FirebaseService().currentUser!.uid)
              .set(updates, SetOptions(merge: true));
        } catch (_) {}
      }
    }

    _goToWelcomeScreen();
  }

  void _completeOnboardingSkipPersonalization() {
    _goToWelcomeScreen();
  }

  void _goToWelcomeScreen() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      CosmicFadeRoute(
        page: WelcomeScreen(
          userName: _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : 'Gezgin',
          zodiacName: _calculatedZodiac?.turkishName ?? 'Koç',
          zodiacSymbol: _calculatedZodiac?.symbol ?? '♈',
        ),
      ),
    );
  }

  int _getDaysInMonth(int month) {
    if (month == 2) return 29;
    if (month == 4 || month == 6 || month == 9 || month == 11) return 30;
    return 31;
  }

  // ===================== BUTTONS =====================
  Widget _buildPrimaryButton(String text, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.pinkGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPink.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: AppColors.primaryPink.withOpacity(0.2),
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark.withOpacity(0.55),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleGoogleSignIn,
          borderRadius: BorderRadius.circular(18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'https://www.google.com/favicon.ico',
                width: 22,
                height: 22,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.g_mobiledata,
                  size: 28,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Google ile Devam Et',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppleButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleAppleSignIn,
          borderRadius: BorderRadius.circular(18),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.apple, size: 26, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Apple ile Devam Et',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== AUTH HANDLERS =====================

  /// Apple Sign In ile giriş — _handleGoogleSignIn ile aynı akış
  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await FirebaseService().signInWithApple();
      if (userCredential != null && mounted) {
        final user = userCredential.user;
        if (user != null) {
          final uid = user.uid;

          // Mevcut veri kontrolü — varsa direkt ana sayfaya
          String existingZodiac = '';
          String existingName = '';
          try {
            final doc = await FirebaseService()
                .firestore
                .collection('users')
                .doc(uid)
                .get();
            if (doc.exists && doc.data() != null) {
              existingName = doc.data()!['name'] ?? '';
              existingZodiac = doc.data()!['zodiacSign'] ?? '';
            }
          } catch (_) {}

          if (existingZodiac.isNotEmpty && mounted) {
            // Zaten kayıtlı kullanıcı — onboarding'i atla
            await context.read<AuthProvider>().login(
                  existingName.isNotEmpty
                      ? existingName
                      : (user.displayName ?? 'Gezgin'),
                  user.email ?? '',
                );
            try {
              final zodiac = ZodiacSign.values
                  .firstWhere((z) => z.name == existingZodiac);
              await context.read<AuthProvider>().selectZodiac(zodiac);
            } catch (_) {}
            await ActivityLogService().logLogin(method: 'apple');

            if (mounted) {
              setState(() => _isLoading = false);
              Navigator.of(context).pushReplacement(
                CosmicFadeRoute(
                  page: GreetingScreen(nextScreen: const MainShell()),
                ),
              );
            }
            return;
          }

          // Yeni kullanıcı — normal akış
          await context
              .read<AuthProvider>()
              .login(_nameController.text.trim(), user.email ?? '');
          if (_calculatedZodiac != null) {
            await context
                .read<AuthProvider>()
                .selectZodiac(_calculatedZodiac!);
          }

          // Sadece eksik alanları yaz
          final updates = <String, dynamic>{};
          if (_nameController.text.trim().isNotEmpty &&
              existingName.isEmpty) {
            updates['name'] = _nameController.text.trim();
          }
          if (_birthDate != null) {
            updates['birthDate'] = _birthDate!.toIso8601String();
          }
          if (updates.isNotEmpty && FirebaseService().isAuthenticated) {
            await FirebaseService()
                .firestore
                .collection('users')
                .doc(uid)
                .set(updates, SetOptions(merge: true));
          }

          await ActivityLogService().logSignup(method: 'apple');

          if (mounted) {
            setState(() => _isLoading = false);
            _nextStep();
          }
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Apple sign-in error: $e');
      if (mounted) {
        setState(() => _isLoading = false);

        String errorMsg = 'Apple ile giriş başarısız oldu. Tekrar dene.';
        final errStr = e.toString();
        if (errStr.contains('network')) {
          errorMsg = 'İnternet bağlantını kontrol et.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.primaryPink,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await FirebaseService().signInWithGoogle();
      if (userCredential != null && mounted) {
        final user = userCredential.user;
        if (user != null) {
          final uid = user.uid;

          // Mevcut veri kontrolü — varsa direkt ana sayfaya
          String existingZodiac = '';
          String existingName = '';
          try {
            final doc = await FirebaseService()
                .firestore
                .collection('users')
                .doc(uid)
                .get();
            if (doc.exists && doc.data() != null) {
              existingName = doc.data()!['name'] ?? '';
              existingZodiac = doc.data()!['zodiacSign'] ?? '';
            }
          } catch (_) {}

          if (existingZodiac.isNotEmpty && mounted) {
            // Zaten kayıtlı kullanıcı — onboarding'i atla
            await context.read<AuthProvider>().login(
                  existingName.isNotEmpty
                      ? existingName
                      : (user.displayName ?? 'Gezgin'),
                  user.email ?? '',
                );
            try {
              final zodiac = ZodiacSign.values
                  .firstWhere((z) => z.name == existingZodiac);
              await context.read<AuthProvider>().selectZodiac(zodiac);
            } catch (_) {}
            await ActivityLogService().logLogin(method: 'google');

            if (mounted) {
              setState(() => _isLoading = false);
              Navigator.of(context).pushReplacement(
                CosmicFadeRoute(
                  page: GreetingScreen(nextScreen: const MainShell()),
                ),
              );
            }
            return;
          }

          // Yeni kullanıcı — normal akış
          await context
              .read<AuthProvider>()
              .login(_nameController.text.trim(), user.email ?? '');
          if (_calculatedZodiac != null) {
            await context
                .read<AuthProvider>()
                .selectZodiac(_calculatedZodiac!);
          }

          // Sadece eksik alanları yaz
          final updates = <String, dynamic>{};
          if (_nameController.text.trim().isNotEmpty &&
              existingName.isEmpty) {
            updates['name'] = _nameController.text.trim();
          }
          if (_birthDate != null) {
            updates['birthDate'] = _birthDate!.toIso8601String();
          }
          if (updates.isNotEmpty && FirebaseService().isAuthenticated) {
            await FirebaseService()
                .firestore
                .collection('users')
                .doc(uid)
                .set(updates, SetOptions(merge: true));
          }

          await ActivityLogService().logSignup(method: 'google');

          if (mounted) {
            setState(() => _isLoading = false);
            // Personalizasyon adımına geç
            _nextStep();
          }
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      if (mounted) {
        setState(() => _isLoading = false);

        String errorMsg = 'Giriş başarısız oldu. Tekrar dene.';
        final errStr = e.toString();
        if (errStr.contains('ApiException: 10')) {
          errorMsg = 'Google giriş yapılandırma hatası. Debug modda SHA-1 gerekli.';
        } else if (errStr.contains('network')) {
          errorMsg = 'İnternet bağlantını kontrol et.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.primaryPink,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _handleAlreadyMember() async {
    // iOS'ta hem Google hem Apple seçeneği sun
    if (Platform.isIOS) {
      _showSignInProviderSheet();
      return;
    }
    // Android'de direkt Google ile devam
    await _handleAlreadyMemberWithProvider('google');
  }

  /// iOS'ta giriş yöntemi seçtir
  void _showSignInProviderSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primaryPink.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Giriş Yöntemi Seç',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            // Google
            _buildProviderSheetButton(
              icon: Icons.g_mobiledata,
              iconSize: 28,
              label: 'Google ile Giriş Yap',
              bgColor: Colors.white,
              textColor: AppColors.textDark,
              useNetworkIcon: true,
              onTap: () {
                Navigator.pop(ctx);
                _handleAlreadyMemberWithProvider('google');
              },
            ),
            const SizedBox(height: 12),
            // Apple
            _buildProviderSheetButton(
              icon: Icons.apple,
              iconSize: 26,
              label: 'Apple ile Giriş Yap',
              bgColor: Colors.black,
              textColor: Colors.white,
              onTap: () {
                Navigator.pop(ctx);
                _handleAlreadyMemberWithProvider('apple');
              },
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderSheetButton({
    required IconData icon,
    required double iconSize,
    required String label,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
    bool useNetworkIcon = false,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: bgColor == Colors.white
            ? Border.all(color: Colors.grey.withOpacity(0.15))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (useNetworkIcon)
                Image.network(
                  'https://www.google.com/favicon.ico',
                  width: 22,
                  height: 22,
                  errorBuilder: (_, __, ___) => Icon(
                    icon,
                    size: iconSize,
                    color: textColor,
                  ),
                )
              else
                Icon(icon, size: iconSize, color: textColor),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAlreadyMemberWithProvider(String provider) async {
    setState(() => _isLoading = true);
    try {
      final userCredential = provider == 'apple'
          ? await FirebaseService().signInWithApple()
          : await FirebaseService().signInWithGoogle();
      if (userCredential == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final user = userCredential.user;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Firebase'den kullanıcı bilgilerini çek
      String name = user.displayName ?? '';
      String zodiacStr = '';
      bool hasExistingRecord = false;

      try {
        final doc = await FirebaseService()
            .firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          hasExistingRecord = true;
          final data = doc.data()!;
          name = data['name'] ?? name;
          zodiacStr = data['zodiacSign'] ?? '';
        }
      } catch (_) {}

      if (!mounted) return;

      // AuthProvider'a login yap
      await context.read<AuthProvider>().login(
            name.isNotEmpty ? name : (user.displayName ?? 'Kullanıcı'),
            user.email ?? '',
          );

      // Burç varsa yükle
      if (zodiacStr.isNotEmpty) {
        try {
          final zodiac =
              ZodiacSign.values.firstWhere((z) => z.name == zodiacStr);
          await context.read<AuthProvider>().selectZodiac(zodiac);
        } catch (_) {}
      }

      if (mounted) {
        setState(() => _isLoading = false);

        if (hasExistingRecord && zodiacStr.isNotEmpty) {
          // ✅ Gerçekten mevcut üye — direkt ana sayfaya
          await ActivityLogService().logLogin(method: provider);
          Navigator.of(context).pushReplacement(
            CosmicFadeRoute(
              page: GreetingScreen(nextScreen: const MainShell()),
            ),
          );
        } else if (hasExistingRecord && zodiacStr.isEmpty) {
          // Kaydı var ama burcu yok — doğum tarihi adımına
          await ActivityLogService().logLogin(method: provider);
          _nameController.text = name;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Hoş geldin! Burcunu belirleyelim.'),
              backgroundColor: AppColors.primaryPink,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
          setState(() => _currentStep = 2);
          _pageController.animateToPage(
            2,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
          );
        } else {
          // ❌ Kaydı yok — aslında yeni kullanıcı, normal onboarding'e devam
          await ActivityLogService().logSignup(method: provider);
          _nameController.text =
              name.isNotEmpty ? name : (user.displayName ?? '');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Hesabın oluşturuldu! Hadi bilgilerini tamamlayalım.'),
              backgroundColor: AppColors.primaryPink,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
          // İsim zaten doluysa doğum tarihine, değilse isim adımına
          final targetStep =
              _nameController.text.trim().isNotEmpty ? 2 : 1;
          setState(() => _currentStep = targetStep);
          _pageController.animateToPage(
            targetStep,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
          );
        }
      }
    } catch (e) {
      debugPrint('Already member error: $e');
      if (mounted) {
        setState(() => _isLoading = false);

        String errorMsg = 'Giriş başarısız oldu. Tekrar dene.';
        final errStr = e.toString();
        if (errStr.contains('ApiException: 10')) {
          errorMsg = 'Giriş yapılandırma hatası. Lütfen başka bir yöntemle dene.';
        } else if (errStr.contains('network')) {
          errorMsg = 'İnternet bağlantını kontrol et.';
        } else if (errStr.contains('canceled') ||
            errStr.contains('cancelled')) {
          errorMsg = 'Giriş iptal edildi.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.primaryPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }
}
