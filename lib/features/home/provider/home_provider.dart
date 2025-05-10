import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/features/habit_category/provider/habit_category_provider.dart';
import '/models/completion_entry/completion_entry.dart';
import '/models/habit/habit_extension.dart';
import '/models/habit/habit_model.dart';
import '/services/habit_service/habit_service_interface.dart';
import 'home_state.dart';

/// Provider for filtered habits based on selected categories
final filteredHabitsProvider = Provider<List<Habit>>((ref) {
  final homeState = ref.watch(homeProvider);
  final selectedCategories = ref.watch(selectedCategoriesProvider);

  // Return all habits if no categories are selected
  if (selectedCategories.isEmpty) {
    return homeState.value?.habits ?? [];
  }

  // Filter habits based on selected categories
  final filteredHabits = homeState.value?.habits.where((habit) {
        // If habit has no categories, don't show it when categories are selected
        if (habit.categoryIds.isEmpty) return false;

        // Check if the habit has any of the selected categories
        return habit.categoryIds.any((categoryId) => selectedCategories.contains(categoryId));
      }).toList() ??
      [];

  return filteredHabits;
});

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

  /// Fetches all active habits from the service layer and sort
  Future<HomeState> fetchHabits() async {
    final List<Habit> habits = await habitService.getHabits();

    return HomeState(habits: habits.sortHabitsByTime);
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
