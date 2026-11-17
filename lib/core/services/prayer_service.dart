import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moaqit/core/services/storage_service.dart';
import 'package:moaqit/core/services/location_service.dart';

class PrayerSchedule {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final Prayer nextPrayer;
  final DateTime nextPrayerTime;
  final Duration timeRemaining;
  final Prayer currentPrayer;
  final DateTime currentPrayerTime;
  final Duration timeElapsed;
  final double celestialProgress; // 0.0 to 1.0 for arc painter
  final bool isNight;

  const PrayerSchedule({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.nextPrayer,
    required this.nextPrayerTime,
    required this.timeRemaining,
    required this.currentPrayer,
    required this.currentPrayerTime,
    required this.timeElapsed,
    required this.celestialProgress,
    required this.isNight,
  });

  DateTime getTimeForPrayer(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return fajr;
      case Prayer.sunrise:
        return sunrise;
      case Prayer.dhuhr:
        return dhuhr;
      case Prayer.asr:
        return asr;
      case Prayer.maghrib:
        return maghrib;
      case Prayer.isha:
        return isha;
      case Prayer.none:
        return fajr;
    }
  }
}

class HijriInfo {
  final int year;
  final int month;
  final int day;
  final String formattedAr;
  final String formattedEn;
  final int offset;

  const HijriInfo({
    required this.year,
    required this.month,
    required this.day,
    required this.formattedAr,
    required this.formattedEn,
    required this.offset,
  });
}

class RamadanCountdownInfo {
  final int days;
  final int hours;
  final int minutes;
  final int seconds;
  final bool isRamadanNow;
  final int currentRamadanDay;
  final double yearProgress; // 0.0 to 1.0
  final double moonPhase; // 0.0 to 1.0
  final String moonPhaseNameAr;
  final String moonPhaseNameEn;

  const RamadanCountdownInfo({
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.isRamadanNow,
    required this.currentRamadanDay,
    required this.yearProgress,
    required this.moonPhase,
    required this.moonPhaseNameAr,
    required this.moonPhaseNameEn,
  });
}

// Settings State Models
class PrayerSettings {
  final CalculationMethod calculationMethod;
  final Madhab madhab;
  final int hijriOffset;

  const PrayerSettings({
    this.calculationMethod = CalculationMethod.umm_al_qura,
    this.madhab = Madhab.shafi,
    this.hijriOffset = 0,
  });

  PrayerSettings copyWith({
    CalculationMethod? calculationMethod,
    Madhab? madhab,
    int? hijriOffset,
  }) {
    return PrayerSettings(
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      hijriOffset: hijriOffset ?? this.hijriOffset,
    );
  }
}

final prayerSettingsProvider =
    NotifierProvider<PrayerSettingsNotifier, PrayerSettings>(() {
  return PrayerSettingsNotifier();
});

class PrayerSettingsNotifier extends Notifier<PrayerSettings> {
  @override
  PrayerSettings build() {
    final storage = ref.watch(storageServiceProvider);
    final methodName =
        storage.getString('calc_method') ?? CalculationMethod.umm_al_qura.name;
    final madhabName = storage.getString('madhab') ?? Madhab.shafi.name;
    final offset = storage.getInt('hijri_offset') ?? 0;

    CalculationMethod method = CalculationMethod.umm_al_qura;
    for (final m in CalculationMethod.values) {
      if (m.name == methodName) {
        method = m;
        break;
      }
    }

    Madhab madhab = Madhab.shafi;
    for (final md in Madhab.values) {
      if (md.name == madhabName) {
        madhab = md;
        break;
      }
    }

    return PrayerSettings(
      calculationMethod: method,
      madhab: madhab,
      hijriOffset: offset,
    );
  }

  Future<void> setCalculationMethod(CalculationMethod method) async {
    state = state.copyWith(calculationMethod: method);
    final storage = ref.read(storageServiceProvider);
    await storage.setString('calc_method', method.name);
  }

  Future<void> setMadhab(Madhab madhab) async {
    state = state.copyWith(madhab: madhab);
    final storage = ref.read(storageServiceProvider);
    await storage.setString('madhab', madhab.name);
  }

  Future<void> setHijriOffset(int offset) async {
    state = state.copyWith(hijriOffset: offset);
    final storage = ref.read(storageServiceProvider);
    await storage.setInt('hijri_offset', offset);
  }
}

// Live timer tick provider (fires every 1 second)
final tickerProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});

// Prayer calculation provider
final prayerScheduleProvider = Provider<PrayerSchedule>((ref) {
  // Trigger update every second
  final now = ref.watch(tickerProvider).value ?? DateTime.now();
  final location = ref.watch(currentLocationProvider);
  final settings = ref.watch(prayerSettingsProvider);

  final coords = Coordinates(location.latitude, location.longitude);
  final params = settings.calculationMethod.getParameters();
  params.madhab = settings.madhab;

  final dateComponents = DateComponents.from(now);
  final prayerTimes = PrayerTimes(coords, dateComponents, params);

  // Determine current & next prayer
  Prayer next = prayerTimes.nextPrayer();
  DateTime nextTime;
  DateTime prevTime;
  Prayer prev;

  if (next == Prayer.none) {
    // Tomorrow Fajr
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowPT =
        PrayerTimes(coords, DateComponents.from(tomorrow), params);
    next = Prayer.fajr;
    nextTime = tomorrowPT.fajr;
    prev = Prayer.isha;
    prevTime = prayerTimes.isha;
  } else {
    nextTime = prayerTimes.timeForPrayer(next)!;
    prev = prayerTimes.currentPrayer();
    if (prev == Prayer.none) {
      // Before Fajr today, so previous prayer was yesterday Isha
      final yesterday = now.subtract(const Duration(days: 1));
      final yesterdayPT =
          PrayerTimes(coords, DateComponents.from(yesterday), params);
      prev = Prayer.isha;
      prevTime = yesterdayPT.isha;
    } else {
      prevTime = prayerTimes.timeForPrayer(prev)!;
    }
  }

  final remaining = nextTime.isAfter(now)
      ? nextTime.difference(now)
      : Duration.zero;
  final elapsed = now.isAfter(prevTime)
      ? now.difference(prevTime)
      : Duration.zero;

  // Celestial progress (fraction between previous and next prayer)
  final totalInterval = nextTime.difference(prevTime).inSeconds;
  final progressSeconds = now.difference(prevTime).inSeconds;
  double celestialProgress = totalInterval > 0
      ? (progressSeconds / totalInterval).clamp(0.0, 1.0)
      : 0.0;

  // Day vs Night check
  final isNight = now.isBefore(prayerTimes.sunrise) || now.isAfter(prayerTimes.maghrib);

  return PrayerSchedule(
    fajr: prayerTimes.fajr,
    sunrise: prayerTimes.sunrise,
    dhuhr: prayerTimes.dhuhr,
    asr: prayerTimes.asr,
    maghrib: prayerTimes.maghrib,
    isha: prayerTimes.isha,
    nextPrayer: next,
    nextPrayerTime: nextTime,
    timeRemaining: remaining,
    currentPrayer: prev,
    currentPrayerTime: prevTime,
    timeElapsed: elapsed,
    celestialProgress: celestialProgress,
    isNight: isNight,
  );
});

// Hijri Date Provider
final hijriInfoProvider = Provider<HijriInfo>((ref) {
  final now = ref.watch(tickerProvider).value ?? DateTime.now();
  final settings = ref.watch(prayerSettingsProvider);

  // Apply manual offset
  final adjustedDate = now.add(Duration(days: settings.hijriOffset));
  final hDate = HijriCalendar.fromDate(adjustedDate);

  const arabicMonths = [
    '',
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الثاني',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة'
  ];

  const englishMonths = [
    '',
    'Muharram',
    'Safar',
    'Rabi al-Awwal',
    'Rabi al-Thani',
    'Jumada al-Ula',
    'Jumada al-Akhirah',
    'Rajab',
    'Sha’ban',
    'Ramadan',
    'Shawwal',
    'Dhu al-Qi’dah',
    'Dhu al-Hijjah'
  ];

  final monthIndex = hDate.hMonth.clamp(1, 12);
  final mAr = arabicMonths[monthIndex];
  final mEn = englishMonths[monthIndex];

  final formattedAr = '${hDate.hDay} $mAr ${hDate.hYear} هـ';
  final formattedEn = '${hDate.hDay} $mEn ${hDate.hYear} AH';

  return HijriInfo(
    year: hDate.hYear,
    month: hDate.hMonth,
    day: hDate.hDay,
    formattedAr: formattedAr,
    formattedEn: formattedEn,
    offset: settings.hijriOffset,
  );
});

// Ramadan Countdown Provider
final ramadanCountdownProvider = Provider<RamadanCountdownInfo>((ref) {
  final now = ref.watch(tickerProvider).value ?? DateTime.now();
  final hijri = ref.watch(hijriInfoProvider);

  final isRamadanNow = hijri.month == 9;
  final currentRamadanDay = isRamadanNow ? hijri.day : 0;

  // Approximate next Ramadan target:
  // If month is < 9 (Sha'ban, Rajab, etc.), Ramadan is in this Hijri year.
  // If month is >= 9, next Ramadan is in year + 1.
  int targetHijriYear = hijri.month < 9 ? hijri.year : hijri.year + 1;
  final targetHijriDate = HijriCalendar()
    ..hYear = targetHijriYear
    ..hMonth = 9
    ..hDay = 1;
  final ramadanStartDate = targetHijriDate.hijriToGregorian(
    targetHijriYear,
    9,
    1,
  );

  Duration diff = ramadanStartDate.difference(now);
  if (diff.isNegative) {
    diff = Duration.zero;
  }

  final days = diff.inDays;
  final hours = diff.inHours % 24;
  final minutes = diff.inMinutes % 60;
  final seconds = diff.inSeconds % 60;

  // Year Progress calculation (Hijri year is ~354.36 days)
  final dayOfYear = ((hijri.month - 1) * 29.5) + hijri.day;
  final yearProgress = (dayOfYear / 354.36).clamp(0.0, 1.0);

  // Approximate Moon phase calculation (29.53-day synodic lunar cycle)
  final moonAge = (hijri.day - 1) % 30;
  final moonPhase = (moonAge / 29.53).clamp(0.0, 1.0);

  String phaseAr;
  String phaseEn;
  if (hijri.day <= 2) {
    phaseAr = 'محاق / ولادة الهلال';
    phaseEn = 'New Moon';
  } else if (hijri.day <= 6) {
    phaseAr = 'هلال متزايد';
    phaseEn = 'Waxing Crescent';
  } else if (hijri.day <= 9) {
    phaseAr = 'تربيع أول';
    phaseEn = 'First Quarter';
  } else if (hijri.day <= 13) {
    phaseAr = 'أحدب متزايد';
    phaseEn = 'Waxing Gibbous';
  } else if (hijri.day <= 16) {
    phaseAr = 'بدر كامل (الليالي البيض)';
    phaseEn = 'Full Moon';
  } else if (hijri.day <= 20) {
    phaseAr = 'أحدب متناقص';
    phaseEn = 'Waning Gibbous';
  } else if (hijri.day <= 24) {
    phaseAr = 'تربيع ثانٍ';
    phaseEn = 'Third Quarter';
  } else {
    phaseAr = 'هلال أخير';
    phaseEn = 'Waning Crescent';
  }

  return RamadanCountdownInfo(
    days: days,
    hours: hours,
    minutes: minutes,
    seconds: seconds,
    isRamadanNow: isRamadanNow,
    currentRamadanDay: currentRamadanDay,
    yearProgress: yearProgress,
    moonPhase: moonPhase,
    moonPhaseNameAr: phaseAr,
    moonPhaseNameEn: phaseEn,
  );
});
