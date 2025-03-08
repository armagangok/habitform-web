import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/models/completion_entry/completion_entry.dart';
import '/models/habit/habit_model.dart';
import '../../../core/core.dart';
import '../../../services/habit_service/habit_service_interface.dart';

/// Provider for managing habits in the home screen
/// Returns an async list of habits
final homeProvider = AsyncNotifierProvider<HomeNotifier, List<Habit>>(() {
  return HomeNotifier();
});

/// Notifier class that handles all habit-related operations
class HomeNotifier extends AsyncNotifier<List<Habit>> {
  @override
  Future<List<Habit>> build() async {
    // Initial fetch of habits when the provider is created
    return fetchHabits();
  }

  /// Fetches all active habits from the service layer
  /// Updates the state with loading and result/error
  Future<List<Habit>> fetchHabits() async {
    state = const AsyncValue.loading();
    final habits = await habitService.getHabits();
    return habits;
  }

  /// Archives a habit by moving it to the archived habits storage
  Future<void> archiveHabit(Habit habit) async {
    state = const AsyncValue.loading();
    await habitService.archiveHabit(habit);
    state = AsyncValue.data(await fetchHabits());
  }

  /// Toggles the completion status of a habit for a specific date
  /// Creates a new completion entry if one doesn't exist, or updates existing one
  Future<void> toggleHabitCompletion(String habitId, DateTime date) async {
    LogHelper.shared.debugPrint('Toggling habit completion for habit: $habitId on date: $date');

    // Normalize the date (without time components)
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final dateKey = normalizedDate.toIso8601DateString;

    LogHelper.shared.debugPrint('Using date key: $dateKey for normalized date: $normalizedDate');

    // Check current state
    final currentState = state;
    if (currentState is! AsyncData<List<Habit>>) {
      LogHelper.shared.debugPrint('Cannot toggle habit completion: State is not loaded yet');
      return;
    }

    // Find the habit by ID
    final habitIndex = currentState.value.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) {
      LogHelper.shared.debugPrint('Habit not found with ID: $habitId');
      throw Exception('Habit not found');
    }

    final habit = currentState.value[habitIndex];

    // Check for existing completion entry for this date
    CompletionEntry? existingEntry;
    bool isCurrentlyCompleted = false;

    // Check if there's an entry for this date in completions
    for (var entry in habit.completions.values) {
      if (entry.date.normalized.isSameDayWith(normalizedDate)) {
        existingEntry = entry;
        isCurrentlyCompleted = entry.isCompleted;
        LogHelper.shared.debugPrint('Found existing completion entry with ID: ${entry.id}, status: ${entry.isCompleted}');
        break;
      }
    }

    // Update existing entry or create a new one
    final CompletionEntry completion;

    if (existingEntry != null) {
      // Use existing entry, just toggle the isCompleted value
      completion = existingEntry.copyWith(
        isCompleted: !isCurrentlyCompleted,
      );
      LogHelper.shared.debugPrint('Updating existing completion entry, new status: ${!isCurrentlyCompleted}');
    } else {
      // Create a new entry
      completion = CompletionEntry(
        id: dateKey,
        date: normalizedDate,
        isCompleted: true, // If creating a new entry, mark it as completed
      );
      LogHelper.shared.debugPrint('Creating new completion entry with status: true');
    }

    // Call the method to update the habit completion status
    await updateHabitCompletionStatus(habitId, completion);

    LogHelper.shared.debugPrint('Habit toggling completed successfully');
  }

  /// Updates the completion status of a habit with optimistic UI update
  /// Updates local state first, then persists to database
  Future<void> updateHabitCompletionStatus(String habitId, CompletionEntry completion) async {
    LogHelper.shared.debugPrint('Updating habit completion status: $habitId, date: ${completion.date}, completed: ${completion.isCompleted}');

    // Get current state
    final currentState = state;
    if (currentState is AsyncData<List<Habit>>) {
      // Get current habits
      final habits = List<Habit>.from(currentState.value);

      // Find habit to update by index
      final habitIndex = habits.indexWhere((h) => h.id == habitId);

      if (habitIndex != -1) {
        // Get the habit
        final habit = habits[habitIndex];

        // Update completions
        final updatedCompletions = Map<String, CompletionEntry>.from(habit.completions);

        // Check if there's an existing entry with the same date but different ID
        CompletionEntry? existingEntryWithSameDate;
        String? existingKey;

        for (var entry in updatedCompletions.entries) {
          if (entry.value.date.normalized.isSameDayWith(completion.date.normalized) && entry.key != completion.id) {
            existingEntryWithSameDate = entry.value;
            existingKey = entry.key;
            LogHelper.shared.debugPrint('Found existing entry with same date but different ID. Existing ID: ${entry.key}, New ID: ${completion.id}');
            break;
          }
        }

        if (existingEntryWithSameDate != null && existingKey != null) {
          // Update existing entry, don't add a new one
          final updatedEntry = existingEntryWithSameDate.copyWith(isCompleted: completion.isCompleted);

          // Save with the existing ID
          updatedCompletions[existingKey] = updatedEntry;
          LogHelper.shared.debugPrint('Updated existing entry with ID: $existingKey and kept the original ID');

          // If there's an entry with the incoming completion ID, remove it (to prevent inconsistency)
          if (completion.id != existingKey && updatedCompletions.containsKey(completion.id)) {
            updatedCompletions.remove(completion.id);
            LogHelper.shared.debugPrint('Removed duplicate entry with ID: ${completion.id}');
          }
        } else {
          // If there's no entry with the same date, add the new one
          updatedCompletions[completion.id] = completion;
          LogHelper.shared.debugPrint('Added new entry with ID: ${completion.id}');
        }

        // Create updated habit
        final updatedHabit = habit.copyWith(
          completions: updatedCompletions,
        );

        // Update habit in the list
        habits[habitIndex] = updatedHabit;

        // Update state (without loading state)
        state = AsyncData(habits);

        // Update database
        await habitService.updateHabitCompletionStatus(habitId, updatedHabit.completions.values.firstWhere((e) => e.date.normalized.isSameDayWith(completion.date.normalized), orElse: () => completion));
        LogHelper.shared.debugPrint('Habit completion status updated successfully');
        return;
      }
    }

    // If current state is not AsyncData or habit not found
    LogHelper.shared.debugPrint('Falling back to loading state for habit update');
    state = const AsyncValue.loading();

    // Update completion status with the habit service
    await habitService.updateHabitCompletionStatus(habitId, completion);
    state = AsyncValue.data(await fetchHabits());
  }

  /// Creates a new habit
  Future<void> createHabit(Habit habit) async {
    state = const AsyncValue.loading();
    await habitService.createHabit(habit);
    state = AsyncValue.data(await fetchHabits());
  }

  /// Updates an existing habit
  Future<void> updateHabit(Habit habit) async {
    state = const AsyncValue.loading();
    await habitService.updateHabit(habit);
    state = AsyncValue.data(await fetchHabits());
  }

  /// Deletes (archives) a habit
  Future<void> deleteHabit(String habitId) async {
    state = const AsyncValue.loading();
    await habitService.deleteHabit(habitId);
    state = AsyncValue.data(await fetchHabits());
  }
}
