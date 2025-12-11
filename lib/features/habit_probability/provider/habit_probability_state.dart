import '../../../models/habit/habit_difficulty.dart';

/// State model for statistics
class ProbabilityState {
  final int totalCompletedDays;
  final Map<String, HabitStatistic> habitStatistics;
  final bool isMockData;

  const ProbabilityState({
    required this.totalCompletedDays,
    required this.habitStatistics,
    this.isMockData = false,
  });

  // Factory constructor for initial state with default values
  factory ProbabilityState.initial({bool isMockData = false}) => ProbabilityState(
        totalCompletedDays: 0,
        habitStatistics: {},
        isMockData: isMockData,
      );

  // CopyWith method for immutability
  ProbabilityState copyWith({
    int? totalCompletedDays,
    int? longestStreak,
    Map<String, HabitStatistic>? habitStatistics,
    bool? isMockData,
  }) {
    return ProbabilityState(
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
  final HabitDifficulty? difficulty;
  final double probabilityScore; // 0-100 probability of successful habit formation
  final int estimatedProbabilityDays; // Days needed for habit formation based on difficulty
  final int remainingProbabilityDays; // Days remaining to complete habit formation

  const HabitStatistic({
    required this.habitId,
    required this.habitName,
    required this.totalDays,
    required this.completedDays,
    required this.progressPercentage,
    required this.startDate,
    this.difficulty,
    required this.probabilityScore,
    required this.estimatedProbabilityDays,
    required this.remainingProbabilityDays,
  });
}
