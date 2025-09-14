import '../../../models/habit/habit_difficulty.dart';

/// State model for statistics
class FormtionState {
  final int totalCompletedDays;
  final Map<String, HabitStatistic> habitStatistics;
  final bool isMockData;

  const FormtionState({
    required this.totalCompletedDays,
    required this.habitStatistics,
    this.isMockData = false,
  });

  // Factory constructor for initial state with default values
  factory FormtionState.initial({bool isMockData = false}) => FormtionState(
        totalCompletedDays: 0,
        habitStatistics: {},
        isMockData: isMockData,
      );

  // CopyWith method for immutability
  FormtionState copyWith({
    int? totalCompletedDays,
    int? longestStreak,
    Map<String, HabitStatistic>? habitStatistics,
    bool? isMockData,
  }) {
    return FormtionState(
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
  // Optional difficulty for insights; defaults can be applied where computed
  final HabitDifficulty? difficulty;

  const HabitStatistic({
    required this.habitId,
    required this.habitName,
    required this.totalDays,
    required this.completedDays,
    required this.progressPercentage,
    required this.startDate,
    this.difficulty,
  });
}
