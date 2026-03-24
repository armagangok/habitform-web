import 'dart:io';

import '/features/reminder/models/days/days_enum.dart';
import '/features/reminder/models/reminder/reminder_model.dart';
import 'smart_notification_manager.dart';

/// Utility class for notification management and user feedback
class NotificationUtils {
  NotificationUtils._();
  static final shared = NotificationUtils._();

  /// Calculate the total number of notifications that would be created for a list of reminders
  int calculateTotalNotifications(List<ReminderModel> reminders) {
    int total = 0;

    for (final reminder in reminders) {
      if (!reminder.hasAnyReminders) continue;

      final times = reminder.allReminderTimes;
      final days = reminder.days ?? Days.values;

      total += times.length * days.length;
    }

    return total;
  }

  /// Check if the notification count would exceed platform limits
  bool wouldExceedLimit(List<ReminderModel> reminders) {
    final total = calculateTotalNotifications(reminders);
    final platformLimit = Platform.isIOS ? SmartNotificationManager.maxNotifications : SmartNotificationManager.androidMaxNotifications;
    return total > platformLimit;
  }

  /// Get a user-friendly message about notification limits
  String getNotificationLimitMessage(List<ReminderModel> reminders) {
    final total = calculateTotalNotifications(reminders);
    final platformLimit = Platform.isIOS ? SmartNotificationManager.maxNotifications : SmartNotificationManager.androidMaxNotifications;
    final platformName = Platform.isIOS ? 'iOS' : 'Android';

    if (total <= platformLimit) {
      return 'All $total notifications will be scheduled successfully.';
    } else {
      final excess = total - platformLimit;
      return 'You have $total notifications but $platformName limits apps to $platformLimit notifications. '
          'The $excess least important notifications will be automatically managed.';
    }
  }

  /// Get notification usage statistics
  NotificationUsageStats getNotificationUsageStats(List<ReminderModel> reminders) {
    final total = calculateTotalNotifications(reminders);
    final platformLimit = Platform.isIOS ? SmartNotificationManager.maxNotifications : SmartNotificationManager.androidMaxNotifications;
    final percentage = (total / platformLimit * 100).round();

    return NotificationUsageStats(
      totalNotifications: total,
      limit: platformLimit,
      percentage: percentage,
      wouldExceedLimit: total > platformLimit,
      excessCount: total > platformLimit ? total - platformLimit : 0,
    );
  }

  /// Suggest optimization strategies for users approaching the limit
  List<String> getOptimizationSuggestions(List<ReminderModel> reminders) {
    final stats = getNotificationUsageStats(reminders);
    final suggestions = <String>[];

    if (stats.percentage > 80) {
      suggestions.add('Consider reducing the number of reminder times per habit');
    }

    if (stats.percentage > 90) {
      suggestions.add('Focus on your most important habits and reduce less critical reminders');
    }

    if (stats.percentage > 95) {
      suggestions.add('Consider using fewer days per week for some habits');
    }

    if (stats.wouldExceedLimit) {
      suggestions.add('The app will automatically prioritize your most important reminders');
    }

    return suggestions;
  }

  /// Get habits that contribute most to notification count
  List<HabitNotificationInfo> getHabitNotificationBreakdown(List<ReminderModel> reminders) {
    final breakdown = <HabitNotificationInfo>[];

    for (final reminder in reminders) {
      if (!reminder.hasAnyReminders) continue;

      final times = reminder.allReminderTimes;
      final days = reminder.days ?? Days.values;
      final notificationCount = times.length * days.length;

      breakdown.add(
        HabitNotificationInfo(
          reminderId: reminder.id,
          notificationCount: notificationCount,
          timesPerDay: times.length,
          daysPerWeek: days.length,
          priority: _calculateHabitPriority(reminder),
        ),
      );
    }

    // Sort by notification count (highest first)
    breakdown.sort((a, b) => b.notificationCount.compareTo(a.notificationCount));

    return breakdown;
  }

  /// Calculate priority for a habit based on various factors
  int _calculateHabitPriority(ReminderModel reminder) {
    int priority = 0;

    // Base priority
    priority += 100;

    // Higher priority for habits with more specific times (shows more commitment)
    final times = reminder.allReminderTimes;
    if (times.length > 1) {
      priority += 20;
    }

    // Higher priority for habits with more days
    final days = reminder.days ?? Days.values;
    if (days.length >= 5) {
      priority += 30;
    } else if (days.length >= 3) {
      priority += 20;
    }

    // Higher priority for morning habits (6 AM - 12 PM)
    final hasMorningHabits = times.any((time) => time.hour >= 6 && time.hour < 12);
    if (hasMorningHabits) {
      priority += 15;
    }

    return priority;
  }
}

/// Data class for notification usage statistics
class NotificationUsageStats {
  final int totalNotifications;
  final int limit;
  final int percentage;
  final bool wouldExceedLimit;
  final int excessCount;

  NotificationUsageStats({
    required this.totalNotifications,
    required this.limit,
    required this.percentage,
    required this.wouldExceedLimit,
    required this.excessCount,
  });
}

/// Data class for habit notification breakdown
class HabitNotificationInfo {
  final int reminderId;
  final int notificationCount;
  final int timesPerDay;
  final int daysPerWeek;
  final int priority;

  HabitNotificationInfo({
    required this.reminderId,
    required this.notificationCount,
    required this.timesPerDay,
    required this.daysPerWeek,
    required this.priority,
  });
}
