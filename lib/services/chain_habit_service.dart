import '../models/chained_habit_model.dart';
import '../models/habit_model.dart';

class ChainHabitService {
  final List<String> chainNames = ["Morning Routine", "Midday Routine", "Night Routine"];
  final List<String> habitNames = [
    "Time to Wake Up!",
    "Wash your face",
    "Drink some water",
    "Brush your teeth",
    "Stretch your body",
    "Prepare your breakfast",
    "Take a short walk",
    "Meditate for 5 minutes",
  ];

  Future<List<ChainedHabit>> fetchChainedHabits() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate network delay

    final chainedHabit = [
      ChainedHabit(
        chainName: "Morning Habits",
        firstHabit: Habit(
          id: "1",
          habitName: "Drink Water",
          icon: "💦",
          completeTime: DateTime(2024, 12, 25, 6, 30), // December 25, 2024, 06:30 AM
        ),
        mainHabit: Habit(
          id: "2",
          habitName: "Morning Workout",
          icon: "🏋",
          completeTime: DateTime(2024, 12, 25, 7, 0), // December 25, 2024, 07:00 AM
        ),
        secondHabit: Habit(
          id: "3",
          icon: "📚",
          habitName: "Read Book",
          completeTime: DateTime(2024, 12, 25, 8, 0), // December 25, 2024, 08:00 AM
        ),
      ),
      ChainedHabit(
        chainName: "Evening Habits",
        firstHabit: Habit(
          id: "4",
          habitName: "Dinner",
          icon: "🍽️",
          completeTime: DateTime(2024, 12, 25, 19, 0), // December 25, 2024, 07:00 PM
        ),
        mainHabit: Habit(
          id: "5",
          habitName: "Relaxation",
          icon: "🧘🏼",
          completeTime: DateTime(2024, 12, 25, 20, 0), // December 25, 2024, 08:00 PM
        ),
        secondHabit: Habit(
          id: "6",
          habitName: "Night Walk",
          icon: "🚶🏻‍♂️",
          completeTime: DateTime(2024, 12, 25, 21, 0), // December 25, 2024, 09:00 PM
        ),
      ),
      ChainedHabit(
        chainName: "Night Habits",
        firstHabit: Habit(
          id: "7",
          icon: "🪥",
          habitName: "Prepare for Bed",
          completeTime: DateTime(2024, 12, 25, 22, 0), // December 25, 2024, 10:00 PM
        ),
        mainHabit: Habit(
          id: "8",
          habitName: "Meditation",
          icon: "🧘🏼",
          completeTime: DateTime(2024, 12, 25, 22, 30), // December 25, 2024, 10:30 PM
        ),
        secondHabit: Habit(
          id: "9",
          habitName: "Sleep",
          icon: "😴🛌",
          completeTime: DateTime(2024, 12, 25, 23, 0), // December 25, 2024, 11:00 PM
        ),
      ),
      ChainedHabit(
        chainName: "Evening Habits",
        firstHabit: Habit(
          id: "4",
          habitName: "Dinner",
          completeTime: DateTime(2024, 12, 25, 19, 0), // December 25, 2024, 07:00 PM
        ),
        mainHabit: Habit(
          id: "5",
          habitName: "Relaxation",
          completeTime: DateTime(2024, 12, 25, 20, 0), // December 25, 2024, 08:00 PM
        ),
        // secondHabit: Habit(
        //   id: "6",
        //   habitName: "Night Walk",
        //   completeTime: DateTime(2024, 12, 25, 21, 0), // December 25, 2024, 09:00 PM
        // ),
      ),
    ];

    return chainedHabit;
  }
}
