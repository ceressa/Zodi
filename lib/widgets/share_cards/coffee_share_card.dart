import 'dart:io';
import 'package:flutter/material.dart';
import 'share_card_base.dart';

/// Kahve falı paylaşım kartı — premium tasarım
class CoffeeShareCard extends StatelessWidget {
  final File? cupImage;
  final String? loveReading;
  final String? careerReading;
  final String? generalReading;
  final String? luckyMessage;
  final String? zodiacSymbol;
  final String? zodiacName;

  const CoffeeShareCard({
    super.key,
    this.cupImage,
    this.loveReading,
    this.careerReading,
    this.generalReading,
    this.luckyMessage,
    this.zodiacSymbol,
    this.zodiacName,
  });

  @override
  Widget build(BuildContext context) {
    return ShareCardBase(
      zodiacSymbol: zodiacSymbol,
      zodiacName: zodiacName,
      featureTag: 'Kahve Falı',
      backgroundColors: const [
        Color(0xFF0A0806),
        Color(0xFF1A1208),
        Color(0xFF2A1E0E),
        Color(0xFF1A1208),
        Color(0xFF0A0806),
      ],
      child: Column(
        children: [
          // === Fincan görseli ===
          if (cupImage != null)
            Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFD4A574).withOpacity(0.25),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD97706).withOpacity(0.15),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.file(
                  cupImage!,
                  width: 260,
                  height: 260,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildFallbackCup(),
                ),
              ),
            )
          else
            _buildFallbackCup(),

          const SizedBox(height: 36),

          // === Okuma kartları ===
          if (loveReading != null)
            _buildReadingRow('💕', 'Aşk', loveReading!, const Color(0xFFF472B6)),
          if (careerReading != null)
            _buildReadingRow('💼', 'Kariyer', careerReading!, const Color(0xFFFBBF24)),
          if (generalReading != null)
            _buildReadingRow('✨', 'Genel', generalReading!, const Color(0xFFD4A574)),

          const Spacer(),

          // === Şanslı mesaj ===
          if (luckyMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFD97706).withOpacity(0.15),
                    const Color(0xFFFBBF24).withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFD97706).withOpacity(0.15),
                ),
              ),
              child: Row(
                children: [
                  const Text('🍀', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      luckyMessage!,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFBBF24).withOpacity(0.8),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFallbackCup() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFF3D2B1F).withOpacity(0.6),
            const Color(0xFF2A1E0E),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFD4A574).withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withOpacity(0.12),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Center(
        child: Text('☕', style: TextStyle(fontSize: 80)),
      ),
    );
  }

  Widget _buildReadingRow(
      String emoji, String title, String content, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor.withOpacity(0.08)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withOpacity(0.1),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: accentColor.withOpacity(0.8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content.length > 90
                        ? '${content.substring(0, 90)}...'
                        : content,
                    style: TextStyle(
                      fontSize: 19,
                      color: Colors.white.withOpacity(0.5),
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
