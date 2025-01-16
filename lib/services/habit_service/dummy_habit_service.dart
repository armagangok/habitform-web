import '../../core/core.dart';
import '../../models/habit/habit_model.dart';
import 'i_habit_service.dart';

class MockHabitService extends IHabitService {
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
        habitDescription: "Some test description goes here",
        emoji: "🛌",
        colorCode: Colors.red.value,
      ),
      Habit(
        id: UuidHelper.uid,
        habitName: "Watch your face",
        habitDescription: "Some test description goes here",
        emoji: "🧼",
        colorCode: Colors.green.value,
      ),
      Habit(
        id: UuidHelper.uid,
        habitName: "Drink some water",
        habitDescription: "Some test description goes here",
        emoji: "💧",
        colorCode: Colors.orange.value,
      ),
      Habit(
        id: UuidHelper.uid,
        habitName: "Make Your Bed",
        habitDescription: "Some test description goes here",
        emoji: "🛌",
        colorCode: Colors.cyan.value,
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
