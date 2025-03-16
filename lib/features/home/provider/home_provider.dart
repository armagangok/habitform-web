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
    final habits = await fetchHabits();

    // Use the default time filter
    final initialFilter = _getDefaultTimeFilter();

    return habits.copyWith(timeFilter: initialFilter);
  }

  /// Fetches all active habits from the service layer
  /// Updates the state with loading and result/error
  Future<HomeState> fetchHabits() async {
    final habits = await habitService.getHabits();

    // Preserve the current time filter if available
    TimeOfDayFilter? currentFilter;
    if (state.value != null) {
      currentFilter = state.value!.timeFilter;
    }

    final newState = HomeState(
      habits: habits,
      timeFilter: currentFilter ?? _getDefaultTimeFilter(),
    );

    return newState;
  }

  /// Helper method to get the default time filter based on current time
  TimeOfDayFilter _getDefaultTimeFilter() {
    final currentHour = DateTime.now().hour;

    if (currentHour >= 5 && currentHour < 12) {
      // Morning: 5:00 AM - 11:59 AM
      return TimeOfDayFilter.morning;
    } else if (currentHour >= 12 && currentHour < 18) {
      // Noon: 12:00 PM - 5:59 PM
      return TimeOfDayFilter.noon;
    } else if (currentHour >= 18 && currentHour < 24) {
      // Evening: 6:00 PM - 11:59 PM
      return TimeOfDayFilter.evening;
    } else {
      // Night: 12:00 AM - 4:59 AM
      return TimeOfDayFilter.night;
    }
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
  /// Creates a new completion entry if one doesn't exist, or removes it if it's already completed
  Future<void> toggleHabitCompletion(String habitId, DateTime date) async {
    LogHelper.shared.debugPrint('Toggling habit completion for habit: $habitId on date: $date');

    // Normalize the date (without time components)
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final dateKey = normalizedDate.toIso8601DateString;

    LogHelper.shared.debugPrint('Using date key: $dateKey for normalized date: $normalizedDate');

    // Check current state
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

    // If the day is already completed, remove the completion
    if (isCurrentlyCompleted) {
      await removeHabitCompletion(habitId, normalizedDate);
      return;
    }

    // Otherwise, mark it as completed
    final CompletionEntry completion = existingEntry != null
        ? existingEntry.copyWith(isCompleted: true)
        : CompletionEntry(
            id: dateKey,
            date: normalizedDate,
            isCompleted: true, // If creating a new entry, mark it as completed
          );

    // Call the method to update the habit completion status
    await updateHabitCompletionStatus(habitId, completion);

    LogHelper.shared.debugPrint('Habit toggling completed successfully');
  }

  /// Removes a completion entry for a specific date
  Future<void> removeHabitCompletion(String habitId, DateTime date) async {
    LogHelper.shared.debugPrint('Removing completion for habit: $habitId on date: $date');

    // Get current state
    final currentState = state;
    if (currentState is! AsyncData<HomeState>) {
      LogHelper.shared.debugPrint('Cannot remove habit completion: State is not loaded yet');
      return;
    }

    final currentHabits = List<Habit>.from(currentState.value.habits);
    final currentTimeFilter = currentState.value.timeFilter; // Preserve current filter

    // Find habit to update by index
    final habitIndex = currentHabits.indexWhere((h) => h.id == habitId);

    if (habitIndex == -1) {
      LogHelper.shared.debugPrint('Habit not found with ID: $habitId');
      throw Exception('Habit not found');
    }

    // Get the habit
    final habit = currentHabits[habitIndex];

    // Copy completions
    final updatedCompletions = Map<String, CompletionEntry>.from(habit.completions);

    // Find the entry with the specified date
    String? keyToRemove;
    for (var entry in updatedCompletions.entries) {
      if (entry.value.date.normalized.isSameDayWith(date.normalized)) {
        keyToRemove = entry.key;
        break;
      }
    }

    // If found, remove it
    if (keyToRemove != null) {
      updatedCompletions.remove(keyToRemove);
      LogHelper.shared.debugPrint('Removed completion with key: $keyToRemove');

      // Create updated habit
      final updatedHabit = habit.copyWith(completions: updatedCompletions);

      // Update habit in the list
      currentHabits[habitIndex] = updatedHabit;

      // Update state (optimistic update) with preserved filter
      final optimisticState = HomeState(
        habits: currentHabits,
        timeFilter: currentTimeFilter,
      );
      state = AsyncData(optimisticState);

      // Update database
      state = await AsyncValue.guard(() async {
        // Create a dummy completion entry with isCompleted = false to signal removal
        // Bu, service layer'da silme işlemini tetikleyecek
        final dummyCompletion = CompletionEntry(
          id: date.toIso8601DateString,
          date: date.normalized,
          isCompleted: false, // false değeri, service layer'da bu kaydın silinmesi gerektiğini belirtir
        );

        // This will trigger the removal logic in the service layer
        await habitService.updateHabitCompletionStatus(habitId, dummyCompletion);

        LogHelper.shared.debugPrint('Habit completion removed successfully');
        return optimisticState;
      });
    } else {
      LogHelper.shared.debugPrint('No completion found for the specified date');
    }
  }

  /// Updates the completion status of a habit with optimistic UI update
  /// Updates local state first, then persists to database
  /// If completion.isCompleted is false, the entry will be removed completely
  Future<void> updateHabitCompletionStatus(String habitId, CompletionEntry completion) async {
    LogHelper.shared.debugPrint('Updating habit completion status: $habitId, date: ${completion.date}, completed: ${completion.isCompleted}');

    // Get current state
    final currentState = state;
    if (currentState is AsyncData<HomeState>) {
      final currentHabits = List<Habit>.from(currentState.value.habits);
      final currentTimeFilter = currentState.value.timeFilter; // Preserve current filter

      // Find habit to update by index
      final habitIndex = currentHabits.indexWhere((h) => h.id == habitId);

      if (habitIndex != -1) {
        // Get the habit
        final habit = currentHabits[habitIndex];

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
          if (completion.isCompleted) {
            // If marked as completed, update the entry
            final updatedEntry = existingEntryWithSameDate.copyWith(isCompleted: true);

            // Save with the existing ID
            updatedCompletions[existingKey] = updatedEntry;
            LogHelper.shared.debugPrint('Updated existing entry with ID: $existingKey and kept the original ID');
          } else {
            // If marked as not completed, remove the entry
            updatedCompletions.remove(existingKey);
            LogHelper.shared.debugPrint('Removed entry with ID: $existingKey because it was marked as not completed');
          }

          // If there's an entry with the incoming completion ID, remove it (to prevent inconsistency)
          if (completion.id != existingKey && updatedCompletions.containsKey(completion.id)) {
            updatedCompletions.remove(completion.id);
            LogHelper.shared.debugPrint('Removed duplicate entry with ID: ${completion.id}');
          }
        } else {
          // If there's no entry with the same date
          if (completion.isCompleted) {
            // If marked as completed, add the new entry
            updatedCompletions[completion.id] = completion;
            LogHelper.shared.debugPrint('Added new entry with ID: ${completion.id}');
          } else {
            // If marked as not completed and there's an entry with the same ID, remove it
            if (updatedCompletions.containsKey(completion.id)) {
              updatedCompletions.remove(completion.id);
              LogHelper.shared.debugPrint('Removed entry with ID: ${completion.id} because it was marked as not completed');
            }
          }
        }

        // Create updated habit
        final updatedHabit = habit.copyWith(
          completions: updatedCompletions,
        );

        // Update habit in the list
        currentHabits[habitIndex] = updatedHabit;

        // Update state (optimistic update) with preserved filter
        final optimisticState = HomeState(
          habits: currentHabits,
          timeFilter: currentTimeFilter, // Explicitly preserve the time filter
        );
        state = AsyncData(optimisticState);

        // Update database and handle any errors
        state = await AsyncValue.guard(() async {
          if (!completion.isCompleted) {
            await habitService.updateHabitCompletionStatus(habitId, completion);
          } else {
            final entryToUpdate = updatedHabit.completions.values.firstWhere((e) => e.date.normalized.isSameDayWith(completion.date.normalized), orElse: () => completion);
            await habitService.updateHabitCompletionStatus(habitId, entryToUpdate);
          }

          LogHelper.shared.debugPrint('Habit completion status updated successfully');
          return optimisticState;
        });
        return;
      }
    }

    // If current state is not AsyncData or habit not found
    LogHelper.shared.debugPrint('Falling back to loading state for habit update');

    // Save current filter if available
    TimeOfDayFilter? currentFilter;
    if (state.value != null) {
      currentFilter = state.value!.timeFilter;
    }

    state = const AsyncValue.loading();

    // Update completion status with the habit service
    state = await AsyncValue.guard(() async {
      await habitService.updateHabitCompletionStatus(habitId, completion);
      final newState = await fetchHabits();

      // Restore the filter if it was saved
      if (currentFilter != null) {
        return newState.copyWith(timeFilter: currentFilter);
      }
      return newState;
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

  /// Sets the time of day filter
  Future<void> setTimeFilter(TimeOfDayFilter filter) async {
    final currentState = state;
    if (currentState is AsyncData<HomeState>) {
      // Update state with new filter but keep same habits
      state = AsyncData(currentState.value.copyWith(timeFilter: filter));
    }
  }

  /// Refreshes the habits list from the service and updates the state
  Future<void> refreshHabits() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await fetchHabits();
    });
  }
}
