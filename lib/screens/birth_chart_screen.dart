import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/ad_service.dart';
import '../services/astronomy_service.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';
import '../constants/colors.dart';
import 'premium_screen.dart';
import '../theme/cosmic_page_route.dart';
import '../services/activity_log_service.dart';

class BirthChartScreen extends StatefulWidget {
  const BirthChartScreen({super.key});

  @override
  State<BirthChartScreen> createState() => _BirthChartScreenState();
}

class _BirthChartScreenState extends State<BirthChartScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ActivityLogService _activityLog = ActivityLogService();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _cityController = TextEditingController();
  final AdService _adService = AdService();
  final StorageService _storageService = StorageService();
  final GeminiService _geminiService = GeminiService();

  // State
  bool _showChart = false;
  bool _isLoading = false;
  bool _chartUnlockedByAd = false;
  bool _isOtherPersonMode = false;
  bool _hasPrefilledProfileData = false;
  bool _isBirthDateLocked = false;
  String? _error;

  // Calculated data
  List<Map<String, dynamic>> _planets = [];
  Map<String, dynamic>? _ascendant;
  String? _interpretation;

  // Loading animation
  late AnimationController _spinController;
  int _loadingMessageIndex = 0;
  static const _loadingMessages = [
    'Gezegenleri konumlandırıyorum...',
    'Evleri hesaplıyorum...',
    'Yükselen burcunu arıyorum...',
    'Kozmik haritanı çiziyorum...',
    'Yorumunu yazıyorum...',
  ];

  // Cache key
  static const String _cacheKeyMyChart = 'myBirthChartData';
  static const String _cacheKeyMyChartInterpretation = 'myBirthChartInterpretation';

  // Turkish cities for autocomplete
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
    'Mersin', 'Muğla', 'Muş', 'Nevşehir', 'Niğde', 'Ordu',
    'Osmaniye', 'Rize', 'Sakarya', 'Samsun', 'Siirt', 'Sinop',
    'Sivas', 'Şanlıurfa', 'Şırnak', 'Tekirdağ', 'Tokat', 'Trabzon',
    'Tunceli', 'Uşak', 'Van', 'Yalova', 'Yozgat', 'Zonguldak',
  ];

  // Planet colors for UI
  static const _planetColors = {
    'Güneş': [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    'Ay': [Color(0xFFBFDBFE), Color(0xFF93C5FD)],
    'Merkür': [Color(0xFF34D399), Color(0xFF10B981)],
    'Venüs': [Color(0xFFF472B6), Color(0xFFBE185D)],
    'Mars': [Color(0xFFFB7185), Color(0xFFE11D48)],
    'Jüpiter': [Color(0xFFA78BFA), Color(0xFF7C3AED)],
    'Satürn': [Color(0xFF9CA3AF), Color(0xFF6B7280)],
    'Uranüs': [Color(0xFF67E8F9), Color(0xFF06B6D4)],
    'Neptün': [Color(0xFF818CF8), Color(0xFF6366F1)],
    'Plüton': [Color(0xFFC084FC), Color(0xFF9333EA)],
  };

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _adService.loadRewardedAd();
    _tryLoadCachedChart();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasPrefilledProfileData) return;

    final profile = Provider.of<AuthProvider>(context).userProfile;
    if (profile == null) return;

    if (profile.birthDate.year > 1900) {
      _selectedDate = profile.birthDate;
      _isBirthDateLocked = true;
    }

    if (profile.birthTime.trim().isNotEmpty) {
      final parts = profile.birthTime.trim().split(':');
      if (parts.length == 2) {
        _selectedTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 12,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    if (profile.birthPlace.trim().isNotEmpty) {
      _cityController.text = profile.birthPlace.trim();
    }

    _hasPrefilledProfileData = true;

    // Profilde tam doğum bilgisi varsa ve cache yoksa otomatik hesapla
    final hasBirthData = profile.birthDate.year > 1900 &&
        profile.birthTime.trim().isNotEmpty &&
        profile.birthPlace.trim().isNotEmpty;
    if (hasBirthData && !_showChart && !_isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_showChart && !_isLoading) _autoCalculateChart();
      });
    }
  }

  /// Profil verileriyle otomatik hesaplama başlat (form skip)
  Future<void> _autoCalculateChart() async {
    if (_selectedDate == null || _selectedTime == null || _cityController.text.isEmpty) return;
    if (_showChart || _isLoading) return; // zaten yüklendi veya yükleniyor

    setState(() {
      _isLoading = true;
      _error = null;
      _loadingMessageIndex = 0;
    });

    _cycleLoadingMessages();

    try {
      final birthTimeStr =
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

      await AstronomyService.initialize();
      final chartData = await AstronomyService.calculateBirthChart(
        birthDate: _selectedDate!,
        birthTime: birthTimeStr,
        birthPlace: _cityController.text,
      );

      final planets = List<Map<String, dynamic>>.from(
        (chartData['planets'] as List).map((p) => Map<String, dynamic>.from(p as Map)),
      );
      final ascendant = Map<String, dynamic>.from(chartData['ascendant'] as Map);

      final birthDateStr = DateFormat('dd MMMM yyyy', 'tr_TR').format(_selectedDate!);
      final interpretation = await _geminiService.generateBirthChartInterpretation(
        planets: planets,
        ascendant: ascendant,
        birthDateStr: birthDateStr,
        birthTimeStr: birthTimeStr,
        birthPlace: _cityController.text,
      );

      if (!mounted) return;

      setState(() {
        _planets = planets;
        _ascendant = ascendant;
        _interpretation = interpretation;
        _showChart = true;
        _isLoading = false;
      });

      await _activityLog.logBirthChart(isOwnChart: true);

      await _storageService.saveString(_cacheKeyMyChart, jsonEncode(chartData));
      await _storageService.saveString(_cacheKeyMyChartInterpretation, interpretation);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Doğum haritası hesaplanırken bir hata oluştu. Lütfen tekrar deneyin.';
          _isLoading = false;
        });
      }
      debugPrint('❌ Auto birth chart calculation error: $e');
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  /// Try to load cached birth chart from SharedPreferences
  Future<void> _tryLoadCachedChart() async {
    if (_isOtherPersonMode) return;

    final cachedJson = await _storageService.getString(_cacheKeyMyChart);
    final cachedInterpretation = await _storageService.getString(_cacheKeyMyChartInterpretation);

    if (cachedJson != null && cachedInterpretation != null) {
      try {
        final data = jsonDecode(cachedJson);
        if (mounted) {
          setState(() {
            _planets = List<Map<String, dynamic>>.from(
              (data['planets'] as List).map((p) => Map<String, dynamic>.from(p)),
            );
            _ascendant = Map<String, dynamic>.from(data['ascendant']);
            _interpretation = cachedInterpretation;
            _showChart = true;
          });
        }
      } catch (e) {
        debugPrint('⚠️ Failed to parse cached birth chart: $e');
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _calculateChart() async {
    if (!(_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null)) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    // For other person mode, require premium or ad
    if (_isOtherPersonMode) {
      if (!authProvider.isPremium && !_chartUnlockedByAd) {
        _showOtherPersonGateDialog();
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _loadingMessageIndex = 0;
    });

    // Start cycling loading messages
    _cycleLoadingMessages();

    try {
      final birthTimeStr =
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

      // Step 1: Calculate planet positions with Swiss Ephemeris
      await AstronomyService.initialize();
      final chartData = await AstronomyService.calculateBirthChart(
        birthDate: _selectedDate!,
        birthTime: birthTimeStr,
        birthPlace: _cityController.text,
      );

      final planets = List<Map<String, dynamic>>.from(
        (chartData['planets'] as List).map((p) => Map<String, dynamic>.from(p as Map)),
      );
      final ascendant = Map<String, dynamic>.from(chartData['ascendant'] as Map);

      // Step 2: Generate interpretation with Gemini
      final birthDateStr = DateFormat('dd MMMM yyyy', 'tr_TR').format(_selectedDate!);
      final interpretation = await _geminiService.generateBirthChartInterpretation(
        planets: planets,
        ascendant: ascendant,
        birthDateStr: birthDateStr,
        birthTimeStr: birthTimeStr,
        birthPlace: _cityController.text,
      );

      if (!mounted) return;

      setState(() {
        _planets = planets;
        _ascendant = ascendant;
        _interpretation = interpretation;
        _showChart = true;
        _isLoading = false;
      });

      await _activityLog.logBirthChart(isOwnChart: !_isOtherPersonMode);

      // Cache if it's user's own chart
      if (!_isOtherPersonMode) {
        await _storageService.saveString(
          _cacheKeyMyChart,
          jsonEncode(chartData),
        );
        await _storageService.saveString(
          _cacheKeyMyChartInterpretation,
          interpretation,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Doğum haritası hesaplanırken bir hata oluştu. Lütfen tekrar deneyin.';
          _isLoading = false;
        });
      }
    }
  }

  void _cycleLoadingMessages() {
    Future.delayed(const Duration(seconds: 2), () {
      if (_isLoading && mounted) {
        setState(() {
          _loadingMessageIndex =
              (_loadingMessageIndex + 1) % _loadingMessages.length;
        });
        _cycleLoadingMessages();
      }
    });
  }

  void _showOtherPersonGateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withOpacity(0.3),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Center(
                child: Text('🪐', style: TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Başkasının Haritası',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Başka birinin doğum haritasını görmek için reklam izle veya premium\'a geç!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final success = await _adService.showRewardedAd(
                    placement: 'birth_chart_other_person',
                  );
                  if (success && mounted) {
                    setState(() => _chartUnlockedByAd = true);
                    _calculateChart();
                  }
                },
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Reklam İzle & Haritayı Gör'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF7C3AED),
                  side: const BorderSide(color: Color(0xFF7C3AED)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    CosmicBottomSheetRoute(page: const PremiumScreen()),
                  );
                },
                icon: const Icon(Icons.diamond, size: 18),
                label: const Text('Premium\'a Geç'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                : [const Color(0xFFDDD6FE), const Color(0xFFFAE8FF), const Color(0xFFFECDD3)],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? _buildLoadingOverlay()
              : Column(
                  children: [
                    _buildAppBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: _showChart
                            ? _buildChartView()
                            : _buildFormView(),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF6B21A8)),
            onPressed: () {
              if (_showChart && _isOtherPersonMode) {
                setState(() {
                  _showChart = false;
                  _planets = [];
                  _ascendant = null;
                  _interpretation = null;
                });
              } else if (_showChart) {
                // For own chart, go back to form but keep cache
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildRotatingCircles(),
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF7C3AED)],
            ).createShader(bounds),
            child: const Text(
              'Doğum Haritası',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kozmik kimliğini keşfet',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF7C3AED),
              fontWeight: FontWeight.w600,
            ),
          ),

          // Mode toggle
          const SizedBox(height: 24),
          _buildModeToggle(isDark),

          const SizedBox(height: 24),

          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (!_isOtherPersonMode) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.cardDark : Colors.white).withOpacity(0.8),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Doğum Haritası Nedir?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimary : const Color(0xFF7C3AED),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Doğduğun an gökyüzündeki gezegenlerin konumlarını gösteren haritadır. '
                    'Swiss Ephemeris ile astronomik olarak hassas hesaplama yapılır.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textSecondary : Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          _buildDateField(),
          const SizedBox(height: 16),
          _buildTimeField(),
          const SizedBox(height: 16),
          _buildCityField(isDark),
          const SizedBox(height: 24),
          _buildSubmitButton(),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFDDD6FE).withOpacity(isDark ? 0.2 : 1.0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF7C3AED), width: 2),
            ),
            child: Text(
              'Doğum saatinizi bilmiyorsanız, 12:00 yazabilirsiniz',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSecondary : const Color(0xFF6B21A8),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: (isDark ? AppColors.cardDark : Colors.white).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isOtherPersonMode = false;
                  _chartUnlockedByAd = false;
                  _showChart = false;
                  _planets = [];
                  _ascendant = null;
                  _interpretation = null;
                });
                _tryLoadCachedChart();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: !_isOtherPersonMode
                      ? const Color(0xFF7C3AED).withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Benim Haritam',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: !_isOtherPersonMode
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: !_isOtherPersonMode
                        ? const Color(0xFF7C3AED)
                        : (isDark ? AppColors.textSecondary : AppColors.textMuted),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isOtherPersonMode = true;
                  _chartUnlockedByAd = false;
                  _showChart = false;
                  _planets = [];
                  _ascendant = null;
                  _interpretation = null;
                  _selectedDate = null;
                  _selectedTime = null;
                  _cityController.clear();
                  _isBirthDateLocked = false;
                });
              },
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _isOtherPersonMode
                          ? const Color(0xFF7C3AED).withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Başkasının Haritası',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: _isOtherPersonMode
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _isOtherPersonMode
                            ? const Color(0xFF7C3AED)
                            : (isDark ? AppColors.textSecondary : AppColors.textMuted),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final authProvider = context.read<AuthProvider>();
    final showAdBadge = _isOtherPersonMode &&
        !authProvider.isPremium &&
        !_chartUnlockedByAd;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _calculateChart,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C3AED),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome),
            const SizedBox(width: 8),
            const Text(
              'Haritayı Hesapla',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (showAdBadge) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_circle_outline, color: Colors.white, size: 14),
                    SizedBox(width: 3),
                    Text('AD',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRotatingCircles() {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFA78BFA), width: 2),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: 20.seconds),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF7C3AED), width: 2),
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF6366F1), width: 2),
            ),
          ),
          const Text('✨', style: TextStyle(fontSize: 32)),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _isBirthDateLocked ? null : _selectDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA78BFA), width: 2),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF7C3AED)),
            const SizedBox(width: 12),
            Text(
              _selectedDate == null
                  ? 'Doğum Tarihiniz'
                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              style: TextStyle(
                fontSize: 16,
                color: _selectedDate == null
                    ? const Color(0xFFA78BFA)
                    : const Color(0xFF7C3AED),
              ),
            ),
            if (_isBirthDateLocked) ...[
              const Spacer(),
              Icon(Icons.lock, color: Colors.grey[400], size: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA78BFA), width: 2),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Color(0xFF7C3AED)),
            const SizedBox(width: 12),
            Text(
              _selectedTime == null
                  ? 'Doğum Saatiniz'
                  : '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 16,
                color: _selectedTime == null
                    ? const Color(0xFFA78BFA)
                    : const Color(0xFF7C3AED),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityField(bool isDark) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return _turkishCities.where((String city) {
          return city.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        _cityController.text = selection;
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController fieldTextEditingController,
        FocusNode fieldFocusNode,
        VoidCallback onFieldSubmitted,
      ) {
        fieldTextEditingController.text = _cityController.text;
        fieldTextEditingController.addListener(() {
          _cityController.text = fieldTextEditingController.text;
        });

        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFA78BFA), width: 2),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Icon(Icons.location_on, color: Color(0xFF7C3AED)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Doğduğun şehir',
                    hintStyle: TextStyle(color: Color(0xFFA78BFA)),
                  ),
                  style: const TextStyle(fontSize: 16, color: Color(0xFF7C3AED)),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Lütfen şehir girin' : null,
                ),
              ),
            ],
          ),
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
              width: MediaQuery.of(context).size.width - 40,
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_city,
                              size: 16, color: Color(0xFF7C3AED)),
                          const SizedBox(width: 12),
                          Text(option),
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
    );
  }

  Widget _buildChartView() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          _isOtherPersonMode ? 'Doğum Haritası' : 'Senin Doğum Haritam',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7C3AED),
          ),
        ),
        if (_selectedDate != null && _selectedTime != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} - '
              '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')} - '
              '${_cityController.text}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF9333EA)),
            ),
          ),

        // Ascendant badge
        if (_ascendant != null) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _ascendant!['signSymbol'] ?? '',
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Yükselen Burç',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                    Text(
                      '${_ascendant!['sign']} ${_ascendant!['degree']}°',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn().scale(
                begin: const Offset(0.8, 0.8),
                duration: 600.ms,
                curve: Curves.elasticOut,
              ),
        ],

        const SizedBox(height: 32),
        _buildZodiacWheel(),
        const SizedBox(height: 32),

        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Gezegen Konumların',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7C3AED),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Planet cards
        ..._planets.asMap().entries.map((entry) {
          final index = entry.key;
          final planet = entry.value;
          final name = planet['name'] as String;
          final colors = _planetColors[name] ??
              [const Color(0xFFA78BFA), const Color(0xFF7C3AED)];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colors[0].withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${planet['house']}. Ev  •  ${planet['degree']}°',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${planet['signSymbol']} ${planet['sign']}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
                .animate(delay: Duration(milliseconds: index * 80))
                .fadeIn()
                .slideX(begin: -0.2, end: 0),
          );
        }),

        // Interpretation
        if (_interpretation != null) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Astro Dozi\'nin Yorumu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _interpretation!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 800.ms)
              .slideY(begin: 0.1, end: 0),
        ],

        // Methodology note
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFDDD6FE).withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Color(0xFF7C3AED)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Gezegen pozisyonları Swiss Ephemeris ile astronomik olarak hesaplandı. Tropical Zodyak + Placidus ev sistemi.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF6B21A8)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        if (_isOtherPersonMode)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _showChart = false;
                  _planets = [];
                  _ascendant = null;
                  _interpretation = null;
                  _selectedDate = null;
                  _selectedTime = null;
                  _cityController.clear();
                });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF7C3AED)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Başka Birinin Haritasını Oluştur',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildZodiacWheel() {
    final zodiacSigns = [
      '♈', '♉', '♊', '♋', '♌', '♍',
      '♎', '♏', '♐', '♑', '♒', '♓',
    ];

    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFA78BFA), width: 4),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: 60.seconds),
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF9A8D4), width: 4),
            ),
          ),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF818CF8), width: 4),
              gradient: const LinearGradient(
                colors: [Color(0xFFF5F3FF), Color(0xFFFCE7F3)],
              ),
            ),
          ),
          if (_ascendant != null)
            Text(
              _ascendant!['signSymbol'] ?? '✨',
              style: const TextStyle(fontSize: 48),
            )
          else
            const Text('✨', style: TextStyle(fontSize: 48)),
          ...zodiacSigns.asMap().entries.map((entry) {
            final index = entry.key;
            final sign = entry.value;
            final angle = (index * 30) - 90;
            final radian = angle * math.pi / 180;
            final x = math.cos(radian) * 120;
            final y = math.sin(radian) * 120;
            return Positioned(
              left: 140 + x - 12,
              top: 140 + y - 12,
              child: Text(
                sign,
                style: const TextStyle(fontSize: 24, color: Color(0xFF7C3AED)),
              ),
            );
          }),
        ],
      ),
    ).animate().scale(
        begin: const Offset(0, 0),
        duration: 1.seconds,
        curve: Curves.elasticOut);
  }

  Widget _buildLoadingOverlay() {
    return AnimatedBuilder(
      animation: _spinController,
      builder: (context, child) {
        final zodiacSymbols = [
          '♈', '♉', '♊', '♋', '♌', '♍',
          '♎', '♏', '♐', '♑', '♒', '♓',
        ];

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 250,
                height: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ...List.generate(12, (index) {
                      final angle =
                          (index * 30.0 + _spinController.value * 360) *
                              math.pi /
                              180;
                      const radius = 100.0;
                      return Positioned(
                        left: 125 + radius * math.cos(angle) - 14,
                        top: 125 + radius * math.sin(angle) - 14,
                        child: Text(
                          zodiacSymbols[index],
                          style: TextStyle(
                            fontSize: 28,
                            color: const Color(0xFF7C3AED).withOpacity(
                              0.4 +
                                  0.6 *
                                      ((math.sin(angle +
                                                  _spinController.value *
                                                      math.pi *
                                                      2) +
                                              1) /
                                          2),
                            ),
                          ),
                        ),
                      );
                    }),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF7C3AED).withOpacity(0.6),
                            const Color(0xFF7C3AED).withOpacity(0.0),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Text('🪐', style: TextStyle(fontSize: 36)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _loadingMessages[_loadingMessageIndex],
                  key: ValueKey(_loadingMessageIndex),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7C3AED),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF7C3AED).withOpacity(
                        0.3 +
                            0.7 *
                                ((math.sin(_spinController.value *
                                            math.pi *
                                            2 +
                                        index * 1.0) +
                                    1) /
                                2),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
