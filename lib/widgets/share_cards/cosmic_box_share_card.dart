import 'package:flutter/material.dart';
import 'share_card_base.dart';

/// Kozmik kutu ödül paylaşım kartı — altın/parlak tema
class CosmicBoxShareCard extends StatelessWidget {
  final String rewardType;
  final String rewardTitle;
  final String rewardName;
  final String rewardEmoji;
  final String rewardDescription;
  final String? zodiacSymbol;
  final String? zodiacName;

  const CosmicBoxShareCard({
    super.key,
    required this.rewardType,
    required this.rewardTitle,
    required this.rewardName,
    required this.rewardEmoji,
    required this.rewardDescription,
    this.zodiacSymbol,
    this.zodiacName,
  });

  @override
  Widget build(BuildContext context) {
    return ShareCardBase(
      zodiacSymbol: zodiacSymbol,
      zodiacName: zodiacName,
      featureTag: 'Kozmik Kutu',
      backgroundColors: const [
        Color(0xFF0C0A1A),
        Color(0xFF1A1030),
        Color(0xFF241840),
        Color(0xFF1A1030),
        Color(0xFF0C0A1A),
      ],
      child: Column(
        children: [
          // === Hediye kutusu — büyük animasyonlu emoji ===
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF7C3AED).withOpacity(0.20),
                  const Color(0xFF7C3AED).withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
            child: Center(
              child: Text(rewardEmoji, style: const TextStyle(fontSize: 100)),
            ),
          ),

          const SizedBox(height: 28),

          // === Ödül başlığı ===
          Text(
            rewardTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.4),
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 10),

          // === Ödül adı — büyük ve parlak ===
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFCD34D), Color(0xFFF59E0B), Color(0xFFFCD34D)],
            ).createShader(bounds),
            child: Text(
              rewardName,
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 36),

          // === Açıklama — glassmorphism kutu ===
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFF59E0B).withOpacity(0.10),
                width: 1,
              ),
            ),
            child: Text(
              rewardDescription,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white.withOpacity(0.65),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
              maxLines: 8,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 32),

          // === Dekoratif "Günün Sürprizi" badge ===
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withOpacity(0.30),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Text(
              "Günün Sürprizi",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
