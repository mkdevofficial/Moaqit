import 'dart:ui';
import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moaqit/core/theme/app_theme.dart';
import 'package:moaqit/core/localization/app_localizations.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final items = [
      {'icon': Icons.access_time_rounded, 'label': loc.translate('homeTab')},
      {'icon': Icons.nights_stay_rounded, 'label': loc.translate('ramadanTab')},
      {'icon': Icons.volume_up_rounded, 'label': loc.translate('adhanTab')},
      {'icon': Icons.tune_rounded, 'label': loc.translate('settingsTab')},
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF101C24).withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (index) {
                  final isSelected = selectedIndex == index;
                  final item = items[index];

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onItemSelected(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.gold.withValues(alpha: 0.18)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                          border: isSelected
                              ? Border.all(
                                  color: AppTheme.gold.withValues(alpha: 0.45),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedScale(
                              scale: isSelected ? 1.15 : 1.0,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutBack,
                              child: Icon(
                                item['icon'] as IconData,
                                color: isSelected
                                    ? AppTheme.gold
                                    : Colors.white.withValues(alpha: 0.55),
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 3),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: GoogleFonts.cairo(
                                fontSize: isSelected ? 11.5 : 10.5,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppTheme.goldLight
                                    : Colors.white.withValues(alpha: 0.5),
                              ),
                              child: Text(
                                item['label'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
