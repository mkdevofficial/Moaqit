import 'package:material_ui/material_ui.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('ar'));
  }

  bool get isArabic => locale.languageCode == 'ar';

  String formatNumber(dynamic value) {
    final str = value.toString();
    if (!isArabic) return str;
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return str.replaceAllMapped(RegExp(r'\d'), (m) {
      final digit = int.parse(m.group(0)!);
      return arabicDigits[digit];
    });
  }

  static const _localizedValues = <String, Map<String, String>>{
    'appName': {
      'ar': 'مواقيت',
      'en': 'Mawaqit',
    },
    'fajr': {
      'ar': 'الفجر',
      'en': 'Fajr',
    },
    'sunrise': {
      'ar': 'الشروق',
      'en': 'Sunrise',
    },
    'dhuhr': {
      'ar': 'الظهر',
      'en': 'Dhuhr',
    },
    'asr': {
      'ar': 'العصر',
      'en': 'Asr',
    },
    'maghrib': {
      'ar': 'المغرب',
      'en': 'Maghrib',
    },
    'isha': {
      'ar': 'العشاء',
      'en': 'Isha',
    },
    'nextPrayer': {
      'ar': 'الصلاة القادمة',
      'en': 'Next Prayer',
    },
    'remaining': {
      'ar': 'المتبقي',
      'en': 'Remaining',
    },
    'elapsed': {
      'ar': 'مضى على الأذان',
      'en': 'Elapsed',
    },
    'nowAdhan': {
      'ar': 'حان الآن وقت الأذان',
      'en': 'It is now Adhan time',
    },
    'selectLocation': {
      'ar': 'تحديد الموقع والمدينة',
      'en': 'Select Location & City',
    },
    'autoGps': {
      'ar': 'الموقع التلقائي (GPS)',
      'en': 'Auto-detect GPS',
    },
    'searchCity': {
      'ar': 'ابحث عن مدينة أو دولة...',
      'en': 'Search city or country...',
    },
    'ramadanCountdownTitle': {
      'ar': 'كم بقي على رمضان',
      'en': 'Countdown to Ramadan',
    },
    'ramadanMubarak': {
      'ar': 'رمضان مبارك! تقبل الله منا ومنكم',
      'en': 'Ramadan Mubarak! May Allah accept our deeds',
    },
    'days': {
      'ar': 'يوم',
      'en': 'Days',
    },
    'hours': {
      'ar': 'ساعة',
      'en': 'Hours',
    },
    'minutes': {
      'ar': 'دقيقة',
      'en': 'Minutes',
    },
    'seconds': {
      'ar': 'ثانية',
      'en': 'Seconds',
    },
    'hijriYearProgress': {
      'ar': 'تقدّم العام الهجري',
      'en': 'Hijri Year Progress',
    },
    'currentMoonPhase': {
      'ar': 'طَوْر القمر',
      'en': 'Moon Phase',
    },
    'spiritualChecklist': {
      'ar': 'الاستعداد الروحي اليومي',
      'en': 'Daily Spiritual Readiness',
    },
    'adhanStudio': {
      'ar': 'استوديو الأذان',
      'en': 'Adhan Studio',
    },
    'previewAdhan': {
      'ar': 'معاينة صوت الأذان',
      'en': 'Preview Adhan Voice',
    },
    'volume': {
      'ar': 'مستوى الصوت',
      'en': 'Volume Level',
    },
    'fadeIn': {
      'ar': 'تدرج الصوت الهادئ (Fade-in)',
      'en': 'Gentle Fade-in Effect',
    },
    'calmSerene': {
      'ar': 'هادئ وسكينة (الفجر والبيئات الهادئة)',
      'en': 'Calm & Serene (Soft & tranquil)',
    },
    'mujawwad': {
      'ar': 'مجود ومقامي (الحرمين والقدس)',
      'en': 'Melodious / Mujawwad (Classical)',
    },
    'clearHigh': {
      'ar': 'واضح ومرتفع (للبيئات الصاخبة)',
      'en': 'Clear & High Volume (Crisp projection)',
    },
    'shortTakbir': {
      'ar': 'تكبير مختصر / تنبيه لطيف',
      'en': 'Short Takbir / Gentle Alert',
    },
    'settings': {
      'ar': 'الإعدادات',
      'en': 'Settings',
    },
    'calculationMethod': {
      'ar': 'طريقة الحساب الفلكي',
      'en': 'Astronomical Calculation Method',
    },
    'madhab': {
      'ar': 'المذهب الفقهي (العصر)',
      'en': 'Jurisprudence (Madhab - Asr)',
    },
    'hijriAdjustment': {
      'ar': 'تعديل رؤية الهلال (بالأيام)',
      'en': 'Hijri Day Offset (Moon sighting)',
    },
    'notifications': {
      'ar': 'التنبيهات والأذان',
      'en': 'Notifications & Adhan',
    },
    'theme': {
      'ar': 'المظهر والخلفية',
      'en': 'Theme & Appearance',
    },
    'language': {
      'ar': 'اللغة',
      'en': 'Language',
    },
    'permissionTitle': {
      'ar': 'أذونات أساسية لخدمتك بأفضل دقة',
      'en': 'Essential Permissions for Precision',
    },
    'permissionDesc': {
      'ar': 'يحتاج مواقيت لبعض الأذونات لحساب أوقات الصلاة الدقيقة وتنبيهك بها في وقتها تماماً.',
      'en': 'Mawaqit requires permissions to calculate precise times and notify you at the exact moment.',
    },
    'permissionLocation': {
      'ar': 'الموقع الجغرافي: لحساب مواقيت الصلاة والقبلة بدقة متناهية وفق إحداثياتك.',
      'en': 'Location: To calculate astronomical times and Qibla for your exact coordinates.',
    },
    'permissionNotification': {
      'ar': 'الإشعارات: لإرسال التنبيهات والأذان عند دخول وقت الصلاة.',
      'en': 'Notifications: To deliver Adhan audio and alerts at prayer times.',
    },
    'permissionAlarm': {
      'ar': 'المنبهات الدقيقة: لضمان رفع الأذان في الثانية המحددة دون تأخير.',
      'en': 'Exact Alarms: Ensures Adhan plays at the exact second without OS battery delays.',
    },
    'grantPermissions': {
      'ar': 'تفعيل الأذونات والمتابعة',
      'en': 'Grant Permissions & Continue',
    },
    'later': {
      'ar': 'سأفعلها لاحقاً',
      'en': 'Maybe Later',
    },
    'homeTab': {
      'ar': 'الرئيسية',
      'en': 'Home',
    },
    'ramadanTab': {
      'ar': 'رمضان',
      'en': 'Ramadan',
    },
    'adhanTab': {
      'ar': 'الأذان',
      'en': 'Adhan',
    },
    'settingsTab': {
      'ar': 'الإعدادات',
      'en': 'Settings',
    },
  };

  String translate(String key) {
    return _localizedValues[key]?[locale.languageCode] ??
        _localizedValues[key]?['ar'] ??
        key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
