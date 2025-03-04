import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../models/days/days_enum.dart';
import '../models/reminder/reminder_model.dart';
import '../service/reminder_service.dart';
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
    print(initialReminder);
    if (initialReminder != null) {
      state = ReminderState(reminder: initialReminder);
    } else {
      final reminderModelToInitialize = ReminderModel(
        id: UuidHelper.uidInt,
        days: [],
        reminderTime: null,
      );
      state = ReminderState(reminder: reminderModelToInitialize);
    }
  }

  // Cancel existing notifications and schedule new reminder
  void scheduleReminder({required String title, required String body}) async {
    try {
      state = state.copyWith(isLoading: true);
      final reminder = state.reminder;
      final days = reminder?.days;
      final reminderTime = reminder?.reminderTime;

      if (reminder != null) {
        // Cancel existing notifications first
        await ReminderService.cancelReminderNotification(reminder.id);

        // Create new notification if days and time are selected
        if (days != null && days.isNotEmpty && reminderTime != null) {
          await ReminderService.createReminderNotification(
            reminder,
            title,
            body,
          );
        } 
      } 
      state = state.copyWith(isLoading: false);
    } catch (e, s) {
      LogHelper.shared.debugPrint('$e');
      LogHelper.shared.debugPrint('$s');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to schedule reminder',
      );
    }
  }

  // Cancel reminder
  Future<void> cancelReminder() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final reminder = state.reminder;

      if (reminder != null) {
        await ReminderService.cancelReminderNotification(reminder.id);

        // Keep ID but reset other values
        final updatedReminder = reminder.copyWith(days: [], time: null);
        state = state.copyWith(
          reminder: updatedReminder,
          isLoading: false,
        );
        AppFlushbar.shared.successFlushbar("Reminder cancelled successfuly");
      }
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

    if (days == null || days.isEmpty) {
      // Reset time as well but keep ID
      final updatedReminder = currentReminder?.copyWith(
            days: [],
            time: null,
          ) ??
          ReminderModel(
            id: UuidHelper.uidInt,
            days: [],
            reminderTime: null,
          );
      state = state.copyWith(reminder: updatedReminder);
      return;
    }

    // If days are selected for the first time and time is null, set default time to 12:00
    final DateTime reminderTime = currentReminder?.reminderTime ?? DateTime.now().copyWith(hour: 12, minute: 0, second: 0);

    final updatedReminder = currentReminder?.copyWith(
          days: days,
          time: reminderTime,
        ) ??
        ReminderModel(
          id: UuidHelper.uidInt,
          days: days,
          reminderTime: reminderTime,
        );

    state = state.copyWith(reminder: updatedReminder);
  }

  // Update reminder time
  void updateTime(DateTime? time) {
    final currentReminder = state.reminder;

    if (time == null) {
      // Reset days as well but keep ID
      final updatedReminder = ReminderModel(
        id: currentReminder?.id ?? UuidHelper.uidInt,
        days: [],
        reminderTime: null,
      );
      state = state.copyWith(reminder: updatedReminder);
      return;
    }

    final updatedReminder = ReminderModel(
      id: currentReminder?.id ?? UuidHelper.uidInt,
      days: currentReminder?.days ?? [],
      reminderTime: time,
    );

    state = state.copyWith(reminder: updatedReminder);
  }
}
