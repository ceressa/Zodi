import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';
import '../models/zodiac_sign.dart';
import '../models/daily_horoscope.dart';
import '../models/detailed_analysis.dart';
import '../models/compatibility_result.dart';
import '../models/weekly_horoscope.dart';
import '../models/monthly_horoscope.dart';
import '../models/rising_sign.dart';
import '../models/dream_interpretation.dart';

class HoroscopeProvider with ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final StorageService _storageService = StorageService();

  DailyHoroscope? _dailyHoroscope;
  DetailedAnalysis? _detailedAnalysis;
  CompatibilityResult? _compatibilityResult;
  WeeklyHoroscope? _weeklyHoroscope;
  MonthlyHoroscope? _monthlyHoroscope;
  RisingSignResult? _risingSignResult;
  DreamInterpretation? _dreamInterpretation;

  bool _isLoadingDaily = false;
  bool _isLoadingAnalysis = false;
  bool _isLoadingCompatibility = false;
  bool _isLoadingWeekly = false;
  bool _isLoadingMonthly = false;
  bool _isLoadingRisingSign = false;
  bool _isLoadingDream = false;

  String? _error;

  // Concurrent request tracking
  ZodiacSign? _currentDailyRequestSign;

  DailyHoroscope? get dailyHoroscope => _dailyHoroscope;
  DetailedAnalysis? get detailedAnalysis => _detailedAnalysis;
  CompatibilityResult? get compatibilityResult => _compatibilityResult;
  WeeklyHoroscope? get weeklyHoroscope => _weeklyHoroscope;
  MonthlyHoroscope? get monthlyHoroscope => _monthlyHoroscope;
  RisingSignResult? get risingSignResult => _risingSignResult;
  DreamInterpretation? get dreamInterpretation => _dreamInterpretation;

  bool get isLoadingDaily => _isLoadingDaily;
  bool get isLoadingAnalysis => _isLoadingAnalysis;
  bool get isLoadingCompatibility => _isLoadingCompatibility;
  bool get isLoadingWeekly => _isLoadingWeekly;
  bool get isLoadingMonthly => _isLoadingMonthly;
  bool get isLoadingRisingSign => _isLoadingRisingSign;
  bool get isLoadingDream => _isLoadingDream;

  String? get error => _error;

  Future<void> fetchDailyHoroscope(ZodiacSign sign) async {
    _currentDailyRequestSign = sign;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. Dun yarin icin cache'lenmis fal var mi?
    final tomorrowCache = await _storageService.getTomorrowHoroscope();
    if (tomorrowCache != null) {
      final cachedDate = tomorrowCache['date'] as DateTime;
      final cachedZodiac = tomorrowCache['zodiac'] as String;
      final cachedHoroscope = tomorrowCache['horoscope'] as String;

      if (cachedZodiac == sign.name &&
          cachedDate.year == today.year &&
          cachedDate.month == today.month &&
          cachedDate.day == today.day) {
        try {
          _dailyHoroscope = DailyHoroscope.fromJson(jsonDecode(cachedHoroscope));
          await _storageService.saveLastDailyFetch(today, sign.name);
          await _storageService.saveCachedDailyHoroscope(cachedHoroscope);
          await _storageService.clearTomorrowCache();
          notifyListeners();
          return;
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Failed to parse tomorrow cache: $e');
          }
        }
      }
    }

    // 2. Normal cache kontrolu
    final cachedInfo = await _storageService.getLastDailyFetch();
    if (cachedInfo != null) {
      final cachedDate = cachedInfo['date'] as DateTime;
      final cachedZodiac = cachedInfo['zodiac'] as String;

      if (cachedZodiac == sign.name &&
          cachedDate.year == today.year &&
          cachedDate.month == today.month &&
          cachedDate.day == today.day) {
        final cachedJson = await _storageService.getCachedDailyHoroscope();
        if (cachedJson != null) {
          try {
            _dailyHoroscope = DailyHoroscope.fromJson(jsonDecode(cachedJson));
            notifyListeners();
            return;
          } catch (e) {
            if (kDebugMode) {
              debugPrint('Failed to parse cached horoscope: $e');
            }
          }
        }
      }
    }

    // Loading state - single notification
    _isLoadingDaily = true;
    _error = null;
    notifyListeners();

    try {
      final horoscope = await _geminiService.fetchDailyHoroscope(sign);

      // Check if request was superseded by a newer one
      if (_currentDailyRequestSign != sign) return;

      _dailyHoroscope = horoscope;
      await _storageService.saveLastDailyFetch(today, sign.name);
      await _storageService.saveCachedDailyHoroscope(
        jsonEncode(_dailyHoroscope!.toJson()),
      );
    } catch (e) {
      if (_currentDailyRequestSign != sign) return;
      _error = e.toString();
      if (kDebugMode) {
        debugPrint('Error fetching daily horoscope: $e');
      }
    } finally {
      if (_currentDailyRequestSign == sign) {
        _isLoadingDaily = false;
        notifyListeners();
      }
    }
  }

  Future<String> fetchTomorrowPreview(ZodiacSign sign) async {
    try {
      return await _geminiService.fetchTomorrowPreview(sign);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching tomorrow preview: $e');
      }
      return 'Yarin senin icin harika bir gun olacak! Yeni firsatlar kapida bekliyor.';
    }
  }

  Future<DailyHoroscope> fetchTomorrowHoroscope(ZodiacSign sign, {String? preview}) async {
    try {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

      final cached = await _storageService.getTomorrowHoroscope();
      if (cached != null) {
        final cachedDate = cached['date'] as DateTime;
        final cachedZodiac = cached['zodiac'] as String;
        final cachedHoroscope = cached['horoscope'] as String;

        if (cachedZodiac == sign.name &&
            cachedDate.year == tomorrowDate.year &&
            cachedDate.month == tomorrowDate.month &&
            cachedDate.day == tomorrowDate.day) {
          return DailyHoroscope.fromJson(jsonDecode(cachedHoroscope));
        }
      }

      final horoscope = await _geminiService.fetchTomorrowHoroscope(sign);
      await _storageService.saveTomorrowHoroscope(
        jsonEncode(horoscope.toJson()),
        tomorrowDate,
        sign.name,
        preview: preview,
      );
      return horoscope;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching tomorrow horoscope: $e');
      }
      rethrow;
    }
  }

  Future<void> fetchDetailedAnalysis(ZodiacSign sign, String category) async {
    _isLoadingAnalysis = true;
    _error = null;
    notifyListeners();

    try {
      _detailedAnalysis = await _geminiService.fetchDetailedAnalysis(sign, category);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingAnalysis = false;
      notifyListeners();
    }
  }

  Future<void> fetchCompatibility(ZodiacSign sign1, ZodiacSign sign2) async {
    _isLoadingCompatibility = true;
    _error = null;
    notifyListeners();

    try {
      _compatibilityResult = await _geminiService.fetchCompatibility(sign1, sign2);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingCompatibility = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> fetchWeeklyHoroscope(ZodiacSign sign) async {
    _isLoadingWeekly = true;
    _error = null;
    notifyListeners();

    try {
      final json = await _geminiService.fetchWeeklyHoroscope(sign);
      _weeklyHoroscope = WeeklyHoroscope.fromJson(json);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingWeekly = false;
      notifyListeners();
    }
  }

  Future<void> fetchMonthlyHoroscope(ZodiacSign sign) async {
    _isLoadingMonthly = true;
    _error = null;
    notifyListeners();

    try {
      final json = await _geminiService.fetchMonthlyHoroscope(sign);
      _monthlyHoroscope = MonthlyHoroscope.fromJson(json);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMonthly = false;
      notifyListeners();
    }
  }

  Future<void> calculateRisingSign({
    required ZodiacSign sunSign,
    required DateTime birthDate,
    required String birthTime,
    required String birthPlace,
  }) async {
    _isLoadingRisingSign = true;
    _error = null;
    notifyListeners();

    try {
      final json = await _geminiService.calculateRisingSign(
        sunSign: sunSign,
        birthDate: birthDate,
        birthTime: birthTime,
        birthPlace: birthPlace,
      );
      _risingSignResult = RisingSignResult.fromJson(json);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingRisingSign = false;
      notifyListeners();
    }
  }

  Future<void> interpretDream(String dreamText) async {
    _isLoadingDream = true;
    _error = null;
    notifyListeners();

    try {
      final json = await _geminiService.interpretDream(dreamText);
      _dreamInterpretation = DreamInterpretation.fromJson(json);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingDream = false;
      notifyListeners();
    }
  }
}
