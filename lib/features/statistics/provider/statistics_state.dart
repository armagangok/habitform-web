/// State model for statistics
class StatisticsState {
  
  final int totalCompletedDays;  
  final Map<String, HabitStatistic> habitStatistics;
  final bool isMockData;

  const StatisticsState({
    required this.totalCompletedDays,
    required this.habitStatistics,
    this.isMockData = false,
  });

  // Factory constructor for initial state with default values
  factory StatisticsState.initial({bool isMockData = false}) => StatisticsState(
        totalCompletedDays: 0,
        habitStatistics: {},
        isMockData: isMockData,
      );

  // CopyWith method for immutability
  StatisticsState copyWith({
    int? totalCompletedDays,
    int? longestStreak,
    Map<String, HabitStatistic>? habitStatistics,
    bool? isMockData,
  }) {
    return StatisticsState(
      totalCompletedDays: totalCompletedDays ?? this.totalCompletedDays,
      habitStatistics: habitStatistics ?? this.habitStatistics,
      isMockData: isMockData ?? this.isMockData,
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
