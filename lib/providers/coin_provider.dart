import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/membership_config.dart';

/// Kullanıcının altın (coin) bakiyesini yöneten provider
class CoinProvider with ChangeNotifier {
  static const String _keyBalance = 'coin_balance';
  static const String _keyLastDailyBonus = 'coin_last_daily_bonus_date';
  static const String _keyInitialBonusAwarded = 'coin_initial_bonus_awarded';

  int _balance = 0;
  int _lastDailyBonus = 0;
  int _initialBonusAwarded = 0;
  MembershipTier _tier = MembershipTier.standard;

  int get balance => _balance;
  int get lastDailyBonus => _lastDailyBonus;
  int get initialBonusAwarded => _initialBonusAwarded;

  /// Günlük reklam ödülü (tier'a göre)
  int get adRewardAmount {
    return MembershipTierConfig.getConfig(_tier).adReward;
  }

  /// Mevcut tier'ı ayarla (bonus hesaplamaları için)
  void setTier(MembershipTier tier) {
    _tier = tier;
    notifyListeners();
  }

  /// Bakiyeyi SharedPreferences'tan yükle ve günlük bonus ver
  Future<void> loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    _balance = prefs.getInt(_keyBalance) ?? 0;
    _initialBonusAwarded = 0;
    _lastDailyBonus = 0;

    // Yeni kullanıcıya hoş geldin bonusu (ilk 3-4 deneme için yeterli)
    final initialBonusGiven = prefs.getBool('${_keyInitialBonusAwarded}_given') ?? false;
    if (!initialBonusGiven) {
      _initialBonusAwarded = 50;
      _balance += _initialBonusAwarded;
      await prefs.setBool('${_keyInitialBonusAwarded}_given', true);
      await prefs.setInt(_keyBalance, _balance);
    }

    // Günlük bonus kontrolü
    final today = _todayString();
    final lastBonusDate = prefs.getString(_keyLastDailyBonus);
    if (lastBonusDate != today) {
      final tierConfig = MembershipTierConfig.getConfig(_tier);
      _lastDailyBonus = tierConfig.dailyBonus;
      _balance += _lastDailyBonus;
      await prefs.setString(_keyLastDailyBonus, today);
      await prefs.setInt(_keyBalance, _balance);
    }

    notifyListeners();
  }

  /// Yeterli bakiye var mı kontrol et
  bool canAfford(int amount) => _balance >= amount;

  /// Altın harca — yeterli bakiye varsa true döner
  Future<bool> spendCoins(int amount, String reason) async {
    if (_balance < amount) return false;
    _balance -= amount;
    await _saveBalance();
    notifyListeners();
    return true;
  }

  /// Altın ekle
  Future<void> addCoins(int amount) async {
    _balance += amount;
    await _saveBalance();
    notifyListeners();
  }

  /// Reklam izleyerek kazanılan altın
  Future<void> earnFromAd() async {
    final reward = adRewardAmount;
    _balance += reward;
    await _saveBalance();
    notifyListeners();
  }

  /// Altın paketi satın al (IAP entegrasyonu olmadan mock)
  Future<void> purchaseCoins(CoinPackConfig pack) async {
    final totalCoins = pack.coinAmount + (pack.coinAmount * pack.bonusPercent ~/ 100);
    _balance += totalCoins;
    await _saveBalance();
    notifyListeners();
  }

  Future<void> _saveBalance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyBalance, _balance);
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
