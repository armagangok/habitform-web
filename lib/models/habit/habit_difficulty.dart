import 'package:hive_flutter/hive_flutter.dart';

import '../../core/core.dart';

part 'habit_difficulty.g.dart';

@HiveType(typeId: 10)
enum HabitDifficulty {
  @HiveField(0)
  veryEasy,

  @HiveField(1)
  easy,

  @HiveField(2)
  moderate,

  @HiveField(3)
  difficult,

  @HiveField(4)
  veryDifficult,
}

extension HabitDifficultyExtension on HabitDifficulty {
  /// Returns the display name for the difficulty level
  String get displayName {
    switch (this) {
      case HabitDifficulty.veryEasy:
        return LocaleKeys.create_habit_difficulty_very_easy.tr();
      case HabitDifficulty.easy:
        return LocaleKeys.create_habit_difficulty_easy.tr();
      case HabitDifficulty.moderate:
        return LocaleKeys.create_habit_difficulty_moderate.tr();
      case HabitDifficulty.difficult:
        return LocaleKeys.create_habit_difficulty_difficult.tr();
      case HabitDifficulty.veryDifficult:
        return LocaleKeys.create_habit_difficulty_very_difficult.tr();
    }
  }

  /// Returns the description for the difficulty level
  String get description {
    switch (this) {
      case HabitDifficulty.veryEasy:
        return LocaleKeys.create_habit_difficulty_very_easy_description.tr();
      case HabitDifficulty.easy:
        return LocaleKeys.create_habit_difficulty_easy_description.tr();
      case HabitDifficulty.moderate:
        return LocaleKeys.create_habit_difficulty_moderate_description.tr();
      case HabitDifficulty.difficult:
        return LocaleKeys.create_habit_difficulty_difficult_description.tr();
      case HabitDifficulty.veryDifficult:
        return LocaleKeys.create_habit_difficulty_very_difficult_description.tr();
    }
  }

  /// Returns the estimated formation time in days based on scientific research
  /// Based on Lally et al. (2009) study and complexity factors
  int get estimatedFormationDays {
    switch (this) {
      case HabitDifficulty.veryEasy:
        return 18; // Simple habits form faster
      case HabitDifficulty.easy:
        return 30; // Basic habits
      case HabitDifficulty.moderate:
        return 45; // Moderate complexity
      case HabitDifficulty.difficult:
        return 66; // Standard formation time
      case HabitDifficulty.veryDifficult:
        return 90; // Complex habits take longer
    }
  }

  /// Returns the difficulty multiplier for formation calculations
  double get formationMultiplier {
    switch (this) {
      case HabitDifficulty.veryEasy:
        return 0.7; // Forms 30% faster
      case HabitDifficulty.easy:
        return 0.85; // Forms 15% faster
      case HabitDifficulty.moderate:
        return 1.0; // Standard formation rate
      case HabitDifficulty.difficult:
        return 1.3; // Forms 30% slower
      case HabitDifficulty.veryDifficult:
        return 1.6; // Forms 60% slower
    }
  }

  /// Returns the minimum completion rate required for successful formation
  double get minimumCompletionRate {
    switch (this) {
      case HabitDifficulty.veryEasy:
        return 0.85; // 85% completion rate
      case HabitDifficulty.easy:
        return 0.80; // 80% completion rate
      case HabitDifficulty.moderate:
        return 0.75; // 75% completion rate
      case HabitDifficulty.difficult:
        return 0.70; // 70% completion rate
      case HabitDifficulty.veryDifficult:
        return 0.65; // 65% completion rate
    }
  }

  /// Returns the color associated with the difficulty level
  int get colorValue {
    switch (this) {
      case HabitDifficulty.veryEasy:
        return 0xFF4CAF50; // Green
      case HabitDifficulty.easy:
        return 0xFF8BC34A; // Light Green
      case HabitDifficulty.moderate:
        return 0xFFFFC107; // Amber
      case HabitDifficulty.difficult:
        return 0xFFFF9800; // Orange
      case HabitDifficulty.veryDifficult:
        return 0xFFF44336; // Red
    }
  }
}
