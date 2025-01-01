import 'package:habitrise/services/single_habit/i_single_habit_service.dart';

import '../../core/helpers/unique_id/unique_id.dart';
import '../../models/single_habit/habit_model.dart';

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
  Future<int> updateHabit(Habit habit) {
    throw UnimplementedError();
  }

  @override
  Future<void> addData(Habit habit) async {}
}
