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

  // Limitler
  static const int dailyCommentLimit = 3; // Günde 3 yorum
  static const int weeklyCalendarFreeViews = 3; // Bugün + 3 gün ücretsiz
  static const int retroAnalysisLimit = 1; // Günde 1 retro analizi
  static const int risingSignDetailLimit = 2; // Günde 2 detaylı yükselen burç yorumu
  static const int profileShareLimit = 3; // Günde 3 profil kartı paylaşımı

  /// Günlük yorum limitini kontrol et
  Future<bool> canViewDailyComment() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    
    final lastDate = prefs.getString(_keyDailyCommentDate);
    final count = prefs.getInt(_keyDailyCommentCount) ?? 0;
    
    // Yeni gün başladıysa sıfırla
    if (lastDate != todayStr) {
      await prefs.setString(_keyDailyCommentDate, todayStr);
      await prefs.setInt(_keyDailyCommentCount, 0);
      return true;
    }
    
    return count < dailyCommentLimit;
  }

  /// Günlük yorum sayacını artır
  Future<void> incrementDailyComment() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_keyDailyCommentCount) ?? 0;
    await prefs.setInt(_keyDailyCommentCount, count + 1);
  }

  /// Kalan günlük yorum hakkını getir
  Future<int> getRemainingDailyComments() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    
    final lastDate = prefs.getString(_keyDailyCommentDate);
    final count = prefs.getInt(_keyDailyCommentCount) ?? 0;
    
    if (lastDate != todayStr) {
      return dailyCommentLimit;
    }
    
    return (dailyCommentLimit - count).clamp(0, dailyCommentLimit);
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
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    
    final lastDate = prefs.getString(_keyRetroAnalysisDate);
    final count = prefs.getInt(_keyRetroAnalysisCount) ?? 0;
    
    if (lastDate != todayStr) {
      await prefs.setString(_keyRetroAnalysisDate, todayStr);
      await prefs.setInt(_keyRetroAnalysisCount, 0);
      return true;
    }
    
    return count < retroAnalysisLimit;
  }

  /// Retro analizi sayacını artır
  Future<void> incrementRetroAnalysis() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_keyRetroAnalysisCount) ?? 0;
    await prefs.setInt(_keyRetroAnalysisCount, count + 1);
  }

  /// Yükselen burç detay limitini kontrol et
  Future<bool> canViewRisingSignDetail() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    
    final lastDate = prefs.getString(_keyRisingSignDetailDate);
    final count = prefs.getInt(_keyRisingSignDetailViews) ?? 0;
    
    if (lastDate != todayStr) {
      await prefs.setString(_keyRisingSignDetailDate, todayStr);
      await prefs.setInt(_keyRisingSignDetailViews, 0);
      return true;
    }
    
    return count < risingSignDetailLimit;
  }

  /// Yükselen burç detay sayacını artır
  Future<void> incrementRisingSignDetail() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_keyRisingSignDetailViews) ?? 0;
    await prefs.setInt(_keyRisingSignDetailViews, count + 1);
  }

  /// Profil kartı paylaşım limitini kontrol et
  Future<bool> canShareProfileCard() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    
    final lastDate = prefs.getString(_keyProfileShareDate);
    final count = prefs.getInt(_keyProfileShareCount) ?? 0;
    
    if (lastDate != todayStr) {
      await prefs.setString(_keyProfileShareDate, todayStr);
      await prefs.setInt(_keyProfileShareCount, 0);
      return true;
    }
    
    return count < profileShareLimit;
  }

  /// Profil kartı paylaşım sayacını artır
  Future<void> incrementProfileShare() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_keyProfileShareCount) ?? 0;
    await prefs.setInt(_keyProfileShareCount, count + 1);
  }

  /// Tüm limitleri sıfırla (premium upgrade sonrası)
  Future<void> resetAllLimits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDailyCommentCount);
    await prefs.remove(_keyDailyCommentDate);
    await prefs.remove(_keyWeeklyCalendarViews);
    await prefs.remove(_keyWeeklyCalendarDate);
    await prefs.remove(_keyRetroAnalysisCount);
    await prefs.remove(_keyRetroAnalysisDate);
    await prefs.remove(_keyRisingSignDetailViews);
    await prefs.remove(_keyRisingSignDetailDate);
    await prefs.remove(_keyProfileShareCount);
    await prefs.remove(_keyProfileShareDate);
  }
}
