import 'package:flutter/material.dart';

enum AstroEventType {
  mercuryRetrograde,
  venusRetrograde,
  marsRetrograde,
  jupiterRetrograde,
  saturnRetrograde,
  fullMoon,
  newMoon,
  solarEclipse,
  lunarEclipse,
  zodiacSeasonChange,
}

class AstroEvent {
  final DateTime date;
  final DateTime? endDate; // Retro gibi dönemsel olaylar için
  final String title;
  final String description;
  final AstroEventType type;
  final String? affectedSign;
  final String emoji;

  const AstroEvent({
    required this.date,
    this.endDate,
    required this.title,
    required this.description,
    required this.type,
    this.affectedSign,
    required this.emoji,
  });

  Color get color {
    switch (type) {
      case AstroEventType.mercuryRetrograde:
      case AstroEventType.venusRetrograde:
      case AstroEventType.marsRetrograde:
      case AstroEventType.jupiterRetrograde:
      case AstroEventType.saturnRetrograde:
        return const Color(0xFFFF6B6B);
      case AstroEventType.fullMoon:
        return const Color(0xFFFFD700);
      case AstroEventType.newMoon:
        return const Color(0xFF9B59B6);
      case AstroEventType.solarEclipse:
      case AstroEventType.lunarEclipse:
        return const Color(0xFF3498DB);
      case AstroEventType.zodiacSeasonChange:
        return const Color(0xFF2ECC71);
    }
  }

  String get typeLabel {
    switch (type) {
      case AstroEventType.mercuryRetrograde:
        return 'Merkür Retrosu';
      case AstroEventType.venusRetrograde:
        return 'Venüs Retrosu';
      case AstroEventType.marsRetrograde:
        return 'Mars Retrosu';
      case AstroEventType.jupiterRetrograde:
        return 'Jüpiter Retrosu';
      case AstroEventType.saturnRetrograde:
        return 'Satürn Retrosu';
      case AstroEventType.fullMoon:
        return 'Dolunay';
      case AstroEventType.newMoon:
        return 'Yeniay';
      case AstroEventType.solarEclipse:
        return 'Güneş Tutulması';
      case AstroEventType.lunarEclipse:
        return 'Ay Tutulması';
      case AstroEventType.zodiacSeasonChange:
        return 'Burç Mevsimi';
    }
  }

  /// Verilen tarih bu olayın aktif döneminde mi? (retro gibi dönemsel olaylar)
  bool isActiveOn(DateTime date) {
    if (endDate == null) {
      return date.year == this.date.year &&
          date.month == this.date.month &&
          date.day == this.date.day;
    }
    final d = DateTime(date.year, date.month, date.day);
    final start = DateTime(this.date.year, this.date.month, this.date.day);
    final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
    return !d.isBefore(start) && !d.isAfter(end);
  }
}
