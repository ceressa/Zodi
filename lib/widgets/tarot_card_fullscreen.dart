import 'package:flutter/material.dart';
import '../models/tarot_card.dart';
import '../constants/colors.dart';

class TarotCardFullscreen extends StatelessWidget {
  final TarotCard card;

  const TarotCardFullscreen({
    super.key,
    required this.card,
  });

  static void show(BuildContext context, TarotCard card) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: TarotCardFullscreen(card: card),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Kart boyutları - 2:3 aspect ratio korunarak
    // Ekranın %80'i, maksimum 400px genişlik
    final cardWidth = (screenWidth * 0.8).clamp(300.0, 400.0);
    final cardHeight = cardWidth * 1.5; // 2:3 ratio (0.666:1 = 1.5 height multiplier)

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Karta tıklamayı engelle (arka plana tıklama için)
              child: Hero(
                tag: 'tarot_card_${card.name}',
                child: Container(
                  width: cardWidth,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    border: Border.all(
                      color: _getSuitColor().withOpacity(0.5),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getSuitColor().withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Üst kısım - Kart adı
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _getSuitColor().withOpacity(0.15),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(17),
                            topRight: Radius.circular(17),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              card.name,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _getSuitColor(),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (card.reversed)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Ters Pozisyon',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Orta kısım - Kart görseli
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: card.imageUrl.isNotEmpty
                                ? Image.asset(
                                    card.imageUrl,
                                    fit: BoxFit.contain, // Aspect ratio korunur
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              _getSuitColor().withOpacity(0.3),
                                              _getSuitColor().withOpacity(0.1),
                                            ],
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            _getSuitIcon(),
                                            size: 120,
                                            color: _getSuitColor().withOpacity(0.6),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          _getSuitColor().withOpacity(0.3),
                                          _getSuitColor().withOpacity(0.1),
                                        ],
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        _getSuitIcon(),
                                        size: 120,
                                        color: _getSuitColor().withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      // Alt kısım - Açıklama
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              card.basicMeaning,
                              style: TextStyle(
                                fontSize: 15,
                                color: isDark ? Colors.white70 : Colors.black87,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Kapatmak için dokunun',
                              style: TextStyle(
                                fontSize: 12,
                                color: (isDark ? Colors.white : Colors.black)
                                    .withOpacity(0.4),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getSuitColor() {
    switch (card.suit) {
      case TarotSuit.majorArcana:
        return AppColors.gold;
      case TarotSuit.wands:
        return Colors.orange;
      case TarotSuit.cups:
        return Colors.blue;
      case TarotSuit.swords:
        return Colors.grey;
      case TarotSuit.pentacles:
        return Colors.green;
    }
  }

  IconData _getSuitIcon() {
    switch (card.suit) {
      case TarotSuit.majorArcana:
        return Icons.auto_awesome;
      case TarotSuit.wands:
        return Icons.local_fire_department;
      case TarotSuit.cups:
        return Icons.water_drop;
      case TarotSuit.swords:
        return Icons.flash_on;
      case TarotSuit.pentacles:
        return Icons.circle;
    }
  }
}
