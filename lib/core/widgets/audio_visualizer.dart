import 'package:material_ui/material_ui.dart';
import 'package:moaqit/core/theme/app_theme.dart';

class AudioVisualizerWidget extends StatelessWidget {
  final List<double> amplitudes; // 12 values between 0.0 and 1.0
  final bool isPlaying;
  final double height;
  final Color primaryColor;

  const AudioVisualizerWidget({
    super.key,
    required this.amplitudes,
    required this.isPlaying,
    this.height = 48.0,
    this.primaryColor = AppTheme.gold,
  });

  @override
  Widget build(BuildContext context) {
    final bars = amplitudes.isNotEmpty
        ? amplitudes
        : List.generate(12, (index) => 0.1);

    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(bars.length, (index) {
          final amp = isPlaying ? bars[index] : 0.12;
          final barHeight = (amp * height).clamp(4.0, height);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 90),
              curve: Curves.easeInOut,
              width: 4.5,
              height: barHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    primaryColor.withValues(alpha: 0.6),
                    AppTheme.goldLight,
                    if (amp > 0.65) AppTheme.emerald else AppTheme.goldLight,
                  ],
                ),
                boxShadow: isPlaying && amp > 0.4
                    ? [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }
}
