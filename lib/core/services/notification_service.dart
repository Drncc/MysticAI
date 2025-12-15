import 'dart:io'; // Platform kontrolü için eklendi
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:math';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Windows/Linux için güvenli ayar
    const LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(defaultActionName: 'Open notification');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      linux: initializationSettingsLinux,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleDailyNotification() async {
    // KRİTİK DÜZELTME: Windows'ta zamanlanmış bildirim desteklenmediği için
    // kodu sadece Mobil cihazlarda çalışacak şekilde kısıtlıyoruz.
    if (!Platform.isAndroid && !Platform.isIOS) {
      print("Windows/Desktop platformunda zamanlanmış bildirim atlandı.");
      return; 
    }

    final List<String> messages = [
      "⚠️ Kozmik Uyarı: Bugün enerjiler karışık.",
      "🌌 Evrenin sana bir mesajı var Gezgin.",
      "🔥 Mars retrosu başladı. Dikkatli ol.",
    ];

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'daily_reminder_channel',
      'Günlük Hatırlatıcı',
      channelDescription: 'Günlük kozmik bildirimler',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Mystic AI',
        messages[Random().nextInt(messages.length)],
        _nextInstanceOfNineAM(),
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      print("Bildirim planlama hatası: $e");
    }
  }

  tz.TZDateTime _nextInstanceOfNineAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 9);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}