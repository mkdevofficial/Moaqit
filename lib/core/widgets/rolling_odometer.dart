import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moaqit/core/localization/app_localizations.dart';

class RollingOdometerDigit extends StatelessWidget {
  final String value;
  final TextStyle? style;
  final Duration duration;

  const RollingOdometerDigit({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 350),
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final displayValue = localizations.formatNumber(value);

    final defaultStyle = GoogleFonts.cairo(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      height: 1.1,
    );

    return ClipRect(
      child: AnimatedSwitcher(
        duration: duration,
        transitionBuilder: (child, animation) {
          final inAnimation = Tween<Offset>(
            begin: const Offset(0.0, 0.6),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
          );

          final outAnimation = Tween<Offset>(
            begin: const Offset(0.0, -0.6),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInBack,
            ),
          );

          final isChildCurrent = (child.key as ValueKey<String>?)?.value == displayValue;

          return SlideTransition(
            position: isChildCurrent ? inAnimation : outAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: Text(
          displayValue,
          key: ValueKey<String>(displayValue),
          style: style ?? defaultStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class RollingTimeOdometer extends StatelessWidget {
  final Duration duration;
  final TextStyle? digitStyle;
  final TextStyle? labelStyle;
  final bool showSeconds;

  const RollingTimeOdometer({
    super.key,
    required this.duration,
    this.digitStyle,
    this.labelStyle,
    this.showSeconds = true,
  });

  @override
  Widget build(BuildContext context) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    final colonStyle = (digitStyle ?? GoogleFonts.cairo(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: Colors.white70,
    )).copyWith(
      color: (digitStyle?.color ?? Colors.white).withValues(alpha: 0.6),
    );

    return Directionality(
      textDirection: TextDirection.ltr, // Keep time format HH:MM:SS strictly LTR
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Hours
          _buildUnitBlock(hours, digitStyle),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(':', style: colonStyle),
          ),
          // Minutes
          _buildUnitBlock(minutes, digitStyle),
          if (showSeconds) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(':', style: colonStyle),
            ),
            // Seconds
            _buildUnitBlock(seconds, digitStyle),
          ],
        ],
      ),
    );
  }

  Widget _buildUnitBlock(String val, TextStyle? style) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RollingOdometerDigit(value: val[0], style: style),
          RollingOdometerDigit(value: val[1], style: style),
        ],
      ),
    );
  }
}
