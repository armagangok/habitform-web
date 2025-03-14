/// State model for statistics
class StatisticsState {
  // Overall Progress Stats
  final int totalCompletedDays;
  final double completionRate;
  final int longestStreak;

  // Habit-specific Statistics
  final Map<String, HabitStatistic> habitStatistics;

  const StatisticsState({
    required this.totalCompletedDays,
    required this.completionRate,
    required this.longestStreak,
    required this.habitStatistics,
  });

  // Factory constructor for initial state with default values
  factory StatisticsState.initial() => StatisticsState(
        totalCompletedDays: 0,
        completionRate: 0,
        longestStreak: 0,
        habitStatistics: {},
      );

  // CopyWith method for immutability
  StatisticsState copyWith({
    int? totalCompletedDays,
    double? completionRate,
    int? longestStreak,
    Map<String, HabitStatistic>? habitStatistics,
  }) {
    return StatisticsState(
      totalCompletedDays: totalCompletedDays ?? this.totalCompletedDays,
      completionRate: completionRate ?? this.completionRate,
      longestStreak: longestStreak ?? this.longestStreak,
      habitStatistics: habitStatistics ?? this.habitStatistics,
    );
  }
}

/// Statistics for a specific habit
class HabitStatistic {
  final String habitId;
  final String habitName;
  final int totalDays;
  final int completedDays;
  final double progressPercentage;
  final DateTime startDate;

  const HabitStatistic({
    required this.habitId,
    required this.habitName,
    required this.totalDays,
    required this.completedDays,
    required this.progressPercentage,
    required this.startDate,
  });
}
