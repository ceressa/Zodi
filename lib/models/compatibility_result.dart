class CompatibilityResult {
  final int score;
  final String summary;
  final CompatibilityAspects aspects;

  CompatibilityResult({
    required this.score,
    required this.summary,
    required this.aspects,
  });

  factory CompatibilityResult.fromJson(Map<String, dynamic> json) {
    return CompatibilityResult(
      score: json['score'] ?? 0,
      summary: json['summary'] ?? '',
      aspects: CompatibilityAspects.fromJson(json['aspects'] ?? {}),
    );
  }
}

class CompatibilityAspects {
  final int love;
  final int communication;
  final int trust;

  CompatibilityAspects({
    required this.love,
    required this.communication,
    required this.trust,
  });

  factory CompatibilityAspects.fromJson(Map<String, dynamic> json) {
    return CompatibilityAspects(
      love: json['love'] ?? 0,
      communication: json['communication'] ?? 0,
      trust: json['trust'] ?? 0,
    );
  }
}
