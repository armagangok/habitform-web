import 'dart:convert';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
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
        await androidPlugin.createNotificationChannel(_channel!);
      }

      // Initialize the plugin
      const android = AndroidInitializationSettings("ic_launcher");
      const iOS = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        defaultPresentBadge: false,
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
        LogHelper.shared.debugPrint(' Notification channel not initialized');
        return;
      }

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        _channel!.id,
        _channel!.name,
        channelDescription: _channel!.description,
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        icon: 'ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('ic_launcher'),
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
          badgeNumber: 0,
        ),
      );

      // Format time string
      final timeString = "${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}";

      // If no days are selected, schedule a one-time notification
      if (reminder.days == null || reminder.days!.isEmpty) {
        final scheduledDateTime = tz.TZDateTime.from(scheduledTime, tz.local);
        final notificationBody = LocaleKeys.habit_timeToCompleteYourHabit.tr();

        final Map<String, dynamic> payloadData = {
          'time': timeString,
          'days': [],
        };

        LogHelper.shared.debugPrint('Scheduling one-time notification for: $scheduledDateTime');
        LogHelper.shared.debugPrint('Payload: ${jsonEncode(payloadData)}');

        await _notificationPlugin.zonedSchedule(
          id,
          title,
          notificationBody,
          scheduledDateTime,
          notificationDetails,
          payload: jsonEncode(payloadData),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
        );
        return;
      }

      // Schedule notifications for each selected day
      for (final day in reminder.days!) {
        final scheduleDate = _nextInstanceOfDay(scheduledTime, day);

        final Map<String, dynamic> payloadData = {
          'time': timeString,
          'days': reminder.days!.map((d) => d.name).toList(),
        };

        LogHelper.shared.debugPrint('Scheduling notification for day ${day.name} at: $scheduleDate');
        LogHelper.shared.debugPrint('Payload: ${jsonEncode(payloadData)}');

        // Generate unique notification ID for multiple reminders
        final timeIndex = reminder.hasMultipleReminders ? reminder.multipleReminders!.sortedReminderTimes.indexOf(scheduledTime) : 0;
        final notificationId = id + (day.index * 100) + timeIndex;
        await _notificationPlugin.zonedSchedule(
          notificationId,
          title,
          body,
          scheduleDate,
          notificationDetails,
          payload: jsonEncode(payloadData),
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
      LogHelper.shared.debugPrint('=== STARTING NOTIFICATION CANCELLATION ===');
      LogHelper.shared.debugPrint('Reminder ID: ${reminder.id}');
      LogHelper.shared.debugPrint('Reminder days: ${reminder.days}');
      LogHelper.shared.debugPrint('Has multiple reminders: ${reminder.hasMultipleReminders}');

      // List pending notifications before cancellation
      final beforeNotifications = await _notificationPlugin.pendingNotificationRequests();
      LogHelper.shared.debugPrint('Pending notifications before cancellation: ${beforeNotifications.length}');

      // Cancel the base reminder notification (handles one-time notifications)
      await _notificationPlugin.cancel(reminder.id);
      LogHelper.shared.debugPrint('Cancelled base notification with ID: ${reminder.id}');

      // Only cancel notifications for days that were actually selected for this reminder
      if (reminder.days != null && reminder.days!.isNotEmpty) {
        if (reminder.hasMultipleReminders) {
          // Cancel notifications for multiple reminders
          final times = reminder.multipleReminders!.sortedReminderTimes;
          LogHelper.shared.debugPrint('Cancelling multiple reminders for ${times.length} times');
          for (final day in reminder.days!) {
            for (int timeIndex = 0; timeIndex < times.length; timeIndex++) {
              final notificationId = reminder.id + (day.index * 100) + timeIndex;
              await _notificationPlugin.cancel(notificationId);
              LogHelper.shared.debugPrint('Cancelled notification for day ${day.name} time $timeIndex with ID: $notificationId');
            }
          }
        } else {
          // Cancel notifications for single reminder (backward compatibility)
          LogHelper.shared.debugPrint('Cancelling single reminder for ${reminder.days!.length} days');
          for (final day in reminder.days!) {
            // Try both ID formats to ensure we catch all possible notification IDs

            // New format (matching scheduling logic): id + (day.index * 100) + timeIndex
            final newFormatId = reminder.id + (day.index * 100) + 0;
            await _notificationPlugin.cancel(newFormatId);
            LogHelper.shared.debugPrint('Cancelled notification (new format) for day ${day.name} with ID: $newFormatId');

            // Old format (legacy): id + day.index
            final oldFormatId = reminder.id + day.index;
            await _notificationPlugin.cancel(oldFormatId);
            LogHelper.shared.debugPrint('Cancelled notification (old format) for day ${day.name} with ID: $oldFormatId');
          }
        }
      } else {
        LogHelper.shared.debugPrint('No days selected for reminder ${reminder.id}, only base notification cancelled (one-time notification)');
      }

      // List pending notifications after cancellation
      final afterNotifications = await _notificationPlugin.pendingNotificationRequests();
      LogHelper.shared.debugPrint('Pending notifications after cancellation: ${afterNotifications.length}');
      LogHelper.shared.debugPrint('Notifications cancelled: ${beforeNotifications.length - afterNotifications.length}');

      LogHelper.shared.debugPrint('=== NOTIFICATION CANCELLATION COMPLETED ===');
    } catch (e) {
      LogHelper.shared.debugPrint('Error cancelling notifications: $e');
    }
  }

  /// Cancels a single notification by its ID
  Future<void> cancelNotification(int notificationId) async {
    try {
      await _notificationPlugin.cancel(notificationId);
      LogHelper.shared.debugPrint('Cancelled notification with ID: $notificationId');
    } catch (e) {
      LogHelper.shared.debugPrint('Error cancelling notification $notificationId: $e');
    }
  }

  /// Debug method to analyze notification IDs for a specific habit
  Future<void> debugNotificationIdsForHabit(String habitName, int reminderId, List<Days>? days) async {
    try {
      LogHelper.shared.debugPrint('=== DEBUG: Analyzing notification IDs for habit "$habitName" ===');
      LogHelper.shared.debugPrint('Reminder ID: $reminderId');
      LogHelper.shared.debugPrint('Days: $days');

      final pendingNotifications = await _notificationPlugin.pendingNotificationRequests();
      final habitNotifications = pendingNotifications.where((n) => n.title == habitName).toList();

      LogHelper.shared.debugPrint('Found ${habitNotifications.length} notifications for habit "$habitName"');

      for (var notification in habitNotifications) {
        LogHelper.shared.debugPrint('Notification ID: ${notification.id}, Title: ${notification.title}');
      }

      if (days != null && days.isNotEmpty) {
        LogHelper.shared.debugPrint('Expected notification IDs for this habit:');
        for (var day in days) {
          final newFormatId = reminderId + (day.index * 100) + 0;
          final oldFormatId = reminderId + day.index;
          LogHelper.shared.debugPrint('Day ${day.name}: new format = $newFormatId, old format = $oldFormatId');
        }
      }

      LogHelper.shared.debugPrint('=== DEBUG COMPLETED ===');
    } catch (e) {
      LogHelper.shared.debugPrint('Error in debug analysis: $e');
    }
  }

  Future<List<PendingNotificationRequest>> listScheduledNotifications() async {
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

      return pendingNotifications;
    } catch (e) {
      LogHelper.shared.debugPrint('Error listing notifications: $e');
      return [];
    }
  }

  Future<PermissionStatus> requestNotificationPermission() async {
    if (Platform.isIOS) {
      final iosPlugin = _notificationPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      final permissionStatus = await Permission.notification.status;

      if (permissionStatus.isDenied) {
        // Request permission for iOS
        final result = await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return result == true ? PermissionStatus.granted : PermissionStatus.denied;
      }

      return permissionStatus;
    }

    // Android logic
    final status = await Permission.notification.status;
    if (status.isDenied) {
      return await Permission.notification.request();
    }

    return status;
  }
}
