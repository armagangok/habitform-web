import '../../../models/models.dart';

final chainedHabitMockData = [
  ChainedHabit(
    chainName: "Morning Habits",
    firstHabit: Habit(
      id: "1",
      habitName: "Drink Water",
      icon: "💦",
    ),
    completionDates: [
      DateTime.now(),
      DateTime.now().subtract(Duration(days: 1)),
      DateTime.now().subtract(Duration(days: 2)),
      DateTime.now().subtract(Duration(days: 3)),
    ],
    mainHabit: Habit(
      id: "2",
      habitName: "Morning Workout",
      icon: "🏋",
    ),
    secondHabit: Habit(
      id: "3",
      icon: "📚",
      habitName: "Read Book",
    ),
  ),
  ChainedHabit(
    chainName: "Evening Habits",
    completionDates: [
      DateTime.now(),
      DateTime.now().subtract(Duration(days: 1)),
      DateTime.now().subtract(Duration(days: 2)),
      DateTime.now().subtract(Duration(days: 3)),
    ],
    firstHabit: Habit(
      id: "4",
      habitName: "Dinner",
      icon: "🍽️",
    ),
    mainHabit: Habit(
      id: "5",
      habitName: "Relaxation",
      icon: "🧘🏼",
    ),
    secondHabit: Habit(
      id: "6",
      habitName: "Night Walk",
      icon: "🚶🏻‍♂️",
    ),
  ),
  ChainedHabit(
    completionDates: [
      DateTime.now(),
      DateTime.now().subtract(Duration(days: 1)),
      DateTime.now().subtract(Duration(days: 2)),
      DateTime.now().subtract(Duration(days: 3)),
    ],
    chainName: "Night Habits",
    firstHabit: Habit(
      id: "7",
      icon: "🪥",
      habitName: "Prepare for Bed",
    ),
    mainHabit: Habit(
      id: "8",
      habitName: "Meditation",
      icon: "🧘🏼",
    ),
    secondHabit: Habit(
      id: "9",
      habitName: "It's time to sleep. Are you ready for it?",
      icon: "🛌",
    ),
  ),
  ChainedHabit(
    chainName: "Evening Habits",
    completionDates: [
      DateTime.now(),
      DateTime.now().subtract(Duration(days: 1)),
      DateTime.now().subtract(Duration(days: 2)),
      DateTime.now().subtract(Duration(days: 3)),
    ],
    firstHabit: Habit(
      id: "4",
      habitName: "Dinner",
    ),
    mainHabit: Habit(
      id: "5",
      habitName: "Relaxation",
    ),

    // secondHabit: Habit(
    //   id: "6",
    //   habitName: "Night Walk",
    //
    // ),
  ),
];
