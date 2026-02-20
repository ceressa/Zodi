import 'package:flutter/material.dart';
import 'share_card_base.dart';

/// Uyum analizi paylaşım kartı — premium tasarım
class CompatibilityShareCard extends StatelessWidget {
  final String sign1Symbol;
  final String sign1Name;
  final String sign2Symbol;
  final String sign2Name;
  final int overallScore;
  final int loveScore;
  final int communicationScore;
  final int trustScore;
  final String summary;

  const CompatibilityShareCard({
    super.key,
    required this.sign1Symbol,
    required this.sign1Name,
    required this.sign2Symbol,
    required this.sign2Name,
    required this.overallScore,
    required this.loveScore,
    required this.communicationScore,
    required this.trustScore,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return ShareCardBase(
      featureTag: 'Burç Uyumu',
      showZodiacBadge: false,
      backgroundColors: const [
        Color(0xFF080510),
        Color(0xFF100820),
        Color(0xFF1A0E35),
        Color(0xFF100820),
        Color(0xFF080510),
      ],
      child: Column(
        children: [
          const SizedBox(height: 10),

          // === İki burç — merkez kompozisyon ===
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSignCircle(sign1Symbol, sign1Name),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Kalp glow
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF472B6).withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('💕', style: TextStyle(fontSize: 36)),
                      ),
                    ),
                  ],
                ),
              ),
              _buildSignCircle(sign2Symbol, sign2Name),
            ],
          ),

          const SizedBox(height: 44),

          // === Büyük skor dairesi — ring style ===
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              border: Border.all(
                color: _getScoreColor(overallScore).withOpacity(0.30),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getScoreColor(overallScore).withOpacity(0.18),
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
                BoxShadow(
                  color: _getScoreColor(overallScore).withOpacity(0.08),
                  blurRadius: 80,
                  spreadRadius: 20,
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _getScoreColor(overallScore).withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        _getScoreColor(overallScore),
                        _getScoreColor(overallScore).withOpacity(0.7),
                      ],
                    ).createShader(bounds),
                    child: Text(
                      '%$overallScore',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    'Uyum',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white.withOpacity(0.4),
                      fontWeight: FontWeight.w400,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 44),

          // === Alt skorlar ===
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSubScore('💕', 'Aşk', loveScore, const Color(0xFFF472B6)),
              _buildSubScore('💬', 'İletişim', communicationScore, const Color(0xFF60A5FA)),
              _buildSubScore('🤝', 'Güven', trustScore, const Color(0xFF34D399)),
            ],
          ),

          const SizedBox(height: 36),

          // === Özet ===
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.10),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withOpacity(0.06),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                summary.length > 220
                    ? '${summary.substring(0, 220)}...'
                    : summary,
                style: TextStyle(
                  fontSize: 21,
                  color: Colors.white.withOpacity(0.5),
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignCircle(String symbol, String name) {
    return Column(
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF2D1B69),
                const Color(0xFF1A0A3E).withOpacity(0.8),
              ],
            ),
            border: Border.all(
              color: const Color(0xFFA78BFA).withOpacity(0.30),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withOpacity(0.20),
                blurRadius: 24,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Text(symbol, style: const TextStyle(fontSize: 64)),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSubScore(String emoji, String label, int score, Color color) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.08),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 26)),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '%$score',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: color.withOpacity(0.85),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.35),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF34D399);
    if (score >= 60) return const Color(0xFFFBBF24);
    if (score >= 40) return const Color(0xFFFB923C);
    return const Color(0xFFF87171);
  }
}
