import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Eğlenceli özellikler servisi — cache yönetimi ve sonuç depolama
class FunFeatureService {
  static final FunFeatureService _instance = FunFeatureService._internal();
  factory FunFeatureService() => _instance;
  FunFeatureService._internal();

  static const String _cachePrefix = 'fun_feature_cache_';

  /// Belirli bir özellik için cache'lenmiş sonucu al
  Future<String?> getCachedResult(String featureId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('$_cachePrefix$featureId');
    } catch (e) {
      debugPrint('FunFeatureService cache okuma hatası: $e');
      return null;
    }
  }

  /// Bir özellik sonucunu cache'e kaydet
  Future<void> cacheResult(String featureId, String result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_cachePrefix$featureId', result);
    } catch (e) {
      debugPrint('FunFeatureService cache yazma hatası: $e');
    }
  }

  /// Belirli bir özelliğin cache'ini temizle
  Future<void> clearCache(String featureId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_cachePrefix$featureId');
    } catch (e) {
      debugPrint('FunFeatureService cache temizleme hatası: $e');
    }
  }

  /// Tüm fun feature cache'lerini temizle (doğum bilgisi değiştiğinde çağrılır)
  Future<void> clearAllCaches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(_cachePrefix)).toList();
      for (final key in keys) {
        await prefs.remove(key);
      }
      debugPrint('FunFeatureService: ${keys.length} cache temizlendi');
    } catch (e) {
      debugPrint('FunFeatureService tüm cache temizleme hatası: $e');
    }
  }
}
