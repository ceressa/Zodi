import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Gunun saatine gore degisen zaman dilimi
enum DayPeriod {
  earlyMorning, // 05:00 - 09:59
  lateMorning,  // 10:00 - 11:59
  midday,       // 12:00 - 14:59
  afternoon,    // 15:00 - 17:59
  evening,      // 18:00 - 21:59
  night,        // 22:00 - 04:59
}

/// Zamana gore gradient renkleri
class TimeGradient {
  final Color start;
  final Color mid;
  final Color end;
  final Color accent;
  final DayPeriod period;

  const TimeGradient({
    required this.start,
    required this.mid,
    required this.end,
    required this.accent,
    required this.period,
  });
}

/// Mevcut saat dilimini belirle
DayPeriod getCurrentDayPeriod() {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour <= 9) return DayPeriod.earlyMorning;
  if (hour >= 10 && hour <= 11) return DayPeriod.lateMorning;
  if (hour >= 12 && hour <= 14) return DayPeriod.midday;
  if (hour >= 15 && hour <= 17) return DayPeriod.afternoon;
  if (hour >= 18 && hour <= 21) return DayPeriod.evening;
  return DayPeriod.night;
}

/// Zaman dilimine gore gradient al
/// LIGHT MODE ONLY: Acik arka plan uzerine hafif overlay olarak kullanilir
TimeGradient getTimeGradient([DayPeriod? override]) {
  final period = override ?? getCurrentDayPeriod();

  switch (period) {
    case DayPeriod.earlyMorning:
      return const TimeGradient(
        start: Color(0xFF667EEA),  // Soft mor
        mid: Color(0xFFFFB347),    // Altin sarisi
        end: Color(0xFFFFA500),    // Turuncu
        accent: Color(0xFFFFB347),
        period: DayPeriod.earlyMorning,
      );
    case DayPeriod.lateMorning:
      return const TimeGradient(
        start: Color(0xFF667EEA),  // Soft mor
        mid: Color(0xFF764BA2),    // Mor
        end: Color(0xFFF093FB),    // Pembe
        accent: Color(0xFFFFB347),
        period: DayPeriod.lateMorning,
      );
    case DayPeriod.midday:
      return const TimeGradient(
        start: Color(0xFF4F46E5),  // Indigo
        mid: Color(0xFF7C3AED),    // Mor
        end: Color(0xFFA855F7),    // Acik mor
        accent: Color(0xFFFBBF24), // Sari
        period: DayPeriod.midday,
      );
    case DayPeriod.afternoon:
      return const TimeGradient(
        start: Color(0xFF5B21B6),  // Koyu mor
        mid: Color(0xFF7C3AED),    // Mor
        end: Color(0xFF10B981),    // Yesil
        accent: Color(0xFF10B981),
        period: DayPeriod.afternoon,
      );
    case DayPeriod.evening:
      return const TimeGradient(
        start: Color(0xFF1A1A2E),  // Koyu lacivert
        mid: Color(0xFF8B4513),    // Sonbahar
        end: Color(0xFFE67E22),    // Sicak turuncu
        accent: Color(0xFFD35400),
        period: DayPeriod.evening,
      );
    case DayPeriod.night:
      return const TimeGradient(
        start: Color(0xFF1E1B4B),  // Derin mor
        mid: Color(0xFF312E81),    // Koyu indigo
        end: Color(0xFF4C1D95),    // Mor
        accent: Color(0xFF60A5FA), // Acik mavi (ay isigi)
        period: DayPeriod.night,
      );
  }
}

/// Zamana gore degisen animasyonlu arka plan widget'i
/// Dozi uygulamasindan port edilmistir — LIGHT MODE ONLY
///
/// Kullanim:
/// ```dart
/// TimeBasedBackground(
///   child: Scaffold(...)
/// )
/// ```
class TimeBasedBackground extends StatefulWidget {
  final Widget child;

  const TimeBasedBackground({
    super.key,
    required this.child,
  });

  @override
  State<TimeBasedBackground> createState() => _TimeBasedBackgroundState();
}

class _TimeBasedBackgroundState extends State<TimeBasedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _slowController;
  late TimeGradient _gradient;
  late DayPeriod _lastPeriod;

  @override
  void initState() {
    super.initState();
    _gradient = getTimeGradient();
    _lastPeriod = _gradient.period;

    // Hizli animasyonlar (yildiz, parcacik vs.)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Yavas animasyonlar (gradient pulse, bulut vs.)
    _slowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _slowController.dispose();
    super.dispose();
  }

  /// Her build'de saat dilimini kontrol et, degismisse gradient'i guncelle
  void _checkPeriodChange() {
    final current = getCurrentDayPeriod();
    if (current != _lastPeriod) {
      _gradient = getTimeGradient(current);
      _lastPeriod = current;
    }
  }

  /// Zaman dilimine gore arka plan renk seti
  List<Color> _getBackgroundColors() {
    switch (_gradient.period) {
      case DayPeriod.earlyMorning:
        return [
          const Color(0xFFFFF8F0),  // Sicak krem
          _gradient.mid.withValues(alpha: 0.12),
          _gradient.start.withValues(alpha: 0.08),
          const Color(0xFFF5F0FF),
        ];
      case DayPeriod.lateMorning:
        return [
          const Color(0xFFF8F5FF),  // Lavanta
          _gradient.start.withValues(alpha: 0.10),
          _gradient.end.withValues(alpha: 0.06),
          const Color(0xFFFFF5FB),  // Pembe ton
        ];
      case DayPeriod.midday:
        return [
          const Color(0xFFF5F3FF),  // Acik mor
          _gradient.start.withValues(alpha: 0.12),
          _gradient.mid.withValues(alpha: 0.08),
          const Color(0xFFF0EDFF),
        ];
      case DayPeriod.afternoon:
        return [
          const Color(0xFFF5F9F7),  // Yesil-beyaz
          _gradient.end.withValues(alpha: 0.10),
          _gradient.mid.withValues(alpha: 0.06),
          const Color(0xFFF3F0FF),
        ];
      case DayPeriod.evening:
        return [
          const Color(0xFFFFF5EC),  // Sicak turuncu krem
          _gradient.end.withValues(alpha: 0.14),
          _gradient.mid.withValues(alpha: 0.08),
          const Color(0xFFF5F0FF),
        ];
      case DayPeriod.night:
        return [
          const Color(0xFFF0EDFF),  // Koyu lavanta
          _gradient.start.withValues(alpha: 0.15),
          _gradient.mid.withValues(alpha: 0.10),
          const Color(0xFFEBE8FF),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkPeriodChange();
    final bgColors = _getBackgroundColors();

    return Stack(
      children: [
        // Zamana gore degisen arka plan
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: bgColors,
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),

        // Animasyonlu katman
        AnimatedBuilder(
          animation: Listenable.merge([_controller, _slowController]),
          builder: (context, _) {
            return CustomPaint(
              painter: _TimeAnimationPainter(
                period: _gradient.period,
                gradient: _gradient,
                fastProgress: _controller.value,
                slowProgress: _slowController.value,
              ),
              size: Size.infinite,
            );
          },
        ),

        // Icerik
        widget.child,
      ],
    );
  }
}

/// Ana animasyon painter — donemine gore farkli efektler cizer
class _TimeAnimationPainter extends CustomPainter {
  final DayPeriod period;
  final TimeGradient gradient;
  final double fastProgress;
  final double slowProgress;

  _TimeAnimationPainter({
    required this.period,
    required this.gradient,
    required this.fastProgress,
    required this.slowProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (period) {
      case DayPeriod.night:
        _drawMoonGlow(canvas, size);
        _drawStars(canvas, size);
        _drawShootingStar(canvas, size);
        break;
      case DayPeriod.earlyMorning:
        _drawSunrise(canvas, size);
        _drawDewDrops(canvas, size);
        break;
      case DayPeriod.lateMorning:
        _drawSunrays(canvas, size);
        _drawSoftClouds(canvas, size);
        break;
      case DayPeriod.midday:
        _drawSunGlare(canvas, size);
        _drawHeatShimmer(canvas, size);
        break;
      case DayPeriod.afternoon:
        _drawBreeze(canvas, size);
        _drawFloatingLeaves(canvas, size);
        break;
      case DayPeriod.evening:
        _drawSunsetGlow(canvas, size);
        _drawFallingLeaves(canvas, size);
        break;
    }
  }

  // ══════════════════════════════════════════════════════════
  // GECE (22:00 - 04:59)
  // ══════════════════════════════════════════════════════════

  void _drawMoonGlow(Canvas canvas, Size size) {
    final pulse = 0.5 + 0.5 * math.sin(slowProgress * 2 * math.pi);
    final center = Offset(size.width * 0.8, size.height * 0.08);

    // Genis ay halesi
    canvas.drawCircle(
      center,
      60 + pulse * 15,
      Paint()
        ..color = gradient.accent.withValues(alpha: 0.10 + pulse * 0.05)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40),
    );

    // Ay halesi ic
    canvas.drawCircle(
      center,
      35 + pulse * 8,
      Paint()
        ..color = gradient.accent.withValues(alpha: 0.12 + pulse * 0.04)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    // Ay
    canvas.drawCircle(
      center,
      18,
      Paint()..color = gradient.accent.withValues(alpha: 0.22),
    );
  }

  void _drawStars(Canvas canvas, Size size) {
    final rng = math.Random(42); // deterministik

    for (int i = 0; i < 30; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.6;
      final starSize = 1.0 + rng.nextDouble() * 3.0;
      final phase = rng.nextDouble() * 2 * math.pi;

      // Twinkle efekti — 3 farkli hiz grubu
      final speed = 1.0 + rng.nextInt(3) * 0.5;
      final twinkle = 0.3 + 0.7 * ((math.sin(fastProgress * speed * 2 * math.pi + phase) + 1) / 2);

      // Yildiz
      canvas.drawCircle(
        Offset(x, y),
        starSize,
        Paint()..color = gradient.accent.withValues(alpha: twinkle * 0.25),
      );

      // Isik halesi (buyuk yildizlar icin)
      if (starSize > 2.0) {
        canvas.drawCircle(
          Offset(x, y),
          starSize * 3,
          Paint()
            ..color = gradient.accent.withValues(alpha: twinkle * 0.08)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        );
      }
    }
  }

  void _drawShootingStar(Canvas canvas, Size size) {
    // 8 saniyelik cycle icinde 1-2 saniye gozukur
    final shootPhase = (fastProgress * 3) % 1.0;
    if (shootPhase > 0.3) return;

    final t = shootPhase / 0.3; // 0..1 arasi normalize
    final startX = size.width * 0.2;
    final startY = size.height * 0.05;
    final endX = size.width * 0.6;
    final endY = size.height * 0.15;

    final currentX = startX + (endX - startX) * t;
    final currentY = startY + (endY - startY) * t;

    // Kayan yildiz izi
    final trailPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18 * (1 - t))
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final trailLength = 50.0 * (1 - t * 0.5);
    final angle = math.atan2(endY - startY, endX - startX);
    final trailStartX = currentX - trailLength * math.cos(angle);
    final trailStartY = currentY - trailLength * math.sin(angle);

    canvas.drawLine(
      Offset(trailStartX, trailStartY),
      Offset(currentX, currentY),
      trailPaint,
    );

    // Parlak bas
    canvas.drawCircle(
      Offset(currentX, currentY),
      3,
      Paint()..color = Colors.white.withValues(alpha: 0.28 * (1 - t)),
    );
  }

  // ══════════════════════════════════════════════════════════
  // ERKEN SABAH (05:00 - 09:59)
  // ══════════════════════════════════════════════════════════

  void _drawSunrise(Canvas canvas, Size size) {
    final pulse = 0.5 + 0.5 * math.sin(slowProgress * 2 * math.pi);

    // Gunes isigi yayilimi — buyuk ve belirgin
    final center = Offset(size.width * 0.5, size.height * -0.05);

    canvas.drawCircle(
      center,
      size.width * 0.5 + pulse * 30,
      Paint()
        ..shader = RadialGradient(
          colors: [
            gradient.end.withValues(alpha: 0.18 + pulse * 0.06),
            gradient.mid.withValues(alpha: 0.08),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(center: center, radius: size.width * 0.6),
        ),
    );

    // Ufuk cizgisi parlama
    canvas.drawCircle(
      Offset(size.width * 0.5, 0),
      size.width * 0.3,
      Paint()
        ..color = gradient.accent.withValues(alpha: 0.10 + pulse * 0.05)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
    );
  }

  void _drawDewDrops(Canvas canvas, Size size) {
    final rng = math.Random(77);

    for (int i = 0; i < 18; i++) {
      final x = rng.nextDouble() * size.width;
      final baseY = size.height * 0.15 + rng.nextDouble() * size.height * 0.6;
      final phase = rng.nextDouble() * 2 * math.pi;
      final speed = 0.3 + rng.nextDouble() * 0.5;

      // Yuzen parcaciklar — yavasca yukari
      final yOffset = math.sin(slowProgress * speed * 2 * math.pi + phase) * 20;
      final y = baseY + yOffset;

      final dropSize = 2.5 + rng.nextDouble() * 3.5;
      final alpha = 0.08 + 0.06 * math.sin(fastProgress * 2 * math.pi + phase);

      canvas.drawCircle(
        Offset(x, y),
        dropSize,
        Paint()..color = gradient.accent.withValues(alpha: alpha),
      );

      // Kucuk isik halesi
      if (dropSize > 4) {
        canvas.drawCircle(
          Offset(x, y),
          dropSize * 2.5,
          Paint()
            ..color = gradient.accent.withValues(alpha: alpha * 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
      }
    }
  }

  // ══════════════════════════════════════════════════════════
  // KUSLUK (10:00 - 11:59)
  // ══════════════════════════════════════════════════════════

  void _drawSunrays(Canvas canvas, Size size) {
    final rotation = slowProgress * 2 * math.pi;
    final center = Offset(size.width * 0.85, size.height * 0.05);
    final pulse = 0.5 + 0.5 * math.sin(slowProgress * 4 * math.pi);

    // Gunes parlakligi
    canvas.drawCircle(
      center,
      45 + pulse * 12,
      Paint()
        ..color = gradient.accent.withValues(alpha: 0.14 + pulse * 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
    );

    // Isinlar
    for (int i = 0; i < 8; i++) {
      final angle = rotation + (i * math.pi / 4);
      final length = 80.0 + pulse * 20;
      final endPoint = Offset(
        center.dx + length * math.cos(angle),
        center.dy + length * math.sin(angle),
      );

      canvas.drawLine(
        center,
        endPoint,
        Paint()
          ..color = gradient.accent.withValues(alpha: 0.08 + pulse * 0.04)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke,
      );
    }
  }

  void _drawSoftClouds(Canvas canvas, Size size) {
    final drift = slowProgress * size.width * 0.4;

    _drawCloud(canvas, Offset(-30 + drift, size.height * 0.10), 0.10);
    _drawCloud(canvas, Offset(size.width * 0.5 + drift * 0.5, size.height * 0.20), 0.08);
    _drawCloud(canvas, Offset(size.width * 0.2 + drift * 0.7, size.height * 0.30), 0.06);
  }

  void _drawCloud(Canvas canvas, Offset position, double alpha) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: alpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);

    canvas.drawOval(
      Rect.fromCenter(center: position, width: 120, height: 35),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: position + const Offset(35, -10),
        width: 80,
        height: 30,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: position + const Offset(-25, -5),
        width: 70,
        height: 25,
      ),
      paint,
    );
  }

  // ══════════════════════════════════════════════════════════
  // OGLE (12:00 - 14:59)
  // ══════════════════════════════════════════════════════════

  void _drawSunGlare(Canvas canvas, Size size) {
    final pulse = 0.5 + 0.5 * math.sin(slowProgress * 2 * math.pi);
    final center = Offset(size.width * 0.5, size.height * -0.1);

    // Buyuk gunes efekti
    canvas.drawCircle(
      center,
      size.width * 0.55 + pulse * 40,
      Paint()
        ..shader = RadialGradient(
          colors: [
            gradient.accent.withValues(alpha: 0.16 + pulse * 0.06),
            gradient.mid.withValues(alpha: 0.06),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(center: center, radius: size.width * 0.7),
        ),
    );
  }

  void _drawHeatShimmer(Canvas canvas, Size size) {
    // Sicak hava dalgasi — yatay cizgiler
    for (int i = 0; i < 5; i++) {
      final y = size.height * (0.25 + i * 0.13);
      final wave = math.sin(fastProgress * 2 * math.pi + i * 0.7) * 6;

      final path = Path();
      path.moveTo(0, y + wave);
      for (double x = 0; x <= size.width; x += 15) {
        final yy = y + math.sin(x / 40 + slowProgress * 4 * math.pi + i) * 4 + wave;
        path.lineTo(x, yy);
      }

      canvas.drawPath(
        path,
        Paint()
          ..color = gradient.accent.withValues(alpha: 0.06 + 0.02 * math.sin(fastProgress * 2 * math.pi + i))
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );
    }
  }

  // ══════════════════════════════════════════════════════════
  // IKINDI (15:00 - 17:59)
  // ══════════════════════════════════════════════════════════

  void _drawBreeze(Canvas canvas, Size size) {
    // Esinti efekti — yatay parcaciklar
    final rng = math.Random(99);
    for (int i = 0; i < 12; i++) {
      final baseX = rng.nextDouble() * size.width;
      final y = size.height * (0.1 + rng.nextDouble() * 0.7);
      final phase = rng.nextDouble() * 2 * math.pi;

      final x = (baseX + fastProgress * size.width * 0.4 + math.sin(phase) * 30) % (size.width + 100) - 50;
      final alpha = 0.06 + 0.04 * math.sin(slowProgress * 2 * math.pi + phase);

      // Uzun ince cizgi (ruzgar)
      canvas.drawLine(
        Offset(x, y),
        Offset(x + 35, y + 2),
        Paint()
          ..color = gradient.accent.withValues(alpha: alpha)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawFloatingLeaves(Canvas canvas, Size size) {
    final rng = math.Random(55);

    for (int i = 0; i < 8; i++) {
      final baseX = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final phase = rng.nextDouble() * 2 * math.pi;

      // Yaprak yolculugu — saga ve asagi
      final x = (baseX + fastProgress * 80 + math.sin(slowProgress * 2 * math.pi + phase) * 25) % (size.width + 50);
      final y = (baseY + fastProgress * 40 + math.cos(slowProgress * 2 * math.pi + phase) * 15) % (size.height + 50);

      final leafAlpha = 0.10 + 0.05 * math.sin(fastProgress * 2 * math.pi + phase);

      // Basit yaprak sekli (oval)
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(fastProgress * math.pi + phase);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 10, height: 5),
        Paint()..color = gradient.accent.withValues(alpha: leafAlpha),
      );
      canvas.restore();
    }
  }

  // ══════════════════════════════════════════════════════════
  // AKSAM (18:00 - 21:59)
  // ══════════════════════════════════════════════════════════

  void _drawSunsetGlow(Canvas canvas, Size size) {
    final pulse = 0.5 + 0.5 * math.sin(slowProgress * 2 * math.pi);

    // Ufuktaki sicak isik — belirgin
    final center = Offset(size.width * 0.3, size.height * 0.02);
    canvas.drawCircle(
      center,
      size.width * 0.55 + pulse * 25,
      Paint()
        ..shader = RadialGradient(
          colors: [
            gradient.end.withValues(alpha: 0.16 + pulse * 0.06),
            gradient.mid.withValues(alpha: 0.06),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(center: center, radius: size.width * 0.7),
        ),
    );

    // Ikinci sicak isik (sag ust)
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.05),
      40 + pulse * 10,
      Paint()
        ..color = gradient.end.withValues(alpha: 0.08 + pulse * 0.04)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25),
    );
  }

  void _drawFallingLeaves(Canvas canvas, Size size) {
    final rng = math.Random(33);

    for (int i = 0; i < 7; i++) {
      final baseX = rng.nextDouble() * size.width;
      final phase = rng.nextDouble() * 2 * math.pi;

      // Yaprak dusus yolu
      final progress = (fastProgress + phase / (2 * math.pi)) % 1.0;
      final x = baseX + math.sin(progress * 4 * math.pi) * 35;
      final y = -20 + progress * (size.height + 40);

      final alpha = 0.12 + 0.06 * math.sin(progress * 2 * math.pi);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * 3 * math.pi + phase);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 9, height: 4.5),
        Paint()..color = gradient.end.withValues(alpha: alpha),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_TimeAnimationPainter oldDelegate) {
    return oldDelegate.fastProgress != fastProgress ||
        oldDelegate.slowProgress != slowProgress ||
        oldDelegate.period != period;
  }
}
