import '/core/core.dart';
import '/core/helpers/notifications/notification_helper.dart';
import '/core/helpers/notifications/smart_notification_manager.dart';
import '/services/habit_service/habit_service_interface.dart';
import '../models/reminder/reminder_model.dart';

interface class IReminderService {}

final class ReminderService {
  const ReminderService._();

  /// Create reminder notification using smart scheduling
  static Future<void> createReminderNotification(
    ReminderModel reminder,
    String title,
    String body,
  ) async {
    // Get all active reminders to preserve other habits' notifications
    final allActiveReminders = await _getAllActiveReminders();

    // Use smart notification manager for better iOS limit handling
    await SmartNotificationManager.shared.scheduleSmartNotifications(
      allActiveReminders,
      title,
      body,
    );
  }

  /// Create multiple reminder notifications using smart scheduling
  static Future<void> createMultipleReminderNotifications(
    List<ReminderModel> reminders,
    String title,
    String body,
  ) async {
    // Get all active reminders to preserve other habits' notifications
    final allActiveReminders = await _getAllActiveReminders();

    // Use smart notification manager for better iOS limit handling
    await SmartNotificationManager.shared.scheduleSmartNotifications(
      allActiveReminders,
      title,
      body,
    );
  }

  /// Cancel reminder notification
  static Future<void> cancelReminderNotification(int? id) async {
    if (id == null) return;

    // Cancel using the legacy method for backward compatibility
    final dummyReminder = ReminderModel(id: id, days: [], reminderTime: null);
    await NotificationHelper.shared.cancelReminderNotifications(dummyReminder);
  }

  /// Get current notification count
  static Future<int> getCurrentNotificationCount() async {
    return await SmartNotificationManager.shared.getCurrentNotificationCount();
  }

  /// Check if approaching notification limit
  static Future<bool> isApproachingLimit() async {
    return await SmartNotificationManager.shared.isApproachingLimit();
  }

  /// Get all active reminders from all habits
  static Future<List<ReminderModel>> _getAllActiveReminders() async {
    try {
      final activeHabits = await habitService.getHabits();
      final reminders = <ReminderModel>[];

      for (final habit in activeHabits) {
        if (habit.reminderModel != null && habit.reminderModel!.hasAnyReminders) {
          reminders.add(habit.reminderModel!);
        }
      }

      return reminders;
    } catch (e) {
      LogHelper.shared.debugPrint('Error getting active reminders: $e');
      return [];
    }
  }

  /// Reschedule all notifications (useful when app becomes active)
  static Future<void> rescheduleAllNotifications(
    List<ReminderModel> reminders,
    String title,
    String body,
  ) async {
    await SmartNotificationManager.shared.rescheduleNotifications(
      reminders,
      title,
      body,
    );
  }
}
