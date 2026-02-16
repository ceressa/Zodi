import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_service.dart';
import '../services/activity_log_service.dart';
import '../models/zodiac_sign.dart';
import '../constants/colors.dart';
import 'welcome_screen.dart';
import 'home_screen.dart';

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
  final ActivityLogService _activityLog = ActivityLogService();
  DateTime? _birthDate;
  ZodiacSign? _calculatedZodiac;
  int _currentStep = 0;
  late ConfettiController _confettiController;
  bool _isLoading = false;
  bool _nameValid = false;

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
    super.dispose();
  }

  void _nextStep() {
    FocusScope.of(context).unfocus();
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
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
                      children: List.generate(4, (index) {
                        final isActive = index <= _currentStep;
                        return Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            height: 4,
                            margin:
                                EdgeInsets.only(right: index < 3 ? 8 : 0),
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
                'assets/zodi_logo.webp',
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
                          'assets/dozi_char.webp',
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
                        ? _buildPrimaryButton(
                            'Doğum Gününü Seç 📅', _showMonthDayPicker)
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

  void _showZodiacPicker() {
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
                      _confettiController.play();
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

  // ===================== AUTH HANDLERS =====================
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await FirebaseService().signInWithGoogle();
      if (userCredential != null && mounted) {
        final user = userCredential.user;
        if (user != null) {
          await context
              .read<AuthProvider>()
              .login(_nameController.text.trim(), user.email ?? '');
          if (_calculatedZodiac != null) {
            await context.read<AuthProvider>().selectZodiac(_calculatedZodiac!);
          }
          if (FirebaseService().isAuthenticated && _birthDate != null) {
            await FirebaseService()
                .firestore
                .collection('users')
                .doc(FirebaseService().currentUser!.uid)
                .update({'birthDate': _birthDate!.toIso8601String()});
          }
          
          // Log signup activity
          await _activityLog.logSignup();
          
          if (mounted) {
            setState(() => _isLoading = false);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => WelcomeScreen(
                  userName: _nameController.text.trim(),
                  zodiacName: _calculatedZodiac!.turkishName,
                  zodiacSymbol: _calculatedZodiac!.symbol,
                ),
              ),
            );
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
    setState(() => _isLoading = true);
    try {
      final userCredential = await FirebaseService().signInWithGoogle();
      if (userCredential == null) {
        // Kullanıcı iptal etti
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final user = userCredential.user;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Firebase'de kullanıcı var mı kontrol et
      String name = user.displayName ?? '';
      String zodiacStr = '';

      try {
        final doc = await FirebaseService()
            .firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          name = data['name'] ?? name;
          zodiacStr = data['zodiacSign'] ?? '';
        }
      } catch (_) {
        // Firestore hatası olsa bile giriş devam etsin
      }

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

        // Burç bilgisi varsa direkt ana sayfaya, yoksa onboarding'e devam
        if (zodiacStr.isNotEmpty) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          _nameController.text = name;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Giriş başarılı! Bilgilerini tamamlayalım.'),
              backgroundColor: AppColors.primaryPink,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
          _nextStep();
        }
      }
    } catch (e) {
      debugPrint('Already member error: $e');
      if (mounted) {
        setState(() => _isLoading = false);

        String errorMsg = 'Giriş başarısız oldu. Tekrar dene.';
        final errStr = e.toString();
        if (errStr.contains('ApiException: 10')) {
          errorMsg = 'Google giriş yapılandırma hatası. Lütfen normal kayıt ile devam et.';
        } else if (errStr.contains('network')) {
          errorMsg = 'İnternet bağlantını kontrol et.';
        } else if (errStr.contains('canceled') || errStr.contains('cancelled')) {
          errorMsg = 'Giriş iptal edildi.';
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
}
