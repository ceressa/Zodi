import 'dart:math';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/fun_feature_config.dart';

/// Günün Keşfi servisi — her gün farklı bir eğlenceli özelliği
/// %50 indirimli olarak öne çıkarır.
class DailyDiscoveryService {
  static final DailyDiscoveryService _instance = DailyDiscoveryService._internal();
  factory DailyDiscoveryService() => _instance;
  DailyDiscoveryService._internal();

  static const String _keyPrefix = 'daily_discovery_used_';

  /// Günün keşfine uygun özellikler
  /// - Ücretsiz özelliklere indirim mantıksız → coinCost > 0
  /// - soulmate_drawing hariç — 100 coin çok pahalı, %50 indirim bile 50 coin
  static List<FunFeatureConfig> get _eligible =>
      FunFeatureConfig.allFeatures
          .where((f) => f.coinCost > 0 && f.id != 'soulmate_drawing')
          .toList();

  /// Verilen tarih için deterministik özellik seç
  FunFeatureConfig _getFeatureForDate(DateTime date) {
    final dateStr = DateFormat('yyyyMMdd').format(date);
    final seed = 'daily_discovery_$dateStr'.hashCode;
    final rng = Random(seed);
    final features = _eligible;
    return features[rng.nextInt(features.length)];
  }

  /// Bugünün keşfi
  FunFeatureConfig getTodaysFeature() {
    return _getFeatureForDate(DateTime.now());
  }

  /// Yarının keşfi (teaser için)
  FunFeatureConfig getTomorrowsFeature() {
    return _getFeatureForDate(DateTime.now().add(const Duration(days: 1)));
  }

  /// İndirimli fiyat: %50, floor, minimum 2
  int getDiscountedPrice(FunFeatureConfig feature) {
    final discounted = (feature.coinCost / 2).floor();
    return discounted < 2 ? 2 : discounted;
  }

  /// Orijinal fiyat (üstü çizili gösterim için)
  int getOriginalPrice(FunFeatureConfig feature) => feature.coinCost;

  /// Bugünkü indirim kullanıldı mı?
  Future<bool> hasUsedTodaysDiscount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return prefs.getBool('$_keyPrefix$today') ?? false;
  }

  /// İndirimi kullanıldı olarak işaretle
  Future<void> markDiscountUsed() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await prefs.setBool('$_keyPrefix$today', true);
    // Eski kayıtları temizle (2 günden eski)
    await _cleanupOldKeys(prefs);
  }

  /// Eski SharedPreferences kayıtlarını temizle
  Future<void> _cleanupOldKeys(SharedPreferences prefs) async {
    final keys = prefs.getKeys().where((k) => k.startsWith(_keyPrefix)).toList();
    final today = DateTime.now();
    for (final key in keys) {
      final dateStr = key.replaceFirst(_keyPrefix, '');
      try {
        final date = DateFormat('yyyy-MM-dd').parse(dateStr);
        if (today.difference(date).inDays > 2) {
          await prefs.remove(key);
        }
      } catch (_) {
        await prefs.remove(key);
      }
    }
  }
}
