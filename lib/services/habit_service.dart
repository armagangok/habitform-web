import '../core/helpers/unique_id/unique_id.dart';
import '../models/habit_model.dart';

class HabitService {
  Future<List<Habit>> fetchHabits() async {
    await Future.delayed(Duration(seconds: 2));
    return [
      Habit(
        id: UuidHelper.uid,
        habitName: "Wake up fella!",
        icon: "🛌",
        completeTime: DateTime(2024, 12, 21, 7, 15),
      ),
      Habit(
        id: UuidHelper.uid,
        habitName: "Watch your face",
        icon: "🧼",
        completeTime: DateTime.now(),
      ),
      Habit(
        id: UuidHelper.uid,
        habitName: "Drink some water",
        icon: "💧",
        completeTime: DateTime.now().add(
          Duration(minutes: 5),
        ),
      ),
      Habit(
        id: UuidHelper.uid,
        habitName: "Make Your Bed",
        icon: "🛌",
        completeTime: DateTime.now().add(
          Duration(minutes: 10),
        ),
      ),
    ];
  }
}
