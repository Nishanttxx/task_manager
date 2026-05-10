import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    if (dart.library.html) 'notification_stubs.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/task_model.dart';
import 'dart:io' show Platform, File;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) return;

    tz.initializeTimeZones();
    try {
      // In newer versions of flutter_timezone, this returns a String or TimezoneInfo
      final dynamic tzResult = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = tzResult is String ? tzResult : tzResult.toString();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );
  }

  Future<void> scheduleTaskNotification(TaskModel task) async {
    if (kIsWeb) return;
    if (!task.isAlarmEnabled || task.completed || task.date.isBefore(DateTime.now())) {
      return;
    }

    final int id = task.id.hashCode;
    
    // Custom sound configuration
    AndroidNotificationDetails androidPlatformChannelSpecifics;
    
    if (task.alarmTonePath != null && File(task.alarmTonePath!).existsSync()) {
      androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'task_alarm_channel',
        'Task Alarms',
        channelDescription: 'Notifications for task reminders',
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
      );
    } else {
      androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'task_default_channel',
        'Task Reminders',
        channelDescription: 'Default task notifications',
        importance: Importance.max,
        priority: Priority.high,
      );
    }

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: const DarwinNotificationDetails(),
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      'Task Pending: ${task.title}',
      'Complete your task now: ${task.description}',
      tz.TZDateTime.from(task.date, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: _getMatchComponents(task.repeatOption),
      payload: task.id,
    );
  }

  Future<void> cancelNotification(String taskId) async {
    if (kIsWeb) return;
    await _notificationsPlugin.cancel(taskId.hashCode);
  }


  DateTimeComponents? _getMatchComponents(RepeatOption repeat) {
    switch (repeat) {
      case RepeatOption.daily:
        return DateTimeComponents.time;
      case RepeatOption.weekly:
        return DateTimeComponents.dayOfWeekAndTime;
      default:
        return null;
    }
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) return;
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }
}
