import '/features/reminder/models/reminder/reminder_model.dart';

/// Web build: local OS notification scheduling is disabled. Constants remain for shared helpers.
class SmartNotificationManager {
  SmartNotificationManager._();
  static final shared = SmartNotificationManager._();

  static const int maxNotifications = 64;
  static const int androidMaxNotifications = 200;
  static const int bufferNotifications = 10;

  Future<void> scheduleSmartNotifications(
    List<ReminderModel> reminders,
    String title,
    String body,
  ) async {}

  Future<void> rescheduleNotifications(
    List<ReminderModel> reminders,
    String title,
    String body,
  ) async {}

  Future<int> getCurrentNotificationCount() async => 0;

  Future<bool> isApproachingLimit() async => false;
}
