import 'dart:ui';
import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moaqit/core/theme/app_theme.dart';
import 'package:moaqit/core/services/prayer_service.dart';
import 'package:moaqit/core/services/location_service.dart';
import 'package:moaqit/core/localization/app_localizations.dart';
import 'package:moaqit/core/widgets/celestial_sky_painter.dart';
import 'package:moaqit/core/widgets/rolling_odometer.dart';

class CelestialHeader extends StatefulWidget {
  final PrayerSchedule schedule;
  final UserLocation location;
  final HijriInfo hijri;
  final VoidCallback onLocationTap;

  const CelestialHeader({
    super.key,
    required this.schedule,
    required this.location,
    required this.hijri,
    required this.onLocationTap,
  });

  @override
  State<CelestialHeader> createState() => _CelestialHeaderState();
}

class _CelestialHeaderState extends State<CelestialHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _twinkleController;

  @override
  void initState() {
    super.initState();
    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _twinkleController.dispose();
    super.dispose();
  }

  LinearGradient _getSkyGradient(bool isNight) {
    if (isNight) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF060D17),
          Color(0xFF0F1E2E),
          Color(0xFF14273A),
        ],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0B2433),
          Color(0xFF134255),
          Color(0xFF1C5468),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isArabic = loc.isArabic;
    final now = DateTime.now();
    final gregorianStr = DateFormat('d MMMM yyyy', isArabic ? 'ar' : 'en').format(now);
    final nextPrayerName = loc.translate(widget.schedule.nextPrayer.name);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 270,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            // 1. Dynamic Celestial Sky Background Gradient
            AnimatedContainer(
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: _getSkyGradient(widget.schedule.isNight),
              ),
            ),

            // 2. Trajectory Arc & Particles CustomPainter
            AnimatedBuilder(
              animation: _twinkleController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 270),
                  painter: CelestialSkyPainter(
                    celestialProgress: widget.schedule.celestialProgress,
                    isNight: widget.schedule.isNight,
                    starTwinkleProgress: _twinkleController.value,
                  ),
                );
              },
            ),

            // 3. Header Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Row: Location chip + Hijri Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Location selector chip
                      GestureDetector(
                        onTap: widget.onLocationTap,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    widget.location.isGps
                                        ? Icons.gps_fixed_rounded
                                        : Icons.location_on_rounded,
                                    size: 15,
                                    color: AppTheme.gold,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    widget.location.displayName(isArabic),
                                    style: GoogleFonts.cairo(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  const Icon(
                                    Icons.arrow_drop_down_rounded,
                                    size: 18,
                                    color: Colors.white70,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Dates (Hijri & Gregorian)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            isArabic
                                ? widget.hijri.formattedAr
                                : widget.hijri.formattedEn,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.goldLight,
                            ),
                          ),
                          Text(
                            gregorianStr,
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Center: Next Prayer Title & Rolling Odometer Digits
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${loc.translate('nextPrayer')}: $nextPrayerName',
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Rolling Odometer Countdown Digits
                        RollingTimeOdometer(
                          duration: widget.schedule.timeRemaining,
                          digitStyle: GoogleFonts.cairo(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.goldLight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Bottom Info badge (Adhan time + Shuruq/status)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${loc.translate('nowAdhan')}: ${DateFormat('hh:mm a', isArabic ? 'ar' : 'en').format(widget.schedule.nextPrayerTime)}',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.emerald.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppTheme.emerald.withValues(alpha: 0.4),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          widget.schedule.isNight
                              ? (isArabic ? 'وقت الليل' : 'Night time')
                              : (isArabic ? 'وقت النهار' : 'Day time'),
                          style: GoogleFonts.cairo(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.emerald,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
