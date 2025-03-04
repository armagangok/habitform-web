import 'package:habitrise/models/habit/habit_extension.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/core.dart';
import '../models/completion_entry/completion_entry.dart';
import '../models/habit/habit_model.dart';
import '../models/habit/habit_status.dart';

class LocalHabitService {
  LocalHabitService._();
  static final LocalHabitService _instance = LocalHabitService._();
  static LocalHabitService get instance => _instance;

  final HiveHelper _hiveHelper = HiveHelper.shared;

  // Get all habits (both active and archived)
  Future<List<Habit>> getAllHabits() async {
    LogHelper.shared.debugPrint('Fetching all habits from local storage');
    final activeHabits = await getHabits();
    final archivedHabits = await getArchivedHabits();
    final allHabits = [...activeHabits, ...archivedHabits];
    LogHelper.shared.debugPrint('Found ${allHabits.length} total habits');
    return allHabits;
  }

  // Get all habits
  Future<List<Habit>> getHabits() async {
    LogHelper.shared.debugPrint('Fetching habits from local storage');
    final habits = await _hiveHelper.getAll<Habit>(HiveBoxes.habitBox);
    final activeHabits = habits.where((habit) => habit.status == HabitStatus.active).toList();
    LogHelper.shared.debugPrint('Found ${activeHabits.length} active habits');
    return activeHabits;
  }

  // Get archived habits
  Future<List<Habit>> getArchivedHabits() async {
    LogHelper.shared.debugPrint('Fetching archived habits from local storage');
    final box = await Hive.openBox<Habit>(HiveBoxes.archivedHabitBox);
    final habits = box.values.toList();
    LogHelper.shared.debugPrint('Found ${habits.length} archived habits');
    return habits;
  }

  // Get a specific habit by ID (checks both active and archived habits)
  Future<Habit?> getHabit(String habitId) async {
    LogHelper.shared.debugPrint('Fetching habit by ID: $habitId');

    // Önce aktif alışkanlıklar arasında ara
    final activeHabit = _hiveHelper.getData<Habit>(HiveBoxes.habitBox, habitId);
    if (activeHabit != null) {
      LogHelper.shared.debugPrint('Found active habit: $habitId');
      return activeHabit;
    }

    // Aktif alışkanlıklar arasında bulunamazsa, arşivlenmiş alışkanlıklar arasında ara
    final archivedHabit = _hiveHelper.getData<Habit>(HiveBoxes.archivedHabitBox, habitId);
    if (archivedHabit != null) {
      LogHelper.shared.debugPrint('Found archived habit: $habitId');
      return archivedHabit;
    }

    LogHelper.shared.debugPrint('Habit not found: $habitId');
    return null;
  }

  // Create a new habit
  Future<void> createHabit(Habit habit) async {
    await _hiveHelper.putData<Habit>(
      HiveBoxes.habitBox,
      habit.id,
      habit.copyWith(),
    );
  }

  // Update an existing habit
  Future<void> updateHabit(Habit habit) async {
    await _hiveHelper.putData<Habit>(
      HiveBoxes.habitBox,
      habit.id,
      habit,
    );
  }

  // Mark habit as complete/incomplete
  Future<void> updateHabitCompletionStatus(String habitId, CompletionEntry completion) async {
    // Tüm habit'leri al ve kontrol et
    final allHabits = await _hiveHelper.getAll<Habit>(HiveBoxes.habitBox);

    Habit? habit;
    habit = allHabits.firstWhere((h) => h.id == habitId);

    final updatedCompletions = Map<String, CompletionEntry>.from(habit.completions);
    updatedCompletions[completion.id] = completion;

    final updatedHabit = habit.copyWith(
      completions: updatedCompletions,
    );

    await _hiveHelper.putData<Habit>(HiveBoxes.habitBox, habitId, updatedHabit);
  }

  // Delete a habit (soft delete)
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
  Future<void> archiveHabit(Habit habit) async {
    LogHelper.shared.debugPrint('Starting archive process for habit: ${habit.id} - ${habit.habitName}');

    // Eğer habit zaten arşivlenmiş durumda değilse, arşivle
    final archivedHabit = habit.isArchived
        ? habit
        : habit.copyWith(
            status: HabitStatus.archived,
            archiveDate: DateTime.now(),
          );

    LogHelper.shared.debugPrint('Habit status after archive preparation: ${archivedHabit.status}, isArchived: ${archivedHabit.isArchived}');

    // Önce aktif habitler kutusundan kontrol et ve sil
    final existingActiveHabit = _hiveHelper.getData<Habit>(HiveBoxes.habitBox, habit.id);
    if (existingActiveHabit != null) {
      LogHelper.shared.debugPrint('Removing habit from active box: ${habit.id}');
      await _hiveHelper.deleteData<Habit>(HiveBoxes.habitBox, habit.id);
    }

    LogHelper.shared.debugPrint('Saving to archivedHabitBox...');
    await _hiveHelper.putData<Habit>(HiveBoxes.archivedHabitBox, habit.id, archivedHabit);
    LogHelper.shared.debugPrint('Successfully saved to archivedHabitBox');

    final verifyArchived = _hiveHelper.getData<Habit>(HiveBoxes.archivedHabitBox, habit.id);
    LogHelper.shared.debugPrint('Verification - Habit in archived box: ${verifyArchived != null}');
    if (verifyArchived != null) {
      LogHelper.shared.debugPrint('Archived habit details - status: ${verifyArchived.status}, archiveDate: ${verifyArchived.archiveDate}, isArchived: ${verifyArchived.isArchived}');
    }
  }

  // Unarchive a habit
  Future<void> unarchiveHabit(String habitId) async {
    LogHelper.shared.debugPrint('Unarchiving habit: $habitId');

    final archivedHabit = _hiveHelper.getData<Habit>(HiveBoxes.archivedHabitBox, habitId);
    if (archivedHabit != null) {
      // Alışkanlığı aktif duruma getir, ancak arşiv tarihini null yapma
      // Bu, senkronizasyon sırasında arşivden çıkarıldığını belirlemek için kullanılacak
      final activeHabit = archivedHabit.copyWith(
        status: HabitStatus.active,
      );

      LogHelper.shared.debugPrint('Moving habit from archived to active: $habitId');

      // Önce aktif habitler kutusuna ekle
      await _hiveHelper.putData<Habit>(HiveBoxes.habitBox, habitId, activeHabit);

      // Sonra arşiv kutusundan sil
      await _hiveHelper.deleteData<Habit>(HiveBoxes.archivedHabitBox, habitId);

      LogHelper.shared.debugPrint('Habit successfully moved from archive to active: $habitId');

      // Doğrulama
      final verifyActive = _hiveHelper.getData<Habit>(HiveBoxes.habitBox, habitId);
      final verifyArchived = _hiveHelper.getData<Habit>(HiveBoxes.archivedHabitBox, habitId);

      LogHelper.shared.debugPrint('Verification - Habit in active box: ${verifyActive != null}, in archived box: ${verifyArchived == null}');
    } else {
      LogHelper.shared.debugPrint('Habit not found in archive: $habitId');
    }
  }

  // Permanently delete a habit
  Future<void> permanentlyDeleteHabit(String habitId) async {
    LogHelper.shared.debugPrint('Permanently deleting habit: $habitId');

    final habit = _hiveHelper.getData<Habit>(HiveBoxes.archivedHabitBox, habitId);
    if (habit != null) {
      await _hiveHelper.deleteData<Habit>(HiveBoxes.archivedHabitBox, habitId);
    }
  }

  // Update an archived habit
  Future<void> updateArchivedHabit(Habit habit) async {
    LogHelper.shared.debugPrint('Updating archived habit: ${habit.id}');

    // Eğer habit arşivlenmiş değilse, arşivle
    final archivedHabit = habit.isArchived
        ? habit
        : habit.copyWith(
            status: HabitStatus.archived,
            archiveDate: habit.archiveDate ?? DateTime.now(),
          );

    LogHelper.shared.debugPrint('Habit status after update preparation: ${archivedHabit.status}, isArchived: ${archivedHabit.isArchived}');

    // Aktif habitler kutusunda olup olmadığını kontrol et
    final existingActiveHabit = _hiveHelper.getData<Habit>(HiveBoxes.habitBox, habit.id);
    if (existingActiveHabit != null) {
      LogHelper.shared.debugPrint('Habit found in active box, removing: ${habit.id}');
      await _hiveHelper.deleteData<Habit>(HiveBoxes.habitBox, habit.id);
    }

    await _hiveHelper.putData<Habit>(
      HiveBoxes.archivedHabitBox,
      habit.id,
      archivedHabit.copyWith(),
    );

    // Doğrulama
    final verifyArchived = _hiveHelper.getData<Habit>(HiveBoxes.archivedHabitBox, habit.id);
    if (verifyArchived != null) {
      LogHelper.shared.debugPrint('Verified archived habit: ${verifyArchived.id} - status: ${verifyArchived.status}, isArchived: ${verifyArchived.isArchived}');
    } else {
      LogHelper.shared.debugPrint('WARNING: Could not verify archived habit after update: ${habit.id}');
    }

    LogHelper.shared.debugPrint('Archived habit updated successfully: ${habit.id}');
  }

  Future<void> migrateHabitsToNewModel() async {
    LogHelper.shared.debugPrint('Starting habit migration process...');

    try {
      // Get all habits (both active and archived)
      final allHabits = await getAllHabits();

      for (final habit in allHabits) {
        if (habit.completionDates?.isNotEmpty ?? false) {
          LogHelper.shared.debugPrint('Migrating habit: ${habit.id}');

          // Convert old completion dates to new completion entries
          final newCompletions = habit.toCompletionEntry(habit.completionDates!);

          // Create updated habit with new model
          final updatedHabit = habit.toNewHabitModel(newCompletions);

          // Save the updated habit
          if (habit.isActive) {
            await updateHabit(updatedHabit);
          } else {
            await updateArchivedHabit(updatedHabit);
          }

          LogHelper.shared.debugPrint('Successfully migrated habit: ${habit.id}');
        }
      }

      LogHelper.shared.debugPrint('Habit migration completed successfully');
    } catch (e) {
      LogHelper.shared.debugPrint('Error during habit migration: $e');
      rethrow;
    }
  }

  /// Tüm alışkanlıkları temizler (aktif ve arşivlenmiş)
  Future<void> clearAllHabits() async {
    try {
      LogHelper.shared.debugPrint('Clearing all habits from local storage');

      // Aktif alışkanlıkları temizle
      await _hiveHelper.clearBox(HiveBoxes.habitBox);
      LogHelper.shared.debugPrint('Cleared active habits box');

      // Arşivlenmiş alışkanlıkları temizle
      await _hiveHelper.clearBox(HiveBoxes.archivedHabitBox);
      LogHelper.shared.debugPrint('Cleared archived habits box');

      LogHelper.shared.debugPrint('All habits cleared successfully from local storage');
    } catch (e) {
      LogHelper.shared.debugPrint('Error clearing habits from local storage: $e');
      rethrow;
    }
  }
}
