class DailyHoroscope {
  final String motto;
  final String commentary;
  final int love;
  final int money;
  final int health;
  final int career;
  final String luckyColor;
  final int luckyNumber;
  final DateTime date;

  DailyHoroscope({
    required this.motto,
    required this.commentary,
    required this.love,
    required this.money,
    required this.health,
    required this.career,
    required this.luckyColor,
    required this.luckyNumber,
    required this.date,
  });

  factory DailyHoroscope.fromJson(Map<String, dynamic> json) {
    return DailyHoroscope(
      motto: json['motto'] ?? '',
      commentary: json['commentary'] ?? '',
      love: json['love'] ?? 0,
      money: json['money'] ?? 0,
      health: json['health'] ?? 0,
      career: json['career'] ?? 0,
      luckyColor: json['luckyColor'] ?? '',
      luckyNumber: json['luckyNumber'] ?? 0,
      date: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'motto': motto,
      'commentary': commentary,
      'love': love,
      'money': money,
      'health': health,
      'career': career,
      'luckyColor': luckyColor,
      'luckyNumber': luckyNumber,
    };
  }
}
