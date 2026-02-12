import 'package:flutter/material.dart';
import '../models/tarot_card.dart';
import '../constants/colors.dart';
import 'tarot_card_fullscreen.dart';

class TarotCardWidget extends StatefulWidget {
  final TarotCard card;
  final bool showFlipAnimation;
  final VoidCallback? onTap;
  final bool enableFullscreen;
  final double width;
  final double height;

  const TarotCardWidget({
    super.key,
    required this.card,
    this.showFlipAnimation = false,
    this.onTap,
    this.enableFullscreen = true,
    this.width = 170.0,
    this.height = 256.0, // 2:3 ratio (matches your card design)
  });

  @override
  State<TarotCardWidget> createState() => _TarotCardWidgetState();
}

class _TarotCardWidgetState extends State<TarotCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFront = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.showFlipAnimation) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _controller.forward().then((_) {
            setState(() => _showFront = true);
          });
        }
      });
    } else {
      _showFront = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        } else if (widget.enableFullscreen && _showFront) {
          // Sadece ön yüz gösteriliyorsa tam ekran aç
          TarotCardFullscreen.show(context, widget.card);
        }
      },
      child: Hero(
        tag: 'tarot_card_${widget.card.name}',
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final angle = _animation.value * 3.14159; // π radians
            final showBack = angle < 1.5708; // π/2 radians

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              child: showBack ? _buildCardBack(isDark) : _buildCardFront(isDark),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardBack(bool isDark) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentPurple,
            AppColors.accentBlue,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Yıldız deseni
          ...List.generate(20, (index) {
            return Positioned(
              left: (index * 37) % (widget.width - 20) + 10,
              top: (index * 53) % (widget.height - 20) + 10,
              child: Icon(
                Icons.star,
                size: 12,
                color: Colors.white.withOpacity(0.3),
              ),
            );
          }),
          // Merkez sembol
          Center(
            child: Icon(
              Icons.auto_awesome,
              size: widget.width * 0.4,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFront(bool isDark) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(3.14159), // Flip back
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          border: Border.all(
            color: _getSuitColor().withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _getSuitColor().withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Üst kısım - Kart adı
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getSuitColor().withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    widget.card.name,
                    style: TextStyle(
                      fontSize: widget.width * 0.08,
                      fontWeight: FontWeight.bold,
                      color: _getSuitColor(),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.card.reversed)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Ters',
                        style: TextStyle(
                          fontSize: 10,
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
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: widget.card.imageUrl.isNotEmpty
                      ? Image.asset(
                          widget.card.imageUrl,
                          fit: BoxFit.contain, // Aspect ratio korunur (2:3)
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to icon if image not found
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _getSuitColor().withOpacity(0.2),
                                    _getSuitColor().withOpacity(0.05),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  _getSuitIcon(),
                                  size: widget.width * 0.4,
                                  color: _getSuitColor().withOpacity(0.5),
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
                                _getSuitColor().withOpacity(0.2),
                                _getSuitColor().withOpacity(0.05),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              _getSuitIcon(),
                              size: widget.width * 0.4,
                              color: _getSuitColor().withOpacity(0.5),
                            ),
                          ),
                        ),
                ),
              ),
            ),

            // Alt kısım - Kısa açıklama (sadece tam ekranda göster)
            if (widget.enableFullscreen && widget.width > 150)
              Container(
                padding: const EdgeInsets.all(10),
                child: Text(
                  widget.card.basicMeaning,
                  style: TextStyle(
                    fontSize: widget.width * 0.06,
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getSuitColor() {
    switch (widget.card.suit) {
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
    switch (widget.card.suit) {
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
