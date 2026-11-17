import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open Mawaqit',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      linux: linuxSettings,
    );

    await _notifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {},
    );

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    bool granted = true;
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final androidGranted = await android.requestNotificationsPermission();
      final alarmGranted = await android.requestExactAlarmsPermission();
      granted = (androidGranted ?? false) && (alarmGranted ?? false);
    }

    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final iosGranted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      granted = iosGranted ?? false;
    }

    return granted;
  }

  Future<void> schedulePrayerNotifications({
    required DateTime fajr,
    required DateTime dhuhr,
    required DateTime asr,
    required DateTime maghrib,
    required DateTime isha,
    required bool isArabic,
  }) async {
    if (!_initialized) await initialize();

    await _notifications.cancelAll();

    final prayers = [
      {'id': 1, 'nameAr': 'صلاة الفجر', 'nameEn': 'Fajr Prayer', 'time': fajr},
      {'id': 2, 'nameAr': 'صلاة الظهر', 'nameEn': 'Dhuhr Prayer', 'time': dhuhr},
      {'id': 3, 'nameAr': 'صلاة العصر', 'nameEn': 'Asr Prayer', 'time': asr},
      {'id': 4, 'nameAr': 'صلاة المغرب', 'nameEn': 'Maghrib Prayer', 'time': maghrib},
      {'id': 5, 'nameAr': 'صلاة العشاء', 'nameEn': 'Isha Prayer', 'time': isha},
    ];

    const androidDetails = AndroidNotificationDetails(
      'mawaqit_adhan_channel',
      'Mawaqit Adhan & Prayer Times',
      channelDescription: 'Astronomical prayer times and Adhan alerts',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('adhan_calm'),
      playSound: true,
      enableVibration: true,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'adhan_calm.wav',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    final now = DateTime.now();

    for (final prayer in prayers) {
      final time = prayer['time'] as DateTime;
      if (time.isAfter(now)) {
        final id = prayer['id'] as int;
        final title = isArabic
            ? 'حان الآن موعد ${prayer['nameAr']}'
            : 'Time for ${prayer['nameEn']}';
        final body = isArabic
            ? 'حي على الصلاة .. حي على الفلاح'
            : 'Come to prayer .. Come to success';

        try {
          await _notifications.zonedSchedule(
            id: id,
            title: title,
            body: body,
            scheduledDate: tz.TZDateTime.from(time, tz.local),
            notificationDetails: details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        } catch (_) {
          // If timezone conversion fails fallback
        }
      }
    }
  }

  Future<void> showInstantTestNotification({
    required String title,
    required String body,
  }) async {
    if (!_initialized) await initialize();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'mawaqit_adhan_channel',
        'Mawaqit Adhan & Prayer Times',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      id: 999,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}
