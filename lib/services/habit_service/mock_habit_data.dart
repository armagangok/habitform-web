import 'package:flutter/material.dart';

import '../../features/reminder/models/days/days_enum.dart';
import '../../features/reminder/models/reminder/reminder_model.dart';
import '../../models/completion_entry/completion_entry.dart';
import '../../models/habit/habit_model.dart';
import '../../models/habit/habit_status.dart';

/// Mock habit data for testing and development purposes
class MockHabitData {
  static final List<Habit> habits = [
    // 1. Wake up early habit
    Habit(
      id: "habit-wakeup-1",
      habitName: "WakeUp Early",
      habitDescription: "Wake up at 6:00 AM to start the day with more time and energy",
      emoji: "⏰",
      colorCode: Colors.blue.shade400.value,
      reminderModel: ReminderModel(
        id: 1001,
        reminderTime: DateTime(2023, 1, 1, 5, 45),
        days: [Days.mon, Days.tue, Days.wed, Days.thu, Days.fri],
      ),
      completions: _generateRandomCompletions(),
      status: HabitStatus.active,
    ),

    // // 2. Meditation habit
    // Habit(
    //   id: "habit-meditation-1",
    //   habitName: "Meditate",
    //   habitDescription: "Practice mindfulness meditation for 10 minutes",
    //   emoji: "🧘",
    //   colorCode: Colors.deepPurple.shade400.value,
    //   reminderModel: ReminderModel(
    //     id: 1002,
    //     reminderTime: DateTime(2023, 1, 1, 6, 15),
    //     days: [Days.mon, Days.tue, Days.wed, Days.thu, Days.fri, Days.sat, Days.sun],
    //   ),
    //   completions: _generateRandomCompletions(),
    //   status: HabitStatus.active,
    // ),

    // 3. Healthy breakfast habit
    Habit(
      id: "habit-breakfast-1",
      habitName: "Healthy breakfast",
      habitDescription: "Start your day with a nutritious breakfast including protein and fruits",
      emoji: "🍳",
      colorCode: Colors.greenAccent.shade400.value,
      reminderModel: ReminderModel(
        id: 1003,
        reminderTime: DateTime(2023, 1, 1, 7, 0),
        days: [Days.mon, Days.tue, Days.wed, Days.thu, Days.fri, Days.sat, Days.sun],
      ),
      completions: _generateRandomCompletions(),
      status: HabitStatus.active,
    ),

    // 4. Drinking water habit
    Habit(
      id: "habit-water-1",
      habitName: "Stay Hydrated",
      habitDescription: "Stay hydrated by drinking at least 2 liters of water throughout the day",
      emoji: "💧",
      colorCode: Colors.blue.value,
      reminderModel: ReminderModel(
        id: 1004,
        reminderTime: DateTime(2023, 1, 1, 9, 0),
        days: [Days.mon, Days.tue, Days.wed, Days.thu, Days.fri, Days.sat, Days.sun],
      ),
      completions: _generateRandomCompletions(),
      status: HabitStatus.active,
    ),

    // // 5. Healthy eating habit
    // Habit(
    //   id: "habit-vegetables-1",
    //   habitName: "Eat vegetables",
    //   habitDescription: "Include at least one serving of vegetables in each meal",
    //   emoji: "🥗",
    //   colorCode: Colors.green.value,
    //   reminderModel: ReminderModel(
    //     id: 1005,
    //     reminderTime: DateTime(2023, 1, 1, 12, 30),
    //     days: [Days.mon, Days.tue, Days.wed, Days.thu, Days.fri, Days.sat, Days.sun],
    //   ),
    //   completions: _generateRandomCompletions(),
    //   status: HabitStatus.active,
    // ),

    // 7. Learning habit
    Habit(
      id: "habit-learning-1",
      habitName: "Learn something new",
      habitDescription: "Spend 20 minutes learning a new skill or topic",
      emoji: "🧠",
      colorCode: Colors.redAccent.shade200.value,
      reminderModel: ReminderModel(
        id: 1007,
        reminderTime: DateTime(2023, 1, 1, 19, 0),
        days: [Days.mon, Days.tue, Days.wed, Days.thu, Days.fri],
      ),
      completions: _generateRandomCompletions(),
      status: HabitStatus.active,
    ),

    // 8. Reading habit
    Habit(
      id: "habit-reading-1",
      habitName: "Read for 30 minutes",
      habitDescription: "Read a book for at least 30 minutes to improve knowledge and relax",
      emoji: "📚",
      colorCode: Colors.amber.shade400.value,
      reminderModel: ReminderModel(
        id: 1008,
        reminderTime: DateTime(2023, 1, 1, 20, 30),
        days: [Days.mon, Days.tue, Days.wed, Days.thu, Days.fri, Days.sat, Days.sun],
      ),
      completions: _generateRandomCompletions(),
      status: HabitStatus.active,
    ),

    // 9. Gratitude habit
    Habit(
      id: "habit-gratitude-1",
      habitName: "Practice gratitude",
      habitDescription: "Write down three things you're grateful for today",
      emoji: "🙏",
      colorCode: Colors.orange.value,
      reminderModel: ReminderModel(
        id: 1009,
        reminderTime: DateTime(2023, 1, 1, 21, 0),
        days: [Days.mon, Days.tue, Days.wed, Days.thu, Days.fri, Days.sat, Days.sun],
      ),
      completions: _generateRandomCompletions(),
      status: HabitStatus.active,
    ),

    // 10. Journaling habit
    Habit(
      id: "habit-journal-1",
      habitName: "Journal",
      habitDescription: "Write down thoughts and reflections for the day",
      emoji: "✏️",
      colorCode: Colors.deepOrangeAccent.value,
      reminderModel: ReminderModel(
        id: 1010,
        reminderTime: DateTime(2023, 1, 1, 21, 30),
        days: [Days.mon, Days.tue, Days.wed, Days.thu, Days.fri, Days.sat, Days.sun],
      ),
      completions: _generateRandomCompletions(),
      status: HabitStatus.archived,
      archiveDate: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  /// Generate random completion entries for the last 30 days
  static Map<String, CompletionEntry> _generateRandomCompletions() {
    final Map<String, CompletionEntry> completions = {};
    final now = DateTime.now();

    // Generate completions for the last 30 days with ~70% completion rate
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      // ~70% chance of completion
      if (i == 0 || i % 3 != 0) {
        completions[dateString] = CompletionEntry(
          id: dateString,
          date: date,
          isCompleted: true,
        );
      }
    }

    return completions;
  }
}
