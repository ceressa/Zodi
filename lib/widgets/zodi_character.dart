import 'package:flutter/material.dart';

enum ZodiSize { small, medium, large }

class ZodiCharacter extends StatefulWidget {
  final ZodiSize size;
  
  const ZodiCharacter({super.key, this.size = ZodiSize.medium});
  
  @override
  State<ZodiCharacter> createState() => _ZodiCharacterState();
}

class _ZodiCharacterState extends State<ZodiCharacter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounce;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _bounce = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  double get _dimension {
    switch (widget.size) {
      case ZodiSize.small:
        return 80;
      case ZodiSize.medium:
        return 128;
      case ZodiSize.large:
        return 160;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounce,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounce.value),
          child: child,
        );
      },
      child: SizedBox(
        width: _dimension,
        height: _dimension,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow efekti
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7C3AED).withOpacity(0.3),
                    const Color(0xFFA78BFA).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Karakter görseli
            Image.asset(
              'assets/astro_dozi_main.webp',
              width: _dimension * 0.8,
              height: _dimension * 0.8,
              errorBuilder: (context, error, stackTrace) {
                // Fallback: Emoji
                return Text(
                  '🔮',
                  style: TextStyle(fontSize: _dimension * 0.5),
                );
              },
            ),
            // Yıldız parıltıları
            Positioned(
              top: 0,
              right: _dimension * 0.1,
              child: const _SparkleEmoji(text: '✨', size: 16),
            ),
            Positioned(
              bottom: _dimension * 0.15,
              left: 0,
              child: const _SparkleEmoji(text: '⭐', size: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparkleEmoji extends StatefulWidget {
  final String text;
  final double size;
  
  const _SparkleEmoji({required this.text, required this.size});
  
  @override
  State<_SparkleEmoji> createState() => _SparkleEmojiState();
}

class _SparkleEmojiState extends State<_SparkleEmoji>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Text(
        widget.text,
        style: TextStyle(fontSize: widget.size),
      ),
    );
  }
}
