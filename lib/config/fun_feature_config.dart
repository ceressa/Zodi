import 'package:flutter/material.dart';
import 'membership_config.dart';

/// Eğlenceli özellik konfigürasyonu
class FunFeatureConfig {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> gradient;
  final int coinCost;
  final MembershipTier? requiredTier;

  const FunFeatureConfig({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradient,
    this.coinCost = 5,
    this.requiredTier,
  });

  /// Bu özelliğe verilen tier ile erişilebilir mi?
  bool canAccess(MembershipTier userTier) {
    if (requiredTier == null) return true;
    return userTier.index >= requiredTier!.index;
  }

  /// Bu özellik verilen tier'da Yıldız Tozu harcamadan dahil mi?
  bool isIncludedInTier(MembershipTier userTier) {
    if (requiredTier == null) return true;
    return userTier.index >= requiredTier!.index;
  }

  /// Tüm eğlenceli özellikler listesi
  ///
  /// FİYAT DENGESİ:
  /// - Herkese açık: 5-8 Yıldız Tozu (1 reklam = 5 Yıldız Tozu = 1 feature)
  /// - Altın tier gerekli: 10-12 Yıldız Tozu (premium içerik hissi)
  /// - Standart kullanıcı günde 5 Yıldız Tozu bonus + reklam → rahatça 2 feature
  static const List<FunFeatureConfig> allFeatures = [
    // ── Herkese Açık (5 Yıldız Tozu) ──
    FunFeatureConfig(
      id: 'numerology',
      title: 'Numeroloji',
      subtitle: 'Sayıların sırrını keşfet',
      emoji: '🔢',
      gradient: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
      coinCost: 5,
    ),
    FunFeatureConfig(
      id: 'spirit_animal',
      title: 'Ruh Hayvanın',
      subtitle: 'Totem hayvanını bul',
      emoji: '🦋',
      gradient: [Color(0xFF059669), Color(0xFF047857)],
      coinCost: 5,
    ),
    FunFeatureConfig(
      id: 'luck_map',
      title: 'Şans Haritası',
      subtitle: 'Bugünkü şansın nerede?',
      emoji: '🍀',
      gradient: [Color(0xFF16A34A), Color(0xFF15803D)],
      coinCost: 5,
    ),
    FunFeatureConfig(
      id: 'element_analysis',
      title: 'Element Analizi',
      subtitle: 'Ateş mi su mu toprak mı?',
      emoji: '🔥',
      gradient: [Color(0xFFEA580C), Color(0xFFC2410C)],
      coinCost: 5,
    ),

    // ── Herkese Açık (8 Yıldız Tozu) ──
    FunFeatureConfig(
      id: 'aura',
      title: 'Aura Analizi',
      subtitle: 'Enerjini keşfet',
      emoji: '✨',
      gradient: [Color(0xFFDB2777), Color(0xFFBE185D)],
      coinCost: 8,
    ),
    FunFeatureConfig(
      id: 'chakra',
      title: 'Çakra Analizi',
      subtitle: 'Enerji merkezlerin',
      emoji: '🌈',
      gradient: [Color(0xFF0891B2), Color(0xFF0E7490)],
      coinCost: 8,
    ),
    FunFeatureConfig(
      id: 'cosmic_message',
      title: 'Kozmik Mesaj',
      subtitle: 'Evrenden sana bir not',
      emoji: '💫',
      gradient: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
      coinCost: 8,
    ),

    // ── Altın Tier Gerekli (10-12 Yıldız Tozu) ──
    FunFeatureConfig(
      id: 'life_path',
      title: 'Yaşam Yolu',
      subtitle: 'Kaderine bak',
      emoji: '🛤️',
      gradient: [Color(0xFFD97706), Color(0xFFB45309)],
      coinCost: 10,
      requiredTier: MembershipTier.altin,
    ),
    FunFeatureConfig(
      id: 'astro_career',
      title: 'Astro Kariyer',
      subtitle: 'Hangi meslek sana göre?',
      emoji: '💼',
      gradient: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
      coinCost: 10,
      requiredTier: MembershipTier.altin,
    ),
    FunFeatureConfig(
      id: 'past_life',
      title: 'Önceki Yaşam',
      subtitle: 'Geçmiş yaşam izlerini gör',
      emoji: '🌀',
      gradient: [Color(0xFF4C1D95), Color(0xFF5B21B6)],
      coinCost: 12,
      requiredTier: MembershipTier.altin,
    ),
  ];
}
