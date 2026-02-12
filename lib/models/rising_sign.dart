import 'zodiac_sign.dart';

class RisingSignResult {
  final ZodiacSign sunSign;
  final ZodiacSign risingSign;
  final ZodiacSign moonSign;
  final String personality;
  final String strengths;
  final String weaknesses;
  final String lifeApproach;
  final String relationships;

  RisingSignResult({
    required this.sunSign,
    required this.risingSign,
    required this.moonSign,
    required this.personality,
    required this.strengths,
    required this.weaknesses,
    required this.lifeApproach,
    required this.relationships,
  });

  factory RisingSignResult.fromJson(Map<String, dynamic> json) {
    return RisingSignResult(
      sunSign: ZodiacSign.values.firstWhere(
        (z) => z.name == json['sunSign'],
        orElse: () => ZodiacSign.aries,
      ),
      risingSign: ZodiacSign.values.firstWhere(
        (z) => z.name == json['risingSign'],
        orElse: () => ZodiacSign.aries,
      ),
      moonSign: ZodiacSign.values.firstWhere(
        (z) => z.name == json['moonSign'],
        orElse: () => ZodiacSign.aries,
      ),
      personality: json['personality'] ?? '',
      strengths: json['strengths'] ?? '',
      weaknesses: json['weaknesses'] ?? '',
      lifeApproach: json['lifeApproach'] ?? '',
      relationships: json['relationships'] ?? '',
    );
  }
}
