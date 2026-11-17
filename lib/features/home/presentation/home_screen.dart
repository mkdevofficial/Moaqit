import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:adhan/adhan.dart';
import 'package:moaqit/core/theme/app_theme.dart';
import 'package:moaqit/core/services/prayer_service.dart';
import 'package:moaqit/core/services/location_service.dart';
import 'package:moaqit/core/services/audio_service.dart';
import 'package:moaqit/core/services/notification_service.dart';
import 'package:moaqit/core/services/widget_sync_service.dart';
import 'package:moaqit/core/localization/app_localizations.dart';
import 'package:moaqit/core/localization/locale_provider.dart';
import 'package:moaqit/core/widgets/custom_nav_bar.dart';
import 'package:moaqit/core/widgets/permission_sheet.dart';
import 'package:moaqit/features/home/presentation/widgets/celestial_header.dart';
import 'package:moaqit/features/home/presentation/widgets/prayer_card.dart';
import 'package:moaqit/features/home/presentation/widgets/city_selector_modal.dart';
import 'package:moaqit/features/ramadan/presentation/ramadan_screen.dart';
import 'package:moaqit/features/adhan/presentation/adhan_screen.dart';
import 'package:moaqit/features/settings/presentation/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentTabIndex = 0;
  bool _hasCheckedPermissions = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissionsIfNeeded();
    });
  }

  void _checkPermissionsIfNeeded() {
    if (!_hasCheckedPermissions) {
      _hasCheckedPermissions = true;
      // Show permission sheet gracefully on initial launch
      PermissionBottomSheet.show(
        context,
        onPermissionsHandled: () {
          // Re-schedule prayer notifications once granted
          final schedule = ref.read(prayerScheduleProvider);
          final loc = AppLocalizations.of(context);
          ref.read(notificationServiceProvider).schedulePrayerNotifications(
                fajr: schedule.fajr,
                dhuhr: schedule.dhuhr,
                asr: schedule.asr,
                maghrib: schedule.maghrib,
                isha: schedule.isha,
                isArabic: loc.isArabic,
              );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep widgets and notifications in sync with reactive Riverpod providers
    ref.watch(widgetSyncCoordinatorProvider);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Background celestial mesh gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF07141A),
                    Color(0xFF0A1E24),
                    Color(0xFF081216),
                  ],
                ),
              ),
            ),
          ),

          // Main View Tabs
          IndexedStack(
            index: _currentTabIndex,
            children: [
              _buildHomeDashboard(),
              const RamadanScreen(),
              const AdhanScreen(),
              const SettingsScreen(),
            ],
          ),

          // Custom Floating Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomNavBar(
              selectedIndex: _currentTabIndex,
              onItemSelected: (index) {
                setState(() => _currentTabIndex = index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeDashboard() {
    final loc = AppLocalizations.of(context);
    final schedule = ref.watch(prayerScheduleProvider);
    final location = ref.watch(currentLocationProvider);
    final hijri = ref.watch(hijriInfoProvider);

    final prayersList = [
      {'prayer': Prayer.fajr, 'time': schedule.fajr},
      {'prayer': Prayer.sunrise, 'time': schedule.sunrise},
      {'prayer': Prayer.dhuhr, 'time': schedule.dhuhr},
      {'prayer': Prayer.asr, 'time': schedule.asr},
      {'prayer': Prayer.maghrib, 'time': schedule.maghrib},
      {'prayer': Prayer.isha, 'time': schedule.isha},
    ];

    final now = DateTime.now();

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppTheme.gold.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppTheme.gold.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.mosque_rounded,
                          color: AppTheme.gold,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        loc.translate('appName'),
                        style: GoogleFonts.amiri(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.goldLight,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Quick Language toggle
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            loc.isArabic ? 'EN' : 'عربي',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        onPressed: () {
                          ref.read(localeProvider.notifier).toggleLocale();
                        },
                      ),
                      // Permission Sheet opener
                      IconButton(
                        icon: const Icon(Icons.shield_outlined,
                            color: Colors.white70),
                        tooltip: loc.translate('permissionTitle'),
                        onPressed: () {
                          PermissionBottomSheet.show(
                            context,
                            onPermissionsHandled: () {},
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Celestial Sky Trajectory Arc Header
          SliverToBoxAdapter(
            child: CelestialHeader(
              schedule: schedule,
              location: location,
              hijri: hijri,
              onLocationTap: () => CitySelectorModal.show(context),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Staggered Prayer Cards
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = prayersList[index];
                final prayer = item['prayer'] as Prayer;
                final time = item['time'] as DateTime;
                final isNext = schedule.nextPrayer == prayer;
                final isPassed = time.isBefore(now);

                return PrayerCard(
                  prayer: prayer,
                  time: time,
                  isNext: isNext,
                  isPassed: isPassed,
                  remainingTime: isNext ? schedule.timeRemaining : null,
                  onAdhanTap: () {
                    // Preview configured adhan style for this prayer
                    final audioNotifier = ref.read(audioEngineProvider.notifier);
                    final audioEngine = ref.read(audioEngineProvider);
                    final prayerKey = prayer.name;
                    final style =
                        audioEngine.prayerStyles[prayerKey] ?? AdhanStyle.mujawwad;
                    audioNotifier.previewStyle(style);
                  },
                )
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: 60 * index),
                      duration: const Duration(milliseconds: 400),
                    )
                    .slideY(
                      begin: 0.15,
                      end: 0,
                      curve: Curves.easeOutCubic,
                    );
              },
              childCount: prayersList.length,
            ),
          ),

          // Space for floating nav bar
          const SliverToBoxAdapter(
            child: SizedBox(height: 110),
          ),
        ],
      ),
    );
  }
}
