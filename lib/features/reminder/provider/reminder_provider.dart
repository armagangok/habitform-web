import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../models/days/days_enum.dart';
import '../models/multiple_reminder/multiple_reminder_model.dart';
import '../models/reminder/reminder_model.dart';
import '../service/reminder_service.dart';
import 'remind_time_provider.dart';
import 'reminder_state.dart';

// Provider for reminder state management
final reminderProvider = AutoDisposeNotifierProvider<ReminderNotifier, ReminderState>(() {
  return ReminderNotifier();
});

class ReminderNotifier extends AutoDisposeNotifier<ReminderState> {
  @override
  ReminderState build() {
    return const ReminderState();
  }

  // Initialize reminder data
  void initializeReminder(ReminderModel? initialReminder) {
    if (initialReminder != null) {
      state = ReminderState(reminder: initialReminder);

      final reminderTime = initialReminder.reminderTime;

      if (reminderTime != null) {
        ref.watch(remindTimeProvider.notifier).setTime(reminderTime);
      }
    } else {
      final reminderModelToInitialize = ReminderModel(
        id: UuidHelper.uidInt,
        days: [],
        reminderTime: null,
      );
      state = ReminderState(reminder: reminderModelToInitialize);
    }
  }

  // İki hatırlatıcı modelinin farklı olup olmadığını kontrol et
  bool isReminderChanged(ReminderModel? oldReminder, ReminderModel? newReminder) {
    // Direkt state'i kullan, geçici state oluşturmaya gerek yok
    return state != ReminderState(reminder: oldReminder);
  }

  // Cancel existing notifications and schedule new reminder
  Future<void> scheduleReminder({
    required String title,
    required String body,
    ReminderModel? oldReminder,
  }) async {
    try {
      // Önce mevcut state'i kontrol et
      if (oldReminder != null && !isReminderChanged(oldReminder, state.reminder)) {
        LogHelper.shared.debugPrint('Reminder has not changed, skipping schedule');
        return;
      }

      state = state.copyWith(isLoading: true, errorMessage: null);
      final reminder = state.reminder;

      if (reminder == null) {
        LogHelper.shared.debugPrint('Reminder is null, cannot schedule');
        state = state.copyWith(isLoading: false);
        return;
      }

      final days = reminder.days;
      final reminderTime = reminder.reminderTime;

      LogHelper.shared.debugPrint('Scheduling reminder: $reminder');
      LogHelper.shared.debugPrint('Days: $days, Time: $reminderTime');

      // Cancel existing notifications first
      await ReminderService.cancelReminderNotification(reminder.id);
      LogHelper.shared.debugPrint('Cancelled existing notifications for ID: ${reminder.id}');

      // Create new notification if days and time are selected
      if (days != null && days.isNotEmpty && reminderTime != null) {
        LogHelper.shared.debugPrint('Creating new notification with days: $days and time: $reminderTime');
        await ReminderService.createReminderNotification(
          reminder,
          title,
          body,
        );
        LogHelper.shared.debugPrint('Notification scheduled successfully');
      } else {
        LogHelper.shared.debugPrint('Skipping notification creation: days or time is missing');
        if (days == null || days.isEmpty) {
          LogHelper.shared.debugPrint('Days are empty or null');
        }
        if (reminderTime == null) {
          LogHelper.shared.debugPrint('Reminder time is null');
        }
      }

      state = state.copyWith(isLoading: false);
    } catch (e, s) {
      LogHelper.shared.debugPrint('Error scheduling reminder: $e');
      LogHelper.shared.debugPrint('Stack trace: $s');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to schedule reminder: $e',
      );
      AppFlushbar.shared.errorFlushbar('Failed to schedule reminder');
    }
  }

  // Cancel reminder
  Future<void> cancelReminder() async {
    try {
      final reminder = state.reminder;
      if (reminder == null) return;

      state = state.copyWith(isLoading: true, errorMessage: null);
      await ReminderService.cancelReminderNotification(reminder.id);

      // Keep ID but reset other values
      final updatedReminder = reminder.copyWith(days: [], time: null);
      state = state.copyWith(
        reminder: updatedReminder,
        isLoading: false,
      );
      AppFlushbar.shared.successFlushbar("Reminder cancelled successfuly");
    } catch (e) {
      LogHelper.shared.debugPrint('$e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to cancel reminder',
      );
    }
  }

  // Update reminder days
  void updateDays(List<Days>? days) {
    final currentReminder = state.reminder;
    if (currentReminder == null) return;

    if (days == null || days.isEmpty) {
      // Reset time as well but keep ID
      state = state.copyWith(
        reminder: currentReminder.copyWith(
          days: [],
          time: null,
        ),
      );
      return;
    }

    // If days are selected for the first time and time is null, set default time to 12:00
    final DateTime reminderTime = currentReminder.reminderTime ?? DateTime.now().copyWith(hour: 12, minute: 0, second: 0);

    state = state.copyWith(
      reminder: currentReminder.copyWith(
        days: days,
        time: reminderTime,
      ),
    );
  }

  // Update reminder time
  void updateTime(DateTime? time) {
    final currentReminder = state.reminder;
    if (currentReminder == null) return;

    if (time == null) {
      // Reset days as well but keep ID
      state = state.copyWith(
        reminder: currentReminder.copyWith(
          days: [],
          time: null,
        ),
      );
      return;
    }

    state = state.copyWith(
      reminder: currentReminder.copyWith(
        days: currentReminder.days,
        time: time,
      ),
    );
  }

  // Set reminder mode (single or multiple)
  void setReminderMode(bool isMultiple) {
    final currentReminder = state.reminder;
    if (currentReminder == null) return;

    if (isMultiple) {
      // Switch to multiple reminders mode
      final currentTime = currentReminder.reminderTime;
      final multipleReminders = MultipleReminderModel(
        id: UuidHelper.uidInt,
        reminderTimes: currentTime != null ? [currentTime] : [],
        days: currentReminder.days,
      );

      state = state.copyWith(
        reminder: currentReminder.copyWith(
          multipleReminders: multipleReminders,
          time: null, // Clear single time when switching to multiple
        ),
      );
    } else {
      // Switch to single reminder mode
      final firstTime = currentReminder.multipleReminders?.reminderTimes.isNotEmpty == true ? currentReminder.multipleReminders!.reminderTimes.first : null;

      state = state.copyWith(
        reminder: currentReminder.copyWith(
          time: firstTime,
          multipleReminders: null, // Clear multiple reminders when switching to single
        ),
      );
    }
  }

  // Update multiple reminders
  void updateMultipleReminders(MultipleReminderModel? multipleReminders) {
    final currentReminder = state.reminder;
    if (currentReminder == null) return;

    state = state.copyWith(
      reminder: currentReminder.copyWith(
        multipleReminders: multipleReminders,
      ),
    );
  }

  // Clear multiple reminders
  void clearMultipleReminders() {
    final currentReminder = state.reminder;
    if (currentReminder == null) return;

    state = state.copyWith(
      reminder: currentReminder.copyWith(
        multipleReminders: null,
      ),
    );
  }
}
