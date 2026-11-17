import 'dart:math';
import 'package:material_ui/material_ui.dart';
import 'package:moaqit/core/theme/app_theme.dart';

class CelestialSkyPainter extends CustomPainter {
  final double celestialProgress; // 0.0 to 1.0 along the trajectory arc
  final bool isNight;
  final double starTwinkleProgress; // 0.0 to 1.0 animation controller

  CelestialSkyPainter({
    required this.celestialProgress,
    required this.isNight,
    required this.starTwinkleProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Draw animated background particles: Stars if night, golden dust if day
    final random = Random(42); // deterministic seed
    final starCount = isNight ? 28 : 14;

    for (int i = 0; i < starCount; i++) {
      final x = random.nextDouble() * w;
      final y = random.nextDouble() * (h * 0.7);
      final radius = random.nextDouble() * 1.6 + 0.6;
      final phaseOffset = random.nextDouble() * pi * 2;
      final opacity = ((sin(starTwinkleProgress * pi * 2 + phaseOffset) + 1.0) / 2.0)
          .clamp(0.2, 0.95);

      final starPaint = Paint()
        ..color = isNight
            ? Colors.white.withValues(alpha: opacity)
            : AppTheme.goldLight.withValues(alpha: opacity * 0.4)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }

    // 2. Trajectory Arc Path (Quadratic Bezier curve)
    // Left endpoint: (w * 0.08, h * 0.88), Control: (w * 0.5, h * 0.12), Right: (w * 0.92, h * 0.88)
    final p0 = Offset(w * 0.08, h * 0.85);
    final p1 = Offset(w * 0.50, h * 0.15);
    final p2 = Offset(w * 0.92, h * 0.85);

    final arcPath = Path()
      ..moveTo(p0.dx, p0.dy)
      ..quadraticBezierTo(p1.dx, p1.dy, p2.dx, p2.dy);

    // Draw dotted/dashed trajectory arc
    final arcPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(arcPath, arcPaint);

    // 3. Mark prayer milestone points along the arc (6 nodes: Fajr, Shuruq, Dhuhr, Asr, Maghrib, Isha)
    const milestoneFractions = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0];
    for (final frac in milestoneFractions) {
      final nodePt = _getQuadraticBezierPoint(p0, p1, p2, frac);
      final isPassed = frac <= celestialProgress;

      final nodePaint = Paint()
        ..color = isPassed ? AppTheme.gold : Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(nodePt, isPassed ? 4.0 : 3.0, nodePaint);

      if (isPassed) {
        final nodeGlow = Paint()
          ..color = AppTheme.gold.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(nodePt, 6.0, nodeGlow);
      }
    }

    // 4. Calculate current celestial orb position (Sun or Moon)
    final orbPosition = _getQuadraticBezierPoint(p0, p1, p2, celestialProgress.clamp(0.0, 1.0));

    // Luminous halo around orb
    final haloColor = isNight ? const Color(0xFF93C5FD) : AppTheme.goldLight;
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          haloColor.withValues(alpha: 0.55),
          haloColor.withValues(alpha: 0.18),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: orbPosition, radius: 24));
    canvas.drawCircle(orbPosition, 24, haloPaint);

    // Orb body
    final orbPaint = Paint()
      ..color = isNight ? const Color(0xFFF1F5F9) : AppTheme.goldLight
      ..style = PaintingStyle.fill;
    canvas.drawCircle(orbPosition, 8.5, orbPaint);

    // Inner bright core
    final corePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(orbPosition, 4.5, corePaint);

    // If day, draw gentle golden sun rays
    if (!isNight) {
      final rayPaint = Paint()
        ..color = AppTheme.gold.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < 8; i++) {
        final angle = (i * pi / 4) + (starTwinkleProgress * pi * 0.5);
        final r1 = 11.0;
        final r2 = 16.0;
        final start = Offset(orbPosition.dx + r1 * cos(angle), orbPosition.dy + r1 * sin(angle));
        final end = Offset(orbPosition.dx + r2 * cos(angle), orbPosition.dy + r2 * sin(angle));
        canvas.drawLine(start, end, rayPaint);
      }
    }
  }

  Offset _getQuadraticBezierPoint(Offset p0, Offset p1, Offset p2, double t) {
    final oneMinusT = 1.0 - t;
    final x = oneMinusT * oneMinusT * p0.dx + 2 * oneMinusT * t * p1.dx + t * t * p2.dx;
    final y = oneMinusT * oneMinusT * p0.dy + 2 * oneMinusT * t * p1.dy + t * t * p2.dy;
    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant CelestialSkyPainter oldDelegate) {
    return oldDelegate.celestialProgress != celestialProgress ||
        oldDelegate.isNight != isNight ||
        oldDelegate.starTwinkleProgress != starTwinkleProgress;
  }
}
