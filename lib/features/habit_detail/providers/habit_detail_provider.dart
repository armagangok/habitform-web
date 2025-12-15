import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../models/completion_entry/completion_entry.dart';
import '../../../models/habit/habit_model.dart';
import '../../../services/habit_service/habit_service_interface.dart';
import '../../../services/widget_sync_service.dart';
import '../../habit_probability/provider/habit_probability_provider.dart';
import '../../home/provider/home_provider.dart';
import 'habit_statistics_provider.dart';

final habitDetailProvider = AutoDisposeNotifierProvider<HabitDetailNotifier, Habit?>(() {
  return HabitDetailNotifier();
});

class HabitDetailNotifier extends AutoDisposeNotifier<Habit?> {
  @override
  Habit? build() => null;

  Future<void> initHabit(Habit habit) async {
    state = habit;
    // Trigger async statistics calculation (non-blocking)
    // This allows the UI to render immediately while statistics calculate in background
    ref.read(habitStatisticsProvider.notifier).forceRecalculate(habit);
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      await habitService.updateHabit(habit);
      state = habit;
    } catch (e) {
      LogHelper.shared.errorPrint("Error updating habit: $e");
    }
  }

  Future<void> markHabitAsComplete(String habitId, CompletionEntry completion) async {
    final startTime = DateTime.now();
    try {
      LogHelper.shared.debugPrint("🚀 [PERF] Starting markHabitAsComplete at ${startTime.millisecondsSinceEpoch}");

      // Optimistic update: Update local state first for immediate UI response
      if (state != null && state!.id == habitId) {
        final optimisticStart = DateTime.now();
        final currentHabit = state!;
        final updatedCompletions = Map<String, CompletionEntry>.from(currentHabit.completions);

        // Optimized lookup: try direct key lookup first (O(1) instead of O(n))
        final normalizedDate = completion.date.normalized;
        final dateKey = normalizedDate.toIso8601DateString;
        String? existingKey;
        CompletionEntry? existingEntry = updatedCompletions[dateKey];

        if (existingEntry != null && existingEntry.date.normalized.isSameDayWith(normalizedDate)) {
          existingKey = dateKey;
        } else {
          // Try alternative key format
          final altKey = '${normalizedDate.year}-${normalizedDate.month}-${normalizedDate.day}';
          existingEntry = updatedCompletions[altKey];
          if (existingEntry != null && existingEntry.date.normalized.isSameDayWith(normalizedDate)) {
            existingKey = altKey;
          } else {
            existingEntry = null;
            // Fallback to linear search only if direct lookup fails (should be rare)
            for (var entry in updatedCompletions.entries) {
              if (entry.value.date.normalized.isSameDayWith(normalizedDate)) {
                existingKey = entry.key;
                existingEntry = entry.value;
                break;
              }
            }
          }
        }

        // Calculate new count
        int currentCount = existingEntry?.count ?? 0;
        int target = currentHabit.dailyTarget <= 0 ? 1 : currentHabit.dailyTarget;
        int newCount;
        if (completion.isCompleted) {
          newCount = (currentCount + 1) > target ? target : (currentCount + 1);
        } else {
          newCount = (currentCount - 1) < 0 ? 0 : (currentCount - 1);
        }

        // Remove old entry and add updated one
        if (existingKey != null) {
          updatedCompletions.remove(existingKey);
        }

        final updatedEntry = CompletionEntry(
          id: completion.id,
          date: completion.date.normalized,
          isCompleted: newCount >= target,
          count: newCount,
        );
        updatedCompletions[updatedEntry.id] = updatedEntry;

        // Update local state immediately
        final updatedHabit = currentHabit.copyWith(completions: updatedCompletions);
        state = updatedHabit;

        // Trigger async statistics recalculation (non-blocking)
        // This allows UI to remain responsive while statistics update in background
        ref.read(habitStatisticsProvider.notifier).forceRecalculate(updatedHabit);

        final optimisticEnd = DateTime.now();
        LogHelper.shared.debugPrint("⚡ [PERF] Optimistic update completed in ${optimisticEnd.difference(optimisticStart).inMilliseconds}ms");
      }

      // Update habit service in background
      final serviceStart = DateTime.now();
      await habitService.updateHabitCompletionStatus(habitId, completion);
      final serviceEnd = DateTime.now();
      LogHelper.shared.debugPrint("💾 [PERF] Habit service update completed in ${serviceEnd.difference(serviceStart).inMilliseconds}ms");

      // Update other providers asynchronously without blocking UI
      _updateProvidersAsync(habitId);

      final totalTime = DateTime.now().difference(startTime);
      LogHelper.shared.debugPrint("✅ [PERF] markHabitAsComplete total time: ${totalTime.inMilliseconds}ms");
    } catch (e, s) {
      LogHelper.shared.errorPrint("Error marking habit as complete: $e\n$s");
      // Revert optimistic update on error
      if (state != null && state!.id == habitId) {
        final revertedHabit = await habitService.getHabit(habitId);
        if (revertedHabit != null) {
          state = revertedHabit;
        }
      }
      rethrow;
    }
  }

  /// Update providers asynchronously without blocking the UI
  void _updateProvidersAsync(String habitId) {
    // Use Future.microtask to ensure this runs after the current frame
    Future.microtask(() async {
      final asyncStart = DateTime.now();
      try {
        LogHelper.shared.debugPrint("🔄 [PERF] Starting background provider updates");

        // Update home provider
        final homeStart = DateTime.now();
        await ref.read(homeProvider.notifier).refreshHabits();
        final homeEnd = DateTime.now();
        LogHelper.shared.debugPrint("🏠 [PERF] Home provider updated in ${homeEnd.difference(homeStart).inMilliseconds}ms");

        // Update formation provider
        final formationStart = DateTime.now();
        await ref.read(probabilityProvider.notifier).refreshFormationStatistics();
        final formationEnd = DateTime.now();
        LogHelper.shared.debugPrint("📊 [PERF] Formation provider updated in ${formationEnd.difference(formationStart).inMilliseconds}ms");

        // Update widget data (debounced in WidgetSyncService)
        final widgetStart = DateTime.now();
        final allHabits = await habitService.getAllHabits();
        await WidgetSyncService().updateWidgetData(allHabits);
        final widgetEnd = DateTime.now();
        LogHelper.shared.debugPrint("📱 [PERF] Widget data updated in ${widgetEnd.difference(widgetStart).inMilliseconds}ms");

        final asyncEnd = DateTime.now();
        LogHelper.shared.debugPrint("✅ [PERF] Background providers updated successfully in ${asyncEnd.difference(asyncStart).inMilliseconds}ms");
      } catch (e) {
        LogHelper.shared.errorPrint("Error updating background providers: $e");
      }
    });
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

        // Formation provider'ı da güncelle
        await ref.read(probabilityProvider.notifier).refreshFormationStatistics();
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
