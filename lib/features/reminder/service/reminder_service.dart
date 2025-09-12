import '/core/helpers/notifications/notification_helper.dart';
import '../models/reminder/reminder_model.dart';

interface class IReminderService {}

final class ReminderService {
  const ReminderService._();

  static Future<void> createReminderNotification(
    ReminderModel reminder,
    String title,
    String body,
  ) async {
    await NotificationHelper.shared.cancelReminderNotifications(reminder);

    if (reminder.hasMultipleReminders) {
      // Schedule multiple notifications for each time
      for (final time in reminder.multipleReminders!.sortedReminderTimes) {
        await NotificationHelper.shared.scheduleReminderNotification(
          reminder.id,
          title,
          body,
          time,
          reminder,
        );
      }
    } else if (reminder.hasSingleReminder) {
      // Schedule single notification
      await NotificationHelper.shared.scheduleReminderNotification(
        reminder.id,
        title,
        body,
        reminder.reminderTime!,
        reminder,
      );
    }
  }

  static Future<void> cancelReminderNotification(int? id) async {
    if (id == null) return;

    // Tüm günlerin bildirimlerini iptal et
    final dummyReminder = ReminderModel(id: id, days: [], reminderTime: null);
    await NotificationHelper.shared.cancelReminderNotifications(dummyReminder);
  }
}
