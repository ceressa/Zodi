import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/theme_config.dart';

class AnimatedBackground extends StatefulWidget {
  final AnimationType type;
  final Color primaryColor;
  final Color secondaryColor;
  final Widget child;

  const AnimatedBackground({
    super.key,
    required this.type,
    required this.primaryColor,
    required this.secondaryColor,
    required this.child,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.primaryColor, widget.secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        
        // Animated layer
        if (widget.type != AnimationType.none)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              switch (widget.type) {
                case AnimationType.particles:
                  return CustomPaint(
                    painter: ParticlesPainter(
                      animation: _controller,
                      color: widget.primaryColor,
                    ),
                    size: Size.infinite,
                  );
                case AnimationType.gradient:
                  return CustomPaint(
                    painter: GradientAnimationPainter(
                      animation: _controller,
                      primaryColor: widget.primaryColor,
                      secondaryColor: widget.secondaryColor,
                    ),
                    size: Size.infinite,
                  );
                case AnimationType.constellation:
                  return CustomPaint(
                    painter: ConstellationPainter(
                      animation: _controller,
                      color: widget.primaryColor,
                    ),
                    size: Size.infinite,
                  );
                case AnimationType.zodiacSymbol:
                  return CustomPaint(
                    painter: ZodiacSymbolPainter(
                      animation: _controller,
                      color: widget.primaryColor.withOpacity(0.1),
                    ),
                    size: Size.infinite,
                  );
                default:
                  return const SizedBox();
              }
            },
          ),
        
        // Content
        widget.child,
      ],
    );
  }
}

/// Particles animation painter
class ParticlesPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  final List<Particle> particles = [];

  ParticlesPainter({required this.animation, required this.color}) {
    // Generate particles
    for (int i = 0; i < 50; i++) {
      particles.add(Particle(
        x: math.Random().nextDouble(),
        y: math.Random().nextDouble(),
        size: math.Random().nextDouble() * 3 + 1,
        speed: math.Random().nextDouble() * 0.5 + 0.1,
      ));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (var particle in particles) {
      final x = particle.x * size.width;
      final y = ((particle.y + animation.value * particle.speed) % 1.0) * size.height;
      
      canvas.drawCircle(
        Offset(x, y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) =>
      animation.value != oldDelegate.animation.value;
}

class Particle {
  final double x;
  final double y;
  final double size;
  final double speed;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  });
}

/// Gradient animation painter
class GradientAnimationPainter extends CustomPainter {
  final Animation<double> animation;
  final Color primaryColor;
  final Color secondaryColor;

  GradientAnimationPainter({
    required this.animation,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    
    final gradient = LinearGradient(
      colors: [
        primaryColor.withOpacity(0.3),
        secondaryColor.withOpacity(0.3),
      ],
      begin: Alignment(
        math.cos(animation.value * 2 * math.pi),
        math.sin(animation.value * 2 * math.pi),
      ),
      end: Alignment(
        -math.cos(animation.value * 2 * math.pi),
        -math.sin(animation.value * 2 * math.pi),
      ),
    );

    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(GradientAnimationPainter oldDelegate) =>
      animation.value != oldDelegate.animation.value;
}

/// Constellation animation painter
class ConstellationPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  final List<Star> stars = [];

  ConstellationPainter({required this.animation, required this.color}) {
    // Generate stars
    for (int i = 0; i < 30; i++) {
      stars.add(Star(
        x: math.Random().nextDouble(),
        y: math.Random().nextDouble(),
        size: math.Random().nextDouble() * 2 + 1,
      ));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw stars
    for (var star in stars) {
      final x = star.x * size.width;
      final y = star.y * size.height;
      
      canvas.drawCircle(
        Offset(x, y),
        star.size,
        paint,
      );
    }

    // Draw connections
    for (int i = 0; i < stars.length; i++) {
      for (int j = i + 1; j < stars.length; j++) {
        final star1 = stars[i];
        final star2 = stars[j];
        
        final distance = math.sqrt(
          math.pow(star1.x - star2.x, 2) + math.pow(star1.y - star2.y, 2),
        );

        if (distance < 0.2) {
          canvas.drawLine(
            Offset(star1.x * size.width, star1.y * size.height),
            Offset(star2.x * size.width, star2.y * size.height),
            linePaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(ConstellationPainter oldDelegate) => false;
}

class Star {
  final double x;
  final double y;
  final double size;

  Star({required this.x, required this.y, required this.size});
}

/// Zodiac symbol watermark painter
class ZodiacSymbolPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  ZodiacSymbolPainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;
    
    // Rotate the symbol
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(animation.value * 2 * math.pi);
    canvas.translate(-center.dx, -center.dy);

    // Draw zodiac circle
    canvas.drawCircle(center, radius, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(ZodiacSymbolPainter oldDelegate) =>
      animation.value != oldDelegate.animation.value;
}
