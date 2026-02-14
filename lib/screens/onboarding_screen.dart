import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_service.dart';
import '../models/zodiac_sign.dart';
import '../constants/colors.dart';
import 'welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  ZodiacSign? _calculatedZodiac;
  int _currentStep = 0;
  late ConfettiController _confettiController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  ZodiacSign _calculateZodiacSign(DateTime birthDate) {
    final month = birthDate.month;
    final day = birthDate.day;
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return ZodiacSign.aries;
    else if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return ZodiacSign.taurus;
    else if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return ZodiacSign.gemini;
    else if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return ZodiacSign.cancer;
    else if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return ZodiacSign.leo;
    else if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return ZodiacSign.virgo;
    else if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return ZodiacSign.libra;
    else if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return ZodiacSign.scorpio;
    else if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return ZodiacSign.sagittarius;
    else if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return ZodiacSign.capricorn;
    else if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return ZodiacSign.aquarius;
    else return ZodiacSign.pisces;
  }

  bool _isOnZodiacBoundary(DateTime birthDate) {
    final month = birthDate.month;
    final day = birthDate.day;
    
    // Her burç geçiş tarihinin ±2 günü içinde mi kontrol et
    final boundaries = [
      (3, 21), (4, 19), // Koç
      (4, 20), (5, 20), // Boğa
      (5, 21), (6, 20), // İkizler
      (6, 21), (7, 22), // Yengeç
      (7, 23), (8, 22), // Aslan
      (8, 23), (9, 22), // Başak
      (9, 23), (10, 22), // Terazi
      (10, 23), (11, 21), // Akrep
      (11, 22), (12, 21), // Yay
      (12, 22), (1, 19), // Oğlak
      (1, 20), (2, 18), // Kova
      (2, 19), (3, 20), // Balık
    ];
    
    for (final boundary in boundaries) {
      final boundaryMonth = boundary.$1;
      final boundaryDay = boundary.$2;
      
      if (month == boundaryMonth) {
        // Aynı ay içinde ±2 gün kontrolü
        if ((day - boundaryDay).abs() <= 2) {
          return true;
        }
      }
    }
    
    return false;
  }

  String _getZodiacMessage(ZodiacSign sign, String name) {
    final messages = {
      ZodiacSign.aries: 'Vay be $name! Koç burcu musun? Ateşli, cesur ve lider ruhlu! 🔥',
      ZodiacSign.taurus: '$name! Boğa burcu olarak kararlı ve sadıksın! 🌸',
      ZodiacSign.gemini: 'Hey $name! İkizler burcu - meraklı ve çok yönlü! 💫',
      ZodiacSign.cancer: 'Hoş geldin $name! Yengeç burcu - duygusal ve koruyucu! 🌙',
      ZodiacSign.leo: 'Selam $name! Aslan burcu - kraliyet havası var! 👑',
      ZodiacSign.virgo: '$name! Başak burcu - mükemmeliyetçi! ✨',
      ZodiacSign.libra: 'Hey $name! Terazi burcu - dengeli ve adil! ⚖️',
      ZodiacSign.scorpio: 'Vay be $name! Akrep burcu - gizemli ve tutkulu! 🦂',
      ZodiacSign.sagittarius: '$name! Yay burcu - özgür ruhlu! 🏹',
      ZodiacSign.capricorn: '$name! Oğlak burcu - disiplinli! 🏔️',
      ZodiacSign.aquarius: 'Hey $name! Kova burcu - özgün! 💧',
      ZodiacSign.pisces: '$name! Balık burcu - hayalperest! 🐟',
    };
    return messages[sign] ?? 'Hoş geldin $name! 🌟';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.bgDark, AppColors.cardDark],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [AppColors.accentPurple, AppColors.accentBlue, AppColors.accentPink, AppColors.gold],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    children: List.generate(4, (index) {
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                          decoration: BoxDecoration(
                            color: index <= _currentStep ? AppColors.accentPurple : AppColors.borderDark,
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
        ],
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Zodi Logo
            ClipOval(
              child: Image.asset(
                'assets/zodi_logo.webp',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 120,
                  height: 120,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: AppColors.cosmicGradient,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.accentPurple.withOpacity(0.5), blurRadius: 30, offset: const Offset(0, 10))],
                  ),
                  child: const Icon(Icons.auto_awesome, size: 60, color: Colors.white),
                ),
              ),
            ).animate().scale(duration: 600.ms).shimmer(duration: 2000.ms),
            const SizedBox(height: 40),
            const Text('Zodi', style: TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: Colors.white)).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 16),
            const Text('Yıldızlar senin için konuşuyor ✨', style: TextStyle(fontSize: 18, color: AppColors.textSecondary), textAlign: TextAlign.center).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 60),
            _buildButton('Hadi Başlayalım! 🚀', _nextStep).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
          ],
        ),
      ),
    );
  }

  Widget _buildNameStep() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 16),
                    // Content
                    Column(
                      children: [
                        ClipOval(
                          child: Image.asset(
                            'assets/dozi_char.webp',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Text('👋', style: TextStyle(fontSize: 80)),
                          ),
                        ).animate().scale(duration: 600.ms),
                        const SizedBox(height: 24),
                        const Text('Adın ne?', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 12),
                        const Text('Sana nasıl hitap edeyim?', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                        const SizedBox(height: 40),
                        TextField(
                          controller: _nameController,
                          autofocus: true,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Örn: Ayşe',
                            hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
                            filled: true,
                            fillColor: AppColors.cardDark,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                            errorText: _nameController.text.isEmpty && _nameController.text.isNotEmpty ? 'Lütfen adını gir' : null,
                          ),
                          onSubmitted: (_) {
                            if (_nameController.text.trim().isNotEmpty) _nextStep();
                          },
                        ),
                      ],
                    ),
                    // Button always at bottom
                    Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 16),
                      child: _buildButton('Devam Et', () {
                        if (_nameController.text.trim().isEmpty) {
                          setState(() {});
                          return;
                        }
                        _nextStep();
                      }),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBirthDateStep() {
    final isOnBoundary = _birthDate != null && _isOnZodiacBoundary(_birthDate!);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 16),
                  // Content
                  Column(
                    children: [
                      const Text('🎂', style: TextStyle(fontSize: 80)).animate().scale(duration: 600.ms),
                      const SizedBox(height: 24),
                      const Text('Doğum tarihin ne?', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 12),
                      const Text('Burcunu hesaplayalım', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                      const SizedBox(height: 40),
                      if (_birthDate == null)
                        const SizedBox()
                      else ...[
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(gradient: AppColors.goldGradient, borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            children: [
                              Text(_calculatedZodiac!.symbol, style: const TextStyle(fontSize: 60)),
                              const SizedBox(height: 12),
                              Text(_calculatedZodiac!.turkishName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 12),
                              Text(_getZodiacMessage(_calculatedZodiac!, _nameController.text.trim()), style: const TextStyle(fontSize: 16, color: Colors.white), textAlign: TextAlign.center),
                            ],
                          ),
                        ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
                        if (isOnBoundary) ...[
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                            ),
                            child: Column(
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Burç geçiş tarihinde doğdun!',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Doğum tarihin burç geçiş dönemine denk geliyor. Bazı kaynaklara göre farklı burç olabilirsin. Emin değilsen değiştirebilirsin.',
                                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ).animate(delay: 300.ms).fadeIn(),
                        ],
                      ],
                    ],
                  ),
                  // Button always at bottom
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 16),
                    child: _birthDate == null
                        ? _buildButton('Doğum Gününü Seç 📅', () => _showMonthDayPicker())
                        : isOnBoundary
                            ? Row(
                                children: [
                                  Expanded(
                                    child: _buildSecondaryButton('Burcu Değiştir', () {
                                      _showZodiacPicker();
                                    }),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: _buildButton('Doğru, Devam Et ✓', _nextStep),
                                  ),
                                ],
                              )
                            : _buildButton('Devam Et ✓', _nextStep),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showZodiacPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Burcunu Seç',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.purpleGradient : null,
                        color: isSelected ? null : AppColors.bgDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.accentPurple : AppColors.borderDark,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(sign.symbol, style: const TextStyle(fontSize: 32)),
                          const SizedBox(height: 4),
                          Text(
                            sign.turkishName,
                            style: const TextStyle(fontSize: 11, color: Colors.white),
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

  Widget _buildSecondaryButton(String text, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthStep() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🔐', style: TextStyle(fontSize: 80)).animate().scale(duration: 600.ms),
              const SizedBox(height: 24),
              const Text('Son adım!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              const Text('Google hesabınla giriş yap', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
              const SizedBox(height: 40),
              _buildGoogleButton(),
              const SizedBox(height: 24),
              Text(
                'Giriş yaparak Gizlilik Politikası ve\nKullanım Koşullarını kabul etmiş olursun',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary.withOpacity(0.7)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        // Loading overlay
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.accentPurple),
                  SizedBox(height: 16),
                  Text(
                    'Giriş yapılıyor...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showMonthDayPicker() {
    int selectedMonth = 1;
    int selectedDay = 1;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final daysInMonth = _getDaysInMonth(selectedMonth);
          if (selectedDay > daysInMonth) {
            selectedDay = daysInMonth;
          }
          
          return Container(
            height: 400,
            decoration: const BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Doğum Gününü Seç',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Row(
                    children: [
                      // Ay seçici
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          itemExtent: 50,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setModalState(() {
                              selectedMonth = index + 1;
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              final months = [
                                'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
                                'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
                              ];
                              return Center(
                                child: Text(
                                  months[index],
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: selectedMonth == index + 1
                                        ? AppColors.accentPurple
                                        : AppColors.textSecondary,
                                    fontWeight: selectedMonth == index + 1
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              );
                            },
                            childCount: 12,
                          ),
                        ),
                      ),
                      // Gün seçici
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          itemExtent: 50,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setModalState(() {
                              selectedDay = index + 1;
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              return Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: selectedDay == index + 1
                                        ? AppColors.accentPurple
                                        : AppColors.textSecondary,
                                    fontWeight: selectedDay == index + 1
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              );
                            },
                            childCount: daysInMonth,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: AppColors.purpleGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          // Yıl olarak 2000 kullan (burç için önemli değil)
                          final birthDate = DateTime(2000, selectedMonth, selectedDay);
                          setState(() {
                            _birthDate = birthDate;
                            _calculatedZodiac = _calculateZodiacSign(birthDate);
                          });
                          _confettiController.play();
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Tamam',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int _getDaysInMonth(int month) {
    // Şubat için 29 gün (artık yıl olabilir)
    if (month == 2) return 29;
    // 30 günlük aylar
    if (month == 4 || month == 6 || month == 9 || month == 11) return 30;
    // 31 günlük aylar
    return 31;
  }

  Widget _buildButton(String text, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(gradient: AppColors.purpleGradient, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.accentPurple.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))]),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 18), child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center)),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleGoogleSignIn,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network('https://www.google.com/favicon.ico', width: 24, height: 24),
                const SizedBox(width: 12),
                const Text('Google ile Devam Et', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await FirebaseService().signInWithGoogle();
      if (userCredential != null && mounted) {
        final user = userCredential.user;
        if (user != null) {
          await context.read<AuthProvider>().login(_nameController.text.trim(), user.email ?? '');
          if (_calculatedZodiac != null) await context.read<AuthProvider>().selectZodiac(_calculatedZodiac!);
          if (FirebaseService().isAuthenticated && _birthDate != null) {
            await FirebaseService().firestore.collection('users').doc(FirebaseService().currentUser!.uid).update({'birthDate': _birthDate!.toIso8601String()});
          }
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
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

}
