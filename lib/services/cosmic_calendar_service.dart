import 'package:flutter/foundation.dart';
import '../models/astro_event.dart';
import '../models/beauty_day.dart';
import '../constants/astro_data.dart';
import 'astronomy_service.dart';

/// Kozmik Takvim servisi — ay fazı, güzellik puanları ve astro olayları
class CosmicCalendarService {
  static final CosmicCalendarService _instance = CosmicCalendarService._internal();
  factory CosmicCalendarService() => _instance;
  CosmicCalendarService._internal();

  // Cache
  final Map<String, List<BeautyDay>> _beautyCache = {};
  final Map<String, Map<int, MoonPhase>> _moonPhaseCache = {};

  /// Belirli bir ay için astrolojik olayları getir
  List<AstroEvent> getEventsForMonth(int year, int month) {
    return AstroData.getEventsForMonth(year, month);
  }

  /// Belirli bir gün için astrolojik olayları getir
  List<AstroEvent> getEventsForDay(DateTime date) {
    return AstroData.getEventsForDay(date);
  }

  /// Bir ayın tüm günleri için ay fazlarını hesapla
  Future<Map<int, MoonPhase>> getMoonPhasesForMonth(int year, int month) async {
    final cacheKey = '$year-$month';
    if (_moonPhaseCache.containsKey(cacheKey)) {
      return _moonPhaseCache[cacheKey]!;
    }

    try {
      await AstronomyService.initialize();
    } catch (e) {
      debugPrint('Sweph init hatası: $e');
    }

    final daysInMonth = DateTime(year, month + 1, 0).day;
    final phases = <int, MoonPhase>{};

    for (int day = 1; day <= daysInMonth; day++) {
      try {
        phases[day] = await AstronomyService.getMoonPhase(
          DateTime(year, month, day, 12), // Öğlen saati
        );
      } catch (e) {
        phases[day] = MoonPhase.firstQuarter; // Fallback
      }
    }

    _moonPhaseCache[cacheKey] = phases;
    return phases;
  }

  /// Bir ayın tüm günleri için güzellik puanlarını hesapla
  Future<List<BeautyDay>> getBeautyMonth(int year, int month) async {
    final cacheKey = '$year-$month';
    if (_beautyCache.containsKey(cacheKey)) {
      return _beautyCache[cacheKey]!;
    }

    try {
      await AstronomyService.initialize();
    } catch (e) {
      debugPrint('Sweph init hatası: $e');
    }

    final daysInMonth = DateTime(year, month + 1, 0).day;
    final days = <BeautyDay>[];

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day, 12);

      MoonPhase moonPhase;
      String moonSign;

      try {
        moonPhase = await AstronomyService.getMoonPhase(date);
        moonSign = await AstronomyService.getMoonSign(date);
      } catch (e) {
        moonPhase = MoonPhase.firstQuarter;
        moonSign = 'Koç';
      }

      final ratings = _calculateBeautyRatings(moonPhase, moonSign);

      days.add(BeautyDay(
        date: date,
        moonPhase: moonPhase,
        moonSign: moonSign,
        hairCut: ratings['hairCut']!,
        hairDye: ratings['hairDye']!,
        skinCare: ratings['skinCare']!,
        nailCare: ratings['nailCare']!,
      ));
    }

    _beautyCache[cacheKey] = days;
    return days;
  }

  /// Belirli bir gün için güzellik puanını hesapla
  Future<BeautyDay> getBeautyDay(DateTime date) async {
    final month = await getBeautyMonth(date.year, date.month);
    return month.firstWhere(
      (d) => d.date.day == date.day,
      orElse: () => BeautyDay(
        date: date,
        moonPhase: MoonPhase.firstQuarter,
        moonSign: 'Koç',
        hairCut: BeautyRating.neutral,
        hairDye: BeautyRating.neutral,
        skinCare: BeautyRating.neutral,
        nailCare: BeautyRating.neutral,
      ),
    );
  }

  /// Bu haftanın en iyi güzellik gününü bul
  Future<BeautyDay?> getBestDayThisWeek() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final month = await getBeautyMonth(now.year, now.month);

    BeautyDay? bestDay;
    int bestScore = -1;

    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      if (day.month != now.month) continue;

      final beautyDay = month.firstWhere(
        (d) => d.date.day == day.day,
        orElse: () => BeautyDay(
          date: day,
          moonPhase: MoonPhase.firstQuarter,
          moonSign: 'Koç',
          hairCut: BeautyRating.neutral,
          hairDye: BeautyRating.neutral,
          skinCare: BeautyRating.neutral,
          nailCare: BeautyRating.neutral,
        ),
      );

      final score = _ratingScore(beautyDay.hairCut) +
          _ratingScore(beautyDay.hairDye) +
          _ratingScore(beautyDay.skinCare) +
          _ratingScore(beautyDay.nailCare);

      if (score > bestScore) {
        bestScore = score;
        bestDay = beautyDay;
      }
    }

    return bestDay;
  }

  int _ratingScore(BeautyRating r) {
    switch (r) {
      case BeautyRating.great: return 3;
      case BeautyRating.good: return 2;
      case BeautyRating.neutral: return 1;
      case BeautyRating.avoid: return 0;
    }
  }

  /// Ay fazı + ay burcu kombinasyonuna göre güzellik puanlarını hesapla
  Map<String, BeautyRating> _calculateBeautyRatings(
    MoonPhase phase,
    String moonSign,
  ) {
    // Temel puanlar (ay fazına göre)
    var hairCut = _baseHairCutRating(phase);
    var hairDye = _baseHairDyeRating(phase);
    var skinCare = _baseSkinCareRating(phase);
    var nailCare = _baseNailCareRating(phase);

    // Ay burcu modifiyerleri
    final earthSigns = ['Boğa', 'Başak', 'Oğlak'];
    final waterSigns = ['Yengeç', 'Balık', 'Akrep'];
    final fireSigns = ['Koç', 'Aslan', 'Yay'];

    if (earthSigns.contains(moonSign)) {
      // Toprak burçları: saç aktiviteleri +1
      hairCut = _upgradeRating(hairCut);
      hairDye = _upgradeRating(hairDye);
    }

    if (moonSign == 'Aslan') {
      // Aslan: boyama için özellikle iyi
      hairDye = _upgradeRating(hairDye);
    }

    if (waterSigns.contains(moonSign)) {
      // Su burçları: cilt bakımı +1
      skinCare = _upgradeRating(skinCare);
    }

    if (fireSigns.contains(moonSign)) {
      // Ateş burçları: cesur değişiklikler için iyi
      if (hairCut == BeautyRating.neutral) hairCut = BeautyRating.good;
    }

    return {
      'hairCut': hairCut,
      'hairDye': hairDye,
      'skinCare': skinCare,
      'nailCare': nailCare,
    };
  }

  BeautyRating _upgradeRating(BeautyRating current) {
    switch (current) {
      case BeautyRating.avoid: return BeautyRating.neutral;
      case BeautyRating.neutral: return BeautyRating.good;
      case BeautyRating.good: return BeautyRating.great;
      case BeautyRating.great: return BeautyRating.great;
    }
  }

  // Temel puanlama tabloları
  BeautyRating _baseHairCutRating(MoonPhase phase) {
    switch (phase) {
      case MoonPhase.newMoon: return BeautyRating.avoid;
      case MoonPhase.waxingCrescent: return BeautyRating.good;
      case MoonPhase.firstQuarter: return BeautyRating.great;
      case MoonPhase.waxingGibbous: return BeautyRating.great;
      case MoonPhase.fullMoon: return BeautyRating.great;
      case MoonPhase.waningGibbous: return BeautyRating.good;
      case MoonPhase.lastQuarter: return BeautyRating.neutral;
      case MoonPhase.waningCrescent: return BeautyRating.avoid;
    }
  }

  BeautyRating _baseHairDyeRating(MoonPhase phase) {
    switch (phase) {
      case MoonPhase.newMoon: return BeautyRating.avoid;
      case MoonPhase.waxingCrescent: return BeautyRating.good;
      case MoonPhase.firstQuarter: return BeautyRating.great;
      case MoonPhase.waxingGibbous: return BeautyRating.great;
      case MoonPhase.fullMoon: return BeautyRating.good;
      case MoonPhase.waningGibbous: return BeautyRating.neutral;
      case MoonPhase.lastQuarter: return BeautyRating.neutral;
      case MoonPhase.waningCrescent: return BeautyRating.avoid;
    }
  }

  BeautyRating _baseSkinCareRating(MoonPhase phase) {
    switch (phase) {
      case MoonPhase.newMoon: return BeautyRating.great;
      case MoonPhase.waxingCrescent: return BeautyRating.good;
      case MoonPhase.firstQuarter: return BeautyRating.good;
      case MoonPhase.waxingGibbous: return BeautyRating.neutral;
      case MoonPhase.fullMoon: return BeautyRating.great;
      case MoonPhase.waningGibbous: return BeautyRating.good;
      case MoonPhase.lastQuarter: return BeautyRating.great;
      case MoonPhase.waningCrescent: return BeautyRating.good;
    }
  }

  BeautyRating _baseNailCareRating(MoonPhase phase) {
    switch (phase) {
      case MoonPhase.newMoon: return BeautyRating.avoid;
      case MoonPhase.waxingCrescent: return BeautyRating.good;
      case MoonPhase.firstQuarter: return BeautyRating.great;
      case MoonPhase.waxingGibbous: return BeautyRating.good;
      case MoonPhase.fullMoon: return BeautyRating.great;
      case MoonPhase.waningGibbous: return BeautyRating.good;
      case MoonPhase.lastQuarter: return BeautyRating.neutral;
      case MoonPhase.waningCrescent: return BeautyRating.avoid;
    }
  }

  /// Cache'i temizle
  void clearCache() {
    _beautyCache.clear();
    _moonPhaseCache.clear();
  }
}
