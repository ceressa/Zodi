class WeeklyHoroscope {
  final String zodiacSign;
  final String weekRange;
  final String summary;
  final String love;
  final String career;
  final String health;
  final String money;
  final List<String> highlights;
  final List<String> warnings;

  WeeklyHoroscope({
    required this.zodiacSign,
    required this.weekRange,
    required this.summary,
    required this.love,
    required this.career,
    required this.health,
    required this.money,
    required this.highlights,
    required this.warnings,
  });

  factory WeeklyHoroscope.fromJson(Map<String, dynamic> json) {
    return WeeklyHoroscope(
      zodiacSign: json['zodiacSign'] ?? '',
      weekRange: json['weekRange'] ?? '',
      summary: json['summary'] ?? '',
      love: json['love'] ?? '',
      career: json['career'] ?? '',
      health: json['health'] ?? '',
      money: json['money'] ?? '',
      highlights: List<String>.from(json['highlights'] ?? []),
      warnings: List<String>.from(json['warnings'] ?? []),
    );
  }
}
