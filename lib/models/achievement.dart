import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final List<Color> gradient;
  final int requiredCount;
  final String category; // 'daily', 'quiz', 'social', 'explore'

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.gradient,
    required this.requiredCount,
    required this.category,
  });

  /// Predefined achievements
  static const List<Achievement> allAchievements = [
    // Daily usage
    Achievement(
      id: 'first_horoscope',
      title: '\u0130lk Ad\u0131m',
      description: '\u0130lk g\u00fcnl\u00fck yorumunu oku',
      emoji: '\u2b50',
      gradient: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
      requiredCount: 1,
      category: 'daily',
    ),
    Achievement(
      id: 'week_streak',
      title: 'Haftal\u0131k Kahin',
      description: '7 g\u00fcn \u00fcst \u00fcste giri\u015f yap',
      emoji: '\ud83d\udd25',
      gradient: [Color(0xFFEF4444), Color(0xFFF97316)],
      requiredCount: 7,
      category: 'daily',
    ),
    Achievement(
      id: 'month_streak',
      title: 'Ay Ustas\u0131',
      description: '30 g\u00fcn \u00fcst \u00fcste giri\u015f yap',
      emoji: '\ud83c\udf19',
      gradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      requiredCount: 30,
      category: 'daily',
    ),
    // Quiz
    Achievement(
      id: 'quiz_beginner',
      title: '\u00c7\u0131rak Astrolog',
      description: '\u0130lk quiz\'ini tamamla',
      emoji: '\ud83d\udcda',
      gradient: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
      requiredCount: 1,
      category: 'quiz',
    ),
    Achievement(
      id: 'quiz_master',
      title: 'Usta Astrolog',
      description: '10 quiz tamamla',
      emoji: '\ud83c\udfc6',
      gradient: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      requiredCount: 10,
      category: 'quiz',
    ),
    Achievement(
      id: 'perfect_score',
      title: 'M\u00fckemmel Skor',
      description: 'Bir quiz\'de t\u00fcm sorular\u0131 do\u011fru cevapla',
      emoji: '\ud83d\udcaf',
      gradient: [Color(0xFF10B981), Color(0xFF34D399)],
      requiredCount: 1,
      category: 'quiz',
    ),
    // Social
    Achievement(
      id: 'first_share',
      title: 'Payla\u015f\u0131mc\u0131',
      description: '\u0130lk payla\u015f\u0131m\u0131n\u0131 yap',
      emoji: '\ud83d\udce4',
      gradient: [Color(0xFFEC4899), Color(0xFFF472B6)],
      requiredCount: 1,
      category: 'social',
    ),
    Achievement(
      id: 'compatibility_check',
      title: 'A\u015fk Dedektifi',
      description: '5 bur\u00e7 uyumu kontrol et',
      emoji: '\ud83d\udc95',
      gradient: [Color(0xFFE11D48), Color(0xFFFB7185)],
      requiredCount: 5,
      category: 'social',
    ),
    // Explore
    Achievement(
      id: 'tarot_reader',
      title: 'Tarot Ustas\u0131',
      description: '10 tarot fal\u0131 bakt\u0131r',
      emoji: '\ud83c\udccf',
      gradient: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
      requiredCount: 10,
      category: 'explore',
    ),
    Achievement(
      id: 'dream_explorer',
      title: 'R\u00fcya K\u00e2\u015fifi',
      description: '5 r\u00fcya yorumlat',
      emoji: '\ud83c\udf0c',
      gradient: [Color(0xFF4C1D95), Color(0xFF5B21B6)],
      requiredCount: 5,
      category: 'explore',
    ),
    Achievement(
      id: 'cosmic_collector',
      title: 'Kozmik Koleksiyoncu',
      description: 'T\u00fcm e\u011flenceli \u00f6zellikleri dene',
      emoji: '\ud83c\udf08',
      gradient: [Color(0xFFDB2777), Color(0xFFBE185D)],
      requiredCount: 6,
      category: 'explore',
    ),
  ];
}
