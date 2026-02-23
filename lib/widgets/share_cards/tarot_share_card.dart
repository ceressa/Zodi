import 'package:flutter/material.dart';
import 'share_card_base.dart';

/// Tarot fali paylasim karti — premium tasarim
class TarotShareCard extends StatelessWidget {
  final String cardName;
  final String interpretation;
  final String? zodiacSymbol;
  final String? zodiacName;
  final bool isThreeCard;
  final List<String>? threeCardNames;

  const TarotShareCard({
    super.key,
    required this.cardName,
    required this.interpretation,
    this.zodiacSymbol,
    this.zodiacName,
    this.isThreeCard = false,
    this.threeCardNames,
  });

  @override
  Widget build(BuildContext context) {
    return ShareCardBase(
      zodiacSymbol: zodiacSymbol,
      zodiacName: zodiacName,
      featureTag: 'Tarot',
      backgroundColors: const [
        Color(0xFF080510),
        Color(0xFF0F0A20),
        Color(0xFF1A1035),
        Color(0xFF0F0A20),
        Color(0xFF080510),
      ],
      child: Column(
        children: [
          const SizedBox(height: 10),

          if (isThreeCard && threeCardNames != null) ...[
            // === Uc kart spread ===
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMiniCard(threeCardNames![0], 'Gecmis', const Color(0xFF7C3AED)),
                const SizedBox(width: 16),
                _buildMiniCard(threeCardNames![1], 'Simdi', const Color(0xFFC084FC)),
                const SizedBox(width: 16),
                _buildMiniCard(threeCardNames![2], 'Gelecek', const Color(0xFFE879F9)),
              ],
            ),
          ] else ...[
            // === Tek kart ===
            _buildSingleCard(),
          ],

          const SizedBox(height: 36),

          // === Yorum kutusu — glassmorphism ===
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.06),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baslik
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFC084FC).withValues(alpha: 0.3),
                              const Color(0xFFE879F9).withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Text('\u{1F52E}', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFC084FC), Color(0xFFE879F9)],
                        ).createShader(bounds),
                        child: const Text(
                          'Kartlarin Mesaji',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Ayirici
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFC084FC).withValues(alpha: 0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Yorum metni
                  Expanded(
                    child: Text(
                      interpretation.length > 380
                          ? '${interpretation.substring(0, 380)}...'
                          : interpretation,
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white.withValues(alpha: 0.6),
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleCard() {
    return Container(
      width: 300,
      height: 440,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1048), Color(0xFF2D1B69)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.30),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.10),
            blurRadius: 50,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Kose dekorasyon
          Positioned(
            top: 16,
            left: 16,
            child: _cornerDecor(),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Transform.scale(scaleX: -1, child: _cornerDecor()),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Transform.scale(scaleY: -1, child: _cornerDecor()),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Transform.scale(scaleX: -1, scaleY: -1, child: _cornerDecor()),
          ),
          // Icerik
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('\u{1F0CF}', style: TextStyle(fontSize: 80)),
                const SizedBox(height: 24),
                Container(
                  width: 80,
                  height: 1,
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    cardName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cornerDecor() {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(painter: _CornerPainter()),
    );
  }

  Widget _buildMiniCard(String name, String label, Color accentColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 17,
            color: accentColor.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 190,
          height: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentColor.withValues(alpha: 0.15),
                accentColor.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.08),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('\u{1F0CF}', style: TextStyle(fontSize: 50)),
              const SizedBox(height: 14),
              Container(
                width: 40,
                height: 1,
                color: accentColor.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.45)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset.zero, Offset(size.width * 0.6, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, size.height * 0.6), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
