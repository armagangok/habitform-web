import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/models/completion_entry/completion_entry.dart';
import '/models/habit/habit_model.dart';
import '/services/habit_service/habit_service_interface.dart';
import 'home_state.dart';

/// Provider for managing habits in the home screen
/// Returns an async state containing habits and error info
final homeProvider = AsyncNotifierProvider<HomeNotifier, HomeState>(() {
  return HomeNotifier();
});

/// Notifier class that handles all habit-related operations
class HomeNotifier extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    // Initial fetch of habits when the provider is created
    return await fetchHabits();
  }

  /// Fetches all active habits from the service layer
  Future<HomeState> fetchHabits() async {
    final habits = await habitService.getHabits();

    // Sort habits by reminder time
    final sortedHabits = habits.toList()
      ..sort((a, b) {
        // Habits without reminder time go at the end
        if (a.reminderModel?.reminderTime == null && b.reminderModel?.reminderTime == null) {
          return 0; // Both have no reminder time, keep original order
        }
        if (a.reminderModel?.reminderTime == null) {
          return 1; // a goes after b
        }
        if (b.reminderModel?.reminderTime == null) {
          return -1; // a goes before b
        }

        // Compare only the time part of the day (ignoring date)
        final aTime = a.reminderModel!.reminderTime!;
        final bTime = b.reminderModel!.reminderTime!;

        // Create DateTime objects with just the hour and minute for comparison
        final aTimeOnly = DateTime(0, 0, 0, aTime.hour, aTime.minute);
        final bTimeOnly = DateTime(0, 0, 0, bTime.hour, bTime.minute);

        return aTimeOnly.compareTo(bTimeOnly);
      });

    return HomeState(habits: sortedHabits);
  }

  /// Archives a habit by moving it to the archived habits storage
  Future<void> archiveHabit(Habit habit) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await habitService.archiveHabit(habit);
      return await fetchHabits();
    });
  }

  /// Toggles the completion status of a habit for a specific date
  Future<void> toggleHabitCompletion(String habitId, DateTime date) async {
    LogHelper.shared.debugPrint('Toggling habit completion for habit: $habitId on date: $date');

    // Normalize the date (without time components)
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final dateKey = normalizedDate.toIso8601DateString;

    // Get current state
    final currentState = state;
    if (currentState is! AsyncData<HomeState>) {
      LogHelper.shared.debugPrint('Cannot toggle habit completion: State is not loaded yet');
      return;
    }

    final currentHabits = currentState.value.habits;

    // Find the habit by ID
    final habitIndex = currentHabits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) {
      LogHelper.shared.debugPrint('Habit not found with ID: $habitId');
      throw Exception('Habit not found');
    }

    final habit = currentHabits[habitIndex];

    // Check if the habit is already completed for this date
    bool isCurrentlyCompleted = false;
    for (var entry in habit.completions.values) {
      if (entry.date.normalized.isSameDayWith(normalizedDate)) {
        isCurrentlyCompleted = entry.isCompleted;
        break;
      }
    }

    // Create the completion entry
    final completion = CompletionEntry(
      id: dateKey,
      date: normalizedDate,
      isCompleted: !isCurrentlyCompleted, // Toggle the completion status
    );

    // Apply optimistic update
    final updatedHabits = List<Habit>.from(currentHabits);
    final updatedCompletions = Map<String, CompletionEntry>.from(habit.completions);

    if (!isCurrentlyCompleted) {
      // Mark as completed
      updatedCompletions[dateKey] = completion;
    } else {
      // Remove completion if it exists
      for (var key in updatedCompletions.keys.toList()) {
        final entry = updatedCompletions[key]!;
        if (entry.date.normalized.isSameDayWith(normalizedDate)) {
          updatedCompletions.remove(key);
          break;
        }
      }
    }

    updatedHabits[habitIndex] = habit.copyWith(completions: updatedCompletions);

    // Update state with optimistic update
    state = AsyncData(HomeState(habits: updatedHabits));

    // Update database
    state = await AsyncValue.guard(() async {
      await habitService.updateHabitCompletionStatus(habitId, completion);
      return HomeState(habits: updatedHabits);
    });
  }

  /// Creates a new habit
  Future<void> createHabit(Habit habit) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await habitService.createHabit(habit);
      return await fetchHabits();
    });
  }

  /// Updates an existing habit
  Future<void> updateHabit(Habit habit) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await habitService.updateHabit(habit);
      return await fetchHabits();
    });
  }

  /// Deletes (archives) a habit
  Future<void> deleteHabit(String habitId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await habitService.deleteHabit(habitId);
      return await fetchHabits();
    });
  }

  /// Refreshes the habits list from the service and updates the state
  Future<void> refreshHabits() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await fetchHabits();
    });
  }
}
