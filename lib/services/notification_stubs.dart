// Stubs for types that are not available on all platforms
class FlutterLocalNotificationsPlugin {
  Future<void> initialize(dynamic settings, {dynamic onDidReceiveNotificationResponse}) async {}
  Future<void> zonedSchedule(int id, String? title, String? body, dynamic scheduledDate, dynamic notificationDetails, {dynamic androidScheduleMode, dynamic uiLocalNotificationDateInterpretation, dynamic matchDateTimeComponents, dynamic payload}) async {}
  Future<void> cancel(int id) async {}
  T? resolvePlatformSpecificImplementation<T>() => null;
}

class AndroidInitializationSettings {
  const AndroidInitializationSettings(String icon);
}

class DarwinInitializationSettings {
  const DarwinInitializationSettings({bool requestAlertPermission = true, bool requestBadgePermission = true, bool requestSoundPermission = true});
}

class InitializationSettings {
  const InitializationSettings({dynamic android, dynamic iOS});
}

class NotificationResponse {}

class AndroidNotificationDetails {
  const AndroidNotificationDetails(String channelId, String channelName, {String? channelDescription, dynamic importance, dynamic priority, bool fullScreenIntent = false, dynamic category});
}

class DarwinNotificationDetails {
  const DarwinNotificationDetails();
}

class NotificationDetails {
  const NotificationDetails({dynamic android, dynamic iOS});
}

class AndroidFlutterLocalNotificationsPlugin {
  Future<void> requestNotificationsPermission() async {}
  Future<void> requestExactAlarmsPermission() async {}
}

enum Importance { max }
enum Priority { high }
enum AndroidNotificationCategory { alarm }

class AndroidScheduleMode {
  static const exact = null;
  static const exactAllowWhileIdle = null;
  static const inexact = null;
  static const inexactAllowWhileIdle = null;
}

class UILocalNotificationDateInterpretation {
  static const absoluteTime = null;
  static const wallClockTime = null;
}

class DateTimeComponents {
  static const time = null;
  static const dayOfWeekAndTime = null;
  static const dayOfMonthAndTime = null;
  static const dateAndTime = null;
}
