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
  AndroidNotificationChannel? _channel;

  bool? isInitializationSucceded;

  /// Call this method in the `main` method to initialize the notification plugin.
  Future<void> get initializeNotificationPlugin async {
    try {
      // Create the notification channel first
      _channel = const AndroidNotificationChannel(
        'HabitRise_Habit_Reminder', // Channel ID
        'Habit Reminder', // Channel Name
        description: 'Channel for habit reminder notifications',
        importance: Importance.high,
        enableVibration: true,
        showBadge: true,
      );

      // Create the Android-specific notification channel
      final androidPlugin = _notificationPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        // await androidPlugin.requestNotificationsPermission();
        await androidPlugin.createNotificationChannel(_channel!);
      }

      // Initialize the plugin
      const android = AndroidInitializationSettings("ic_launcher");
      const iOS = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      
      const initializationSettings = InitializationSettings(android: android, iOS: iOS);

      isInitializationSucceded = await _notificationPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          LogHelper.shared.debugPrint('Notification clicked: ${response.payload}');
        },
      );

      LogHelper.shared.debugPrint('Notification plugin initialized: $isInitializationSucceded');
    } catch (e, s) {
      LogHelper.shared.debugPrint('Error initializing notifications: $e');
      LogHelper.shared.debugPrint('Stack trace: $s');
      isInitializationSucceded = false;
    }
  }

  Future<void> scheduleReminderNotification(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
    ReminderModel reminder,
  ) async {
    try {
      if (_channel == null) {
        LogHelper.shared.debugPrint('Notification channel not initialized');
        return;
      }

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        _channel!.id,
        _channel!.name,
        channelDescription: _channel!.description,
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        color: Colors.orange.shade600,
        icon: 'ic_launcher',
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      // If no days are selected, schedule a one-time notification
      if (reminder.days == null || reminder.days!.isEmpty) {
        final scheduledDateTime = tz.TZDateTime.from(scheduledTime, tz.local);
        LogHelper.shared.debugPrint('Scheduling one-time notification for: $scheduledDateTime');

        await _notificationPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDateTime,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
        );
        return;
      }

      // Schedule notifications for each selected day
      for (final day in reminder.days!) {
        final scheduleDate = _nextInstanceOfDay(scheduledTime, day);
        LogHelper.shared.debugPrint('Scheduling notification for day ${day.name} at: $scheduleDate');

        final notificationId = id + day.index;
        await _notificationPlugin.zonedSchedule(
          notificationId,
          title,
          body,
          scheduleDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
        LogHelper.shared.debugPrint('Successfully scheduled notification with ID: $notificationId');
      }
    } catch (e, s) {
      LogHelper.shared.debugPrint('Error scheduling notification: $e');
      LogHelper.shared.debugPrint('Stack trace: $s');
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
    try {
      // Cancel the base reminder notification
      await _notificationPlugin.cancel(reminder.id);
      LogHelper.shared.debugPrint('Cancelled base notification with ID: ${reminder.id}');

      // Cancel notifications for all possible days
      for (final day in Days.values) {
        final notificationId = reminder.id + day.index;
        await _notificationPlugin.cancel(notificationId);
        LogHelper.shared.debugPrint('Cancelled notification for day ${day.name} with ID: $notificationId');
      }
    } catch (e) {
      LogHelper.shared.debugPrint('Error cancelling notifications: $e');
    }
  }

  Future<void> listScheduledNotifications() async {
    try {
      final List<PendingNotificationRequest> pendingNotifications = await _notificationPlugin.pendingNotificationRequests();

      LogHelper.shared.debugPrint('Total pending notifications: ${pendingNotifications.length}');

      for (var notification in pendingNotifications) {
        LogHelper.shared.debugPrint('Notification ID: ${notification.id}');
        LogHelper.shared.debugPrint('Title: ${notification.title}');
        LogHelper.shared.debugPrint('Body: ${notification.body}');
        LogHelper.shared.debugPrint('Payload: ${notification.payload}');
        LogHelper.shared.debugPrint('---');
      }
    } catch (e) {
      LogHelper.shared.debugPrint('Error listing notifications: $e');
    }
  }
}
