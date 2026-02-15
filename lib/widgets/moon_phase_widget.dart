import 'package:flutter/material.dart';
import 'dart:math';
import '../models/beauty_day.dart';

/// Ay fazını görsel olarak gösteren CustomPainter widget'ı
class MoonPhaseWidget extends StatelessWidget {
  final MoonPhase phase;
  final double size;
  final Color moonColor;
  final Color shadowColor;

  const MoonPhaseWidget({
    super.key,
    required this.phase,
    this.size = 80,
    this.moonColor = const Color(0xFFFFF8DC),
    this.shadowColor = const Color(0xFF1A1A2E),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: moonColor.withOpacity(0.3),
            blurRadius: size * 0.3,
            spreadRadius: size * 0.05,
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: _MoonPhasePainter(
          phase: phase,
          moonColor: moonColor,
          shadowColor: shadowColor,
        ),
      ),
    );
  }
}

class _MoonPhasePainter extends CustomPainter {
  final MoonPhase phase;
  final Color moonColor;
  final Color shadowColor;

  _MoonPhasePainter({
    required this.phase,
    required this.moonColor,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Ay'ın parlak kısmını çiz
    final moonPaint = Paint()
      ..color = moonColor
      ..style = PaintingStyle.fill;

    // Gölge kısmı
    final shadowPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.fill;

    // Krater efekti
    final craterPaint = Paint()
      ..color = moonColor.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    // Önce tam daireyi çiz
    canvas.drawCircle(center, radius, moonPaint);

    // Kraterleri ekle
    _drawCraters(canvas, center, radius, craterPaint);

    // Faza göre gölge ekle
    _drawPhaseShadow(canvas, center, radius, shadowPaint);

    // Parlak kenar efekti
    final borderPaint = Paint()
      ..color = moonColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius - 0.5, borderPaint);
  }

  void _drawCraters(Canvas canvas, Offset center, double radius, Paint paint) {
    // Birkaç küçük krater
    canvas.drawCircle(
      Offset(center.dx - radius * 0.25, center.dy - radius * 0.15),
      radius * 0.12,
      paint,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.3, center.dy + radius * 0.25),
      radius * 0.08,
      paint,
    );
    canvas.drawCircle(
      Offset(center.dx - radius * 0.1, center.dy + radius * 0.4),
      radius * 0.1,
      paint,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.15, center.dy - radius * 0.35),
      radius * 0.06,
      paint,
    );
  }

  void _drawPhaseShadow(Canvas canvas, Offset center, double radius, Paint paint) {
    // Clip dairesel alan
    canvas.save();
    final clipPath = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.clipPath(clipPath);

    switch (phase) {
      case MoonPhase.newMoon:
        // Tamamen karanlık
        canvas.drawCircle(center, radius, paint);
        break;

      case MoonPhase.waxingCrescent:
        // Sağda ince parlak hilal (sol taraf karanlık)
        final path = Path();
        path.addOval(Rect.fromCircle(center: center, radius: radius));
        // Sağ taraftan ince bir ay bırak
        final ovalRect = Rect.fromCenter(
          center: Offset(center.dx + radius * 0.3, center.dy),
          width: radius * 1.4,
          height: radius * 2,
        );
        path.addOval(ovalRect);
        path.fillType = PathFillType.evenOdd;
        canvas.drawPath(path, paint);
        break;

      case MoonPhase.firstQuarter:
        // Sol yarı karanlık
        canvas.drawRect(
          Rect.fromLTWH(center.dx - radius, center.dy - radius, radius, radius * 2),
          paint,
        );
        break;

      case MoonPhase.waxingGibbous:
        // Sol tarafta ince gölge
        final path = Path();
        final ovalRect = Rect.fromCenter(
          center: Offset(center.dx - radius * 0.3, center.dy),
          width: radius * 1.4,
          height: radius * 2,
        );
        path.addOval(ovalRect);
        // Daire ile intersect
        final circlePath = Path()
          ..addOval(Rect.fromCircle(center: center, radius: radius));
        // Sol dış kısmı boya
        canvas.drawPath(
          Path.combine(PathOperation.intersect, path, circlePath),
          Paint()..color = shadowColor.withOpacity(0.4),
        );
        break;

      case MoonPhase.fullMoon:
        // Tam parlak - gölge yok, sadece hafif parıltı
        final glowPaint = Paint()
          ..shader = RadialGradient(
            colors: [
              moonColor.withOpacity(0.0),
              moonColor.withOpacity(0.15),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius));
        canvas.drawCircle(center, radius, glowPaint);
        break;

      case MoonPhase.waningGibbous:
        // Sağ tarafta ince gölge
        final path = Path();
        final ovalRect = Rect.fromCenter(
          center: Offset(center.dx + radius * 0.3, center.dy),
          width: radius * 1.4,
          height: radius * 2,
        );
        path.addOval(ovalRect);
        final circlePath = Path()
          ..addOval(Rect.fromCircle(center: center, radius: radius));
        canvas.drawPath(
          Path.combine(PathOperation.intersect, path, circlePath),
          Paint()..color = shadowColor.withOpacity(0.4),
        );
        break;

      case MoonPhase.lastQuarter:
        // Sağ yarı karanlık
        canvas.drawRect(
          Rect.fromLTWH(center.dx, center.dy - radius, radius, radius * 2),
          paint,
        );
        break;

      case MoonPhase.waningCrescent:
        // Solda ince parlak hilal (sağ taraf karanlık)
        final path = Path();
        path.addOval(Rect.fromCircle(center: center, radius: radius));
        final ovalRect = Rect.fromCenter(
          center: Offset(center.dx - radius * 0.3, center.dy),
          width: radius * 1.4,
          height: radius * 2,
        );
        path.addOval(ovalRect);
        path.fillType = PathFillType.evenOdd;
        canvas.drawPath(path, paint);
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MoonPhasePainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}
