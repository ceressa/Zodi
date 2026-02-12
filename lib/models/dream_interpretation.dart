class DreamInterpretation {
  final String dreamText;
  final String interpretation;
  final String symbolism;
  final String emotionalMeaning;
  final String advice;
  final List<String> keywords;
  final String mood; // positive, negative, neutral, mixed

  DreamInterpretation({
    required this.dreamText,
    required this.interpretation,
    required this.symbolism,
    required this.emotionalMeaning,
    required this.advice,
    required this.keywords,
    required this.mood,
  });

  factory DreamInterpretation.fromJson(Map<String, dynamic> json) {
    return DreamInterpretation(
      dreamText: json['dreamText'] ?? '',
      interpretation: json['interpretation'] ?? '',
      symbolism: json['symbolism'] ?? '',
      emotionalMeaning: json['emotionalMeaning'] ?? '',
      advice: json['advice'] ?? '',
      keywords: List<String>.from(json['keywords'] ?? []),
      mood: json['mood'] ?? 'neutral',
    );
  }
}
