class MonthlyHoroscope {
  final String zodiacSign;
  final String month;
  final String overview;
  final String love;
  final String career;
  final String health;
  final String money;
  final List<String> keyDates;
  final List<String> opportunities;
  final int loveScore;
  final int careerScore;
  final int healthScore;
  final int moneyScore;

  MonthlyHoroscope({
    required this.zodiacSign,
    required this.month,
    required this.overview,
    required this.love,
    required this.career,
    required this.health,
    required this.money,
    required this.keyDates,
    required this.opportunities,
    required this.loveScore,
    required this.careerScore,
    required this.healthScore,
    required this.moneyScore,
  });

  factory MonthlyHoroscope.fromJson(Map<String, dynamic> json) {
    return MonthlyHoroscope(
      zodiacSign: json['zodiacSign'] ?? '',
      month: json['month'] ?? '',
      overview: json['overview'] ?? '',
      love: json['love'] ?? '',
      career: json['career'] ?? '',
      health: json['health'] ?? '',
      money: json['money'] ?? '',
      keyDates: List<String>.from(json['keyDates'] ?? []),
      opportunities: List<String>.from(json['opportunities'] ?? []),
      loveScore: json['loveScore'] ?? 50,
      careerScore: json['careerScore'] ?? 50,
      healthScore: json['healthScore'] ?? 50,
      moneyScore: json['moneyScore'] ?? 50,
    );
  }
}
