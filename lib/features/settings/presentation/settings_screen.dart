import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adhan/adhan.dart';
import 'package:moaqit/core/theme/app_theme.dart';
import 'package:moaqit/core/services/prayer_service.dart';
import 'package:moaqit/core/localization/app_localizations.dart';
import 'package:moaqit/core/localization/locale_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _getMethodName(CalculationMethod method, bool isArabic) {
    switch (method) {
      case CalculationMethod.umm_al_qura:
        return isArabic ? 'أم القرى (مكة المكرمة)' : 'Umm Al-Qura (Makkah)';
      case CalculationMethod.muslim_world_league:
        return isArabic
            ? 'رابطة العالم الإسلامي'
            : 'Muslim World League (MWL)';
      case CalculationMethod.egyptian:
        return isArabic
            ? 'الهيئة المصرية العامة للمساحة'
            : 'Egyptian General Authority';
      case CalculationMethod.karachi:
        return isArabic
            ? 'جامعة العلوم الإسلامية بكراتشي'
            : 'University of Islamic Sciences, Karachi';
      case CalculationMethod.dubai:
        return isArabic ? 'دائرة الشؤون الإسلامية بدبي' : 'Dubai (UAE)';
      case CalculationMethod.qatar:
        return isArabic ? 'وزارة الأوقاف القطرية' : 'Qatar';
      case CalculationMethod.kuwait:
        return isArabic ? 'وزارة الأوقاف الكويتية' : 'Kuwait';
      case CalculationMethod.north_america:
        return isArabic
            ? 'الجمعية الإسلامية لأمريكا الشمالية (ISNA)'
            : 'North America (ISNA)';
      case CalculationMethod.singapore:
        return isArabic
            ? 'مجلس الشؤون الإسلامية بسنغافورة (MUIS)'
            : 'Singapore (MUIS)';
      case CalculationMethod.turkey:
        return isArabic
            ? 'رئاسة الشؤون الدينية بتركيا (Diyanet)'
            : 'Turkey (Diyanet)';
      default:
        return method.name;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final isArabic = loc.isArabic;
    final settings = ref.watch(prayerSettingsProvider);
    final settingsNotifier = ref.read(prayerSettingsProvider.notifier);
    final hijri = ref.watch(hijriInfoProvider);

    final methods = [
      CalculationMethod.umm_al_qura,
      CalculationMethod.muslim_world_league,
      CalculationMethod.egyptian,
      CalculationMethod.karachi,
      CalculationMethod.dubai,
      CalculationMethod.qatar,
      CalculationMethod.kuwait,
      CalculationMethod.north_america,
      CalculationMethod.singapore,
      CalculationMethod.turkey,
    ];

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Screen Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: AppTheme.gold,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.translate('settings'),
                        style: GoogleFonts.amiri(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.goldLight,
                        ),
                      ),
                      Text(
                        isArabic
                            ? 'طرق الحساب والمذهب وتعديل التقويم الهجري'
                            : 'Calculation methods, Madhab, and Hijri moon sighting',
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

          // 1. Astronomical Calculation Method
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF101920).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calculate_outlined,
                          color: AppTheme.gold, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        loc.translate('calculationMethod'),
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<CalculationMethod>(
                        isExpanded: true,
                        value: settings.calculationMethod,
                        dropdownColor: const Color(0xFF13202C),
                        icon: const Icon(Icons.arrow_drop_down,
                            color: AppTheme.gold),
                        items: methods.map((m) {
                          return DropdownMenuItem<CalculationMethod>(
                            value: m,
                            child: Text(
                              _getMethodName(m, isArabic),
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (newMethod) {
                          if (newMethod != null) {
                            settingsNotifier.setCalculationMethod(newMethod);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Madhab Jurisprudence (Asr)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF101920).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.menu_book_rounded,
                          color: AppTheme.emerald, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        loc.translate('madhab'),
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildChoiceChip(
                          title: isArabic
                              ? 'الجمهور (شافعي/مالكي/حنبلي)'
                              : 'Standard (Shafi, Maliki, Hanbali)',
                          isSelected: settings.madhab == Madhab.shafi,
                          onTap: () => settingsNotifier.setMadhab(Madhab.shafi),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildChoiceChip(
                          title: isArabic ? 'الحنفي (ظل المثلين)' : 'Hanafi',
                          isSelected: settings.madhab == Madhab.hanafi,
                          onTap: () =>
                              settingsNotifier.setMadhab(Madhab.hanafi),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. Hijri Day Offset Adjustment (-2 to +2 days)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF101920).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded,
                          color: AppTheme.gold, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        loc.translate('hijriAdjustment'),
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isArabic
                        ? 'لتطابق التاريخ الهجري تماماً مع رؤية الهلال في بلدك:'
                        : 'Adjust Hijri date to precisely match your local moon sighting:',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Offset Selector Buttons: -2, -1, 0, +1, +2
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [-2, -1, 0, 1, 2].map((offset) {
                      final isSelected = settings.hijriOffset == offset;
                      final sign = offset > 0 ? '+$offset' : '$offset';

                      return GestureDetector(
                        onTap: () => settingsNotifier.setHijriOffset(offset),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.gold
                                : Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.goldLight
                                  : Colors.white12,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            loc.formatNumber(sign),
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Live Date Result Preview
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.gold.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            color: AppTheme.gold, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${loc.isArabic ? "التاريخ الهجري الحالي:" : "Current Hijri Date:"} ${isArabic ? hijri.formattedAr : hijri.formattedEn}',
                            style: GoogleFonts.cairo(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.goldLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Language & System Preferences
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF101920).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language_rounded,
                          color: AppTheme.sapphire, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        loc.translate('language'),
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildChoiceChip(
                          title: 'العربية (Arabic - RTL)',
                          isSelected: isArabic,
                          onTap: () => ref
                              .read(localeProvider.notifier)
                              .setLocale(const Locale('ar')),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildChoiceChip(
                          title: 'English (LTR)',
                          isSelected: !isArabic,
                          onTap: () => ref
                              .read(localeProvider.notifier)
                              .setLocale(const Locale('en')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // App Architecture & Motion Signature Card
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Mawaqit مواقيت v1.0.0',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Engineered for Flutter 3.50 & Dart 3.14 with Impeller Engine & Swift Package Manager',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 110)),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.gold.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.gold : Colors.white12,
            width: isSelected ? 1.2 : 0.8,
          ),
        ),
        child: Center(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.goldLight : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
