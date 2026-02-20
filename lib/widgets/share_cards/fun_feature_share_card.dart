import 'package:flutter/material.dart';
import 'share_card_base.dart';

/// Eğlenceli özellik paylaşım kartı — premium Instagram Story tasarım
class FunFeatureShareCard extends StatelessWidget {
  final String featureTitle;
  final String featureEmoji;
  final String mainResult;
  final String resultEmoji;
  final String description;
  final List<String> details;
  final List<Color> gradientColors;
  final String? zodiacSymbol;
  final String? zodiacName;

  const FunFeatureShareCard({
    super.key,
    required this.featureTitle,
    required this.featureEmoji,
    required this.mainResult,
    required this.resultEmoji,
    required this.description,
    required this.details,
    required this.gradientColors,
    this.zodiacSymbol,
    this.zodiacName,
  });

  @override
  Widget build(BuildContext context) {
    return ShareCardBase(
      zodiacSymbol: zodiacSymbol,
      zodiacName: zodiacName,
      featureTag: featureTitle,
      child: Column(
        children: [
          // === Ana sonuç — büyük emoji + result ===
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  gradientColors.first.withOpacity(0.20),
                  gradientColors.last.withOpacity(0.10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: gradientColors.first.withOpacity(0.15),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(resultEmoji, style: const TextStyle(fontSize: 80)),
                const SizedBox(height: 20),
                Text(
                  mainResult,
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: gradientColors.first,
                    letterSpacing: 0.5,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),

          // === Açıklama — glassmorphism kutu ===
          if (description.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.10),
                  width: 1,
                ),
              ),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white.withOpacity(0.75),
                  height: 1.6,
                ),
                maxLines: 8,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          if (details.isNotEmpty) ...[
            const SizedBox(height: 28),

            // === Detaylar — numaralı liste ===
            ...details.take(4).toList().asMap().entries.map((entry) {
              final idx = entry.key;
              final detail = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradientColors),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '${idx + 1}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          detail,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.65),
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],

          const Spacer(),
        ],
      ),
    );
  }
}
