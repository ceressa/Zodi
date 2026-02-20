import 'package:flutter/material.dart';
import 'share_card_base.dart';

/// Günlük fal paylaşım kartı — premium tasarım
class DailyShareCard extends StatelessWidget {
  final String zodiacSymbol;
  final String zodiacName;
  final String motto;
  final String commentary;
  final int love;
  final int money;
  final int health;
  final int career;
  final String luckyColor;
  final int luckyNumber;

  const DailyShareCard({
    super.key,
    required this.zodiacSymbol,
    required this.zodiacName,
    required this.motto,
    required this.commentary,
    required this.love,
    required this.money,
    required this.health,
    required this.career,
    required this.luckyColor,
    required this.luckyNumber,
  });

  @override
  Widget build(BuildContext context) {
    return ShareCardBase(
      zodiacSymbol: zodiacSymbol,
      zodiacName: zodiacName,
      featureTag: 'Günlük Fal',
      child: Column(
        children: [
          // === Büyük burç sembolü — glow circle ===
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFF2D1B69), Color(0xFF1A0A3E)],
              ),
              border: Border.all(
                width: 2,
                color: const Color(0xFFE879F9).withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(0.30),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
                BoxShadow(
                  color: const Color(0xFFA78BFA).withOpacity(0.15),
                  blurRadius: 80,
                  spreadRadius: 20,
                ),
              ],
            ),
            child: Center(
              child: Text(zodiacSymbol, style: const TextStyle(fontSize: 90)),
            ),
          ),

          const SizedBox(height: 40),

          // === Motto — glassmorphism kutu ===
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(0.08),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFC084FC), Color(0xFFE879F9)],
                  ).createShader(bounds),
                  child: const Text(
                    '\u201C',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  motto,
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.85),
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),

          // === 4 Metrik — 2x2 grid ===
          Row(
            children: [
              Expanded(child: _buildMetricTile('💕', 'Aşk', love, const Color(0xFFF472B6))),
              const SizedBox(width: 14),
              Expanded(child: _buildMetricTile('💰', 'Para', money, const Color(0xFFFBBF24))),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildMetricTile('💪', 'Sağlık', health, const Color(0xFF34D399))),
              const SizedBox(width: 14),
              Expanded(child: _buildMetricTile('💼', 'Kariyer', career, const Color(0xFF60A5FA))),
            ],
          ),

          const SizedBox(height: 30),

          // === Şanslı renk & sayı ===
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLuckyPill('🎨', luckyColor),
              const SizedBox(width: 16),
              _buildLuckyPill('🔢', '$luckyNumber'),
            ],
          ),

          const Spacer(),

          // === Yorum özeti ===
          Text(
            commentary.length > 160
                ? '${commentary.substring(0, 160)}...'
                : commentary,
            style: TextStyle(
              fontSize: 21,
              color: Colors.white.withOpacity(0.4),
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String emoji, String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 19,
                      color: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                '%$value',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: value / 100,
                backgroundColor: Colors.white.withOpacity(0.06),
                valueColor: AlwaysStoppedAnimation(color.withOpacity(0.7)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyPill(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFBBF24).withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFFBBF24).withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 20,
              color: const Color(0xFFFBBF24).withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
