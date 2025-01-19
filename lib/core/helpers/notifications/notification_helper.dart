import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '/features/reminder/models/reminder/reminder_model.dart';
import '../../../features/reminder/models/days/days_enum.dart';
import '../../core.dart';

const showTimeUpdateNotificationId = 0;

final class NotificationHelper {
  NotificationHelper._();
  static final shared = NotificationHelper._();

  final _notificationPlugin = FlutterLocalNotificationsPlugin();

  bool? isInitializationSucceded;

  /// Call this method in the `main` method to initialize the notification plugin.
  Future<void> get initializeNotificationPlugin async {
    try {
      const android = AndroidInitializationSettings("ic_launcher");
      const iOS = DarwinInitializationSettings();
      const initializationSettings = InitializationSettings(android: android, iOS: iOS, macOS: iOS);

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'HabitRise_Reminder', // Channel ID
        'Habit Reminder', // Channel Name
        description: 'Channel for reminder notifications',
        importance: Importance.high,
      );

      await _notificationPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

      isInitializationSucceded = await _notificationPlugin.initialize(initializationSettings);
    } catch (e, s) {
      LogHelper.shared.debugPrint('$e\n$s');
    }
  }

  void cancelNotificationWithId(int id) async {
    await _notificationPlugin.cancel(id);
  }

  Future<void> scheduleReminderNotification(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
    ReminderModel reminder,
  ) async {
    // Android-specific details
    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'HabitRise_Reminder_Channel',
      'HabitRise Reminder',
      channelDescription: 'Channel for habit reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
      color: Colors.deepOrangeAccent.shade400,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(),
    );

    // If no days are selected, schedule a one-time notification
    if (reminder.days == null || reminder.days!.isEmpty) {
      await _notificationPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        // androidAllowWhileIdle: true,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
      );
      return;
    }

    // Schedule notifications for each selected day
    for (final day in reminder.days!) {
      final scheduleDate = _nextInstanceOfDay(scheduledTime, day);

      await _notificationPlugin.zonedSchedule(
        // Create unique ID for each day by combining reminder ID and day index
        id + day.index,
        title,
        body,
        scheduleDate,
        notificationDetails,
        // androidAllowWhileIdle: true,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  /// Returns the next instance of the given day at the specified time
  tz.TZDateTime _nextInstanceOfDay(DateTime scheduledTime, Days day) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDateTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    // Convert Days enum to DateTime weekday (DateTime uses 1-7 where 1 is Monday)
    final weekday = day.index + 1;

    while (scheduledDateTime.weekday != weekday || scheduledDateTime.isBefore(now)) {
      scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
    }

    return scheduledDateTime;
  }

  /// Cancels all notifications for a given reminder
  Future<void> cancelReminderNotifications(ReminderModel reminder) async {
    // Önce temel reminder ID'si ile bildirimi iptal et
    cancelNotificationWithId(reminder.id);

    // Tüm olası günler için bildirimleri iptal et
    for (final day in Days.values) {
      cancelNotificationWithId(reminder.id + day.index);
    }
  }

  Future<void> listScheduledNotifications() async {
    final List<PendingNotificationRequest> pendingNotifications = await _notificationPlugin.pendingNotificationRequests();

    int index = 0;
    for (var notification in pendingNotifications) {
      print("${index++}" ".Notifitication");
      print('Notification ID: ${notification.id}');
      print('Notification Title: ${notification.title}');
      print('Notification Body: ${notification.body}');
      print('Payload: ${notification.payload}');
      print("--------------------------------------------------");
    }
  }


}
