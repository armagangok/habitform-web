import '../../core/constants/debug_constants.dart';
import '../../models/completion_entry/completion_entry.dart';
import '../../models/habit/habit_model.dart';
import '../../models/habit/habit_summary.dart';
import 'local_habit_service.dart';
import 'mock_habit_service.dart';

// Use MockHabitService when in debug mode, otherwise use LocalHabitService
final HabitService habitService = KDebug.mockHabitServiceDebugMode ? MockHabitService() : LocalHabitService.instance;

abstract class HabitService {
  // Get all habits (both active and archived)
  Future<List<Habit>> getAllHabits();

  // Get active habits
  Future<List<Habit>> getHabits();

  // Get habit summaries (lightweight data for main page)
  Future<List<HabitSummary>> getHabitSummaries();

  // Get archived habits
  Future<List<Habit>> getArchivedHabits();

  // Get a specific habit by ID
  Future<Habit?> getHabit(String habitId);

  // Create a new habit
  Future<void> createHabit(Habit habit);

  // Update an existing habit. When [skipRemoteSync] is true, Hive/widget update runs but Firestore is not called (e.g. canvas debounce).
  Future<void> updateHabit(Habit habit, {bool skipRemoteSync = false});

  // Mark habit as complete/incomplete
  Future<void> updateHabitCompletionStatus(String habitId, CompletionEntry completion);

  // Delete a habit (soft delete)
  Future<void> deleteHabit(String habitId);

  // Archive a habit
  Future<void> archiveHabit(Habit habit);

  // Unarchive a habit
  Future<void> unarchiveHabit(String habitId);

  // Permanently delete a habit
  Future<void> permanentlyDeleteHabit(String habitId);

  // Update an archived habit
  Future<void> updateArchivedHabit(Habit habit);

  // Sync any pending habits to remote storage
  Future<void> syncPendingHabits();

  /// Pulls habits from Firestore, merges with local using conflict resolution, and saves to Hive.
  /// Call this when user logs in to sync remote data to local storage.
  Future<void> syncFromRemote();
}
