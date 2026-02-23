import 'package:flutter/material.dart';
import 'share_card_base.dart';

/// Haftalik burc yorumu paylasim karti — gun emoji gostergeli
class WeeklyShareCard extends StatelessWidget {
  final String weekRange;
  final String summary;
  final String love;
  final String career;
  final String health;
  final String money;
  final List<String> highlights;
  final String? zodiacSymbol;
  final String? zodiacName;

  /// Her gun icin emoji gostergesi (7 eleman).
  /// Ornek: ['\u{2B50}', '\u{1F525}', '\u{1F4AB}', '\u{2764}\u{FE0F}', '\u{26A1}', '\u{1F31F}', '\u{1F389}']
  /// Bos birakildiyinda varsayilan emoji seti kullanilir.
  final List<String>? dayEmojis;

  const WeeklyShareCard({
    super.key,
    required this.weekRange,
    required this.summary,
    required this.love,
    required this.career,
    required this.health,
    required this.money,
    required this.highlights,
    this.zodiacSymbol,
    this.zodiacName,
    this.dayEmojis,
  });

  static const _defaultDayEmojis = [
    '\u{2B50}', // Pzt
    '\u{1F525}', // Sal
    '\u{1F4AB}', // Car
    '\u{2764}\u{FE0F}', // Per
    '\u{26A1}', // Cum
    '\u{1F31F}', // Cmt
    '\u{1F389}', // Paz
  ];

  static const _dayLabels = ['Pzt', 'Sal', 'Car', 'Per', 'Cum', 'Cmt', 'Paz'];

  @override
  Widget build(BuildContext context) {
    final emojis = dayEmojis ?? _defaultDayEmojis;

    return ShareCardBase(
      zodiacSymbol: zodiacSymbol,
      zodiacName: zodiacName,
      featureTag: 'Haftalik Yorum',
      child: Column(
        children: [
          // === Hafta araligi badge ===
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Text(
              weekRange,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.8),
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // === 7 Gun Emoji Gostergesi ===
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (i) {
                return Column(
                  children: [
                    Text(
                      _dayLabels[i],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.35),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
                        border: Border.all(
                          color: const Color(0xFFA78BFA).withValues(alpha: 0.12),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          i < emojis.length ? emojis[i] : '\u{2B50}',
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: 20),

          // === Ozet — glassmorphism ===
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
            child: Text(
              summary,
              style: TextStyle(
                fontSize: 19,
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 20),

          // === 4 Alan Kartlari — 2x2 Grid ===
          Row(
            children: [
              Expanded(
                child: _buildAreaCard('\u{1F497}', 'Ask', love, const Color(0xFFF472B6)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildAreaCard('\u{1F4B0}', 'Para', money, const Color(0xFFFBBF24)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildAreaCard('\u{1F4AA}', 'Saglik', health, const Color(0xFF34D399)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildAreaCard('\u{1F3AF}', 'Kariyer', career, const Color(0xFF60A5FA)),
              ),
            ],
          ),

          // === One Cikanlar ===
          if (highlights.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF59E0B).withValues(alpha: 0.08),
                    const Color(0xFFF59E0B).withValues(alpha: 0.03),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('\u{2B50}', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        'One Cikanlar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFCD34D).withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...highlights.take(3).map((h) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\u{2022}  ',
                              style: TextStyle(
                                fontSize: 18,
                                color: const Color(0xFFFCD34D).withValues(alpha: 0.6),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                h,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withValues(alpha: 0.55),
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildAreaCard(String emoji, String label, String text, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.5),
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
