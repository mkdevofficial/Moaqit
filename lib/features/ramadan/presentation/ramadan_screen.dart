import 'dart:math';
import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moaqit/core/theme/app_theme.dart';
import 'package:moaqit/core/services/prayer_service.dart';
import 'package:moaqit/core/services/storage_service.dart';
import 'package:moaqit/core/localization/app_localizations.dart';
import 'package:moaqit/core/widgets/rolling_odometer.dart';

class RamadanScreen extends ConsumerStatefulWidget {
  const RamadanScreen({super.key});

  @override
  ConsumerState<RamadanScreen> createState() => _RamadanScreenState();
}

class _RamadanScreenState extends ConsumerState<RamadanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _swayController;
  final Set<int> _checkedItems = {};

  @override
  void initState() {
    super.initState();
    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _loadChecklist();
  }

  void _loadChecklist() {
    final storage = ref.read(storageServiceProvider);
    final savedList = storage.getStringList('spiritual_checklist') ?? [];
    setState(() {
      _checkedItems.clear();
      for (final s in savedList) {
        final parsed = int.tryParse(s);
        if (parsed != null) _checkedItems.add(parsed);
      }
    });
  }

  Future<void> _toggleChecklist(int index) async {
    setState(() {
      if (_checkedItems.contains(index)) {
        _checkedItems.remove(index);
      } else {
        _checkedItems.add(index);
      }
    });

    final storage = ref.read(storageServiceProvider);
    final strList = _checkedItems.map((e) => e.toString()).toList();
    await storage.setStringList('spiritual_checklist', strList);
  }

  @override
  void dispose() {
    _swayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isArabic = loc.isArabic;
    final ramadanInfo = ref.watch(ramadanCountdownProvider);
    final hijri = ref.watch(hijriInfoProvider);

    final checklist = [
      loc.isArabic
          ? 'المحافظة على الصلوات الخمس في وقتها بخشوع'
          : 'Preserve 5 daily prayers in their times',
      loc.isArabic
          ? 'تلاوة جزء من القرآن الكريم بتدبر'
          : 'Recite daily Juz of the Holy Quran',
      loc.isArabic
          ? 'المحافظة على أذكار الصباح والمساء'
          : 'Morning & evening remembrance (Adhkar)',
      loc.isArabic
          ? 'صيام الإثنين والخميس والأيام البيض'
          : 'Fasting Mondays, Thursdays, and White Days',
      loc.isArabic
          ? 'صلاة الضحى والوتر وقيام الليل'
          : 'Praying Duha, Witr, and Qiyam al-Layl',
      loc.isArabic
          ? 'الصدقة اليومية والإحسان إلى الناس'
          : 'Giving daily Sadaqah and kindness to others',
    ];

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Screen Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.nights_stay_rounded,
                      color: AppTheme.gold,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.translate('ramadanCountdownTitle'),
                        style: GoogleFonts.amiri(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.goldLight,
                        ),
                      ),
                      Text(
                        isArabic
                            ? 'أيام مباركة نستعد فيها لنفحات الشهر الفضيل'
                            : 'Blessed countdown to the Holy Month of Ramadan',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Swaying Crescent & Lantern Motion Card
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0E251E),
                    Color(0xFF14352B),
                    Color(0xFF091A15),
                  ],
                ),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: AppTheme.gold.withValues(alpha: 0.3),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Animated Swaying Crescent & Lantern
                  SizedBox(
                    height: 120,
                    child: AnimatedBuilder(
                      animation: _swayController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(double.infinity, 120),
                          painter: SwayingLanternPainter(
                            swayProgress: _swayController.value,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Ramadan status or Countdown digits
                  if (ramadanInfo.isRamadanNow) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.gold,
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        '${loc.translate('ramadanMubarak')} - ${loc.isArabic ? "اليوم ${loc.formatNumber(ramadanInfo.currentRamadanDay)}" : "Day ${ramadanInfo.currentRamadanDay}"}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.amiri(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.goldLight,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Countdown Grid: Days, Hours, Minutes, Seconds
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCountdownColumn(
                            value: ramadanInfo.days.toString(),
                            label: loc.translate('days'),
                          ),
                          _buildColonDivider(),
                          _buildCountdownColumn(
                            value: ramadanInfo.hours.toString().padLeft(2, '0'),
                            label: loc.translate('hours'),
                          ),
                          _buildColonDivider(),
                          _buildCountdownColumn(
                            value: ramadanInfo.minutes.toString().padLeft(2, '0'),
                            label: loc.translate('minutes'),
                          ),
                          _buildColonDivider(),
                          _buildCountdownColumn(
                            value: ramadanInfo.seconds.toString().padLeft(2, '0'),
                            label: loc.translate('seconds'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Hijri Year Progress & Moon Phase Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  // Year Progress Arc Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111E26).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.translate('hijriYearProgress'),
                            style: GoogleFonts.cairo(
                              fontSize: 12.5,
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              SizedBox(
                                width: 44,
                                height: 44,
                                child: Stack(
                                  children: [
                                    Center(
                                      child: CircularProgressIndicator(
                                        value: ramadanInfo.yearProgress,
                                        strokeWidth: 4.5,
                                        backgroundColor:
                                            Colors.white.withValues(alpha: 0.1),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                AppTheme.gold),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        '${(ramadanInfo.yearProgress * 100).toInt()}%',
                                        style: GoogleFonts.cairo(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.goldLight,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  isArabic
                                      ? 'مضى ${loc.formatNumber(hijri.month)} أشهر من ${loc.formatNumber(hijri.year)} هـ'
                                      : '${hijri.month} months of ${hijri.year} AH passed',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.5,
                                    color: Colors.white60,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Moon Phase Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111E26).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.translate('currentMoonPhase'),
                            style: GoogleFonts.cairo(
                              fontSize: 12.5,
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.sapphire.withValues(alpha: 0.15),
                                  border: Border.all(
                                    color: AppTheme.sapphire.withValues(alpha: 0.4),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.brightness_2_rounded,
                                  color: Color(0xFF93C5FD),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  isArabic
                                      ? ramadanInfo.moonPhaseNameAr
                                      : ramadanInfo.moonPhaseNameEn,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Daily Spiritual Readiness Checklist Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.translate('spiritualChecklist'),
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${_checkedItems.length}/${checklist.length}',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.emerald,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Checklist items
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final isChecked = _checkedItems.contains(index);
                final text = checklist[index];

                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: isChecked
                        ? AppTheme.emerald.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isChecked
                          ? AppTheme.emerald.withValues(alpha: 0.45)
                          : Colors.white.withValues(alpha: 0.07),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    onTap: () => _toggleChecklist(index),
                    leading: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: isChecked ? AppTheme.emerald : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isChecked ? AppTheme.emerald : Colors.white38,
                          width: 1.8,
                        ),
                      ),
                      child: isChecked
                          ? const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: Colors.black,
                            )
                          : null,
                    ),
                    title: Text(
                      text,
                      style: GoogleFonts.cairo(
                        fontSize: 13.5,
                        fontWeight:
                            isChecked ? FontWeight.bold : FontWeight.normal,
                        color: isChecked ? Colors.white : Colors.white70,
                        decoration: isChecked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                );
              },
              childCount: checklist.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 110)),
        ],
      ),
    );
  }

  Widget _buildCountdownColumn({
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.gold.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value.length > 2) ...[
                RollingOdometerDigit(
                  value: value[0],
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldLight,
                  ),
                ),
                RollingOdometerDigit(
                  value: value[1],
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldLight,
                  ),
                ),
                RollingOdometerDigit(
                  value: value[2],
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldLight,
                  ),
                ),
              ] else ...[
                RollingOdometerDigit(
                  value: value.padLeft(2, '0')[0],
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldLight,
                  ),
                ),
                RollingOdometerDigit(
                  value: value.padLeft(2, '0')[1],
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldLight,
                  ),
                ),
              ]
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildColonDivider() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Text(
        ':',
        style: GoogleFonts.cairo(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppTheme.gold.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

class SwayingLanternPainter extends CustomPainter {
  final double swayProgress; // 0.0 to 1.0 (sine wave oscillation)

  SwayingLanternPainter({required this.swayProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final centerOrigin = Offset(w / 2, 0);

    // Harmonic angle swing: -0.06 to +0.06 rad
    final angle = sin(swayProgress * pi * 2) * 0.08;

    canvas.save();
    canvas.translate(centerOrigin.dx, centerOrigin.dy);
    canvas.rotate(angle);

    // 1. Hanging cord
    final cordPaint = Paint()
      ..color = AppTheme.gold.withValues(alpha: 0.6)
      ..strokeWidth = 1.4;
    canvas.drawLine(Offset.zero, const Offset(0, 36), cordPaint);

    // 2. Crescent Moon hanging
    final moonCenter = const Offset(0, 52);
    final moonOuter = Path()
      ..addOval(Rect.fromCircle(center: moonCenter, radius: 14));
    final moonInner = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(moonCenter.dx + 6, moonCenter.dy - 3), radius: 12));
    final moonPath =
        Path.combine(PathOperation.difference, moonOuter, moonInner);

    final moonPaint = Paint()
      ..color = AppTheme.goldLight
      ..style = PaintingStyle.fill;
    canvas.drawPath(moonPath, moonPaint);

    // 3. Lantern body hanging below moon
    final lanternCordPaint = Paint()
      ..color = AppTheme.gold.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;
    canvas.drawLine(const Offset(0, 66), const Offset(0, 76), lanternCordPaint);

    final lanternCenter = const Offset(0, 96);

    // Lantern glowing aura
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.goldLight.withValues(alpha: 0.45),
          Colors.transparent,
        ],
      ).createShader(
          Rect.fromCircle(center: lanternCenter, radius: 26));
    canvas.drawCircle(lanternCenter, 26, auraPaint);

    // Lantern hexagonal frame
    final lanternPath = Path()
      ..moveTo(-10, 76)
      ..lineTo(10, 76)
      ..lineTo(14, 94)
      ..lineTo(8, 110)
      ..lineTo(-8, 110)
      ..lineTo(-14, 94)
      ..close();

    final lanternFill = Paint()
      ..color = AppTheme.gold.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawPath(lanternPath, lanternFill);

    final lanternStroke = Paint()
      ..color = AppTheme.goldLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(lanternPath, lanternStroke);

    // Inner glowing flame
    final flamePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(0, 93), 3.5, flamePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SwayingLanternPainter oldDelegate) {
    return oldDelegate.swayProgress != swayProgress;
  }
}
