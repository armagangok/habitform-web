import 'package:habitrise/core/core.dart';

import '/core/helpers/notifications/smart_notification_manager.dart';
import '/features/reminder/models/reminder/reminder_model.dart';
import '/services/habit_service/habit_service_interface.dart';

/// Uygulama yaşam döngüsü servis sınıfı.
/// Bu sınıf, uygulama yaşam döngüsü olaylarını dinler ve gerekli işlemleri tetikler.
class AppLifecycleService with WidgetsBindingObserver {
  bool _initialized = false;
  final SmartNotificationManager _notificationManager = SmartNotificationManager.shared;

  AppLifecycleService();

  /// Servisi başlatır ve yaşam döngüsü olaylarını dinlemeye başlar
  void initialize() {
    if (_initialized) return;

    WidgetsBinding.instance.addObserver(this);
    LogHelper.shared.debugPrint('AppLifecycleService initialized');
    _initialized = true;
  }

  /// Servisi durdurur ve yaşam döngüsü olaylarını dinlemeyi bırakır
  void dispose() {
    if (!_initialized) return;

    WidgetsBinding.instance.removeObserver(this);
    LogHelper.shared.debugPrint('AppLifecycleService disposed');
    _initialized = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    LogHelper.shared.debugPrint('App lifecycle state changed to: $state');

    // Uygulama arka plana geçtiğinde veya tamamen kapandığında senkronizasyon yap
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      LogHelper.shared.debugPrint('App is closing or going to background, triggering auto sync');
    } else if (state == AppLifecycleState.resumed) {
      LogHelper.shared.debugPrint('App is resuming from background, triggering auto sync');
      _handleAppResumed();
    }
  }

  /// Handle app resumed - reschedule notifications if needed
  Future<void> _handleAppResumed() async {
    try {
      // Check if we need to reschedule notifications
      final isApproachingLimit = await _notificationManager.isApproachingLimit();
      final currentCount = await _notificationManager.getCurrentNotificationCount();

      LogHelper.shared.debugPrint('Current notification count: $currentCount');
      LogHelper.shared.debugPrint('Approaching limit: $isApproachingLimit');

      // If we're approaching the limit or have very few notifications,
      // reschedule to ensure we have the most relevant upcoming notifications
      if (isApproachingLimit || currentCount < 20) {
        await _rescheduleNotifications();
      }
    } catch (e) {
      LogHelper.shared.debugPrint('Error handling app resumed: $e');
    }
  }

  /// Reschedule notifications based on current habits
  Future<void> _rescheduleNotifications() async {
    try {
      // Get all active reminders from the reminder provider
      // Note: This would need to be adapted based on your actual data access pattern
      final reminders = await _getAllActiveReminders();

      if (reminders.isNotEmpty) {
        await _notificationManager.rescheduleNotifications(
          reminders,
          'Habit Reminder',
          'Time to complete your habit!',
        );
        LogHelper.shared.debugPrint('Rescheduled notifications for ${reminders.length} reminders');
      }
    } catch (e) {
      LogHelper.shared.debugPrint('Error rescheduling notifications: $e');
    }
  }

  /// Get all active reminders from active habits
  Future<List<ReminderModel>> _getAllActiveReminders() async {
    try {
      // Get all active habits
      final activeHabits = await habitService.getHabits();

      // Extract reminder models from habits that have reminders
      final reminders = <ReminderModel>[];
      for (final habit in activeHabits) {
        if (habit.reminderModel != null && habit.reminderModel!.hasAnyReminders) {
          reminders.add(habit.reminderModel!);
        }
      }

      LogHelper.shared.debugPrint('Found ${reminders.length} active reminders from ${activeHabits.length} habits');
      return reminders;
    } catch (e) {
      LogHelper.shared.debugPrint('Error getting active reminders: $e');
      return [];
    }
  }

  /// Manually trigger notification rescheduling
  Future<void> rescheduleNotificationsNow() async {
    await _rescheduleNotifications();
  }
}
