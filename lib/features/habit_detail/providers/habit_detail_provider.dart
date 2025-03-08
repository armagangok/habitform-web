import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../models/completion_entry/completion_entry.dart';
import '../../../models/habit/habit_model.dart';
import '../../../services/habit_service/habit_service_interface.dart';
import '../../home/provider/home_provider.dart';

final habitDetailProvider = AutoDisposeNotifierProvider<HabitDetailNotifier, Habit?>(() {
  return HabitDetailNotifier();
});

class HabitDetailNotifier extends AutoDisposeNotifier<Habit?> {
  @override
  Habit? build() => null;

  Future<void> updateHabit(Habit habit) async {
    try {
      await habitService.updateHabit(habit);
      state = habit;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setHabit(Habit habit) async {
    state = habit;
  }

  Future<void> markHabitAsComplete(String habitId, CompletionEntry completion) async {
    try {
      LogHelper.shared.debugPrint("Marking habit $habitId as ${completion.isCompleted ? 'completed' : 'not completed'} for date ${completion.date}");

      // Önce habit service ile güncelleme yap
      await habitService.updateHabitCompletionStatus(habitId, completion);
      LogHelper.shared.debugPrint("Habit service updated successfully");

      // Yerel state'i güncelle, eğer bu habit şu anda açıksa
      if (state != null && state!.id == habitId) {
        LogHelper.shared.debugPrint("Updating local state for the habit");

        // Güncel habit'i db'den al
        final habits = await habitService.getHabits();

        try {
          // Güncellenmiş habit'i bul
          final updatedHabit = habits.firstWhere((h) => h.id == habitId);
          LogHelper.shared.debugPrint("Updated habit found, updating state");

          // State'i güncelle
          state = updatedHabit;

          // Home provider'ı da güncelle
          ref.read(homeProvider.notifier).fetchHabits();
          LogHelper.shared.debugPrint("State and home provider updated successfully");
        } catch (e) {
          LogHelper.shared.debugPrint("Could not find the updated habit: $e");
        }
      } else {
        LogHelper.shared.debugPrint("Current habit is not being viewed, only updating home provider");
        // Sadece home provider'ı güncelle
        ref.read(homeProvider.notifier).fetchHabits();
      }
    } catch (e, s) {
      LogHelper.shared.debugPrint("Error marking habit as complete: $e\n$s");
      // Hatayı yukarı ilet, widget layer'da handling yapılabilir
      rethrow;
    }
  }
}
