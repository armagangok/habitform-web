import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/features/habit_category/provider/habit_category_provider.dart';
import '/features/habit_formation/provider/habit_formation_provider.dart';
import '/features/reminder/service/reminder_service.dart';
import '/models/completion_entry/completion_entry.dart';
import '/models/habit/habit_model.dart';
import '/services/app_lifecycle_service.dart';
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

    return HomeState(habits: habits);
  }

  /// Archives a habit by moving it to the archived habits storage
  Future<void> archiveHabit(Habit habit) async {
    LogHelper.shared.debugPrint('🏠 HOME PROVIDER: archiveHabit called for habit: ${habit.habitName} (ID: ${habit.id})');

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      LogHelper.shared.debugPrint('🏠 Step 1: Setting state to loading');

      LogHelper.shared.debugPrint('🏠 Step 2: Notifying app lifecycle service (backup)');
      // Notify app lifecycle service that archiving is starting (backup)
      AppLifecycleService.shared.notifyArchivingStarted();

      LogHelper.shared.debugPrint('🏠 Step 3: Backup notification cancellation');
      // Cancel notifications before archiving (backup in case UI doesn't do it)
      if (habit.reminderModel != null) {
        LogHelper.shared.debugPrint('🏠 Habit has reminder model, cancelling notifications (backup)');
        await ReminderService.cancelAllReminderNotifications(habit.reminderModel);
        LogHelper.shared.debugPrint('🏠 Backup: Cancelled notifications for habit being archived: ${habit.id}');
      } else {
        LogHelper.shared.debugPrint('🏠 Habit has NO reminder model (backup)');
      }

      LogHelper.shared.debugPrint('🏠 Step 4: Calling habitService.archiveHabit...');
      await habitService.archiveHabit(habit);
      LogHelper.shared.debugPrint('🏠 habitService.archiveHabit completed');

      LogHelper.shared.debugPrint('🏠 Step 5: Fetching updated habits...');
      final result = await fetchHabits();
      LogHelper.shared.debugPrint('🏠 fetchHabits completed, returning result');
      return result;
    });

    LogHelper.shared.debugPrint('🏠 HOME PROVIDER: archiveHabit completed for habit: ${habit.habitName}');
  }

  /// Toggles the completion status of a habit for a specific date
  Future<void> toggleHabitCompletion(String habitId, DateTime date) async {
    // Backward compatibility: default to increment when tapping
    await adjustHabitCompletion(habitId, date, increment: true);
  }

  /// Adjusts completion count progressively (increment/decrement) for a date
  Future<void> adjustHabitCompletion(String habitId, DateTime date, {required bool increment}) async {
    LogHelper.shared.debugPrint('Adjusting habit completion for habit: $habitId on date: $date, increment: $increment');

    // Normalize date and fetch current state
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final dateKey = normalizedDate.toIso8601DateString;
    final currentState = state;
    if (currentState is! AsyncData<HomeState>) return;

    final currentHabits = List<Habit>.from(currentState.value.habits);
    final habitIndex = currentHabits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) throw Exception('Habit not found');

    final habit = currentHabits[habitIndex];
    final target = habit.dailyTarget <= 0 ? 1 : habit.dailyTarget;

    // Find existing entry
    final updatedCompletions = Map<String, CompletionEntry>.from(habit.completions);
    String? existingKey;
    CompletionEntry? existingEntry;
    for (final entry in updatedCompletions.entries) {
      if (entry.value.date.normalized.isSameDayWith(normalizedDate)) {
        existingKey = entry.key;
        existingEntry = entry.value;
        break;
      }
    }

    int currentCount = existingEntry?.count ?? 0;
    int newCount = increment ? (currentCount + 1) : (currentCount - 1);
    if (newCount < 0) newCount = 0;
    if (newCount > target) newCount = target;

    // Remove old entry and write updated
    if (existingKey != null) updatedCompletions.remove(existingKey);
    final updatedEntry = CompletionEntry(
      id: dateKey,
      date: normalizedDate,
      isCompleted: newCount > 0,
      count: newCount,
    );
    updatedCompletions[dateKey] = updatedEntry;

    // Optimistic state
    currentHabits[habitIndex] = habit.copyWith(completions: updatedCompletions);
    state = AsyncData(HomeState(habits: currentHabits));

    // Persist via service using increment/decrement semantics
    await AsyncValue.guard(() async {
      final completion = CompletionEntry(id: dateKey, date: normalizedDate, isCompleted: increment);
      await habitService.updateHabitCompletionStatus(habitId, completion);
    });

    // Refresh formation statistics after completion update
    await ref.read(formationProvider.notifier).refreshFormationStatistics();
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
      // Get the habit before deleting to cancel its reminders
      final habit = await habitService.getHabit(habitId);
      if (habit != null) {
        // Cancel all reminder notifications before archiving
        await ReminderService.cancelAllReminderNotifications(habit.reminderModel);
      }

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
