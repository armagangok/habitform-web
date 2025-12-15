// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../features/reminder/models/days/days_enum.dart';
import '../../features/reminder/models/reminder/reminder_model.dart';
import '../../models/completion_entry/completion_entry.dart';
import '../../models/habit/habit_difficulty.dart';
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
      completions: _generateRandomCompletions("habit-wakeup-1"),
      status: HabitStatus.active,
      difficulty: HabitDifficulty.moderate,
    ),

    // 2. Morning Stretch habit (yeni)
    Habit(
      id: "habit-stretch-1",
      habitName: "Morning Stretch",
      habitDescription: "Do 5 minutes of stretching to wake up your body",
      emoji: "🤸‍♂️",
      colorCode: Colors.pink.shade300.value,
      reminderModel: ReminderModel(
        id: 1002,
        reminderTime: DateTime(2023, 1, 1, 6, 05),
        days: [Days.mon, Days.tue, Days.wed, Days.thu, Days.fri, Days.sat, Days.sun],
      ),
      completions: _generateRandomCompletions("habit-stretch-1"),
      status: HabitStatus.active,
      difficulty: HabitDifficulty.easy,
    ),

    // 3. Healthy breakfast habit
    Habit(
      id: "habit-breakfast-1",
      habitName: "Healthy Breakfast",
      habitDescription: "Start your day with a nutritious breakfast including protein and fruits",
      emoji: "🍳",
      colorCode: Colors.greenAccent.shade400.value,
      reminderModel: ReminderModel(
        id: 1003,
        reminderTime: DateTime(2023, 1, 1, 7, 0),
        days: [Days.mon, Days.tue, Days.wed, Days.thu, Days.fri, Days.sat, Days.sun],
      ),
      completions: _generateRandomCompletions("habit-breakfast-1"),
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
      completions: _generateRandomCompletions("habit-water-1"),
      status: HabitStatus.active,
    ),

    // 5. Take Vitamins habit (yeni)
    Habit(
      id: "habit-vitamins-1",
      habitName: "Take Vitamins",
      habitDescription: "Take your daily vitamins and supplements",
      emoji: "💊",
      colorCode: Colors.purple.shade300.value,
      reminderModel: ReminderModel(
        id: 1005,
        reminderTime: DateTime(2023, 1, 1, 9, 30),
        days: [Days.mon, Days.tue, Days.wed, Days.thu, Days.fri, Days.sat, Days.sun],
      ),
      completions: _generateRandomCompletions("habit-vitamins-1"),
      status: HabitStatus.active,
    ),

    // 6. Healthy eating habit
    Habit(
      id: "habit-vegetables-1",
      habitName: "Healthy Breakfast",
      habitDescription: "Start your day with a nutritious breakfast including protein and fruits",
      emoji: "🍳",
      colorCode: Colors.red.value,
      reminderModel: ReminderModel(
        id: 1006,
        reminderTime: DateTime(2023, 1, 1, 12, 30),
        days: [Days.mon, Days.tue, Days.wed, Days.thu, Days.fri, Days.sat, Days.sun],
      ),
      completions: _generateRandomCompletions("habit-vegetables-1"),
      status: HabitStatus.active,
    ),

    // 7. Posture Check habit (yeni)
    Habit(
      id: "habit-posture-1",
      habitName: "Posture Check",
      habitDescription: "Check and correct your posture while working",
      emoji: "🧍",
      colorCode: Colors.teal.shade400.value,
      reminderModel: ReminderModel(
        id: 1007,
        reminderTime: DateTime(2023, 1, 1, 14, 0),
        days: [Days.mon, Days.tue, Days.wed, Days.thu, Days.fri],
      ),
      completions: _generateRandomCompletions("habit-posture-1"),
      status: HabitStatus.active,
    ),

    // 8. Daily Walk habit (yeni)
    Habit(
      id: "habit-walk-1",
      habitName: "Daily Walk",
      habitDescription: "Take a 30-minute walk to stay active and clear your mind",
      emoji: "🚶‍♂️",
      colorCode: Colors.lightGreen.shade400.value,
      reminderModel: ReminderModel(
        id: 1008,
        reminderTime: DateTime(2023, 1, 1, 17, 30),
        days: [Days.mon, Days.tue, Days.wed, Days.thu, Days.fri, Days.sat, Days.sun],
      ),
      completions: _generateRandomCompletions("habit-walk-1"),
      status: HabitStatus.active,
    ),

    // 9. Learning habit
    Habit(
      id: "habit-learning-1",
      habitName: "Learn Something",
      habitDescription: "Spend 20 minutes learning a new skill or topic",
      emoji: "🧠",
      colorCode: Colors.redAccent.shade200.value,
      reminderModel: ReminderModel(
        id: 1009,
        reminderTime: DateTime(2023, 1, 1, 19, 0),
        days: [Days.mon, Days.tue, Days.wed, Days.thu, Days.fri],
      ),
      completions: _generateRandomCompletions("habit-learning-1"),
      status: HabitStatus.active,
    ),

    // 10. Reading habit
    Habit(
      id: "habit-reading-1",
      habitName: "Daily Read",
      habitDescription: "Read a book for at least 30 minutes to improve knowledge and relax",
      emoji: "📚",
      colorCode: Colors.amber.shade400.value,
      reminderModel: ReminderModel(
        id: 1010,
        reminderTime: DateTime(2023, 1, 1, 20, 30),
        days: [Days.mon, Days.tue, Days.wed, Days.thu, Days.fri, Days.sat, Days.sun],
      ),
      completions: _generateRandomCompletions("habit-reading-1"),
      status: HabitStatus.active,
    ),

    // 11. Meditation habit (akşama taşındı)
    Habit(
      id: "habit-meditation-1",
      habitName: "Meditate",
      habitDescription: "Practice mindfulness meditation for 10 minutes",
      emoji: "🧘",
      colorCode: Colors.deepPurple.shade400.value,
      reminderModel: ReminderModel(
        id: 1011,
        reminderTime: DateTime(2023, 1, 1, 20, 45),
        days: [Days.mon, Days.tue, Days.wed, Days.thu, Days.fri, Days.sat, Days.sun],
      ),
      completions: _generateRandomCompletions("habit-meditation-1"),
      status: HabitStatus.active,
    ),

    // 12. Gratitude habit
    Habit(
      id: "habit-gratitude-1",
      habitName: "Practice Gratitude",
      habitDescription: "Write down three things you're grateful for today",
      emoji: "🙏",
      colorCode: Colors.orange.value,
      reminderModel: ReminderModel(
        id: 1012,
        reminderTime: DateTime(2023, 1, 1, 21, 0),
        days: [Days.mon, Days.tue, Days.wed, Days.thu, Days.fri, Days.sat, Days.sun],
      ),
      completions: _generateRandomCompletions("habit-gratitude-1"),
      status: HabitStatus.active,
    ),

    // 13. Phone-Free Time habit (yeni)
    Habit(
      id: "habit-phoneoff-1",
      habitName: "Phone-Free Time",
      habitDescription: "Put your phone away for at least 1 hour before bed",
      emoji: "📵",
      colorCode: Colors.blueGrey.shade400.value,
      reminderModel: ReminderModel(
        id: 1013,
        reminderTime: DateTime(2023, 1, 1, 21, 15),
        days: [Days.mon, Days.tue, Days.wed, Days.thu, Days.fri, Days.sat, Days.sun],
      ),
      completions: _generateRandomCompletions("habit-phoneoff-1"),
      status: HabitStatus.active,
    ),

    // 14. Journaling habit
    Habit(
      id: "habit-journal-1",
      habitName: "Journal",
      habitDescription: "Write down thoughts and reflections for the day",
      emoji: "✏️",
      colorCode: Colors.blueAccent.value,
      reminderModel: ReminderModel(
        id: 1014,
        reminderTime: DateTime(2023, 1, 1, 21, 30),
        days: [Days.mon, Days.tue, Days.wed, Days.thu, Days.fri, Days.sat, Days.sun],
      ),
      completions: _generateRandomCompletions("habit-journal-1"),
      status: HabitStatus.archived,
      archiveDate: DateTime.now().subtract(const Duration(days: 15)),
    ),

    // 15. Brush Teeth habit (yeni)
    Habit(
      id: "habit-teeth-1",
      habitName: "Brush Teeth",
      habitDescription: "Brush your teeth for 2 minutes before bed",
      emoji: "🪥",
      colorCode: Colors.cyan.shade300.value,
      reminderModel: ReminderModel(
        id: 1015,
        reminderTime: DateTime(2023, 1, 1, 22, 0),
        days: [Days.mon, Days.tue, Days.wed, Days.thu, Days.fri, Days.sat, Days.sun],
      ),
      completions: _generateRandomCompletions("habit-teeth-1"),
      status: HabitStatus.active,
      difficulty: HabitDifficulty.veryEasy,
    ),
  ];

  /// Generate random completion entries for the last 30 days
  static Map<String, CompletionEntry> _generateRandomCompletions([String? habitId]) {
    final Map<String, CompletionEntry> completions = {};
    final now = DateTime.now();
    final random = DateTime.now().millisecondsSinceEpoch; // Use current time as seed for randomness

    // Create a truly unique seed for each habit
    int seed = 0;
    if (habitId != null) {
      for (int i = 0; i < habitId.length; i++) {
        seed += habitId.codeUnitAt(i);
      }
    }
    seed = (seed + random) % 10000;

    // Generate completions for the last 60 days with more realistic completion rates
    for (int i = 0; i < 60; i++) {
      final date = now.subtract(Duration(days: i));
      final dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      // Generate a random number between 0-99 for this specific day and habit
      final daySpecificSeed = (seed + i * 17 + date.day * 31 + date.month * 12) % 100;

      // Different completion rates based on habit type and time
      bool shouldInclude = false;

      // Base completion rate varies by habit type
      int baseCompletionRate = 50; // Default 50%

      if (habitId != null) {
        if (habitId.contains('water')) {
          baseCompletionRate = 65; // Water drinking - higher completion rate
        } else if (habitId.contains('teeth') || habitId.contains('wakeup')) {
          baseCompletionRate = 75; // Daily routines - very high completion rate
        } else if (habitId.contains('exercise') || habitId.contains('stretch')) {
          baseCompletionRate = 45; // Exercise habits - lower completion rate
        } else if (habitId.contains('meditation') || habitId.contains('gratitude')) {
          baseCompletionRate = 35; // Mindfulness habits - lower completion rate
        }
      }

      // Apply time-based variation (recent days have slightly higher completion rates)
      if (i < 7) {
        baseCompletionRate += 10; // Last week - boost completion rate
      } else if (i < 14) {
        baseCompletionRate += 5; // Second week - small boost
      }

      // Add some randomness
      final randomVariation = (daySpecificSeed % 20) - 10; // -10 to +10 variation
      final finalCompletionRate = (baseCompletionRate + randomVariation).clamp(20, 90);

      shouldInclude = daySpecificSeed < finalCompletionRate;

      if (shouldInclude) {
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
