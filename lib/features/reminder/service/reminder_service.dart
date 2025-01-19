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
    if (reminder.reminderTime != null) {
      await NotificationHelper.shared.cancelReminderNotifications(reminder);

      await NotificationHelper.shared.scheduleReminderNotification(
        reminder.id,
        title,
        body,
        reminder.reminderTime!,
        reminder,
      );
    }
  }

  static Future<void> cancelReminderNotification(int id) async {
    // Tüm günlerin bildirimlerini iptal et
    final dummyReminder = ReminderModel(id: id, days: [], reminderTime: null);
    await NotificationHelper.shared.cancelReminderNotifications(dummyReminder);
  }

  
}
