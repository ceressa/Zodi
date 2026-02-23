import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'share_card_base.dart';

/// Ruh Eşi Çizimi paylaşım kartı — Instagram Story formatı
class SoulmateSketchShareCard extends StatelessWidget {
  final Uint8List imageBytes;
  final String? zodiacSymbol;
  final String? zodiacName;

  const SoulmateSketchShareCard({
    super.key,
    required this.imageBytes,
    this.zodiacSymbol,
    this.zodiacName,
  });

  @override
  Widget build(BuildContext context) {
    return ShareCardBase(
      zodiacSymbol: zodiacSymbol,
      zodiacName: zodiacName,
      featureTag: 'Ruh Eşi Çizimi',
      showZodiacBadge: false,
      backgroundColors: const [
        Color(0xFF0A0612),
        Color(0xFF1A0A2E),
        Color(0xFF2D1145),
        Color(0xFF1A0A2E),
        Color(0xFF0A0612),
      ],
      child: Column(
        children: [
          // === Başlık — kompakt ===
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('💘', style: TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ruh Eşimin Portresi',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Doğum haritama göre oluşturuldu',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // === Portre görseli — daha büyük ===
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE91E63).withValues(alpha: 0.25),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                    blurRadius: 50,
                    offset: const Offset(0, -8),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // === Burç badge — alt kısımda ===
          if (zodiacSymbol != null && zodiacName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(zodiacSymbol!, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    zodiacName!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
