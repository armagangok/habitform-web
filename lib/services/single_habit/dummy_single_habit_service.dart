import 'package:habitrise/services/single_habit/i_single_habit_service.dart';

import '../../core/helpers/unique_id/unique_id.dart';
import '../../models/habit_model.dart';

class DummyHabitService extends IHabitService {
  @override
  Future<int> deleteHabit(dynamic key) {
    // TODO: implement deleteHabit
    throw UnimplementedError();
  }

  @override
  Future<List<Habit>> getAllHabits() async {
    await Future.delayed(Duration(milliseconds: 250));
    return [
      Habit(
        id: UuidHelper.uid,
        habitName: "Wake up fella!",
        icon: "🛌",
      ),
      Habit(
        id: UuidHelper.uid,
        habitName: "Watch your face",
        icon: "🧼",
      ),
      Habit(
        id: UuidHelper.uid,
        habitName: "Drink some water",
        icon: "💧",
      ),
      Habit(
        id: UuidHelper.uid,
        habitName: "Make Your Bed",
        icon: "🛌",
      ),
    ];
  }

  @override
  Future<List<Habit>> getCompletedHabits() {
    // TODO: implement getCompletedHabits
    throw UnimplementedError();
  }

  @override
  Future<Habit?> getHabitById(String id) {
    // TODO: implement getHabitById
    throw UnimplementedError();
  }

  @override
  Future<List<Habit>> getHabitsByCompletionDate(DateTime date) {
    // TODO: implement getHabitsByCompletionDate
    throw UnimplementedError();
  }

  @override
  Future<int> addData(Habit habit) {
    // TODO: implement insertHabit
    throw UnimplementedError();
  }

  @override
  Future<void> markHabitAsCompleted(String id) {
    // TODO: implement markHabitAsCompleted
    throw UnimplementedError();
  }

  @override
  Future<void> resetDailyCompletion() {
    // TODO: implement resetDailyCompletion
    throw UnimplementedError();
  }

  @override
  Future<int> updateHabit(Habit habit) {
    // TODO: implement updateHabit
    throw UnimplementedError();
  }
}
