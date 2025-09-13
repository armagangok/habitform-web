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

  Future<void> initHabit(Habit habit) async => state = habit;

  Future<void> updateHabit(Habit habit) async {
    try {
      await habitService.updateHabit(habit);
      state = habit;
    } catch (e) {
      LogHelper.shared.errorPrint("Error updating habit: $e");
    }
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
        final updatedHabit = await habitService.getHabit(habitId);

        if (updatedHabit != null) {
          LogHelper.shared.debugPrint("Updated habit found, updating state");

          // State'i güncelle
          state = updatedHabit;

          // Home provider'ı da güncelle
          await ref.read(homeProvider.notifier).refreshHabits();
          LogHelper.shared.debugPrint("State and home provider updated successfully");
        } else {
          LogHelper.shared.errorPrint("Could not find the updated habit");
        }
      } else {
        LogHelper.shared.debugPrint("Current habit is not being viewed, only updating home provider");
        // Sadece home provider'ı güncelle
        await ref.read(homeProvider.notifier).refreshHabits();
      }
    } catch (e, s) {
      LogHelper.shared.errorPrint("Error marking habit as complete: $e\n$s");
      rethrow;
    }
  }

  /// Belirli bir tarihteki tamamlama kaydını tamamen siler
  Future<void> removeHabitCompletion(String habitId, DateTime date) async {
    try {
      LogHelper.shared.debugPrint("Removing completion for habit $habitId on date $date");

      // Önce habit'i al
      final habits = await habitService.getHabits();
      final habit = habits.firstWhere((h) => h.id == habitId, orElse: () => throw Exception("Habit not found"));

      // Tamamlama kayıtlarını kopyala
      final updatedCompletions = Map<String, CompletionEntry>.from(habit.completions);

      // Belirtilen tarihe sahip kaydı bul
      String? keyToRemove;
      for (var entry in updatedCompletions.entries) {
        if (entry.value.date.normalized.isSameDayWith(date.normalized)) {
          keyToRemove = entry.key;
          break;
        }
      }

      // Eğer kayıt bulunduysa sil
      if (keyToRemove != null) {
        updatedCompletions.remove(keyToRemove);
        LogHelper.shared.debugPrint("Found and removed completion with key: $keyToRemove");

        // Güncellenmiş habit'i oluştur
        final updatedHabit = habit.copyWith(completions: updatedCompletions);

        // Habit'i güncelle
        await habitService.updateHabit(updatedHabit);

        // Yerel state'i güncelle, eğer bu habit şu anda açıksa
        if (state != null && state!.id == habitId) {
          state = updatedHabit;
        }

        // Home provider'ı da güncelle
        await ref.read(homeProvider.notifier).refreshHabits();
        LogHelper.shared.debugPrint("Successfully removed completion and updated state");
      } else {
        LogHelper.shared.debugPrint("No completion found for the specified date");
      }
    } catch (e, s) {
      LogHelper.shared.debugPrint("Error removing habit completion: $e\n$s");
      rethrow;
    }
  }
}
