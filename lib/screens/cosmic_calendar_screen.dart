import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../models/astro_event.dart';
import '../models/beauty_day.dart';
import '../providers/auth_provider.dart';
import '../services/cosmic_calendar_service.dart';
import '../services/gemini_service.dart';
import '../services/share_service.dart';
import '../services/usage_limit_service.dart';
import '../widgets/moon_phase_widget.dart';
import '../widgets/beauty_rating_row.dart';
import '../widgets/share_cards/beauty_share_card.dart';
import '../widgets/limit_reached_dialog.dart';
import '../screens/premium_screen.dart';

class CosmicCalendarScreen extends StatefulWidget {
  const CosmicCalendarScreen({super.key});

  @override
  State<CosmicCalendarScreen> createState() => _CosmicCalendarScreenState();
}

class _CosmicCalendarScreenState extends State<CosmicCalendarScreen> {
  final CosmicCalendarService _calendarService = CosmicCalendarService();
  final GeminiService _geminiService = GeminiService();
  final UsageLimitService _usageLimitService = UsageLimitService();

  int _selectedTab = 0; // 0 = Astroloji, 1 = Güzellik
  late DateTime _currentMonth;
  int? _selectedDay;

  // Veri
  List<AstroEvent> _monthEvents = [];
  List<BeautyDay> _beautyDays = [];
  Map<int, MoonPhase> _moonPhases = {};
  bool _isLoading = true;
  String? _dailyTip;
  bool _isLoadingTip = false;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _selectedDay = DateTime.now().day;
    _loadMonthData();
  }

  Future<void> _loadMonthData() async {
    setState(() => _isLoading = true);

    try {
      _monthEvents = _calendarService.getEventsForMonth(
        _currentMonth.year,
        _currentMonth.month,
      );

      final futures = await Future.wait([
        _calendarService.getBeautyMonth(_currentMonth.year, _currentMonth.month),
        _calendarService.getMoonPhasesForMonth(_currentMonth.year, _currentMonth.month),
      ]);

      _beautyDays = futures[0] as List<BeautyDay>;
      _moonPhases = futures[1] as Map<int, MoonPhase>;
    } catch (e) {
      debugPrint('Calendar data error: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (_selectedDay != null) _loadDailyTip();
    }
  }

  Future<void> _loadDailyTip() async {
    if (_selectedDay == null) return;
    final authProvider = context.read<AuthProvider>();
    final zodiac = authProvider.selectedZodiac;
    if (zodiac == null) return;

    setState(() => _isLoadingTip = true);

    try {
      final date = DateTime(_currentMonth.year, _currentMonth.month, _selectedDay!);

      if (_selectedTab == 0) {
        // Astroloji ipucu
        final dayEvents = _calendarService.getEventsForDay(date);
        final eventStr = dayEvents.map((e) => e.title).join(', ');
        _dailyTip = await _geminiService.fetchDailyAstroTip(
          zodiac, date,
          events: eventStr.isNotEmpty ? eventStr : null,
        );
      } else {
        // Güzellik tavsiyesi
        if (_selectedDay! <= _beautyDays.length) {
          final bd = _beautyDays[_selectedDay! - 1];
          _dailyTip = await _geminiService.fetchBeautyTip(
            zodiac, date, bd.moonPhase.turkishName, bd.moonSign,
          );
        }
      }
    } catch (e) {
      _dailyTip = null;
    }

    if (mounted) setState(() => _isLoadingTip = false);
  }

  void _changeMonth(int delta) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + delta);
      _selectedDay = null;
      _dailyTip = null;
    });
    _loadMonthData();
  }

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat('MMMM yyyy', 'tr_TR').format(_currentMonth);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE4EC), Color(0xFFFFCCE2), Color(0xFFFFB6C1)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Kozmik Takvim',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Tab kontrolü
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _buildTab('🔮 Astroloji', 0),
                      _buildTab('💅 Güzellik', 1),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Ay navigasyonu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: AppColors.textDark, size: 32),
                      onPressed: () => _changeMonth(-1),
                    ),
                    Text(
                      monthName.substring(0, 1).toUpperCase() + monthName.substring(1),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: AppColors.textDark, size: 32),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Takvim grid
              _isLoading
                  ? const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.primaryPink),
                      ),
                    )
                  : Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: Column(
                          children: [
                            if (_selectedTab == 0) _buildMonthlySummary(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  _buildCalendarGrid(),
                                  const SizedBox(height: 16),
                                  if (_selectedDay != null) _buildDayDetail(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
            _dailyTip = null;
          });
          if (_selectedDay != null) _loadDailyTip();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.cosmicGradient : null,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  /// Ay icin onem sirasina gore olay onceliklendirmesi
  int _eventPriority(AstroEvent event) {
    switch (event.type) {
      case AstroEventType.solarEclipse:
      case AstroEventType.lunarEclipse:
        return 0;
      case AstroEventType.mercuryRetrograde:
      case AstroEventType.venusRetrograde:
      case AstroEventType.marsRetrograde:
      case AstroEventType.jupiterRetrograde:
      case AstroEventType.saturnRetrograde:
        return 1;
      case AstroEventType.fullMoon:
      case AstroEventType.newMoon:
        return 2;
      case AstroEventType.zodiacSeasonChange:
        return 3;
    }
  }

  /// Ayin enerjisini belirle
  String _getMonthEnergyLabel(List<AstroEvent> events) {
    final hasEclipse = events.any((e) =>
        e.type == AstroEventType.solarEclipse ||
        e.type == AstroEventType.lunarEclipse);
    final retroCount = events.where((e) =>
        e.type == AstroEventType.mercuryRetrograde ||
        e.type == AstroEventType.venusRetrograde ||
        e.type == AstroEventType.marsRetrograde ||
        e.type == AstroEventType.jupiterRetrograde ||
        e.type == AstroEventType.saturnRetrograde).length;

    if (hasEclipse && retroCount >= 2) return 'Yoğun Dönüşüm';
    if (hasEclipse) return 'Güçlü Değişim';
    if (retroCount >= 2) return 'İçsel Sorgulama';
    if (retroCount == 1) return 'Yavaşlama & Gözden Geçirme';
    return 'Akıcı & Dengeli';
  }

  /// Ayin enerjisine göre emoji
  String _getMonthEnergyEmoji(String energyLabel) {
    switch (energyLabel) {
      case 'Yoğun Dönüşüm':
        return '🔥';
      case 'Güçlü Değişim':
        return '⚡';
      case 'İçsel Sorgulama':
        return '🔮';
      case 'Yavaşlama & Gözden Geçirme':
        return '🌀';
      default:
        return '🌿';
    }
  }

  Widget _buildMonthlySummary() {
    final monthNameOnly = DateFormat('MMMM', 'tr_TR').format(_currentMonth);
    final capitalizedMonth =
        monthNameOnly.substring(0, 1).toUpperCase() + monthNameOnly.substring(1);

    final eventCount = _monthEvents.length;

    // En onemli 3 olayı sec (tutulma > retro > dolunay/yeniay > mevsim)
    final sortedEvents = List<AstroEvent>.from(_monthEvents)
      ..sort((a, b) {
        final priorityCompare = _eventPriority(a).compareTo(_eventPriority(b));
        if (priorityCompare != 0) return priorityCompare;
        return a.date.compareTo(b.date);
      });

    // Ayni tür retrolari tekrarlamamak icin unique basliklar al
    final seen = <String>{};
    final keyEvents = <AstroEvent>[];
    for (final event in sortedEvents) {
      final key = '${event.title}_${event.date.day}';
      if (!seen.contains(key) && keyEvents.length < 3) {
        seen.add(key);
        keyEvents.add(event);
      }
    }

    final energyLabel = _getMonthEnergyLabel(_monthEvents);
    final energyEmoji = _getMonthEnergyEmoji(energyLabel);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baslik
          Row(
            children: [
              const Text('📅', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(
                '$capitalizedMonth Özeti',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Olay sayisi
          Text(
            '$eventCount astrolojik olay',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),

          // Onemli olaylar
          ...keyEvents.map((event) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Text(event.emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${event.title} - ${DateFormat('d MMM', 'tr_TR').format(event.date)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 12),

          // Ayin enerjisi
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(energyEmoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ayın Enerjisi',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      energyLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05, end: 0);
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;
    final today = DateTime.now();

    // Gün isimleri
    const dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Gün başlıkları
          Row(
            children: dayNames
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),

          // Gün hücreleri
          ...List.generate(6, (week) {
            return Row(
              children: List.generate(7, (weekday) {
                final dayIndex = week * 7 + weekday - (firstWeekday - 1);
                if (dayIndex < 1 || dayIndex > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 56));
                }

                final isToday = today.year == _currentMonth.year &&
                    today.month == _currentMonth.month &&
                    today.day == dayIndex;
                final isSelected = _selectedDay == dayIndex;
                final date = DateTime(_currentMonth.year, _currentMonth.month, dayIndex);

                return Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final authProvider = context.read<AuthProvider>();
                      final today = DateTime.now();
                      final daysFromToday = date.difference(DateTime(today.year, today.month, today.day)).inDays;
                      
                      // Premium değilse ve bugün+3 günden sonrasıysa paywall göster
                      if (!authProvider.isPremium) {
                        final canView = await _usageLimitService.canViewCalendarDay(daysFromToday);
                        if (!canView) {
                          if (mounted) {
                            LimitReachedDialog.showCalendarLimit(context);
                          }
                          return;
                        }
                      }
                      
                      setState(() => _selectedDay = dayIndex);
                      _loadDailyTip();
                    },
                    child: Container(
                      height: 56,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryPink.withOpacity(0.15)
                            : isToday
                                ? AppColors.primaryPink.withOpacity(0.05)
                                : null,
                        borderRadius: BorderRadius.circular(10),
                        border: isToday
                            ? Border.all(color: AppColors.primaryPink, width: 1.5)
                            : isSelected
                                ? Border.all(color: AppColors.primaryPink.withOpacity(0.5))
                                : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayIndex',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          _buildDayIndicator(date, dayIndex),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildDayIndicator(DateTime date, int day) {
    if (_selectedTab == 0) {
      // Astroloji: olayları nokta olarak göster
      final events = _calendarService.getEventsForDay(date);
      if (events.isEmpty) {
        // Ay fazı emojisi küçük
        final phase = _moonPhases[day];
        if (phase == MoonPhase.fullMoon || phase == MoonPhase.newMoon) {
          return Text(
            phase == MoonPhase.fullMoon ? '🌕' : '🌑',
            style: const TextStyle(fontSize: 8),
          );
        }
        return const SizedBox(height: 8);
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: events.take(3).map((e) {
          return Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: e.color,
            ),
          );
        }).toList(),
      );
    } else {
      // Güzellik: genel puan rengi
      if (day <= _beautyDays.length) {
        final bd = _beautyDays[day - 1];
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bd.overallRating.color,
          ),
        );
      }
      return const SizedBox(height: 8);
    }
  }

  Widget _buildDayDetail() {
    if (_selectedDay == null) return const SizedBox.shrink();

    final date = DateTime(_currentMonth.year, _currentMonth.month, _selectedDay!);
    final dateStr = DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(date);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarih başlık
          Text(
            dateStr.substring(0, 1).toUpperCase() + dateStr.substring(1),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),

          // Ay fazı bilgisi
          if (_moonPhases.containsKey(_selectedDay)) ...[
            Row(
              children: [
                Text(
                  _moonPhases[_selectedDay!]!.emoji,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  _moonPhases[_selectedDay!]!.turkishName,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          if (_selectedTab == 0)
            _buildAstroDetail(date)
          else
            _buildBeautyDetail(),

          // AI ipucu
          if (_isLoadingTip) ...[
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryPink.withOpacity(0.5),
                ),
              ),
            ),
          ] else if (_dailyTip != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentPurple.withOpacity(0.08),
                    AppColors.primaryPink.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primaryPink.withOpacity(0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _selectedTab == 0 ? '✨' : '💡',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedTab == 0 ? 'Astro Dozi Diyor Ki...' : 'Güzellik Tavsiyesi',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _dailyTip!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textDark.withOpacity(0.7),
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildAstroDetail(DateTime date) {
    final events = _calendarService.getEventsForDay(date);

    if (events.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgLight.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Text('🌟', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Bugün büyük bir astrolojik olay yok. Sakin bir gün!',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textDark.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: events.map((event) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: event.color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: event.color.withOpacity(0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          event.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: event.color,
                          ),
                        ),
                        if (event.affectedSign != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: event.color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              event.affectedSign!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: event.color,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textDark.withOpacity(0.6),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBeautyDetail() {
    if (_selectedDay == null || _selectedDay! > _beautyDays.length) {
      return const SizedBox.shrink();
    }

    final bd = _beautyDays[_selectedDay! - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ay fazı görseli
        Center(
          child: Column(
            children: [
              MoonPhaseWidget(phase: bd.moonPhase, size: 60),
              const SizedBox(height: 8),
              Text(
                'Ay Burcu: ${bd.moonSign}',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textDark.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Güzellik puanları
        BeautyRatingRow(emoji: '✂️', label: 'Saç Kesimi', rating: bd.hairCut),
        BeautyRatingRow(emoji: '🎨', label: 'Saç Boyama', rating: bd.hairDye),
        BeautyRatingRow(emoji: '💆', label: 'Cilt Bakımı', rating: bd.skinCare),
        BeautyRatingRow(emoji: '💅', label: 'Tırnak Bakımı', rating: bd.nailCare),

        const SizedBox(height: 12),

        // Paylaş butonu
        Center(
          child: TextButton.icon(
            onPressed: () => _shareBeautyDay(bd),
            icon: const Icon(Icons.share, size: 18),
            label: const Text('Paylaş'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryPink,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _shareBeautyDay(BeautyDay bd) async {
    final authProvider = context.read<AuthProvider>();
    final zodiac = authProvider.selectedZodiac;

    await ShareService().shareCardWidget(
      context,
      BeautyShareCard(
        beautyDay: bd,
        zodiacSymbol: zodiac?.symbol,
        zodiacName: zodiac?.displayName,
      ),
    );
  }
}
