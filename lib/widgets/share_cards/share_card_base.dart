import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Tüm paylaşım kartlarının premium base widget'ı
/// Instagram Story boyutu: 1080x1920 piksel
class ShareCardBase extends StatelessWidget {
  final Widget child;
  final String? zodiacSymbol;
  final String? zodiacName;
  final String? featureTag;
  final List<Color>? backgroundColors;
  final bool showZodiacBadge;

  const ShareCardBase({
    super.key,
    required this.child,
    this.zodiacSymbol,
    this.zodiacName,
    this.featureTag,
    this.backgroundColors,
    this.showZodiacBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final bgColors = backgroundColors ??
        const [
          Color(0xFF0A0612),
          Color(0xFF140E24),
          Color(0xFF1E1338),
          Color(0xFF140E24),
          Color(0xFF0A0612),
        ];

    final dateStr = DateFormat('dd MMMM yyyy', 'tr_TR').format(DateTime.now());

    return Container(
      width: 1080,
      height: 1920,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: bgColors,
          stops: bgColors.length == 5
              ? const [0.0, 0.25, 0.5, 0.75, 1.0]
              : null,
        ),
      ),
      child: Stack(
        children: [
          // === NEBULA / GLOW efektleri ===
          Positioned(
            top: -150,
            right: -120,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFF1493).withOpacity(0.08),
                    const Color(0xFFFF1493).withOpacity(0.02),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 600,
            left: -200,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF9400D3).withOpacity(0.06),
                    const Color(0xFF9400D3).withOpacity(0.01),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 450,
              height: 450,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7C3AED).withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // === Yıldız partikülleri ===
          ...List.generate(60, (i) {
            final rng = Random(i * 37 + 13);
            final size = rng.nextDouble() * 3 + 0.5;
            final opacity = rng.nextDouble() * 0.25 + 0.05;
            return Positioned(
              left: rng.nextDouble() * 1080,
              top: rng.nextDouble() * 1920,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(opacity),
                  boxShadow: size > 2
                      ? [
                          BoxShadow(
                            color: Colors.white.withOpacity(opacity * 0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),

          // === Üst accent çizgi ===
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Color(0xFFE879F9),
                    Color(0xFFC084FC),
                    Color(0xFFA78BFA),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // === Ana içerik ===
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56),
            child: Column(
              children: [
                const SizedBox(height: 70),

                // === HEADER ===
                _buildHeader(dateStr),

                // === Burç badge ===
                if (showZodiacBadge &&
                    zodiacSymbol != null &&
                    zodiacName != null) ...[
                  const SizedBox(height: 36),
                  _buildZodiacBadge(),
                ],

                const SizedBox(height: 32),

                // === İçerik ===
                Expanded(child: child),

                // === Footer ===
                const SizedBox(height: 24),
                _buildFooter(),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String dateStr) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Zodi Logo — rounded square
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFA78BFA),
                Color(0xFFC084FC),
                Color(0xFFE879F9),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC084FC).withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Zodi text
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFA78BFA), Color(0xFFE879F9)],
          ).createShader(bounds),
          child: const Text(
            'Zodi',
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),

        const Spacer(),

        // Feature tag + tarih
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (featureTag != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE879F9), Color(0xFFC084FC)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE879F9).withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  featureTag!,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              dateStr,
              style: TextStyle(
                fontSize: 17,
                color: Colors.white.withOpacity(0.35),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildZodiacBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE879F9).withOpacity(0.12),
            const Color(0xFFA78BFA).withOpacity(0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: const Color(0xFFE879F9).withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(zodiacSymbol!, style: const TextStyle(fontSize: 34)),
          const SizedBox(width: 14),
          Text(
            zodiacName!,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        // Ayırıcı
        Container(
          width: 200,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.12),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // CTA
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFA78BFA).withOpacity(0.1),
                const Color(0xFFE879F9).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: const Color(0xFFA78BFA).withOpacity(0.12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA78BFA), Color(0xFFE879F9)],
                  ),
                ),
                child: const Center(
                  child:
                      Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Zodi ile falına bak',
                style: TextStyle(
                  fontSize: 19,
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '#Zodi  #Astroloji  #Burçlar',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.18),
            letterSpacing: 2,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
