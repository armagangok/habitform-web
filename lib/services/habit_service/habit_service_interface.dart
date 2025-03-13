import '../../models/completion_entry/completion_entry.dart';
import '../../models/habit/habit_model.dart';
import 'local_habit_service.dart';

// Use MockHabitService when in debug mode, otherwise use LocalHabitService
final HabitService habitService = LocalHabitService.instance;

abstract class HabitService {
  // Get all habits (both active and archived)
  Future<List<Habit>> getAllHabits();

  // Get active habits
  Future<List<Habit>> getHabits();

  // Get archived habits
  Future<List<Habit>> getArchivedHabits();

  // Get a specific habit by ID
  Future<Habit?> getHabit(String habitId);

  // Create a new habit
  Future<void> createHabit(Habit habit);

  // Update an existing habit
  Future<void> updateHabit(Habit habit);

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
}
