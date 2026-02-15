import 'package:flutter/material.dart';

enum MoonPhase {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  fullMoon,
  waningGibbous,
  lastQuarter,
  waningCrescent,
}

enum BeautyRating {
  great,
  good,
  neutral,
  avoid,
}

class BeautyDay {
  final DateTime date;
  final MoonPhase moonPhase;
  final String moonSign; // Ay'ın o gün bulunduğu burç
  final BeautyRating hairCut;
  final BeautyRating hairDye;
  final BeautyRating skinCare;
  final BeautyRating nailCare;
  final String? aiTip;

  const BeautyDay({
    required this.date,
    required this.moonPhase,
    required this.moonSign,
    required this.hairCut,
    required this.hairDye,
    required this.skinCare,
    required this.nailCare,
    this.aiTip,
  });

  /// Günün genel puanı (en yüksek rating'e göre)
  BeautyRating get overallRating {
    final ratings = [hairCut, hairDye, skinCare, nailCare];
    if (ratings.contains(BeautyRating.great)) return BeautyRating.great;
    if (ratings.contains(BeautyRating.good)) return BeautyRating.good;
    if (ratings.contains(BeautyRating.neutral)) return BeautyRating.neutral;
    return BeautyRating.avoid;
  }
}

// Extension'lar
extension MoonPhaseExtension on MoonPhase {
  String get turkishName {
    switch (this) {
      case MoonPhase.newMoon:
        return 'Yeniay';
      case MoonPhase.waxingCrescent:
        return 'Hilal (Büyüyen)';
      case MoonPhase.firstQuarter:
        return 'İlk Dördün';
      case MoonPhase.waxingGibbous:
        return 'Şişkin Ay (Büyüyen)';
      case MoonPhase.fullMoon:
        return 'Dolunay';
      case MoonPhase.waningGibbous:
        return 'Şişkin Ay (Azalan)';
      case MoonPhase.lastQuarter:
        return 'Son Dördün';
      case MoonPhase.waningCrescent:
        return 'Hilal (Azalan)';
    }
  }

  String get emoji {
    switch (this) {
      case MoonPhase.newMoon:
        return '🌑';
      case MoonPhase.waxingCrescent:
        return '🌒';
      case MoonPhase.firstQuarter:
        return '🌓';
      case MoonPhase.waxingGibbous:
        return '🌔';
      case MoonPhase.fullMoon:
        return '🌕';
      case MoonPhase.waningGibbous:
        return '🌖';
      case MoonPhase.lastQuarter:
        return '🌗';
      case MoonPhase.waningCrescent:
        return '🌘';
    }
  }
}

extension BeautyRatingExtension on BeautyRating {
  String get turkishName {
    switch (this) {
      case BeautyRating.great:
        return 'Harika';
      case BeautyRating.good:
        return 'İyi';
      case BeautyRating.neutral:
        return 'Nötr';
      case BeautyRating.avoid:
        return 'Kaçın';
    }
  }

  String get emoji {
    switch (this) {
      case BeautyRating.great:
        return '✨';
      case BeautyRating.good:
        return '👍';
      case BeautyRating.neutral:
        return '😐';
      case BeautyRating.avoid:
        return '⚠️';
    }
  }

  Color get color {
    switch (this) {
      case BeautyRating.great:
        return const Color(0xFF2ECC71);
      case BeautyRating.good:
        return const Color(0xFFF1C40F);
      case BeautyRating.neutral:
        return const Color(0xFF95A5A6);
      case BeautyRating.avoid:
        return const Color(0xFFE74C3C);
    }
  }
}
