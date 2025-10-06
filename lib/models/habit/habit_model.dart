import 'package:hive_flutter/hive_flutter.dart';

import '../../features/reminder/models/reminder/reminder_model.dart';
import '../completion_entry/completion_entry.dart';
import 'habit_difficulty.dart';
import 'habit_status.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 1)
class Habit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String habitName;

  @HiveField(2)
  final String? habitDescription;

  @HiveField(3)
  final String? emoji;

  @HiveField(4)
  final ReminderModel? reminderModel;

  // Number of times the habit is intended to be completed per day (e.g., brush teeth twice)
  @HiveField(5, defaultValue: 1)
  final int dailyTarget;

  @HiveField(6)
  final int colorCode;

  @HiveField(7, defaultValue: {})
  final Map<String, CompletionEntry> completions;

  @HiveField(8)
  final DateTime? archiveDate;

  @HiveField(10, defaultValue: HabitStatus.active)
  final HabitStatus status;

  @HiveField(11, defaultValue: [])
  final List<String> categoryIds;

  @HiveField(12, defaultValue: HabitDifficulty.moderate)
  final HabitDifficulty difficulty;

  Habit({
    required this.id,
    required this.habitName,
    this.habitDescription,
    this.reminderModel,
    this.emoji,
    this.completions = const {},
    this.dailyTarget = 1,
    required this.colorCode,
    this.archiveDate,
    this.status = HabitStatus.active,
    this.categoryIds = const [],
    this.difficulty = HabitDifficulty.moderate,
  });

  Habit copyWith({
    String? id,
    String? habitName,
    String? habitDescription,
    ReminderModel? reminderModel,
    String? emoji,
    int? colorCode,
    Map<String, CompletionEntry>? completions,
    int? dailyTarget,
    DateTime? archiveDate,
    HabitStatus? status,
    List<String>? categoryIds,
    HabitDifficulty? difficulty,
  }) {
    return Habit(
      id: id ?? this.id,
      habitName: habitName ?? this.habitName,
      habitDescription: habitDescription ?? this.habitDescription,
      reminderModel: reminderModel ?? this.reminderModel,
      emoji: emoji ?? this.emoji,
      completions: completions ?? this.completions,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      colorCode: colorCode ?? this.colorCode,
      archiveDate: archiveDate ?? this.archiveDate,
      status: status ?? this.status,
      categoryIds: categoryIds ?? this.categoryIds,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  
}
