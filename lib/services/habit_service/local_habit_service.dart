import 'package:hive_flutter/hive_flutter.dart';

import '../../core/core.dart';
import '../../features/reminder/service/reminder_service.dart';
import '../../models/completion_entry/completion_entry.dart';
import '../../models/habit/habit_extension.dart';
import '../../models/habit/habit_model.dart';
import '../../models/habit/habit_status.dart';
import 'habit_service_interface.dart';

class LocalHabitService extends HabitService {
  LocalHabitService._();
  static final LocalHabitService _instance = LocalHabitService._();
  static LocalHabitService get instance => _instance;

  final HiveHelper _hiveHelper = HiveHelper.shared;

  // Get all habits (both active and archived)
  @override
  Future<List<Habit>> getAllHabits() async {
    LogHelper.shared.debugPrint('Fetching all habits from local storage');
    final activeHabits = await getHabits();
    final archivedHabits = await getArchivedHabits();
    final allHabits = [...activeHabits, ...archivedHabits];
    LogHelper.shared.debugPrint('Found ${allHabits.length} total habits');
    return allHabits;
  }

  // Get all habits
  @override
  Future<List<Habit>> getHabits() async {
    LogHelper.shared.debugPrint('Fetching habits from local storage');
    final habits = await _hiveHelper.getAll<Habit>(HiveBoxes.habitBox);
    final activeHabits = habits.where((habit) => habit.status == HabitStatus.active).toList();
    LogHelper.shared.debugPrint('Found ${activeHabits.length} active habits');
    return activeHabits;
  }

  // Get archived habits
  @override
  Future<List<Habit>> getArchivedHabits() async {
    LogHelper.shared.debugPrint('Fetching archived habits from local storage');
    final box = await Hive.openBox<Habit>(HiveBoxes.archivedHabitBox);
    final habits = box.values.toList();
    LogHelper.shared.debugPrint('Found ${habits.length} archived habits');
    return habits;
  }

  // Get a specific habit by ID (checks both active and archived habits)
  @override
  Future<Habit?> getHabit(String habitId) async {
    LogHelper.shared.debugPrint('Fetching habit by ID: $habitId');

    // First check active habits
    final activeHabit = _hiveHelper.getData<Habit>(HiveBoxes.habitBox, habitId);
    if (activeHabit != null) {
      LogHelper.shared.debugPrint('Found active habit: $habitId');
      return activeHabit;
    }

    // Then check archived habits
    final archivedHabit = _hiveHelper.getData<Habit>(HiveBoxes.archivedHabitBox, habitId);
    if (archivedHabit != null) {
      LogHelper.shared.debugPrint('Found archived habit: $habitId');
      return archivedHabit;
    }

    LogHelper.shared.debugPrint('Habit not found: $habitId');
    return null;
  }

  // Create a new habit
  @override
  Future<void> createHabit(Habit habit) async {
    await _hiveHelper.putData<Habit>(
      HiveBoxes.habitBox,
      habit.id,
      habit.copyWith(),
    );
  }

  // Update an existing habit
  @override
  Future<void> updateHabit(Habit habit) async {
    await _hiveHelper.putData<Habit>(
      HiveBoxes.habitBox,
      habit.id,
      habit,
    );
  }

  // Update habit completion status
  @override
  Future<void> updateHabitCompletionStatus(String habitId, CompletionEntry completion) async {
    // Get the habit
    final habit = await getHabit(habitId);
    if (habit == null) {
      LogHelper.shared.debugPrint('Habit not found: $habitId');
      throw Exception('Habit not found');
    }

    // Update completions with count semantics (supports multi-completions)
    final updatedCompletions = Map<String, CompletionEntry>.from(habit.completions);

    // Find any existing entry for the same date
    String? existingKey;
    CompletionEntry? existingEntry;
    for (var entry in updatedCompletions.entries) {
      if (entry.value.date.normalized.isSameDayWith(completion.date.normalized)) {
        existingKey = entry.key;
        existingEntry = entry.value;
        break;
      }
    }

    // Determine new count based on desired action (completion.isCompleted acts as increment when true, decrement when false)
    int currentCount = existingEntry?.count ?? 0;
    int target = habit.dailyTarget <= 0 ? 1 : habit.dailyTarget;
    int newCount;
    if (completion.isCompleted) {
      newCount = (currentCount + 1) > target ? target : (currentCount + 1);
    } else {
      newCount = (currentCount - 1) < 0 ? 0 : (currentCount - 1);
    }

    // Remove existing entry if found (we will rewrite)
    if (existingKey != null) {
      updatedCompletions.remove(existingKey);
    }

    // Write back entry reflecting the new count and derived isCompleted
    final updatedEntry = CompletionEntry(
      id: completion.id,
      date: completion.date.normalized,
      // Only mark day completed when full target reached (affects streaks)
      isCompleted: newCount >= target,
      count: newCount,
    );
    updatedCompletions[updatedEntry.id] = updatedEntry;

    // Save updated habit
    final updatedHabit = habit.copyWith(completions: updatedCompletions);
    await updateHabit(updatedHabit);

    LogHelper.shared.debugPrint('Successfully updated completion status for habit: $habitId');
  }

  // Delete a habit (soft delete)
  @override
  Future<void> deleteHabit(String habitId) async {
    final habit = _hiveHelper.getData<Habit>(HiveBoxes.habitBox, habitId);
    if (habit != null) {
      await _hiveHelper.putData<Habit>(
        HiveBoxes.habitBox,
        habitId,
        habit.copyWith(
          status: HabitStatus.archived,
        ),
      );
    }
  }

  // Archive a habit
  @override
  Future<void> archiveHabit(Habit habit) async {
    LogHelper.shared.debugPrint('💾 HABIT SERVICE: archiveHabit called for habit: ${habit.habitName} (ID: ${habit.id})');

    LogHelper.shared.debugPrint('💾 Step 1: Checking reminder model');
    // Cancel all reminder notifications before archiving
    if (habit.reminderModel != null) {
      LogHelper.shared.debugPrint('💾 Habit has reminder model, cancelling notifications');
      await ReminderService.cancelAllReminderNotifications(habit.reminderModel);
      LogHelper.shared.debugPrint('💾 Cancelled notifications for archived habit: ${habit.id}');
    } else {
      LogHelper.shared.debugPrint('💾 Habit has NO reminder model');
    }

    LogHelper.shared.debugPrint('💾 Step 2: Creating archived habit object');
    // Set habit to archived if it's not already
    final archivedHabit = habit.isArchived
        ? habit
        : habit.copyWith(
            status: HabitStatus.archived,
            archiveDate: DateTime.now(),
          );
    LogHelper.shared.debugPrint('💾 Archived habit created with status: ${archivedHabit.status}');

    LogHelper.shared.debugPrint('💾 Step 3: Removing from active habits box');
    // Remove from active habits
    await _hiveHelper.deleteData<Habit>(HiveBoxes.habitBox, habit.id);
    LogHelper.shared.debugPrint('💾 Removed from active habits box');

    LogHelper.shared.debugPrint('💾 Step 4: Adding to archived habits box');
    // Add to archived habits
    await _hiveHelper.putData<Habit>(HiveBoxes.archivedHabitBox, habit.id, archivedHabit);
    LogHelper.shared.debugPrint('💾 Added to archived habits box');

    LogHelper.shared.debugPrint('💾 HABIT SERVICE: Habit archived successfully: ${habit.id}');
  }

  // Unarchive a habit
  @override
  Future<void> unarchiveHabit(String habitId) async {
    LogHelper.shared.debugPrint('Unarchiving habit: $habitId');

    final archivedHabit = _hiveHelper.getData<Habit>(HiveBoxes.archivedHabitBox, habitId);
    if (archivedHabit != null) {
      // Set habit to active
      final activeHabit = archivedHabit.copyWith(status: HabitStatus.active);

      // Add to active habits
      await _hiveHelper.putData<Habit>(HiveBoxes.habitBox, habitId, activeHabit);

      // Remove from archived habits
      await _hiveHelper.deleteData<Habit>(HiveBoxes.archivedHabitBox, habitId);

      LogHelper.shared.debugPrint('Habit unarchived successfully: $habitId');
    }
  }

  // Permanently delete a habit
  @override
  Future<void> permanentlyDeleteHabit(String habitId) async {
    LogHelper.shared.debugPrint('Permanently deleting habit: $habitId');
    await _hiveHelper.deleteData<Habit>(HiveBoxes.archivedHabitBox, habitId);
  }

  // Update an archived habit
  @override
  Future<void> updateArchivedHabit(Habit habit) async {
    LogHelper.shared.debugPrint('Updating archived habit: ${habit.id}');

    // Ensure habit is archived
    final archivedHabit = habit.isArchived
        ? habit
        : habit.copyWith(
            status: HabitStatus.archived,
            archiveDate: habit.archiveDate ?? DateTime.now(),
          );

    // Remove from active habits if it exists there
    await _hiveHelper.deleteData<Habit>(HiveBoxes.habitBox, habit.id);

    // Update in archived habits
    await _hiveHelper.putData<Habit>(HiveBoxes.archivedHabitBox, habit.id, archivedHabit);

    LogHelper.shared.debugPrint('Archived habit updated successfully: ${habit.id}');
  }
}
