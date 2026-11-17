import 'package:home_widget/home_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:moaqit/core/services/prayer_service.dart';
import 'package:moaqit/core/services/location_service.dart';
import 'package:moaqit/core/localization/locale_provider.dart';

final widgetSyncServiceProvider = Provider<WidgetSyncService>((ref) {
  return WidgetSyncService();
});

class WidgetSyncService {
  static const String androidWidgetProvider = 'NextPrayerWidgetReceiver';
  static const String iOSWidgetFamily = 'MawaqitWidget';

  Future<void> syncPrayerData({
    required PrayerSchedule schedule,
    required UserLocation location,
    required HijriInfo hijri,
    required bool isArabic,
  }) async {
    try {
      final timeFormatter = DateFormat('hh:mm a', isArabic ? 'ar' : 'en');

      final remainingHours = schedule.timeRemaining.inHours;
      final remainingMinutes = schedule.timeRemaining.inMinutes % 60;
      final remainingText =
          '${remainingHours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}';

      String nextPrayerName;
      switch (schedule.nextPrayer.name) {
        case 'fajr':
          nextPrayerName = isArabic ? 'الفجر' : 'Fajr';
          break;
        case 'sunrise':
          nextPrayerName = isArabic ? 'الشروق' : 'Sunrise';
          break;
        case 'dhuhr':
          nextPrayerName = isArabic ? 'الظهر' : 'Dhuhr';
          break;
        case 'asr':
          nextPrayerName = isArabic ? 'العصر' : 'Asr';
          break;
        case 'maghrib':
          nextPrayerName = isArabic ? 'المغرب' : 'Maghrib';
          break;
        case 'isha':
          nextPrayerName = isArabic ? 'العشاء' : 'Isha';
          break;
        default:
          nextPrayerName = isArabic ? 'الفجر' : 'Fajr';
      }

      await HomeWidget.saveWidgetData<String>(
          'next_prayer_name', nextPrayerName);
      await HomeWidget.saveWidgetData<String>(
          'next_prayer_time', timeFormatter.format(schedule.nextPrayerTime));
      await HomeWidget.saveWidgetData<String>(
          'remaining_time', remainingText);
      await HomeWidget.saveWidgetData<String>(
          'city_name', location.displayName(isArabic));
      await HomeWidget.saveWidgetData<String>(
          'hijri_date', isArabic ? hijri.formattedAr : hijri.formattedEn);

      await HomeWidget.saveWidgetData<String>(
          'fajr_time', timeFormatter.format(schedule.fajr));
      await HomeWidget.saveWidgetData<String>(
          'sunrise_time', timeFormatter.format(schedule.sunrise));
      await HomeWidget.saveWidgetData<String>(
          'dhuhr_time', timeFormatter.format(schedule.dhuhr));
      await HomeWidget.saveWidgetData<String>(
          'asr_time', timeFormatter.format(schedule.asr));
      await HomeWidget.saveWidgetData<String>(
          'maghrib_time', timeFormatter.format(schedule.maghrib));
      await HomeWidget.saveWidgetData<String>(
          'isha_time', timeFormatter.format(schedule.isha));
      await HomeWidget.saveWidgetData<String>(
          'active_prayer', schedule.nextPrayer.name);

      await HomeWidget.updateWidget(
        name: androidWidgetProvider,
        iOSName: iOSWidgetFamily,
      );
    } catch (_) {
      // Widget sync failure non-blocking
    }
  }
}

// Auto sync coordinator provider
final widgetSyncCoordinatorProvider = Provider<void>((ref) {
  final schedule = ref.watch(prayerScheduleProvider);
  final location = ref.watch(currentLocationProvider);
  final hijri = ref.watch(hijriInfoProvider);
  final locale = ref.watch(localeProvider);
  final syncService = ref.watch(widgetSyncServiceProvider);

  // Trigger sync in background
  syncService.syncPrayerData(
    schedule: schedule,
    location: location,
    hijri: hijri,
    isArabic: locale.languageCode == 'ar',
  );
});
