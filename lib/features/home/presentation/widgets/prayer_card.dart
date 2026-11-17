import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';
import 'package:moaqit/core/theme/app_theme.dart';
import 'package:moaqit/core/localization/app_localizations.dart';

class PrayerCard extends StatefulWidget {
  final Prayer prayer;
  final DateTime time;
  final bool isNext;
  final bool isPassed;
  final Duration? remainingTime;
  final VoidCallback? onAdhanTap;

  const PrayerCard({
    super.key,
    required this.prayer,
    required this.time,
    this.isNext = false,
    this.isPassed = false,
    this.remainingTime,
    this.onAdhanTap,
  });

  @override
  State<PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _glowAnimation = Tween<double>(begin: 0.25, end: 0.85).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    if (widget.isNext) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PrayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isNext && !oldWidget.isNext) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isNext && oldWidget.isNext) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  IconData _getPrayerIcon(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return Icons.wb_twilight_rounded;
      case Prayer.sunrise:
        return Icons.wb_sunny_outlined;
      case Prayer.dhuhr:
        return Icons.wb_sunny_rounded;
      case Prayer.asr:
        return Icons.cloud_queue_rounded;
      case Prayer.maghrib:
        return Icons.nights_stay_outlined;
      case Prayer.isha:
        return Icons.nights_stay_rounded;
      case Prayer.none:
        return Icons.access_time_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isArabic = loc.isArabic;
    final prayerName = loc.translate(widget.prayer.name);
    final timeStr = DateFormat('hh:mm a', isArabic ? 'ar' : 'en').format(widget.time);

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutQuad,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final glowVal = widget.isNext ? _glowAnimation.value : 0.0;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: widget.isNext
                    ? AppTheme.gold.withValues(alpha: 0.12)
                    : const Color(0xFF131D27).withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: widget.isNext
                      ? AppTheme.gold.withValues(alpha: glowVal)
                      : Colors.white.withValues(alpha: 0.08),
                  width: widget.isNext ? 1.6 : 0.9,
                ),
                boxShadow: widget.isNext
                    ? [
                        BoxShadow(
                          color: AppTheme.gold.withValues(alpha: glowVal * 0.3),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Prayer icon container
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.isNext
                          ? AppTheme.gold.withValues(alpha: 0.22)
                          : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getPrayerIcon(widget.prayer),
                      color: widget.isNext
                          ? AppTheme.goldLight
                          : (widget.isPassed
                              ? Colors.white38
                              : Colors.white70),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Prayer Name & Badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              prayerName,
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: widget.isNext
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: widget.isNext
                                    ? AppTheme.goldLight
                                    : (widget.isPassed
                                        ? Colors.white54
                                        : Colors.white),
                              ),
                            ),
                            if (widget.isNext) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.gold.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppTheme.gold.withValues(alpha: 0.6),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  loc.translate('nextPrayer'),
                                  style: GoogleFonts.cairo(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.goldLight,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (widget.isNext && widget.remainingTime != null)
                          Text(
                            '${loc.translate('remaining')}: ${loc.formatNumber(widget.remainingTime!.inHours)}:${loc.formatNumber((widget.remainingTime!.inMinutes % 60).toString().padLeft(2, '0'))}',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: AppTheme.goldLight.withValues(alpha: 0.85),
                            ),
                          )
                        else if (widget.isPassed)
                          Text(
                            loc.translate('elapsed'),
                            style: GoogleFonts.cairo(
                              fontSize: 11.5,
                              color: Colors.white38,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Time text
                  Text(
                    timeStr,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight:
                          widget.isNext ? FontWeight.bold : FontWeight.w600,
                      color: widget.isNext
                          ? AppTheme.goldLight
                          : (widget.isPassed
                              ? Colors.white38
                              : Colors.white),
                    ),
                  ),

                  // Adhan speaker icon (excluding sunrise)
                  if (widget.prayer != Prayer.sunrise) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.volume_up_rounded,
                        color: widget.isNext
                            ? AppTheme.gold
                            : Colors.white.withValues(alpha: 0.35),
                        size: 20,
                      ),
                      tooltip: loc.translate('previewAdhan'),
                      onPressed: widget.onAdhanTap,
                      splashRadius: 20,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
