import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/app_settings.dart';
import '../models/task.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// this method is initializing channels and runtime permissions.
  static Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(settings);
    await _requestPermissionIfNeeded();
    _isInitialized = true;
  }

  static Future<void> _requestPermissionIfNeeded() async {
    final PermissionStatus notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      await Permission.notification.request();
    }

    final PermissionStatus exactAlarmStatus =
        await Permission.scheduleExactAlarm.status;
    if (!exactAlarmStatus.isGranted) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  static int _notificationIdFromTask(String taskId) {
    return taskId.hashCode & 0x7fffffff;
  }

  static Future<void> scheduleTaskReminder(
    TaskItem task,
    AppSettings settings,
  ) async {
    final int id = _notificationIdFromTask(task.id);
    final String description = 'rempo task reminder channel';

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      settings.soundEnabled ? 'rempo_loud' : 'rempo_silent',
      settings.soundEnabled ? 'Rempo Loud Alerts' : 'Rempo Silent Alerts',
      channelDescription: description,
      importance: Importance.max,
      priority: Priority.high,
      playSound: settings.soundEnabled,
      enableVibration: settings.hapticsEnabled,
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.reminder,
    );

    final NotificationDetails details = NotificationDetails(android: androidDetails);
    final tz.TZDateTime scheduled = tz.TZDateTime.from(task.dueAt, tz.local);
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    await _plugin.zonedSchedule(
      id,
      'task due',
      task.title,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: task.id,
    );
  }

  static Future<void> cancelTaskReminder(String taskId) async {
    await _plugin.cancel(_notificationIdFromTask(taskId));
  }
}
