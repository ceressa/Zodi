import 'package:flutter/material.dart';
import '../../models/beauty_day.dart';
import '../moon_phase_widget.dart';
import 'share_card_base.dart';

/// Güzellik takvimi günü paylaşım kartı — premium tasarım
class BeautyShareCard extends StatelessWidget {
  final BeautyDay beautyDay;
  final String? zodiacSymbol;
  final String? zodiacName;

  const BeautyShareCard({
    super.key,
    required this.beautyDay,
    this.zodiacSymbol,
    this.zodiacName,
  });

  @override
  Widget build(BuildContext context) {
    return ShareCardBase(
      zodiacSymbol: zodiacSymbol,
      zodiacName: zodiacName,
      featureTag: 'Güzellik Takvimi',
      backgroundColors: const [
        Color(0xFF0A0614),
        Color(0xFF120C24),
        Color(0xFF1E1338),
        Color(0xFF120C24),
        Color(0xFF0A0614),
      ],
      child: Column(
        children: [
          // === Ay fazı görseli ===
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFBBF24).withOpacity(0.08),
                  blurRadius: 40,
                  spreadRadius: 15,
                ),
              ],
            ),
            child: MoonPhaseWidget(
              phase: beautyDay.moonPhase,
              size: 160,
            ),
          ),
          const SizedBox(height: 20),

          // === Ay fazı adı ===
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFDE68A), Color(0xFFFBBF24)],
            ).createShader(bounds),
            child: Text(
              beautyDay.moonPhase.turkishName,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ay Burcu: ${beautyDay.moonSign}',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white.withOpacity(0.35),
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 40),

          // === Güzellik puanları ===
          _buildRatingRow('✂️', 'Saç Kesimi', beautyDay.hairCut),
          const SizedBox(height: 14),
          _buildRatingRow('🎨', 'Saç Boyama', beautyDay.hairDye),
          const SizedBox(height: 14),
          _buildRatingRow('💆', 'Cilt Bakımı', beautyDay.skinCare),
          const SizedBox(height: 14),
          _buildRatingRow('💅', 'Tırnak Bakımı', beautyDay.nailCare),

          const Spacer(),

          // === AI tavsiyesi ===
          if (beautyDay.aiTip != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFC084FC).withOpacity(0.1),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFC084FC).withOpacity(0.1),
                    ),
                    child: const Center(
                      child: Text('💡', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    beautyDay.aiTip!,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white.withOpacity(0.5),
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRatingRow(String emoji, String label, BeautyRating rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        color: rating.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: rating.color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: rating.color.withOpacity(0.08),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: rating.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(rating.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  rating.turkishName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: rating.color.withOpacity(0.9),
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
