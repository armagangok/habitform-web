import '../../models/models.dart';

abstract class IHabitService {
  Future<int> insertHabit(Habit habit);
  Future<List<Habit>> getAllHabits();
  Future<Habit?> getHabitById(String id);
  Future<int> updateHabit(Habit habit);
  Future<int> deleteHabit(String id);
  Future<void> markHabitAsCompleted(String id);
  Future<List<Habit>> getCompletedHabits();
  Future<void> resetDailyCompletion();
  Future<List<Habit>> getHabitsByCompletionDate(DateTime date);
}
