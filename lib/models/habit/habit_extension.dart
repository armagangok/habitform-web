import 'habit_model.dart';
import 'habit_status.dart';

extension EasyHabitStatus on Habit {
  bool get isActive => status == HabitStatus.active;
  bool get isArchived => status == HabitStatus.archived;
}
