import 'package:intl/intl.dart';

class EmojiForecast {
  final DateTime date;
  final String emoji;
  final int moodScore;
  final String keyword;

  EmojiForecast({
    required this.date,
    required this.emoji,
    required this.moodScore,
    required this.keyword,
  });

  factory EmojiForecast.fromJson(Map<String, dynamic> json, DateTime date) {
    final score = (json['moodScore'] as num?)?.toInt() ?? 50;
    return EmojiForecast(
      date: date,
      emoji: json['emoji'] ?? _emojiFromScore(score),
      moodScore: score,
      keyword: json['keyword'] ?? 'Notr',
    );
  }

  static String _emojiFromScore(int score) {
    if (score >= 80) return '\u{1F525}';
    if (score >= 60) return '\u{2728}';
    if (score >= 40) return '\u{1F324}';
    if (score >= 20) return '\u{1F325}';
    return '\u{1F327}';
  }

  String get dayName {
    return DateFormat('EEE', 'tr_TR').format(date);
  }

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
