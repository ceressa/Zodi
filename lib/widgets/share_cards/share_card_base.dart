import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Tum paylasim kartlarinin premium base widget'i
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
          // === NEBULA / GLOW efektleri — kozmik mor palette ===
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
                    const Color(0xFF7C3AED).withValues(alpha:0.10),
                    const Color(0xFF7C3AED).withValues(alpha:0.03),
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
                    const Color(0xFFA78BFA).withValues(alpha:0.07),
                    const Color(0xFFA78BFA).withValues(alpha:0.02),
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
                    const Color(0xFFC084FC).withValues(alpha:0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // === Yildiz partikulleri ===
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
                  color: Colors.white.withValues(alpha:opacity),
                  boxShadow: size > 2
                      ? [
                          BoxShadow(
                            color: Colors.white.withValues(alpha:opacity * 0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),

          // === Ust accent cizgi ===
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
                    Color(0xFFA78BFA),
                    Color(0xFF7C3AED),
                    Color(0xFFA78BFA),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // === Maskot — sag alt kose dekoratif ===
          Positioned(
            bottom: 40,
            right: -10,
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                'assets/astro_dozi_main.webp',
                width: 240,
                height: 240,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),

          // === Ana icerik ===
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56),
            child: Column(
              children: [
                const SizedBox(height: 70),

                // === HEADER — gercek logo asset ===
                _buildHeader(dateStr),

                // === Burc badge — glassmorphism ===
                if (showZodiacBadge &&
                    zodiacSymbol != null &&
                    zodiacName != null) ...[
                  const SizedBox(height: 36),
                  _buildZodiacBadge(),
                ],

                const SizedBox(height: 32),

                // === Icerik ===
                Expanded(child: child),

                // === Footer — logo + bardino + hashtag ===
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
        // Astro Dozi Logo — gercek asset
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withValues(alpha:0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              'assets/astro_dozi_logo.webp',
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Astro Dozi text — shimmer
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFA78BFA), Color(0xFFC084FC)],
          ).createShader(bounds),
          child: const Text(
            'Astro Dozi',
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),

        const Spacer(),

        // Feature tag (goldenStar) + tarih
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (featureTag != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha:0.30),
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
                color: Colors.white.withValues(alpha:0.35),
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
        color: Colors.white.withValues(alpha:0.06),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: Colors.white.withValues(alpha:0.12),
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
        // Ayirici
        Container(
          width: 300,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.white.withValues(alpha:0.15),
                Colors.white.withValues(alpha:0.15),
                Colors.transparent,
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),
        const SizedBox(height: 22),

        // CTA — güçlendirilmiş viral mesaj
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF7C3AED).withValues(alpha:0.18),
                const Color(0xFFA78BFA).withValues(alpha:0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: const Color(0xFF7C3AED).withValues(alpha:0.20),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mini logo asset
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/astro_dozi_logo.webp',
                  width: 34,
                  height: 34,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Astro Dozi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Sen de kesfet!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha:0.45),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Bardino logo
        Opacity(
          opacity: 0.25,
          child: Image.asset(
            'assets/bardino_logo.webp',
            height: 24,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Text(
              'Bardino Technology',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha:0.2),
                letterSpacing: 1,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        Text(
          '#AstroDozi  #Astroloji  #BurcYorumu',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha:0.20),
            letterSpacing: 2,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
