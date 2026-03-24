import 'package:hive_flutter/hive_flutter.dart';

import '../../core/core.dart';
import '../../features/reminder/service/reminder_service.dart';
import '../../models/completion_entry/completion_entry.dart';
import '../../models/habit/habit_model.dart';
import '../../models/habit/habit_status.dart';
import '../../models/habit/habit_summary.dart';
import '../../models/sync_status.dart';
import '../sync_service.dart';
import '../widget_service.dart';
import 'habit_service_interface.dart';

class LocalHabitService extends HabitService {
  LocalHabitService._();
  static final LocalHabitService _instance = LocalHabitService._();
  static LocalHabitService get instance => _instance;

  final HiveHelper _hiveHelper = HiveHelper.shared;
  final WidgetService _widgetService = WidgetService();
  final SyncService _syncService = SyncService();

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

  // Get habit summaries (lightweight data for main page)
  @override
  Future<List<HabitSummary>> getHabitSummaries() async {
    LogHelper.shared.debugPrint('Fetching habit summaries from local storage');
    final habits = await _hiveHelper.getAll<Habit>(HiveBoxes.habitBox);
    final activeHabits = habits.where((habit) => habit.status == HabitStatus.active).toList();

    final today = DateTime.now().normalized;
    final summaries = <HabitSummary>[];

    for (final habit in activeHabits) {
      // Calculate streak once during load
      final streak = habit.calculateCurrentStreak();

      // Extract today's completion data
      final todayCount = habit.getCountForDate(today);
      final target = habit.dailyTarget <= 0 ? 1 : habit.dailyTarget;
      final todayIsCompleted = todayCount >= target;
      final todayCompletionUpdatedAt = habit.getCompletionEntryForDate(today)?.updatedAt;

      summaries.add(HabitSummary(
        id: habit.id,
        habitName: habit.habitName,
        emoji: habit.emoji,
        colorCode: habit.colorCode,
        dailyTarget: habit.dailyTarget,
        categoryIds: habit.categoryIds,
        completionTime: habit.completionTime,
        reminderTime: habit.reminderModel?.reminderTime,
        todayCount: todayCount,
        todayIsCompleted: todayIsCompleted,
        todayCompletionUpdatedAt: todayCompletionUpdatedAt,
        currentStreak: streak,
        constellationPosX: habit.constellationPosX,
        constellationPosY: habit.constellationPosY,
        linkedHabitIds: habit.linkedHabitIds,
      ),);
    }

    LogHelper.shared.debugPrint('Found ${summaries.length} habit summaries');
    return summaries;
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

  @override
  Future<void> createHabit(Habit habit) async {
    final updatedHabit = habit.copyWith(
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );

    await _hiveHelper.putData<Habit>(
      HiveBoxes.habitBox,
      updatedHabit.id,
      updatedHabit,
    );

    // Sync to Firestore in background
    _syncHabitInBackground(updatedHabit, HiveBoxes.habitBox);

    // Export to widget
    await _exportHabitsForWidget();
  }

  @override
  Future<void> updateHabit(Habit habit, {bool skipRemoteSync = false}) async {
    final updatedHabit = habit.copyWith(
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );

    await _hiveHelper.putData<Habit>(
      HiveBoxes.habitBox,
      updatedHabit.id,
      updatedHabit,
    );

    if (!skipRemoteSync) {
      _syncHabitInBackground(updatedHabit, HiveBoxes.habitBox);
    }

    // Export to widget
    await _exportHabitsForWidget();
  }

  // Update habit completion status
  @override
  Future<void> updateHabitCompletionStatus(String habitId, CompletionEntry completion) async {
    final serviceStart = DateTime.now();
    LogHelper.shared.debugPrint('💾 [PERF] Starting updateHabitCompletionStatus at ${serviceStart.millisecondsSinceEpoch}');

    // Get the habit
    final getHabitStart = DateTime.now();
    final habit = await getHabit(habitId);
    final getHabitEnd = DateTime.now();
    LogHelper.shared.debugPrint('📖 [PERF] getHabit completed in ${getHabitEnd.difference(getHabitStart).inMilliseconds}ms');

    if (habit == null) {
      LogHelper.shared.debugPrint('Habit not found: $habitId');
      return;
    }

    // Update completions with count semantics (supports multi-completions)
    final updatedCompletions = Map<String, CompletionEntry>.from(habit.completions);

    // Find any existing entry for the same date using optimized lookup
    final normalizedDate = completion.date.normalized;
    final dateKey = '${normalizedDate.year}-${normalizedDate.month}-${normalizedDate.day}';

    String? existingKey;
    CompletionEntry? existingEntry;

    // Try direct key lookup first (most efficient)
    final directEntry = updatedCompletions[dateKey];
    if (directEntry != null && directEntry.date.normalized.isSameDayWith(normalizedDate)) {
      existingKey = dateKey;
      existingEntry = directEntry;
    } else {
      // Fallback to linear search for legacy data
      for (var entry in updatedCompletions.entries) {
        if (entry.value.date.normalized.isSameDayWith(normalizedDate)) {
          existingKey = entry.key;
          existingEntry = entry.value;
          break;
        }
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
    // Preserve existing rewardRating if it exists
    final updatedEntry = CompletionEntry(
      id: completion.id,
      date: completion.date.normalized,
      // Only mark day completed when full target reached (affects streaks)
      isCompleted: newCount >= target,
      count: newCount,
      rewardRating: existingEntry?.rewardRating, // Preserve reward rating when updating count
      updatedAt: DateTime.now(),
    );
    updatedCompletions[updatedEntry.id] = updatedEntry;

    // Save updated habit
    final updateStart = DateTime.now();
    final updatedHabit = habit.copyWith(
      completions: updatedCompletions,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );

    await _hiveHelper.putData<Habit>(
      HiveBoxes.habitBox,
      updatedHabit.id,
      updatedHabit,
    );

    // Sync only the touched completion day to Firestore (not the whole habit document)
    final removeKey =
        existingKey != null && existingKey != updatedEntry.id ? existingKey : null;
    _syncCompletionPatchInBackground(
      habit: updatedHabit,
      completionMapKey: updatedEntry.id,
      entryForRemote: updatedEntry.copyWith(syncStatus: SyncStatus.synced),
      removeCompletionKeyIfDifferent: removeKey,
      boxName: HiveBoxes.habitBox,
    );

    final updateEnd = DateTime.now();
    LogHelper.shared.debugPrint('💾 [PERF] updateHabit completed in ${updateEnd.difference(updateStart).inMilliseconds}ms');

    final serviceEnd = DateTime.now();
    LogHelper.shared.debugPrint('✅ [PERF] updateHabitCompletionStatus total time: ${serviceEnd.difference(serviceStart).inMilliseconds}ms');
  }

  // Delete a habit (soft delete)
  @override
  Future<void> deleteHabit(String habitId) async {
    final habit = _hiveHelper.getData<Habit>(HiveBoxes.habitBox, habitId);
    if (habit != null) {
      final updatedHabit = habit.copyWith(
        status: HabitStatus.archived,
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
      );
      await _hiveHelper.putData<Habit>(
        HiveBoxes.habitBox,
        habitId,
        updatedHabit,
      );

      // Sync to Firestore in background
      _syncHabitInBackground(updatedHabit, HiveBoxes.habitBox);
    }
  }

  Future<void> _syncHabitInBackground(Habit habit, String boxName) async {
    try {
      await _syncService.syncHabit(habit);
      await _hiveHelper.putData<Habit>(
        boxName,
        habit.id,
        habit.copyWith(syncStatus: SyncStatus.synced),
      );
    } catch (e, stack) {
      LogHelper.shared.debugPrint('Sync failed for habit ${habit.id}: $e\n$stack');
    }
  }

  /// Writes a single completion entry to Firestore; falls back to full [syncHabit] on failure.
  Future<void> _syncCompletionPatchInBackground({
    required Habit habit,
    required String completionMapKey,
    required CompletionEntry entryForRemote,
    String? removeCompletionKeyIfDifferent,
    required String boxName,
  }) async {
    try {
      await _syncService.patchHabitCompletion(
        habitId: habit.id,
        completionMapKey: completionMapKey,
        entry: entryForRemote,
        removeCompletionKeyIfDifferent: removeCompletionKeyIfDifferent,
      );
      await _hiveHelper.putData<Habit>(
        boxName,
        habit.id,
        habit.copyWith(syncStatus: SyncStatus.synced),
      );
    } catch (e, stack) {
      LogHelper.shared.debugPrint('Completion patch sync failed for habit ${habit.id}: $e\n$stack');
      try {
        await _syncService.syncHabit(habit);
        await _hiveHelper.putData<Habit>(
          boxName,
          habit.id,
          habit.copyWith(syncStatus: SyncStatus.synced),
        );
      } catch (e2, stack2) {
        LogHelper.shared.debugPrint('Fallback full sync failed for habit ${habit.id}: $e2\n$stack2');
      }
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
    final archivedHabit = habit.status == HabitStatus.archived
        ? habit.copyWith(
            updatedAt: DateTime.now(),
            syncStatus: SyncStatus.pending,
          )
        : habit.copyWith(
            status: HabitStatus.archived,
            archiveDate: DateTime.now(),
            updatedAt: DateTime.now(),
            syncStatus: SyncStatus.pending,
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

    // Sync to Firestore in background
    _syncHabitInBackground(archivedHabit, HiveBoxes.archivedHabitBox);

    LogHelper.shared.debugPrint('💾 HABIT SERVICE: Habit archived successfully: ${habit.id}');
  }

  // Unarchive a habit
  @override
  Future<void> unarchiveHabit(String habitId) async {
    LogHelper.shared.debugPrint('Unarchiving habit: $habitId');

    final archivedHabit = _hiveHelper.getData<Habit>(HiveBoxes.archivedHabitBox, habitId);
    if (archivedHabit != null) {
      // Set habit to active
      final activeHabit = archivedHabit.copyWith(
        status: HabitStatus.active,
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
      );

      // Add to active habits
      await _hiveHelper.putData<Habit>(HiveBoxes.habitBox, habitId, activeHabit);

      // Remove from archived habits
      await _hiveHelper.deleteData<Habit>(HiveBoxes.archivedHabitBox, habitId);

      // Sync to Firestore in background
      _syncHabitInBackground(activeHabit, HiveBoxes.habitBox);

      LogHelper.shared.debugPrint('Habit unarchived successfully: $habitId');
    }
  }

  @override
  Future<void> permanentlyDeleteHabit(String habitId) async {
    LogHelper.shared.debugPrint('Permanently deleting habit: $habitId');
    await _hiveHelper.deleteData<Habit>(HiveBoxes.archivedHabitBox, habitId);

    // Also delete from Firestore
    _syncService.deleteRemoteHabit(habitId);
  }

  // Update an archived habit
  @override
  Future<void> updateArchivedHabit(Habit habit) async {
    LogHelper.shared.debugPrint('Updating archived habit: ${habit.id}');

    // Ensure habit is archived
    final archivedHabit = habit.status == HabitStatus.archived
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

  // Helper method to export habits for widget
  Future<void> _exportHabitsForWidget() async {
    try {
      final habits = await getHabits();
      await _widgetService.exportHabitsForWidget(habits);
    } catch (e) {
      LogHelper.shared.debugPrint('Error exporting habits for widget: $e');
    }
  }

  /// Migrates existing habits to set completionTime from reminderTime if available
  /// This ensures backward compatibility for users who already have habits with reminders
  Future<void> migrateCompletionTimeFromReminders() async {
    try {
      LogHelper.shared.debugPrint('🔄 Starting completionTime migration...');

      // Get all habits (active and archived)
      final allHabits = await getAllHabits();
      int migratedCount = 0;

      for (final habit in allHabits) {
        // Skip if habit already has completionTime
        if (habit.completionTime != null) {
          continue;
        }

        // Check if habit has reminderModel with a time
        if (habit.reminderModel != null) {
          DateTime? timeToMigrate;

          // Try to get time from single reminder
          if (habit.reminderModel!.hasSingleReminder && habit.reminderModel!.reminderTime != null) {
            timeToMigrate = habit.reminderModel!.reminderTime;
          }
          // Or get first time from multiple reminders
          else if (habit.reminderModel!.hasMultipleReminders) {
            final times = habit.reminderModel!.allReminderTimes;
            if (times.isNotEmpty) {
              timeToMigrate = times.first;
            }
          }

          // If we found a time to migrate, update the habit
          if (timeToMigrate != null) {
            final updatedHabit = habit.copyWith(completionTime: timeToMigrate);

            // Save based on habit status
            if (habit.status == HabitStatus.active) {
              await _hiveHelper.putData<Habit>(HiveBoxes.habitBox, habit.id, updatedHabit);
            } else {
              await _hiveHelper.putData<Habit>(HiveBoxes.archivedHabitBox, habit.id, updatedHabit);
            }

            migratedCount++;
            LogHelper.shared.debugPrint('✅ Migrated completionTime for habit: ${habit.habitName} (${timeToMigrate.toHHMM()})');
          }
        }
      }

      LogHelper.shared.debugPrint('✅ CompletionTime migration completed. Migrated $migratedCount habit(s).');

      // Export updated habits to widget
      await _exportHabitsForWidget();
    } catch (e, stackTrace) {
      LogHelper.shared.errorPrint('❌ Error during completionTime migration: $e');
      LogHelper.shared.errorPrint('Stack trace: $stackTrace');
    }
  }

  @override
  Future<void> syncPendingHabits() async {
    LogHelper.shared.debugPrint('🔄 Starting sync of pending habits...');

    // Get all habits (active and archived)
    final allHabits = await getAllHabits();

    // Filter habits that need syncing
    final pendingHabits = allHabits.where((habit) => habit.syncStatus == SyncStatus.pending).toList();

    LogHelper.shared.debugPrint('🔄 Found ${pendingHabits.length} pending habits to sync');

    int successCount = 0;
    for (final habit in pendingHabits) {
      try {
        await _syncService.syncHabit(habit);

        // Update local status to synced
        final updatedHabit = habit.copyWith(syncStatus: SyncStatus.synced);
        if (updatedHabit.status == HabitStatus.active) {
          await _hiveHelper.putData<Habit>(HiveBoxes.habitBox, habit.id, updatedHabit);
        } else {
          await _hiveHelper.putData<Habit>(HiveBoxes.archivedHabitBox, habit.id, updatedHabit);
        }

        successCount++;
        LogHelper.shared.debugPrint('✅ Synced pending habit: ${habit.id}');
      } catch (e) {
        LogHelper.shared.debugPrint('❌ Failed to sync pending habit ${habit.id}: $e');
      }
    }

    LogHelper.shared.debugPrint('🔄 Finished syncing pending habits: $successCount successful, ${pendingHabits.length - successCount} failed.');
  }

  @override
  Future<void> syncFromRemote() async {
    try {
      LogHelper.shared.debugPrint('🔄 syncFromRemote: Pulling habits from Firestore...');

      final remoteHabits = await _syncService.fetchRemoteHabits();
      if (remoteHabits.isEmpty) {
        LogHelper.shared.debugPrint('🔄 syncFromRemote: No remote habits, syncing pending to remote.');
        await syncPendingHabits();
        return;
      }

      final localActive = await getHabits();
      final localArchived = await getArchivedHabits();
      final localMap = <String, Habit>{
        for (final h in [...localActive, ...localArchived]) h.id: h,
      };
      final remoteIds = remoteHabits.map((h) => h.id).toSet();

      final merged = <String, Habit>{};

      for (final remote in remoteHabits) {
        final local = localMap[remote.id];
        final resolved = local != null ? _syncService.resolveConflict(local, remote) : remote.copyWith(syncStatus: SyncStatus.synced);
        merged[resolved.id] = resolved;
      }

      for (final local in localMap.values) {
        if (!remoteIds.contains(local.id)) {
          merged[local.id] = local;
        }
      }

      final activeHabits = merged.values.where((h) => h.status == HabitStatus.active).toList();
      final archivedHabits = merged.values.where((h) => h.status == HabitStatus.archived).toList();

      await _hiveHelper.clearBox<Habit>(HiveBoxes.habitBox);
      await _hiveHelper.clearBox<Habit>(HiveBoxes.archivedHabitBox);

      for (final habit in activeHabits) {
        await _hiveHelper.putData<Habit>(HiveBoxes.habitBox, habit.id, habit);
      }
      for (final habit in archivedHabits) {
        await _hiveHelper.putData<Habit>(HiveBoxes.archivedHabitBox, habit.id, habit);
      }

      await syncPendingHabits();
      await _exportHabitsForWidget();

      LogHelper.shared.debugPrint('✅ syncFromRemote: Merged ${merged.length} habits from Firestore.');
    } catch (e, stack) {
      LogHelper.shared.debugPrint('❌ syncFromRemote failed: $e\n$stack');
    }
  }
}
