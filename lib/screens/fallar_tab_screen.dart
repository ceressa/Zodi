import 'package:flutter/material.dart';
import '../config/fun_feature_config.dart';
import '../theme/cosmic_page_route.dart';
import 'tarot_screen.dart';
import 'coffee_fortune_screen.dart';
import 'dream_screen.dart';
import 'match_screen.dart';
import 'cosmic_oracle_screen.dart';
import 'fun_feature_screen.dart';
import 'soulmate_sketch_screen.dart';
import 'analysis_screen.dart';

/// Fallar sekmesi — gelir ureten ana ozellikler
class FallarTabScreen extends StatelessWidget {
  const FallarTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // ── Ana Fallar ──
          _buildSectionTitle('Fallar'),
          const SizedBox(height: 12),
          _buildMainFortunesGrid(context),

          const SizedBox(height: 28),

          // ── Derinlemesine ──
          _buildSectionTitle('Derinlemesine'),
          const SizedBox(height: 12),
          _buildDeepDiveCarousel(context),

          const SizedBox(height: 28),

          // ── Detayli Analiz ──
          _buildSectionTitle('Detayli Analiz'),
          const SizedBox(height: 12),
          _buildAnalysisCards(context),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1F2937),
        letterSpacing: -0.3,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // ANA FALLAR — 2x2 Grid
  // ══════════════════════════════════════════════════════════

  Widget _buildMainFortunesGrid(BuildContext context) {
    final items = [
      _FortuneItem(
        emoji: '🃏',
        title: 'Tarot Fali',
        subtitle: 'Kartlar ne soyluyor?',
        gradient: const [Color(0xFF7C3AED), Color(0xFF6D28D9)],
        price: '5 ✨ veya 📺',
        onTap: () => Navigator.push(
          context,
          CosmicPageRoute(page: const TarotScreen()),
        ),
      ),
      _FortuneItem(
        emoji: '☕',
        title: 'Kahve Fali',
        subtitle: 'Fincanin dibi seni bekliyor',
        gradient: const [Color(0xFF92400E), Color(0xFF78350F)],
        price: '5 ✨ veya 📺',
        onTap: () => Navigator.push(
          context,
          CosmicPageRoute(page: const CoffeeFortuneScreen()),
        ),
      ),
      _FortuneItem(
        emoji: '🌙',
        title: 'Ruya Yorumu',
        subtitle: 'Ruyan ne anlatiyor?',
        gradient: const [Color(0xFF1E40AF), Color(0xFF1E3A8A)],
        price: '5 ✨ veya 📺',
        onTap: () => Navigator.push(
          context,
          CosmicPageRoute(page: const DreamScreen()),
        ),
      ),
      _FortuneItem(
        emoji: '💕',
        title: 'Burc Uyumu',
        subtitle: 'Burcunuz ne kadar uyumlu?',
        gradient: const [Color(0xFFEC4899), Color(0xFFDB2777)],
        price: '5 ✨',
        onTap: () => Navigator.push(
          context,
          CosmicPageRoute(page: const MatchScreen()),
        ),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _FortuneCard(item: items[index]),
    );
  }

  // ══════════════════════════════════════════════════════════
  // DERINLEMESINE — Yatay scroll
  // ══════════════════════════════════════════════════════════

  Widget _buildDeepDiveCarousel(BuildContext context) {
    final cosmicOracle = FunFeatureConfig.getById('soulmate_sketch');
    final pastLife = FunFeatureConfig.getById('past_life');
    final soulmateDrawing = FunFeatureConfig.getById('soulmate_drawing');

    final items = [
      _DeepDiveItem(
        emoji: '🌀',
        title: 'Kozmik Kehanet',
        subtitle: 'Evrenin sana mesaji',
        gradient: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
        price: 'Ucretsiz',
        onTap: () => Navigator.push(
          context,
          CosmicPageRoute(page: const CosmicOracleScreen()),
        ),
      ),
      if (cosmicOracle != null)
        _DeepDiveItem(
          emoji: cosmicOracle.emoji,
          title: cosmicOracle.title,
          subtitle: cosmicOracle.subtitle,
          gradient: [cosmicOracle.gradient[0], cosmicOracle.gradient[1]],
          price: '${cosmicOracle.coinCost} ✨',
          onTap: () => Navigator.push(
            context,
            CosmicPageRoute(page: FunFeatureScreen(config: cosmicOracle)),
          ),
        ),
      if (pastLife != null)
        _DeepDiveItem(
          emoji: pastLife.emoji,
          title: pastLife.title,
          subtitle: pastLife.subtitle,
          gradient: [pastLife.gradient[0], pastLife.gradient[1]],
          price: '${pastLife.coinCost} ✨',
          onTap: () => Navigator.push(
            context,
            CosmicPageRoute(page: FunFeatureScreen(config: pastLife)),
          ),
        ),
      if (soulmateDrawing != null)
        _DeepDiveItem(
          emoji: soulmateDrawing.emoji,
          title: soulmateDrawing.title,
          subtitle: soulmateDrawing.subtitle,
          gradient: [soulmateDrawing.gradient[0], soulmateDrawing.gradient[1]],
          price: '${soulmateDrawing.coinCost} ✨',
          onTap: () => Navigator.push(
            context,
            CosmicPageRoute(
              page: SoulmateSketchScreen(config: soulmateDrawing),
            ),
          ),
        ),
    ];

    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) =>
            _DeepDiveCard(item: items[index]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // DETAYLI ANALIZ — 4 kategori karti
  // ══════════════════════════════════════════════════════════

  Widget _buildAnalysisCards(BuildContext context) {
    final categories = [
      _AnalysisItem(
        emoji: '💗',
        title: 'Ask',
        gradient: const [Color(0xFFFF1493), Color(0xFFFF69B4)],
      ),
      _AnalysisItem(
        emoji: '💼',
        title: 'Kariyer',
        gradient: const [Color(0xFF6366F1), Color(0xFF818CF8)],
      ),
      _AnalysisItem(
        emoji: '💪',
        title: 'Saglik',
        gradient: const [Color(0xFF10B981), Color(0xFF34D399)],
      ),
      _AnalysisItem(
        emoji: '💰',
        title: 'Para',
        gradient: const [Color(0xFFEAB308), Color(0xFFFBBF24)],
      ),
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              CosmicPageRoute(page: const AnalysisScreen()),
            ),
            child: Container(
              width: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: cat.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: cat.gradient[0].withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(cat.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 4),
                  Text(
                    cat.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// DATA MODELS
// ══════════════════════════════════════════════════════════

class _FortuneItem {
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final String price;
  final VoidCallback onTap;

  const _FortuneItem({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.price,
    required this.onTap,
  });
}

class _DeepDiveItem {
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final String price;
  final VoidCallback onTap;

  const _DeepDiveItem({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.price,
    required this.onTap,
  });
}

class _AnalysisItem {
  final String emoji;
  final String title;
  final List<Color> gradient;

  const _AnalysisItem({
    required this.emoji,
    required this.title,
    required this.gradient,
  });
}

// ══════════════════════════════════════════════════════════
// FORTUNE CARD — 2x2 grid kartlari
// ══════════════════════════════════════════════════════════

class _FortuneCard extends StatelessWidget {
  final _FortuneItem item;
  const _FortuneCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: item.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: item.gradient[0].withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Dekoratif daire
            Positioned(
              right: -15,
              top: -15,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),

            // Icerik
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Emoji
                  Text(item.emoji, style: const TextStyle(fontSize: 36)),
                  const Spacer(),
                  // Baslik
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Alt baslik
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Fiyat badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.price,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
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

// ══════════════════════════════════════════════════════════
// DEEP DIVE CARD — yatay scroll kartlari
// ══════════════════════════════════════════════════════════

class _DeepDiveCard extends StatelessWidget {
  final _DeepDiveItem item;
  const _DeepDiveCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: item.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: item.gradient[0].withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 30)),
              const Spacer(),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                item.subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.75),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.price,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
