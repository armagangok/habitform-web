import '../../core/core.dart';
import '../../models/models.dart';
import 'i_habit_service.dart';


class SingleHabitService extends IHabitService {
  @override
  Future<void> addData(Habit habit) async {
    await HiveHelper.shared.putData<Habit>(HiveBoxes.habitBox, habit.id, habit);
  }

  @override
  Future<List<Habit>> getAllHabits() async {
    final data = await HiveHelper.shared.getAll<Habit>(HiveBoxes.habitBox);

    LogHelper.shared.debugPrint('$data');

    return data;
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    await HiveHelper.shared.putData<Habit>(HiveBoxes.habitBox, habit.id, habit);
  }

  @override
  Future<void> deleteHabit(dynamic key) async {
    await HiveHelper.shared.deleteData<Habit>(HiveBoxes.habitBox, key);
  }
}
