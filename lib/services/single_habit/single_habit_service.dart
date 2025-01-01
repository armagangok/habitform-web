import 'package:habitrise/core/helpers/hive/hive_helper.dart';
import 'package:habitrise/core/helpers/hive/hive_keys.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import 'i_single_habit_service.dart';

class SingleHabitService extends IHabitService {
  static final shared = SingleHabitService._();
  SingleHabitService._();

  @override
  Future<void> addData(Habit habit) async {
    await HiveHelper.shared.putData<Habit>(HiveBoxes.singleHabitBox, habit.id, habit);
  }

  @override
  Future<List<Habit>> getAllHabits() async {
    final data = await HiveHelper.shared.getAll<Habit>(HiveBoxes.singleHabitBox);

    LogHelper.shared.debugPrint('$data');

    return data;
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    await HiveHelper.shared.putData<Habit>(HiveBoxes.singleHabitBox, habit.id, habit);
  }

  @override
  Future<void> deleteHabit(dynamic key) async {
    await HiveHelper.shared.deleteData<Habit>(HiveBoxes.singleHabitBox, key);
  }
}
