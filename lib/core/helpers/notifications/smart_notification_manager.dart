import 'dart:convert';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '/features/reminder/models/days/days_enum.dart';
import '/features/reminder/models/reminder/reminder_model.dart';
import '../../core.dart';

/// Smart notification manager that handles iOS 64-notification limit
/// by implementing dynamic scheduling and priority-based management
class SmartNotificationManager {
  SmartNotificationManager._();
  static final shared = SmartNotificationManager._();

  final _notificationPlugin = FlutterLocalNotificationsPlugin();
  static const int maxNotifications = 64; // iOS limit
  static const int androidMaxNotifications = 200; // Android recommended limit
  static const int bufferNotifications = 10; // Keep some buffer for new notifications

  /// Schedule notifications intelligently within iOS limits
  Future<void> scheduleSmartNotifications(
    List<ReminderModel> reminders,
    String title,
    String body,
  ) async {
    try {
      // Get all upcoming notification times
      final upcomingNotifications = _getUpcomingNotifications(reminders, title, body);

      // Sort by priority and time
      upcomingNotifications.sort((a, b) {
        // First by priority (higher priority first)
        if (a.priority != b.priority) {
          return b.priority.compareTo(a.priority);
        }
        // Then by time (earlier first)
        return a.scheduledTime.compareTo(b.scheduledTime);
      });

      // Take only the most important and upcoming notifications
      final platformLimit = Platform.isIOS ? maxNotifications : androidMaxNotifications;
      final notificationsToSchedule = upcomingNotifications.take(platformLimit - bufferNotifications).toList();

      LogHelper.shared.debugPrint('Scheduling ${notificationsToSchedule.length} notifications out of ${upcomingNotifications.length} possible');

      // Cancel all existing notifications first
      await _cancelAllNotifications();

      // Schedule the selected notifications
      for (final notification in notificationsToSchedule) {
        await _scheduleSingleNotification(notification);
      }

      // Store metadata for rescheduling
      await _storeNotificationMetadata(notificationsToSchedule);
    } catch (e, s) {
      LogHelper.shared.debugPrint('Error in smart notification scheduling: $e');
      LogHelper.shared.debugPrint('Stack trace: $s');
    }
  }

  /// Get all upcoming notifications from reminders
  List<UpcomingNotification> _getUpcomingNotifications(
    List<ReminderModel> reminders,
    String title,
    String body,
  ) {
    final List<UpcomingNotification> notifications = [];
    final now = tz.TZDateTime.now(tz.local);

    for (final reminder in reminders) {
      if (!reminder.hasAnyReminders) continue;

      final times = reminder.allReminderTimes;
      final days = reminder.days ?? Days.values;

      for (final time in times) {
        for (final day in days) {
          final scheduledTime = _getNextInstanceOfDay(time, day);

          // Only include future notifications
          if (scheduledTime.isAfter(now)) {
            final priority = _calculatePriority(reminder, time, day);

            notifications.add(UpcomingNotification(
              id: _generateNotificationId(reminder.id, day, time),
              reminderId: reminder.id,
              title: title,
              body: body,
              scheduledTime: scheduledTime,
              day: day,
              time: time,
              priority: priority,
            ));
          }
        }
      }
    }

    return notifications;
  }

  /// Calculate priority for a notification based on various factors
  int _calculatePriority(ReminderModel reminder, DateTime time, Days day) {
    int priority = 0;

    // Base priority
    priority += 100;

    // Higher priority for today
    final now = tz.TZDateTime.now(tz.local);
    final today = now.weekday - 1; // Convert to 0-based index
    if (day.index == today) {
      priority += 50;
    }

    // Higher priority for morning habits (6 AM - 12 PM)
    if (time.hour >= 6 && time.hour < 12) {
      priority += 30;
    }

    // Higher priority for evening habits (6 PM - 10 PM)
    if (time.hour >= 18 && time.hour < 22) {
      priority += 20;
    }

    // Lower priority for very early morning (before 6 AM)
    if (time.hour < 6) {
      priority -= 20;
    }

    // Lower priority for very late night (after 10 PM)
    if (time.hour >= 22) {
      priority -= 10;
    }

    return priority;
  }

  /// Get next instance of a specific day and time
  tz.TZDateTime _getNextInstanceOfDay(DateTime scheduledTime, Days day) {
    final now = tz.TZDateTime.now(tz.local);
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

  /// Generate unique notification ID
  int _generateNotificationId(int reminderId, Days day, DateTime time) {
    return reminderId + (day.index * 100) + time.hour * 60 + time.minute;
  }

  /// Schedule a single notification
  Future<void> _scheduleSingleNotification(UpcomingNotification notification) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        'HabitRise_Smart_Reminder',
        'Smart Habit Reminder',
        channelDescription: 'Intelligent habit reminders within iOS limits',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        icon: 'ic_launcher',
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
          badgeNumber: 0,
        ),
      );

      final timeString = "${notification.time.hour.toString().padLeft(2, '0')}:${notification.time.minute.toString().padLeft(2, '0')}";

      final payloadData = {
        'reminderId': notification.reminderId,
        'time': timeString,
        'day': notification.day.name,
        'priority': notification.priority,
        'scheduledTime': notification.scheduledTime.toIso8601String(),
      };

      await _notificationPlugin.zonedSchedule(
        notification.id,
        notification.title,
        notification.body,
        notification.scheduledTime,
        notificationDetails,
        payload: jsonEncode(payloadData),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );

      LogHelper.shared.debugPrint('Scheduled notification ID: ${notification.id} for ${notification.day.name} at $timeString (Priority: ${notification.priority})');
    } catch (e) {
      LogHelper.shared.debugPrint('Error scheduling notification ${notification.id}: $e');
    }
  }

  /// Cancel all notifications
  Future<void> _cancelAllNotifications() async {
    try {
      await _notificationPlugin.cancelAll();
      LogHelper.shared.debugPrint('Cancelled all notifications');
    } catch (e) {
      LogHelper.shared.debugPrint('Error cancelling notifications: $e');
    }
  }

  /// Store notification metadata for rescheduling
  Future<void> _storeNotificationMetadata(List<UpcomingNotification> notifications) async {
    // This could be stored in SharedPreferences or Hive for persistence
    // For now, we'll just log it
    LogHelper.shared.debugPrint('Stored metadata for ${notifications.length} notifications');
  }

  /// Reschedule notifications when app becomes active
  Future<void> rescheduleNotifications(
    List<ReminderModel> reminders,
    String title,
    String body,
  ) async {
    LogHelper.shared.debugPrint('Rescheduling notifications...');
    await scheduleSmartNotifications(reminders, title, body);
  }

  /// Get current notification count
  Future<int> getCurrentNotificationCount() async {
    try {
      final pending = await _notificationPlugin.pendingNotificationRequests();
      return pending.length;
    } catch (e) {
      LogHelper.shared.debugPrint('Error getting notification count: $e');
      return 0;
    }
  }

  /// Check if we're approaching the notification limit
  Future<bool> isApproachingLimit() async {
    final count = await getCurrentNotificationCount();
    final platformLimit = Platform.isIOS ? maxNotifications : androidMaxNotifications;
    return count >= (platformLimit - bufferNotifications);
  }
}

/// Data class for upcoming notifications
class UpcomingNotification {
  final int id;
  final int reminderId;
  final String title;
  final String body;
  final tz.TZDateTime scheduledTime;
  final Days day;
  final DateTime time;
  final int priority;

  UpcomingNotification({
    required this.id,
    required this.reminderId,
    required this.title,
    required this.body,
    required this.scheduledTime,
    required this.day,
    required this.time,
    required this.priority,
  });
}
