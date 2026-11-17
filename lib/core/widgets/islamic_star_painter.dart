import 'dart:math';
import 'package:material_ui/material_ui.dart';
import 'package:moaqit/core/theme/app_theme.dart';

class IslamicRubElHizbPainter extends CustomPainter {
  final double strokeProgress; // 0.0 to 1.0 for path stroke animation
  final double glowProgress;   // 0.0 to 1.0 for golden bloom
  final Color primaryColor;
  final Color glowColor;

  IslamicRubElHizbPainter({
    required this.strokeProgress,
    required this.glowProgress,
    this.primaryColor = AppTheme.gold,
    this.glowColor = AppTheme.goldLight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.42;

    // 1. Radial Golden Bloom
    if (glowProgress > 0.01) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            glowColor.withValues(alpha: 0.35 * glowProgress),
            primaryColor.withValues(alpha: 0.15 * glowProgress),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 1.6));
      canvas.drawCircle(center, radius * 1.6, glowPaint);
    }

    // 2. Build 8-pointed star Path (Two overlapping squares rotated 45 degrees + inner circle)
    final starPath = Path();
    final halfSide = radius * 0.72;

    // Square 1 (Standard)
    final rect1 = Rect.fromCenter(
      center: center,
      width: halfSide * 2,
      height: halfSide * 2,
    );
    starPath.addRect(rect1);

    // Square 2 (Rotated 45 degrees)
    final square2Path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = (pi / 4) + (i * pi / 2);
      final pt = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      if (i == 0) {
        square2Path.moveTo(pt.dx, pt.dy);
      } else {
        square2Path.lineTo(pt.dx, pt.dy);
      }
    }
    square2Path.close();
    starPath.addPath(square2Path, Offset.zero);

    // Inner sacred circle
    final innerCirclePath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius * 0.28));
    starPath.addPath(innerCirclePath, Offset.zero);

    // Central jewel dot
    final centerDotPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius * 0.08));
    starPath.addPath(centerDotPath, Offset.zero);

    // 3. Stroke Path Drawing with PathMetrics
    final strokePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final metrics = starPath.computeMetrics();
    for (final metric in metrics) {
      final extractLength = metric.length * strokeProgress.clamp(0.0, 1.0);
      final pathSegment = metric.extractPath(0.0, extractLength);
      canvas.drawPath(pathSegment, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant IslamicRubElHizbPainter oldDelegate) {
    return oldDelegate.strokeProgress != strokeProgress ||
        oldDelegate.glowProgress != glowProgress ||
        oldDelegate.primaryColor != primaryColor;
  }
}

class CrescentMoonPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color color;
  final bool fill;

  CrescentMoonPainter({
    required this.progress,
    this.color = AppTheme.gold,
    this.fill = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.44;

    // Outer circle
    final outerPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    // Inner cutout circle shifted slightly right and up
    final innerCenter = Offset(center.dx + radius * 0.38, center.dy - radius * 0.1);
    final innerPath = Path()
      ..addOval(Rect.fromCircle(center: innerCenter, radius: radius * 0.88));

    // Moon Crescent is outer minus inner
    final crescentPath = Path.combine(PathOperation.difference, outerPath, innerPath);

    if (fill) {
      final fillPaint = Paint()
        ..color = color.withValues(alpha: 0.9 * progress.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawPath(crescentPath, fillPaint);
    }

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final metrics = crescentPath.computeMetrics();
    for (final metric in metrics) {
      final segment = metric.extractPath(0.0, metric.length * progress.clamp(0.0, 1.0));
      canvas.drawPath(segment, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CrescentMoonPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
