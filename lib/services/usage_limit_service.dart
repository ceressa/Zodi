import 'package:shared_preferences/shared_preferences.dart';

/// Kullanım limiti servisi - Free kullanıcılar için günlük/haftalık limitler
class UsageLimitService {
  static const String _keyDailyCommentCount = 'daily_comment_count';
  static const String _keyDailyCommentDate = 'daily_comment_date';
  static const String _keyWeeklyCalendarViews = 'weekly_calendar_views';
  static const String _keyWeeklyCalendarDate = 'weekly_calendar_date';
  static const String _keyRetroAnalysisCount = 'retro_analysis_count';
  static const String _keyRetroAnalysisDate = 'retro_analysis_date';
  static const String _keyRisingSignDetailViews = 'rising_sign_detail_views';
  static const String _keyRisingSignDetailDate = 'rising_sign_detail_date';
  static const String _keyProfileShareCount = 'profile_share_count';
  static const String _keyProfileShareDate = 'profile_share_date';
  static const String _keyDreamCount = 'dream_interpretation_count';
  static const String _keyDreamDate = 'dream_interpretation_date';
  static const String _keyMonthlyViewCount = 'monthly_view_count';
  static const String _keyMonthlyViewDate = 'monthly_view_date';

  // Limitler
  static const int dailyCommentLimit = 3; // Günde 3 yorum
  static const int weeklyCalendarFreeViews = 3; // Bugün + 3 gün ücretsiz
  static const int retroAnalysisLimit = 1; // Günde 1 retro analizi
  static const int risingSignDetailLimit = 2; // Günde 2 detaylı yükselen burç yorumu
  static const int profileShareLimit = 3; // Günde 3 profil kartı paylaşımı
  static const int dreamInterpretationLimit = 1; // Günde 1 ücretsiz rüya yorumu
  static const int monthlyViewLimit = 1; // Günde 1 aylık yorum görüntüleme

  /// Günlük yorum limitini kontrol et
  Future<bool> canViewDailyComment() async {
    return _checkDailyLimit(_keyDailyCommentDate, _keyDailyCommentCount, dailyCommentLimit);
  }

  /// Günlük yorum sayacını artır
  Future<void> incrementDailyComment() async {
    await _incrementDailyCounter(_keyDailyCommentDate, _keyDailyCommentCount);
  }

  /// Kalan günlük yorum hakkını getir
  Future<int> getRemainingDailyComments() async {
    return _getRemainingCount(_keyDailyCommentDate, _keyDailyCommentCount, dailyCommentLimit);
  }

  /// Kozmik takvim görüntüleme limitini kontrol et (haftalık)
  Future<bool> canViewCalendarDay(int daysFromToday) async {
    // Bugün + 3 gün ücretsiz
    if (daysFromToday <= weeklyCalendarFreeViews) {
      return true;
    }
    return false;
  }

  /// Retro analizi limitini kontrol et
  Future<bool> canViewRetroAnalysis() async {
    return _checkDailyLimit(_keyRetroAnalysisDate, _keyRetroAnalysisCount, retroAnalysisLimit);
  }

  /// Retro analizi sayacını artır
  Future<void> incrementRetroAnalysis() async {
    await _incrementDailyCounter(_keyRetroAnalysisDate, _keyRetroAnalysisCount);
  }

  /// Yükselen burç detay limitini kontrol et
  Future<bool> canViewRisingSignDetail() async {
    return _checkDailyLimit(_keyRisingSignDetailDate, _keyRisingSignDetailViews, risingSignDetailLimit);
  }

  /// Yükselen burç detay sayacını artır
  Future<void> incrementRisingSignDetail() async {
    await _incrementDailyCounter(_keyRisingSignDetailDate, _keyRisingSignDetailViews);
  }

  /// Profil kartı paylaşım limitini kontrol et
  Future<bool> canShareProfileCard() async {
    return _checkDailyLimit(_keyProfileShareDate, _keyProfileShareCount, profileShareLimit);
  }

  /// Profil kartı paylaşım sayacını artır
  Future<void> incrementProfileShare() async {
    await _incrementDailyCounter(_keyProfileShareDate, _keyProfileShareCount);
  }

  /// Rüya yorumu limitini kontrol et
  Future<bool> canInterpretDream() async {
    return _checkDailyLimit(_keyDreamDate, _keyDreamCount, dreamInterpretationLimit);
  }

  /// Rüya yorumu sayacını artır
  Future<void> incrementDreamInterpretation() async {
    await _incrementDailyCounter(_keyDreamDate, _keyDreamCount);
  }

  /// Kalan rüya yorumu hakkını getir
  Future<int> getRemainingDreamInterpretations() async {
    return _getRemainingCount(_keyDreamDate, _keyDreamCount, dreamInterpretationLimit);
  }

  /// Aylık yorum görüntüleme limitini kontrol et
  Future<bool> canViewMonthlyHoroscope() async {
    return _checkDailyLimit(_keyMonthlyViewDate, _keyMonthlyViewCount, monthlyViewLimit);
  }

  /// Aylık yorum görüntüleme sayacını artır
  Future<void> incrementMonthlyView() async {
    await _incrementDailyCounter(_keyMonthlyViewDate, _keyMonthlyViewCount);
  }

  /// Tüm limitleri sıfırla (premium upgrade sonrası)
  Future<void> resetAllLimits() async {
    final prefs = await SharedPreferences.getInstance();
    final keysToRemove = [
      _keyDailyCommentCount, _keyDailyCommentDate,
      _keyWeeklyCalendarViews, _keyWeeklyCalendarDate,
      _keyRetroAnalysisCount, _keyRetroAnalysisDate,
      _keyRisingSignDetailViews, _keyRisingSignDetailDate,
      _keyProfileShareCount, _keyProfileShareDate,
      _keyDreamCount, _keyDreamDate,
      _keyMonthlyViewCount, _keyMonthlyViewDate,
    ];
    for (final key in keysToRemove) {
      await prefs.remove(key);
    }
  }

  // ─── Private Helpers ───

  Future<bool> _checkDailyLimit(String dateKey, String countKey, int limit) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';

    final lastDate = prefs.getString(dateKey);
    final count = prefs.getInt(countKey) ?? 0;

    if (lastDate != todayStr) {
      await prefs.setString(dateKey, todayStr);
      await prefs.setInt(countKey, 0);
      return true;
    }

    return count < limit;
  }

  Future<void> _incrementDailyCounter(String dateKey, String countKey) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';

    // Yeni gün kontrolü
    final lastDate = prefs.getString(dateKey);
    if (lastDate != todayStr) {
      await prefs.setString(dateKey, todayStr);
      await prefs.setInt(countKey, 1);
    } else {
      final count = prefs.getInt(countKey) ?? 0;
      await prefs.setInt(countKey, count + 1);
    }
  }

  Future<int> _getRemainingCount(String dateKey, String countKey, int limit) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';

    final lastDate = prefs.getString(dateKey);
    final count = prefs.getInt(countKey) ?? 0;

    if (lastDate != todayStr) {
      return limit;
    }

    return (limit - count).clamp(0, limit);
  }
}
