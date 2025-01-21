import 'dart:math';

import '../../core/core.dart';
import '../../features/reminder/models/days/days_enum.dart';
import '../../features/reminder/models/reminder/reminder_model.dart';
import '../../models/habit/habit_model.dart';
import 'i_habit_service.dart';

List<Habit> _mockDatabase = [
  Habit(
    id: UuidHelper.uid,
    habitName: "Healthy Breakfast",
    habitDescription: "Take 230 clean calory from a healthy breakfast",
    emoji: "🍳",
    colorCode: Colors.red.value,
    completionDates: List.generate(
      90,
      (index) {
        final generate = Random().nextBool();
        return generate ? DateTime.now().subtract(Duration(days: index)) : DateTime.now().subtract(Duration(days: 500));
      },
    ),
    reminderModel: ReminderModel(id: UuidHelper.uidInt, days: Days.values, reminderTime: DateTime(2025, 1, 20, 7, 10)),
  ),
  Habit(
    id: UuidHelper.uid,
    habitName: "Running",
    habitDescription: "Run three times in a week",
    emoji: "🏃‍♂️",
    colorCode: Colors.green.value,
    completionDates: List.generate(
      90,
      (index) {
        final generate = Random().nextBool();
        return generate ? DateTime.now().subtract(Duration(days: index)) : DateTime.now().subtract(Duration(days: 500));
      },
    ),
    reminderModel: ReminderModel(id: UuidHelper.uidInt, days: Days.values, reminderTime: DateTime(2025, 1, 20, 7, 10)),
  ),
  Habit(
    id: UuidHelper.uid,
    habitName: "Side Hustle",
    habitDescription: "Work on HabitRise app development",
    emoji: "💰",
    colorCode: Colors.orange.value,
    completionDates: List.generate(
      90,
      (index) {
        final generate = Random().nextBool();
        return generate ? DateTime.now().subtract(Duration(days: index)) : DateTime.now().subtract(Duration(days: 500));
      },
    ),
    reminderModel: ReminderModel(id: UuidHelper.uidInt, days: Days.values, reminderTime: DateTime(2025, 1, 20, 7, 10)),
  ),
  Habit(
    id: UuidHelper.uid,
    habitName: "Brush Teeth",
    habitDescription: "Brush your teeth before sleeping",
    emoji: "🪥",
    colorCode: Colors.cyan.value,
    completionDates: List.generate(
      90,
      (index) {
        final generate = Random(1).nextBool();
        return generate ? DateTime.now().subtract(Duration(days: index)) : DateTime.now().subtract(Duration(days: 500));
      },
    ),
    reminderModel: ReminderModel(
      id: UuidHelper.uidInt,
      days: Days.values,
      reminderTime: DateTime(2025, 1, 20, 22, 30),
    ),
  ),
  Habit(
    id: UuidHelper.uid,
    habitName: "English Speaking Practise",
    habitDescription: "30 minutes English practise, use the vocabulary you learned today",
    emoji: "🌍",
    colorCode: Colors.redAccent.value,
    completionDates: List.generate(
      90,
      (index) {
        final generate = Random(1).nextBool();
        return generate ? DateTime.now().subtract(Duration(days: index)) : DateTime.now().subtract(Duration(days: 500));
      },
    ),
    reminderModel: ReminderModel(
      id: UuidHelper.uidInt,
      days: Days.values,
      reminderTime: DateTime(2025, 1, 20, 20),
    ),
  ),
];

class MockHabitService extends IHabitService {
  @override
  Future<void> deleteHabit(dynamic key) async {}

  @override
  Future<List<Habit>> getAllHabits() async {
    await Future.delayed(Duration(milliseconds: 250));
    return _mockDatabase;
  }

  @override
  Future<int> updateHabit(Habit habit) {
    throw UnimplementedError();
  }

  @override
  Future<void> addData(Habit habit) async {}
}
