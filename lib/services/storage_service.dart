import 'package:shared_preferences/shared_preferences.dart';
import '../models/zodiac_sign.dart';

class StorageService {
  static const String _keyUserName = 'userName';
  static const String _keyUserEmail = 'userEmail';
  static const String _keySelectedZodiac = 'selectedZodiac';
  static const String _keyIsPremium = 'isPremium';
  static const String _keyThemeMode = 'themeMode';
  static const String _keyLastDailyFetch = 'lastDailyFetch';
  static const String _keyLastDailyZodiac = 'lastDailyZodiac';
  static const String _keyCachedDailyHoroscope = 'cachedDailyHoroscope';
  static const String _keyTomorrowHoroscope = 'tomorrowHoroscope';
  static const String _keyTomorrowHoroscopeDate = 'tomorrowHoroscopeDate';
  static const String _keyTomorrowHoroscopeZodiac = 'tomorrowHoroscopeZodiac';
  static const String _keyTomorrowUnlocked = 'tomorrowUnlocked';
  static const String _keyNotificationsEnabled = 'notificationsEnabled';
  static const String _keyNotificationTime = 'notificationTime';

  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserEmail, email);
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  Future<void> saveSelectedZodiac(ZodiacSign sign) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedZodiac, sign.displayName);
  }

  Future<ZodiacSign?> getSelectedZodiac() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keySelectedZodiac);
    if (name == null) return null;
    return ZodiacSign.fromString(name);
  }

  Future<void> clearSelectedZodiac() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySelectedZodiac);
  }

  Future<void> saveIsPremium(bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPremium, isPremium);
  }

  Future<bool> getIsPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsPremium) ?? false;
  }

  Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode);
  }

  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyThemeMode) ?? 'dark';
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Daily horoscope cache
  Future<void> saveLastDailyFetch(DateTime date, String zodiac) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastDailyFetch, date.toIso8601String());
    await prefs.setString(_keyLastDailyZodiac, zodiac);
  }

  Future<Map<String, dynamic>?> getLastDailyFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_keyLastDailyFetch);
    final zodiac = prefs.getString(_keyLastDailyZodiac);
    
    if (dateStr == null || zodiac == null) return null;
    
    return {
      'date': DateTime.parse(dateStr),
      'zodiac': zodiac,
    };
  }

  Future<void> saveCachedDailyHoroscope(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCachedDailyHoroscope, json);
  }

  Future<String?> getCachedDailyHoroscope() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCachedDailyHoroscope);
  }

  // Tomorrow horoscope cache
  Future<void> saveTomorrowHoroscope(String horoscope, DateTime forDate, String zodiac, {String? preview}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTomorrowHoroscope, horoscope);
    await prefs.setString(_keyTomorrowHoroscopeDate, forDate.toIso8601String());
    await prefs.setString(_keyTomorrowHoroscopeZodiac, zodiac);
    if (preview != null) {
      await prefs.setString('${_keyTomorrowHoroscope}_preview', preview);
    }
  }

  Future<Map<String, dynamic>?> getTomorrowHoroscope() async {
    final prefs = await SharedPreferences.getInstance();
    final horoscope = prefs.getString(_keyTomorrowHoroscope);
    final dateStr = prefs.getString(_keyTomorrowHoroscopeDate);
    final zodiac = prefs.getString(_keyTomorrowHoroscopeZodiac);
    final preview = prefs.getString('${_keyTomorrowHoroscope}_preview');
    
    if (horoscope == null || dateStr == null || zodiac == null) return null;
    
    return {
      'horoscope': horoscope,
      'date': DateTime.parse(dateStr),
      'zodiac': zodiac,
      'preview': preview,
    };
  }

  Future<void> setTomorrowUnlocked(bool unlocked) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTomorrowUnlocked, unlocked);
  }

  Future<bool> isTomorrowUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTomorrowUnlocked) ?? false;
  }

  Future<void> clearTomorrowCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTomorrowHoroscope);
    await prefs.remove(_keyTomorrowHoroscopeDate);
    await prefs.remove(_keyTomorrowHoroscopeZodiac);
    await prefs.remove(_keyTomorrowUnlocked);
  }

  // Notification settings
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, enabled);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationsEnabled) ?? false;
  }

  Future<void> setNotificationTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNotificationTime, time);
  }

  Future<String?> getNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNotificationTime);
  }

  // Generic string storage
  Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}
