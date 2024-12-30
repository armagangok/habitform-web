import 'package:habitrise/services/single_habit/i_single_habit_service.dart';

import '../../core/helpers/unique_id/unique_id.dart';
import '../../models/habit_model.dart';

class DummyHabitService extends IHabitService {
  @override
  Future<int> deleteHabit(String id) {
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
        completeTime: DateTime(2024, 12, 21, 7, 15).toIso8601String(),
      ),
      Habit(
        id: UuidHelper.uid,
        habitName: "Watch your face",
        icon: "🧼",
        completeTime: DateTime.now().toIso8601String(),
      ),
      Habit(
        id: UuidHelper.uid,
        habitName: "Drink some water",
        icon: "💧",
        completeTime: DateTime.now()
            .add(
              Duration(minutes: 5),
            )
            .toIso8601String(),
      ),
      Habit(
        id: UuidHelper.uid,
        habitName: "Make Your Bed",
        icon: "🛌",
        completeTime: DateTime.now()
            .add(
              Duration(minutes: 10),
            )
            .toIso8601String(),
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
  Future<int> insertHabit(Habit habit) {
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
