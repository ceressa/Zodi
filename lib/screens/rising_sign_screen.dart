import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../providers/auth_provider.dart';
import '../providers/horoscope_provider.dart';
import '../constants/colors.dart';
import '../widgets/animated_card.dart';
import '../services/usage_limit_service.dart';
import '../services/ad_service.dart';
import '../services/activity_log_service.dart';
import '../widgets/limit_reached_dialog.dart';
import '../screens/premium_screen.dart';
import '../theme/cosmic_page_route.dart';

class RisingSignScreen extends StatefulWidget {
  const RisingSignScreen({super.key});

  @override
  State<RisingSignScreen> createState() => _RisingSignScreenState();
}

class _RisingSignScreenState extends State<RisingSignScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final UsageLimitService _usageLimitService = UsageLimitService();
  final AdService _adService = AdService();
  final ActivityLogService _activityLog = ActivityLogService();
  DateTime? _birthDate;
  final _birthTimeController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  bool _hasPrefilledProfileData = false;
  bool _isBirthDateLocked = false;
  late ConfettiController _confettiController;
  late AnimationController _spinController;
  late AnimationController _messageController;
  int _loadingMessageIndex = 0;
  static const _loadingMessages = [
    'Yıldız haritanı okuyorum...',
    'Güneş burcunu analiz ediyorum...',
    'Ay burcunu hesaplıyorum...',
    'Yükselen burcunu arıyorum...',
    'Gezegenler konuşuyor...',
    'Kozmik enerjini çözümlüyorum...',
  ];

  static const _zodiacSymbols = [
    '♈', '♉', '♊', '♋', '♌', '♍',
    '♎', '♏', '♐', '♑', '♒', '♓',
  ];
  
  // Turkish cities for autocomplete
  static const List<String> _turkishCities = [
    'Adana',
    'Adıyaman',
    'Afyonkarahisar',
    'Ağrı',
    'Aksaray',
    'Amasya',
    'Ankara',
    'Antalya',
    'Ardahan',
    'Artvin',
    'Aydın',
    'Balıkesir',
    'Bartın',
    'Batman',
    'Bayburt',
    'Bilecik',
    'Bingöl',
    'Bitlis',
    'Bolu',
    'Burdur',
    'Bursa',
    'Çanakkale',
    'Çankırı',
    'Çorum',
    'Denizli',
    'Diyarbakır',
    'Düzce',
    'Edirne',
    'Elazığ',
    'Erzincan',
    'Erzurum',
    'Eskişehir',
    'Gaziantep',
    'Giresun',
    'Gümüşhane',
    'Hakkari',
    'Hatay',
    'Iğdır',
    'Isparta',
    'İstanbul',
    'İzmir',
    'Kahramanmaraş',
    'Karabük',
    'Karaman',
    'Kars',
    'Kastamonu',
    'Kayseri',
    'Kırıkkale',
    'Kırklareli',
    'Kırşehir',
    'Kilis',
    'Kocaeli',
    'Konya',
    'Kütahya',
    'Malatya',
    'Manisa',
    'Mardin',
    'Mersin',
    'Muğla',
    'Muş',
    'Nevşehir',
    'Niğde',
    'Ordu',
    'Osmaniye',
    'Rize',
    'Sakarya',
    'Samsun',
    'Siirt',
    'Sinop',
    'Sivas',
    'Şanlıurfa',
    'Şırnak',
    'Tekirdağ',
    'Tokat',
    'Trabzon',
    'Tunceli',
    'Uşak',
    'Van',
    'Yalova',
    'Yozgat',
    'Zonguldak',
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _messageController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _loadingMessageIndex = (_loadingMessageIndex + 1) % _loadingMessages.length;
        });
        _messageController.forward(from: 0);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_hasPrefilledProfileData) return;

    final profile = Provider.of<AuthProvider>(context).userProfile;

    if (profile == null) return;

    if (profile.birthDate.year > 1900) {
      _birthDate = profile.birthDate;
      _isBirthDateLocked = true;
    }

    if (profile.birthTime.trim().isNotEmpty) {
      _birthTimeController.text = profile.birthTime.trim();
    }

    if (profile.birthPlace.trim().isNotEmpty) {
      _birthPlaceController.text = profile.birthPlace.trim();
    }

    _hasPrefilledProfileData = true;
  }

  @override
  void dispose() {
    _birthTimeController.dispose();
    _birthPlaceController.dispose();
    _confettiController.dispose();
    _spinController.dispose();
    _messageController.dispose();
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
      setState(() {
        _birthTimeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate() || _birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final horoscopeProvider = context.read<HoroscopeProvider>();

    if (authProvider.selectedZodiac == null) return;

    // Start loading animations
    _loadingMessageIndex = 0;
    _messageController.forward(from: 0);

    await horoscopeProvider.calculateRisingSign(
      sunSign: authProvider.selectedZodiac!,
      birthDate: _birthDate!,
      birthTime: _birthTimeController.text,
      birthPlace: _birthPlaceController.text,
    );

    // Show confetti on success
    if (horoscopeProvider.risingSignResult != null && mounted) {
      _messageController.stop();
      _confettiController.play();
      
      // Log activity
      await _activityLog.logRisingSign(
        horoscopeProvider.risingSignResult!.risingSign.name,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horoscopeProvider = context.watch<HoroscopeProvider>();
    
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDark ? AppColors.textPrimary : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Yükselen Burç',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.textPrimary : AppColors.textDark,
                            ),
                          ),
                          Text(
                            'Gerçek kişiliğini keşfet',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Form
                AnimatedCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Doğum Bilgilerin',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimary : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Birth Date
                        InkWell(
                          onTap: _isBirthDateLocked ? null : _selectDate,
                          child: Container(
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
                                Icon(
                                  Icons.calendar_today,
                                  color: AppColors.accentPurple,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _birthDate == null
                                        ? 'Doğum Tarihi'
                                        : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _birthDate == null
                                          ? AppColors.textMuted
                                          : (isDark ? AppColors.textPrimary : AppColors.textDark),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isBirthDateLocked)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 4),
                            child: Text(
                              'Doğum tarihi profilinden otomatik alındı',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),
                        
                        // Birth Time
                        InkWell(
                          onTap: _selectTime,
                          child: Container(
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
                                Icon(
                                  Icons.access_time,
                                  color: AppColors.accentPurple,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _birthTimeController.text.isEmpty
                                        ? 'Doğum Saati'
                                        : _birthTimeController.text,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _birthTimeController.text.isEmpty
                                          ? AppColors.textMuted
                                          : (isDark ? AppColors.textPrimary : AppColors.textDark),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Birth Place with Autocomplete
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<String>.empty();
                            }
                            return _turkishCities.where((String city) {
                              return city.toLowerCase().contains(textEditingValue.text.toLowerCase());
                            });
                          },
                          onSelected: (String selection) {
                            _birthPlaceController.text = selection;
                          },
                          fieldViewBuilder: (
                            BuildContext context,
                            TextEditingController fieldTextEditingController,
                            FocusNode fieldFocusNode,
                            VoidCallback onFieldSubmitted,
                          ) {
                            // Sync with our controller
                            fieldTextEditingController.text = _birthPlaceController.text;
                            fieldTextEditingController.addListener(() {
                              _birthPlaceController.text = fieldTextEditingController.text;
                            });
                            
                            return TextFormField(
                              controller: fieldTextEditingController,
                              focusNode: fieldFocusNode,
                              decoration: InputDecoration(
                                labelText: 'Doğum Yeri',
                                hintText: 'Şehir adı yazın (örn: Aksaray)',
                                helperText: 'Sadece şehir adı yeterli',
                                prefixIcon: Icon(Icons.location_on, color: AppColors.accentPurple),
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
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Doğum yeri gerekli';
                                }
                                return null;
                              },
                            );
                          },
                          optionsViewBuilder: (
                            BuildContext context,
                            AutocompleteOnSelected<String> onSelected,
                            Iterable<String> options,
                          ) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  constraints: const BoxConstraints(maxHeight: 200),
                                  width: MediaQuery.of(context).size.width - 48,
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.cardDark : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final String option = options.elementAt(index);
                                      return InkWell(
                                        onTap: () => onSelected(option),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: (isDark ? AppColors.textPrimary : AppColors.textDark).withOpacity(0.1),
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.location_city,
                                                size: 16,
                                                color: AppColors.accentPurple,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                option,
                                                style: TextStyle(
                                                  color: isDark ? AppColors.textPrimary : AppColors.textDark,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Calculate Button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: AppColors.cosmicGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: horoscopeProvider.isLoadingRisingSign ? null : _calculate,
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: horoscopeProvider.isLoadingRisingSign
                                    ? const Center(
                                        child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Hesapla',
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
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                _buildCalculationDisclaimer(isDark),
                
                // Results
                if (horoscopeProvider.risingSignResult != null) ...[
                  const SizedBox(height: 24),
                  
                  AnimatedCard(
                    delay: 200.ms,
                    gradient: AppColors.purpleGradient,
                    child: Column(
                      children: [
                        const Text(
                          'Burç Üçlüsü',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSignBadge(
                              horoscopeProvider.risingSignResult!.sunSign.symbol,
                              'Güneş',
                              signName: horoscopeProvider.risingSignResult!.sunSign.displayName,
                            ),
                            _buildSignBadge(
                              horoscopeProvider.risingSignResult!.risingSign.symbol,
                              'Yükselen',
                              signName: horoscopeProvider.risingSignResult!.risingSign.displayName,
                            ),
                            _buildSignBadge(
                              horoscopeProvider.risingSignResult!.moonSign.symbol,
                              'Ay',
                              signName: horoscopeProvider.risingSignResult!.moonSign.displayName,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  AnimatedCard(
                    delay: 300.ms,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          Icons.person,
                          'Kişilik',
                          horoscopeProvider.risingSignResult!.personality,
                          isDark,
                        ),
                        const Divider(height: 24),
                        _buildSection(
                          Icons.star,
                          'Güçlü Yönler',
                          horoscopeProvider.risingSignResult!.strengths,
                          isDark,
                        ),
                        const Divider(height: 24),
                        _buildSection(
                          Icons.warning_amber,
                          'Zayıf Yönler',
                          horoscopeProvider.risingSignResult!.weaknesses,
                          isDark,
                        ),
                        const Divider(height: 24),
                        _buildSection(
                          Icons.explore,
                          'Hayata Yaklaşım',
                          horoscopeProvider.risingSignResult!.lifeApproach,
                          isDark,
                        ),
                        const Divider(height: 24),
                        _buildSection(
                          Icons.favorite,
                          'İlişkiler',
                          horoscopeProvider.risingSignResult!.relationships,
                          isDark,
                        ),
                        
                        // Detaylı Yorum Butonu (Premium/Ad Gate)
                        const Divider(height: 32),
                        _buildDetailedCommentButton(isDark),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [AppColors.accentPurple, AppColors.accentBlue, AppColors.accentPink, AppColors.gold],
            ),
          ),
          // Loading overlay
          if (horoscopeProvider.isLoadingRisingSign)
            _buildLoadingOverlay(),
        ],
      ),
    );
  }


  Widget _buildCalculationDisclaimer(bool isDark) {
    return AnimatedCard(
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 8),
          iconColor: AppColors.accentPurple,
          collapsedIconColor: AppColors.accentPurple,
          leading: const Icon(Icons.info_outline, color: AppColors.accentPurple),
          title: Text(
            'Hesaplama Metodolojisi',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimary : AppColors.textDark,
            ),
          ),
          subtitle: Text(
            'Bu sonuçları nasıl hesaplıyoruz?',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondary : AppColors.textMuted,
            ),
          ),
          children: [
            Text(
              '• Güneş, Ay ve Yükselen hesapları Swiss Ephemeris (astronomik efemeris) ile yapılır.\n'
              '• Hesaplama sistemi Tropical Zodyak + Placidus ev sistemidir.\n'
              "• Doğum saati Türkiye saatine (Europe/Istanbul) göre UTC'ye çevrilerek hesaplanır.\n"
              '• Doğum yeri şehir bazlı koordinatlarla eşleştirilir; şehir bulunamazsa Ankara referans alınır.\n'
              '• Kişilik yorumlarını yapay zeka üretir, ancak burç sonuçları (Güneş/Ay/Yükselen) astronomik hesaplardan gelir.\n\n'
              'Not: Farklı sitelerde Sidereal/Lahiri veya farklı ev sistemi kullanılırsa sonuçlar değişebilir.',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: isDark ? AppColors.textSecondary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return AnimatedBuilder(
      animation: _spinController,
      builder: (context, child) {
        return Container(
          color: const Color(0xDD1E1040),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Spinning zodiac wheel
                SizedBox(
                  width: 250,
                  height: 250,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Zodiac symbols in a circle
                      ...List.generate(12, (index) {
                        final angle = (index * 30.0 + _spinController.value * 360) * math.pi / 180;
                        final radius = 100.0;
                        return Positioned(
                          left: 125 + radius * math.cos(angle) - 14,
                          top: 125 + radius * math.sin(angle) - 14,
                          child: Text(
                            _zodiacSymbols[index],
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.white.withOpacity(
                                0.4 + 0.6 * ((math.sin(angle + _spinController.value * math.pi * 2) + 1) / 2),
                              ),
                            ),
                          ),
                        );
                      }),
                      // Center glow
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.accentPurple.withOpacity(0.6),
                              AppColors.accentPurple.withOpacity(0.0),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Text('✨', style: TextStyle(fontSize: 36)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Loading message
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    _loadingMessages[_loadingMessageIndex],
                    key: ValueKey(_loadingMessageIndex),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                // Subtle progress dots
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentPurple.withOpacity(
                          0.3 + 0.7 * ((math.sin(_spinController.value * math.pi * 2 + index * 1.0) + 1) / 2),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignBadge(String symbol, String label, {String? signName}) {
    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.gold.withOpacity(0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.2),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Text(
              symbol,
              style: const TextStyle(fontSize: 34),
            ),
          ),
        ).animate().scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          duration: 600.ms,
          curve: Curves.elasticOut,
        ),
        const SizedBox(height: 8),
        if (signName != null) ...[
          Text(
            signName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
        ],
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(IconData icon, String title, String content, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.accentPurple, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimary : AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: isDark ? AppColors.textSecondary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedCommentButton(bool isDark) {
    final authProvider = context.watch<AuthProvider>();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentPurple.withOpacity(0.1),
            AppColors.accentBlue.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentPurple.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.purpleGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detaylı Kişisel Yorum',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimary : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Burç üçlüne özel derinlemesine analiz',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!authProvider.isPremium)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final canView = await _usageLimitService.canViewRisingSignDetail();
                      if (!canView) {
                        if (mounted) {
                          LimitReachedDialog.showRisingSignLimit(
                            context,
                            onAdWatched: () {
                              _showDetailedComment();
                            },
                          );
                        }
                        return;
                      }
                      
                      final success = await _adService.showRewardedAd(
                        placement: 'rising_sign_detail',
                      );
                      if (success) {
                        await _usageLimitService.incrementRisingSignDetail();
                        _showDetailedComment();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accentPurple,
                      side: const BorderSide(color: AppColors.accentPurple, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.play_circle_outline, size: 20),
                    label: const Text(
                      'Reklam İzle',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        CosmicBottomSheetRoute(page: const PremiumScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.workspace_premium, size: 20),
                    label: const Text(
                      'Premium',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showDetailedComment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.auto_awesome, size: 20),
                label: const Text(
                  'Detaylı Yorumu Gör',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showDetailedComment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detaylı Kişisel Yorum'),
        content: const Text('Burç üçlüne özel derinlemesine analiz yakında eklenecek!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
