import 'dart:ui';
import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moaqit/core/constants/app_constants.dart';
import 'package:moaqit/core/services/location_service.dart';
import 'package:moaqit/core/theme/app_theme.dart';
import 'package:moaqit/core/localization/app_localizations.dart';

class CitySelectorModal extends ConsumerStatefulWidget {
  const CitySelectorModal({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CitySelectorModal(),
    );
  }

  @override
  ConsumerState<CitySelectorModal> createState() => _CitySelectorModalState();
}

class _CitySelectorModalState extends ConsumerState<CitySelectorModal> {
  final TextEditingController _searchController = TextEditingController();
  List<CityData> _filteredCities = AppConstants.cities;
  bool _isGpsLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCities = AppConstants.cities;
      } else {
        _filteredCities = AppConstants.cities.where((c) {
          return c.nameAr.toLowerCase().contains(query) ||
              c.nameEn.toLowerCase().contains(query) ||
              c.countryAr.toLowerCase().contains(query) ||
              c.countryEn.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isArabic = loc.isArabic;
    final currentLocation = ref.watch(currentLocationProvider);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.82,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: const Color(0xFF0D171F).withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            // Pull bar
            Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.translate('selectLocation'),
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // GPS Auto Detect Button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isGpsLoading
                    ? null
                    : () async {
                        setState(() => _isGpsLoading = true);
                        final success = await ref
                            .read(currentLocationProvider.notifier)
                            .detectGpsLocation();
                        if (mounted) {
                          setState(() => _isGpsLoading = false);
                        }
                        if (success && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.gold.withValues(alpha: 0.22),
                        AppTheme.emerald.withValues(alpha: 0.22),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.gold.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.gold.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: _isGpsLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.gold,
                                ),
                              )
                            : const Icon(
                                Icons.my_location_rounded,
                                color: AppTheme.goldLight,
                                size: 20,
                              ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.translate('autoGps'),
                              style: GoogleFonts.cairo(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              isArabic
                                  ? 'تحديد الإحداثيات الدقيقة عبر الأقمار الصناعية'
                                  : 'High-precision satellite coordinate detection',
                              style: GoogleFonts.cairo(
                                fontSize: 11.5,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (currentLocation.isGps)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.emerald,
                          size: 22,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Search text box
            TextField(
              controller: _searchController,
              style: GoogleFonts.cairo(color: Colors.white, fontSize: 14.5),
              decoration: InputDecoration(
                hintText: loc.translate('searchCity'),
                hintStyle: GoogleFonts.cairo(
                  color: Colors.white38,
                  fontSize: 13.5,
                ),
                prefixIcon:
                    const Icon(Icons.search_rounded, color: AppTheme.gold),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white38),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppTheme.gold,
                    width: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Cities List
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: _filteredCities.length,
                separatorBuilder: (ctx, i) => Divider(
                  color: Colors.white.withValues(alpha: 0.05),
                  height: 1,
                ),
                itemBuilder: (ctx, index) {
                  final city = _filteredCities[index];
                  final isSelected = !currentLocation.isGps &&
                      currentLocation.cityNameAr == city.nameAr;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    onTap: () {
                      ref
                          .read(currentLocationProvider.notifier)
                          .selectCity(city);
                      Navigator.of(context).pop();
                    },
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.gold.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          isArabic ? city.nameAr[0] : city.nameEn[0],
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppTheme.gold : Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      isArabic ? city.nameAr : city.nameEn,
                      style: GoogleFonts.cairo(
                        fontSize: 14.5,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppTheme.goldLight : Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      isArabic ? city.countryAr : city.countryEn,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppTheme.gold,
                            size: 22,
                          )
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
