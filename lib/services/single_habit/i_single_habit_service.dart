import '../../models/models.dart';

abstract class IHabitService {
  Future<void> addData(Habit habit);
  Future<List<Habit>> getAllHabits();

  Future<void> updateHabit(Habit habit);
  Future<void> deleteHabit(dynamic key);
}
