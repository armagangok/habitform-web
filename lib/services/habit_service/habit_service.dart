import '../../core/core.dart';
import '../../models/models.dart';
import 'i_habit_service.dart';

class SingleHabitService extends IHabitService {
  @override
  Future<void> addData(Habit habit) async {
    LogHelper.shared.debugPrint('Adding habit: $habit');
    await HiveHelper.shared.putData<Habit>(HiveBoxes.habitBox, habit.id, habit);
  }

  @override
  Future<List<Habit>> getAllHabits() async {
    final data = await HiveHelper.shared.getAll<Habit>(HiveBoxes.habitBox);
    LogHelper.shared.debugPrint('Retrieved all habits: $data');
    return data;
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    LogHelper.shared.debugPrint('Updating habit: $habit');
    await HiveHelper.shared.putData<Habit>(HiveBoxes.habitBox, habit.id, habit);
    final updatedData = HiveHelper.shared.getData<Habit>(HiveBoxes.habitBox, habit.id);
    LogHelper.shared.debugPrint('Habit after update: $updatedData');
  }

  @override
  Future<void> deleteHabit(dynamic key) async {
    LogHelper.shared.debugPrint('Deleting habit with key: $key');
    await HiveHelper.shared.deleteData<Habit>(HiveBoxes.habitBox, key);
  }
}
