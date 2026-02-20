import 'package:flutter/material.dart';
import 'share_card_base.dart';

/// Haftalık burç yorumu paylaşım kartı
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
  });

  @override
  Widget build(BuildContext context) {
    return ShareCardBase(
      zodiacSymbol: zodiacSymbol,
      zodiacName: zodiacName,
      featureTag: 'Haftalık Yorum',
      child: Column(
        children: [
          // === Hafta aralığı badge ===
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
              ),
            ),
            child: Text(
              weekRange,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.8),
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // === Özet — glassmorphism ===
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.10),
              ),
            ),
            child: Text(
              summary,
              style: TextStyle(
                fontSize: 19,
                color: Colors.white.withOpacity(0.7),
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 28),

          // === 4 Alan Kartları — 2x2 Grid ===
          Row(
            children: [
              Expanded(
                child: _buildAreaCard('💗', 'Aşk', love, const Color(0xFFF472B6)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildAreaCard('💰', 'Para', money, const Color(0xFFFBBF24)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildAreaCard('💪', 'Sağlık', health, const Color(0xFF34D399)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildAreaCard('🎯', 'Kariyer', career, const Color(0xFF60A5FA)),
              ),
            ],
          ),

          // === Öne Çıkanlar ===
          if (highlights.isNotEmpty) ...[
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF59E0B).withOpacity(0.08),
                    const Color(0xFFF59E0B).withOpacity(0.03),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withOpacity(0.10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        'Öne Çıkanlar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFCD34D).withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...highlights.take(3).map((h) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '•  ',
                              style: TextStyle(
                                fontSize: 18,
                                color: const Color(0xFFFCD34D).withOpacity(0.6),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                h,
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white.withOpacity(0.55),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withOpacity(0.10),
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
              color: Colors.white.withOpacity(0.5),
              height: 1.4,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
