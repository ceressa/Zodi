import 'package:shared_preferences/shared_preferences.dart';

/// Yıldız Tozu servisi — streak ödülleri ve genel Yıldız Tozu işlemleri
class CoinService {
  static final CoinService _instance = CoinService._internal();
  factory CoinService() => _instance;
  CoinService._internal();

  static const String _keyBalance = 'coin_balance';

  /// Streak kilometre taşı ödülü ver (7, 14, 21, ... günlük streak için)
  Future<void> awardStreakMilestone(int streakDays) async {
    try {
      final bonus = _calculateStreakBonus(streakDays);
      if (bonus > 0) {
        await _addCoins(bonus);
        print('Streak milestone $streakDays: +$bonus Yıldız Tozu ödülü verildi');
      }
    } catch (e) {
      print('Streak milestone ödülü verilemedi: $e');
    }
  }

  /// Belirli miktarda Yıldız Tozu ekle
  Future<void> addCoins(int amount) async {
    await _addCoins(amount);
  }

  /// Mevcut bakiyeyi al
  Future<int> getBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyBalance) ?? 0;
  }

  Future<void> _addCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyBalance) ?? 0;
    await prefs.setInt(_keyBalance, current + amount);
  }

  int _calculateStreakBonus(int streakDays) {
    if (streakDays >= 28) return 50;
    if (streakDays >= 21) return 35;
    if (streakDays >= 14) return 25;
    if (streakDays >= 7) return 15;
    return 0;
  }
}
