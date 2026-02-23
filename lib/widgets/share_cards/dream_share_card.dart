import 'package:flutter/material.dart';
import 'share_card_base.dart';

/// Rüya yorumu paylaşım kartı — gece mavisi/mor tema
class DreamShareCard extends StatelessWidget {
  final String dreamText;
  final String mood;
  final List<String> keywords;
  final String interpretation;
  final String symbolism;
  final String advice;
  final String? zodiacSymbol;
  final String? zodiacName;

  const DreamShareCard({
    super.key,
    required this.dreamText,
    required this.mood,
    required this.keywords,
    required this.interpretation,
    required this.symbolism,
    required this.advice,
    this.zodiacSymbol,
    this.zodiacName,
  });

  String get _moodEmoji {
    switch (mood.toLowerCase()) {
      case 'positive':
      case 'pozitif':
        return '🌟';
      case 'negative':
      case 'negatif':
        return '🌑';
      default:
        return '🌓';
    }
  }

  String get _moodText {
    switch (mood.toLowerCase()) {
      case 'positive':
      case 'pozitif':
        return 'Pozitif Enerji';
      case 'negative':
      case 'negatif':
        return 'Uyarıcı Mesaj';
      default:
        return 'Karışık Enerji';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShareCardBase(
      zodiacSymbol: zodiacSymbol,
      zodiacName: zodiacName,
      featureTag: 'Rüya Yorumu',
      backgroundColors: const [
        Color(0xFF050520),
        Color(0xFF0A0A35),
        Color(0xFF12104A),
        Color(0xFF0A0A35),
        Color(0xFF050520),
      ],
      child: Column(
        children: [
          // === Rüya mood + emoji ===
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF312E81),
                  const Color(0xFF1E1B4B),
                ],
              ),
              border: Border.all(
                width: 2,
                color: const Color(0xFF818CF8).withValues(alpha:0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha:0.30),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: const Center(
              child: Text('🌙', style: TextStyle(fontSize: 70)),
            ),
          ),

          const SizedBox(height: 24),

          // === Mood badge ===
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.06),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFF818CF8).withValues(alpha:0.15),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_moodEmoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Text(
                  _moodText,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha:0.8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // === Keywords ===
          if (keywords.isNotEmpty)
            Wrap(
              spacing: 10,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: keywords.take(5).map((kw) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1).withValues(alpha:0.15),
                        const Color(0xFF818CF8).withValues(alpha:0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF818CF8).withValues(alpha:0.12),
                    ),
                  ),
                  child: Text(
                    '#$kw',
                    style: TextStyle(
                      fontSize: 17,
                      color: const Color(0xFFA5B4FC).withValues(alpha:0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 32),

          // === Yorum kutusu ===
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.04),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha:0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('📖', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Text(
                      'Yorumu',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha:0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  interpretation,
                  style: TextStyle(
                    fontSize: 19,
                    color: Colors.white.withValues(alpha:0.6),
                    height: 1.5,
                  ),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // === Tavsiye kutusu ===
          if (advice.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF59E0B).withValues(alpha:0.10),
                    const Color(0xFFF59E0B).withValues(alpha:0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha:0.12),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      advice,
                      style: TextStyle(
                        fontSize: 18,
                        color: const Color(0xFFFCD34D).withValues(alpha:0.8),
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          const Spacer(),
        ],
      ),
    );
  }
}
