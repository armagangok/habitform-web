import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/features/habit_category/provider/habit_category_provider.dart';
import '/features/purchase/providers/purchase_provider.dart';
import '/features/reminder/service/reminder_service.dart';
import '/models/completion_entry/completion_entry.dart';
import '/models/habit/habit_model.dart';
import '/services/app_lifecycle_service.dart';
import '/services/habit_service/habit_service_interface.dart';
import '/services/widget_sync_service.dart';
import '../../habit_probability/provider/habit_probability_provider.dart';
import 'home_state.dart';

/// Provider for filtered habits based on selected categories
/// Optimized with memoization: Riverpod automatically caches results when dependencies don't change
final filteredHabitsProvider = Provider<List<Habit>>((ref) {
  final homeState = ref.watch(homeProvider);
  final selectedCategories = ref.watch(selectedCategoriesProvider);

  final habits = homeState.value?.habits ?? [];
  
  // Return all habits if no categories are selected
  if (selectedCategories.isEmpty) {
    return habits;
  }

  // Filter habits based on selected categories
  final filteredHabits = habits.where((habit) {
        // Check if the habit has any of the selected categories
        return habit.categoryIds.any((categoryId) => selectedCategories.contains(categoryId));
      }).toList();

  return filteredHabits;
});

/// Provider for managing habits in the home screen
/// Returns an async state containing habits and error info
final homeProvider = AsyncNotifierProvider<HomeNotifier, HomeState>(() {
  return HomeNotifier();
});

/// Notifier class that handles all habit-related operations
class HomeNotifier extends AsyncNotifier<HomeState> {
  StreamSubscription<Map<String, dynamic>>? _widgetUpdateSubscription;

  @override
  Future<HomeState> build() async {
    // Initial fetch of habits when the provider is created
    final initialState = await fetchHabits();

    // Listen for widget updates
    _setupWidgetUpdateListener();

    // Listen to purchase state changes to update widget when Pro status changes
    ref.listen(purchaseProvider, (previous, next) async {
      if (previous?.value?.isSubscriptionActive != next.value?.isSubscriptionActive) {
        // Pro status changed, update widget with current habits
        final currentState = state;
        if (currentState is AsyncData<HomeState>) {
          LogHelper.shared.debugPrint('🔓 Pro status changed, updating widget...');
          await WidgetSyncService().updateWidgetData(currentState.value.habits);
        }
      }
    });

    return initialState;
  }

  /// Setup listener for widget completion updates
  void _setupWidgetUpdateListener() {
    _widgetUpdateSubscription = WidgetSyncService().widgetUpdates.listen(
      (update) async {
        LogHelper.shared.debugPrint('🔄 Received widget update: ${update['habitId']}');
        await _handleWidgetUpdate(update);
      },
      onError: (error) {
        LogHelper.shared.debugPrint('❌ Widget update stream error: $error');
      },
    );
  }

  /// Handle widget completion update
  Future<void> _handleWidgetUpdate(Map<String, dynamic> update) async {
    try {
      final habitId = update['habitId'] as String;

      LogHelper.shared.debugPrint('🔄 Processing widget update for habit: $habitId');

      // Refresh habits to get the latest state
      await refreshHabits();

      LogHelper.shared.debugPrint('✅ Widget update processed for habit: $habitId');
    } catch (e) {
      LogHelper.shared.debugPrint('❌ Error handling widget update: $e');
    }
  }

  /// Clean up resources
  void dispose() {
    _widgetUpdateSubscription?.cancel();
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
    final homeStart = DateTime.now();
    LogHelper.shared.debugPrint('🏠 [PERF] Starting adjustHabitCompletion at ${homeStart.millisecondsSinceEpoch}');

    // Normalize date and fetch current state
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final dateKey = normalizedDate.toIso8601String();
    final currentState = state;
    if (currentState is! AsyncData<HomeState>) return;

    final currentHabits = List<Habit>.from(currentState.value.habits);
    final habitIndex = currentHabits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) throw Exception('Habit not found');

    final habit = currentHabits[habitIndex];
    final target = habit.dailyTarget <= 0 ? 1 : habit.dailyTarget;

    // Find existing entry using optimized lookup
    final updatedCompletions = Map<String, CompletionEntry>.from(habit.completions);
    String? existingKey;
    CompletionEntry? existingEntry;

    // Try direct key lookup first (most efficient)
    final directEntry = updatedCompletions[dateKey];
    if (directEntry != null && directEntry.date.normalized.isSameDayWith(normalizedDate)) {
      existingKey = dateKey;
      existingEntry = directEntry;
    } else {
      // Fallback to linear search for legacy data
      for (final entry in updatedCompletions.entries) {
        if (entry.value.date.normalized.isSameDayWith(normalizedDate)) {
          existingKey = entry.key;
          existingEntry = entry.value;
          break;
        }
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
      rewardRating: existingEntry?.rewardRating, // Preserve reward rating when updating count
    );
    updatedCompletions[dateKey] = updatedEntry;

    // Optimistic state
    currentHabits[habitIndex] = habit.copyWith(completions: updatedCompletions);
    state = AsyncData(HomeState(habits: currentHabits));

    // Persist via service using increment/decrement semantics
    final persistStart = DateTime.now();
    await AsyncValue.guard(() async {
      final completion = CompletionEntry(id: dateKey, date: normalizedDate, isCompleted: increment);
      await habitService.updateHabitCompletionStatus(habitId, completion);
    });
    final persistEnd = DateTime.now();
    LogHelper.shared.debugPrint('💾 [PERF] Habit service persist completed in ${persistEnd.difference(persistStart).inMilliseconds}ms');

    // Refresh formation statistics after completion update
    final formationStart = DateTime.now();
    await ref.read(probabilityProvider.notifier).refreshFormationStatistics();
    final formationEnd = DateTime.now();
    LogHelper.shared.debugPrint('📊 [PERF] Formation provider refresh completed in ${formationEnd.difference(formationStart).inMilliseconds}ms');

    // Update widget data (debounced in WidgetSyncService)
    final widgetStart = DateTime.now();
    await WidgetSyncService().updateWidgetData(currentHabits);
    final widgetEnd = DateTime.now();
    LogHelper.shared.debugPrint('📱 [PERF] Widget sync completed in ${widgetEnd.difference(widgetStart).inMilliseconds}ms');

    final homeEnd = DateTime.now();
    LogHelper.shared.debugPrint('✅ [PERF] adjustHabitCompletion total time: ${homeEnd.difference(homeStart).inMilliseconds}ms');
  }

  /// Creates a new habit
  Future<void> createHabit(Habit habit) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await habitService.createHabit(habit);
      final newState = await fetchHabits();

      // Update widget data
      await WidgetSyncService().updateWidgetData(newState.habits);

      return newState;
    });
  }

  /// Updates an existing habit
  Future<void> updateHabit(Habit habit) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await habitService.updateHabit(habit);
      final newState = await fetchHabits();

      // Update widget data
      await WidgetSyncService().updateWidgetData(newState.habits);

      return newState;
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
      final newState = await fetchHabits();

      // Update widget data
      await WidgetSyncService().updateWidgetData(newState.habits);

      return newState;
    });
  }

  /// Refreshes the habits list from the service and updates the state
  Future<void> refreshHabits() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final newState = await fetchHabits();

      // Update widget data
      await WidgetSyncService().updateWidgetData(newState.habits);

      return newState;
    });
  }

  /// Force refresh widget data (for debugging)
  Future<void> forceRefreshWidgetData() async {
    try {
      final currentState = state;
      if (currentState is AsyncData<HomeState>) {
        await WidgetSyncService().updateWidgetData(currentState.value.habits);
        LogHelper.shared.debugPrint('🔄 Force refreshed widget data with ${currentState.value.habits.length} habits');
      }
    } catch (e) {
      LogHelper.shared.debugPrint('❌ Error force refreshing widget data: $e');
    }
  }

  /// Check for widget updates manually (for debugging)
  Future<void> checkForWidgetUpdates() async {
    try {
      LogHelper.shared.debugPrint('🔍 Manually checking for widget updates...');
      await WidgetSyncService().checkForWidgetUpdates();
    } catch (e) {
      LogHelper.shared.debugPrint('❌ Error checking for widget updates: $e');
    }
  }

  /// Force widget data refresh and timeline reload (for debugging)
  Future<void> forceWidgetRefresh() async {
    try {
      final currentState = state;
      if (currentState is AsyncData<HomeState>) {
        LogHelper.shared.debugPrint('🔄 Force refreshing widget data and timelines...');
        await WidgetSyncService().updateWidgetData(currentState.value.habits);
        LogHelper.shared.debugPrint('✅ Widget refresh completed');
      }
    } catch (e) {
      LogHelper.shared.debugPrint('❌ Error force refreshing widget: $e');
    }
  }
}
