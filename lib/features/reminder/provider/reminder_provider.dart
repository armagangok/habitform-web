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

  // İki hatırlatıcı modelinin farklı olup olmadığını kontrol et
  bool isReminderChanged(ReminderModel? oldReminder, ReminderModel? newReminder) {
    // Biri null diğeri değilse değişmiş demektir
    if ((oldReminder == null && newReminder != null) || (oldReminder != null && newReminder == null)) {
      return true;
    }

    // İkisi de null ise değişmemiş demektir
    if (oldReminder == null && newReminder == null) {
      return false;
    }

    // ID'ler farklıysa değişmiş demektir
    if (oldReminder!.id != newReminder!.id) {
      return true;
    }

    // Zaman değişmişse
    final oldTime = oldReminder.reminderTime;
    final newTime = newReminder.reminderTime;

    if ((oldTime == null && newTime != null) || (oldTime != null && newTime == null)) {
      return true;
    }

    if (oldTime != null && newTime != null) {
      if (oldTime.hour != newTime.hour || oldTime.minute != newTime.minute) {
        return true;
      }
    }

    // Günler değişmişse
    final oldDays = oldReminder.days ?? [];
    final newDays = newReminder.days ?? [];

    if (oldDays.length != newDays.length) {
      return true;
    }

    // Günlerin içeriğini karşılaştır
    for (final day in oldDays) {
      if (!newDays.contains(day)) {
        return true;
      }
    }

    // Hiçbir değişiklik yoksa
    return false;
  }

  // Cancel existing notifications and schedule new reminder
  Future<void> scheduleReminder({
    required String title,
    required String body,
    ReminderModel? oldReminder,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      final reminder = state.reminder;
      final days = reminder?.days;
      final reminderTime = reminder?.reminderTime;

      LogHelper.shared.debugPrint('Scheduling reminder: $reminder');
      LogHelper.shared.debugPrint('Days: $days, Time: $reminderTime');

      // Eğer eski hatırlatıcı verilmişse, değişiklik kontrolü yap
      if (oldReminder != null) {
        final hasChanged = isReminderChanged(oldReminder, reminder);
        LogHelper.shared.debugPrint('Old reminder: $oldReminder');
        LogHelper.shared.debugPrint('Is reminder changed: $hasChanged');

        // Değişiklik yoksa işlemi sonlandır
        if (!hasChanged) {
          LogHelper.shared.debugPrint('Reminder has not changed, skipping schedule');
          state = state.copyWith(isLoading: false);
          return;
        }
      }

      if (reminder != null) {
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
          AppFlushbar.shared.successFlushbar("Hatırlatıcı başarıyla ayarlandı");
        } else {
          LogHelper.shared.debugPrint('Skipping notification creation: days or time is missing');
          if (days == null || days.isEmpty) {
            LogHelper.shared.debugPrint('Days are empty or null');
          }
          if (reminderTime == null) {
            LogHelper.shared.debugPrint('Reminder time is null');
          }
        }
      } else {
        LogHelper.shared.debugPrint('Reminder is null, cannot schedule');
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
