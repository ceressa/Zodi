import 'package:flutter/material.dart';

/// Uygulama üyelik kademeleri
enum MembershipTier {
  standard,
  altin,
  elmas,
  platinyum,
}

/// Bir üyelik kademesinin tüm konfigürasyon bilgileri
class MembershipTierConfig {
  final MembershipTier tier;
  final String displayName;
  final String description;
  final String emoji;
  final List<Color> gradient;
  final double monthlyPrice;
  final int dailyBonus;
  final int adReward;
  final bool adsEnabled;
  final bool allFeaturesUnlocked;

  const MembershipTierConfig({
    required this.tier,
    required this.displayName,
    required this.description,
    required this.emoji,
    required this.gradient,
    required this.monthlyPrice,
    required this.dailyBonus,
    required this.adReward,
    required this.adsEnabled,
    required this.allFeaturesUnlocked,
  });

  /// Tüm kademelerin listesi (standard dahil)
  ///
  /// EKONOMİ TASARIMI (₺ bazlı, Türkiye pazarı):
  /// ─────────────────────────────────────────────────────────
  /// Standard: Günde 5 Yıldız Tozu + reklam 5 Yıldız Tozu
  ///   → Günde ~15-20 Yıldız Tozu potansiyel (3 reklam izlerse)
  ///   → 1 analiz (10) = 2 reklam, 1 tarot (5) = 1 reklam
  ///
  /// Altın ₺179.99/ay: Günde 15 Yıldız Tozu + reklam 8
  ///   → Günde 1-2 feature ücretsiz, reklam da verimli
  ///
  /// Elmas ₺349.99/ay: Günde 30 Yıldız Tozu, reklam yok
  ///   → Çoğu özellik her gün kullanılabilir
  ///
  /// Platinyum ₺599.99/ay: 50/gün, her şey sınırsız
  /// ─────────────────────────────────────────────────────────
  static const List<MembershipTierConfig> allTiers = [
    MembershipTierConfig(
      tier: MembershipTier.standard,
      displayName: 'Standart',
      description: 'Temel astroloji özellikleri',
      emoji: '⭐',
      gradient: [Color(0xFF9CA3AF), Color(0xFF6B7280)],
      monthlyPrice: 0,
      dailyBonus: 5,
      adReward: 5,
      adsEnabled: true,
      allFeaturesUnlocked: false,
    ),
    MembershipTierConfig(
      tier: MembershipTier.altin,
      displayName: 'Altın',
      description: 'Daha fazla Yıldız Tozu ve avantaj',
      emoji: '🥇',
      gradient: [Color(0xFFEAB308), Color(0xFFCA8A04)],
      monthlyPrice: 179.99,
      dailyBonus: 15,
      adReward: 8,
      adsEnabled: true,
      allFeaturesUnlocked: false,
    ),
    MembershipTierConfig(
      tier: MembershipTier.elmas,
      displayName: 'Elmas',
      description: 'Premium özellikler ve bol Yıldız Tozu',
      emoji: '💎',
      gradient: [Color(0xFF06B6D4), Color(0xFF0891B2)],
      monthlyPrice: 349.99,
      dailyBonus: 30,
      adReward: 15,
      adsEnabled: false,
      allFeaturesUnlocked: false,
    ),
    MembershipTierConfig(
      tier: MembershipTier.platinyum,
      displayName: 'Platinyum',
      description: 'Tüm özellikler sınırsız',
      emoji: '👑',
      gradient: [Color(0xFF9400D3), Color(0xFFFF1493)],
      monthlyPrice: 599.99,
      dailyBonus: 50,
      adReward: 25,
      adsEnabled: false,
      allFeaturesUnlocked: true,
    ),
  ];

  /// Belirli bir tier için konfigürasyonu döndür
  static MembershipTierConfig getConfig(MembershipTier tier) {
    return allTiers.firstWhere(
      (c) => c.tier == tier,
      orElse: () => allTiers.first,
    );
  }

  /// String'den MembershipTier'e dönüştür
  static MembershipTier parseTier(String tierStr) {
    switch (tierStr.toLowerCase()) {
      case 'altin':
        return MembershipTier.altin;
      case 'elmas':
        return MembershipTier.elmas;
      case 'platinyum':
        return MembershipTier.platinyum;
      default:
        return MembershipTier.standard;
    }
  }
}

/// Yıldız Tozu paketi konfigürasyonu
///
/// FİYATLANDIRMA (₺ bazlı, Türkiye pazarı):
/// ──────────────────────────────────────────────
/// Küçük:  50 Yıldız Tozu  = ₺49.99  → 1.00 ₺/adet
/// Orta:   150 Yıldız Tozu = ₺119.99 → 0.67 ₺/adet (180 toplam, +20%)
/// Büyük:  400 Yıldız Tozu = ₺249.99 → 0.42 ₺/adet (600 toplam, +50%)
/// Mega:   1000 Yıldız Tozu= ₺449.99 → 0.22 ₺/adet (2000 toplam, +100%)
/// ──────────────────────────────────────────────
class CoinPackConfig {
  final String id;
  final int coinAmount;
  final int bonusPercent;
  final double price;
  final bool isBestValue;

  const CoinPackConfig({
    required this.id,
    required this.coinAmount,
    required this.bonusPercent,
    required this.price,
    this.isBestValue = false,
  });

  /// Toplam kazanılacak Yıldız Tozu (bonus dahil)
  int get totalCoins => coinAmount + (coinAmount * bonusPercent ~/ 100);

  /// Tüm Yıldız Tozu paketleri
  static const List<CoinPackConfig> allPacks = [
    CoinPackConfig(
      id: 'coin_50',
      coinAmount: 50,
      bonusPercent: 0,
      price: 49.99,
    ),
    CoinPackConfig(
      id: 'coin_400',
      coinAmount: 400,
      bonusPercent: 50,
      price: 249.99,
      isBestValue: true,
    ),
    CoinPackConfig(
      id: 'coin_1000',
      coinAmount: 1000,
      bonusPercent: 100,
      price: 449.99,
    ),
  ];
}

/// Başlangıç paketi konfigürasyonu
///
/// İlk 48 saat içinde sunulan özel teklif:
/// ₺29.99 ile 100 Yıldız Tozu + 3 gün Elmas Premium deneme
/// Normal değeri: 50 Yıldız Tozu (₺49.99) + 3 gün Elmas = ~₺84 değerinde
/// %65 indirimli ilk alım avantajı
class StarterPackConfig {
  static const String id = 'starter_pack';
  static const double price = 29.99;
  static const int coinAmount = 100;
  static const int premiumDays = 3;
  static const MembershipTier trialTier = MembershipTier.elmas;
  static const int offerDurationHours = 48;

  /// Paketin tahmini değeri (₺)
  static double get estimatedValue {
    // 100 Yıldız Tozu ≈ ₺99.98 (50 Yıldız Tozu = ₺49.99 x 2) + 3 gün Elmas (~₺35)
    return 134.97;
  }

  /// İndirim yüzdesi
  static int get discountPercent {
    return ((1 - (price / estimatedValue)) * 100).round();
  }
}
