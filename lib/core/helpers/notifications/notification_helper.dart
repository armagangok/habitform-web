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
        'reminder_channel_id', // Channel ID
        'Reminders', // Channel Name
        description: 'Channel for reminder notifications',
        importance: Importance.high,
      );

      await _notificationPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

      isInitializationSucceded = await _notificationPlugin.initialize(initializationSettings);
    } catch (e, s) {
      LogHelper.shared.debugPrint('$e\n$s');
    }
  }

  Future<void> showTimerCompletedNotification({
    required String title,
    required String message,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      "Time End Channel",
      "Timer Completed Notification",
      priority: Priority.max,
      color: Colors.orange.shade600,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    const darwinNotificationDetails = DarwinNotificationDetails(
      interruptionLevel: InterruptionLevel.critical,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinNotificationDetails,
      macOS: darwinNotificationDetails,
    );

    try {
      if (isInitializationSucceded != null && isInitializationSucceded == true) {
        await _notificationPlugin.show(
          12,
          title,
          message,
          notificationDetails,
        );
      } else {
        LogHelper.shared.debugPrint('isInitializationSucceded $isInitializationSucceded  is false');
      }
    } catch (e, s) {
      LogHelper.shared.debugPrint('$e\n$s}');
    }
  }

  // void showTimeUpdateNotification(String counter, String taskName) async {
  //   if (Platform.isAndroid) {
  //     final androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //       'Remaining Time Chanel',
  //       'Remaining Time Notification',
  //       importance: Importance.max,
  //       priority: Priority.high,
  //       enableVibration: false,
  //       silent: true,
  //       color: Colors.orange.shade600,
  //       playSound: false,
  //       autoCancel: true,
  //     );

  //     final platformChannelSpecifics = NotificationDetails(
  //       android: androidPlatformChannelSpecifics,
  //       iOS: DarwinNotificationDetails(
  //         presentSound: false,
  //       ),
  //     );

  //     await _notificationPlugin.show(
  //       0,
  //       taskName,
  //       '${LocaleKeys.remainingTime.tr()}: $counter',
  //       platformChannelSpecifics,
  //     );
  //   }
  // }

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
      'reminder_channel_id',
      'Reminders',
      channelDescription: 'Channel for reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
      color: Colors.orange.shade600,
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
  Future<void> cancelReminderNotifications(ReminderModel? reminder) async {
    if (reminder != null) {
      if (reminder.days == null || reminder.days!.isEmpty) {
        cancelNotificationWithId(reminder.id);
        return;
      }

      // Cancel notifications for each day
      for (final day in reminder.days!) {
        cancelNotificationWithId(reminder.id + day.index);
      }
    }
  }
}
