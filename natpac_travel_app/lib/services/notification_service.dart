import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: androidInit));
    tz.initializeTimeZones();
  }

  Future<void> showSimple(String title, String body) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails('natpac_channel', 'NATPAC', importance: Importance.defaultImportance),
    );
    await _plugin.show(0, title, body, details);
  }

  Future<void> scheduleDailyReminder({int hour = 20, int minute = 0}) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails('reminders', 'Reminders', importance: Importance.high, priority: Priority.high),
    );
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      100,
      'Daily Trip Reminder',
      'Please review and submit your trip details.',
      scheduled,
      details,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}

