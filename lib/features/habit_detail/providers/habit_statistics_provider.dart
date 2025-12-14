import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitform/models/habit/habit_extension.dart';

import '../../../core/core.dart';
import '../../../models/habit/habit_model.dart';

/// Cached habit statistics to avoid expensive recalculations
class HabitStatistics {
  final int currentStreak;
  final int longestStreak;
  final double formationProgress;
  final double completionRate;
  final int thisMonthCompleted;
  final int thisMonthTotal;
  final double thisMonthRate;
  final List<double> weeklyData;
  final DateTime lastCalculated;

  const HabitStatistics({
    required this.currentStreak,
    required this.longestStreak,
    required this.formationProgress,
    required this.completionRate,
    required this.thisMonthCompleted,
    required this.thisMonthTotal,
    required this.thisMonthRate,
    required this.weeklyData,
    required this.lastCalculated,
  });

  /// Check if statistics are still valid (not older than 1 minute)
  bool get isValid => DateTime.now().difference(lastCalculated).inMinutes < 1;
}

/// Provider for cached habit statistics
final habitStatisticsProvider = AutoDisposeNotifierProvider<HabitStatisticsNotifier, HabitStatistics?>(() {
  return HabitStatisticsNotifier();
});

class HabitStatisticsNotifier extends AutoDisposeNotifier<HabitStatistics?> {
  @override
  HabitStatistics? build() => null;

  /// Calculate and cache statistics for the current habit
  /// Returns immediately if cached statistics are valid
  void calculateStatistics(Habit habit) {
    // Check if we already have valid cached statistics
    if (state != null && state!.isValid) {
      return;
    }

    // Calculate asynchronously to avoid blocking UI
    _calculateStatisticsAsync(habit);
  }

  /// Force recalculation of statistics (async to avoid blocking UI)
  void forceRecalculate(Habit habit) {
    _calculateStatisticsAsync(habit);
  }

  /// Calculate statistics asynchronously to avoid blocking UI
  void _calculateStatisticsAsync(Habit habit) {
    // Use Future.microtask to defer calculation to next event loop
    // This allows the UI to render first while statistics calculate in background
    Future.microtask(() {
      try {
        final statistics = _HabitStatisticsCalculator.calculate(habit);
        // Use a small delay to ensure UI has rendered
        Future.delayed(const Duration(milliseconds: 16), () {
          // Setting state is safe even if provider is disposed - it just won't update anything
          try {
            state = statistics;
          } catch (_) {
            // Provider was disposed, ignore
          }
        });
      } catch (e) {
        LogHelper.shared.errorPrint("Error in async statistics calculation: $e");
        // Fallback: calculate synchronously if async fails
        try {
          final statistics = _HabitStatisticsCalculator.calculate(habit);
          state = statistics;
        } catch (_) {
          // Provider was disposed, ignore
        }
      }
    });
  }
}

/// Helper class for statistics calculation (can be used in isolates)
class _HabitStatisticsCalculator {
  static HabitStatistics calculate(Habit habit) {
    if (habit.completions.isEmpty) {
      return HabitStatistics(
        currentStreak: 0,
        longestStreak: 0,
        formationProgress: 0.0,
        completionRate: 0.0,
        thisMonthCompleted: 0,
        thisMonthTotal: 0,
        thisMonthRate: 0.0,
        weeklyData: List.filled(7, 0.0),
        lastCalculated: DateTime.now(),
      );
    }

    // Calculate streaks (these are expensive operations)
    final currentStreak = habit.calculateCurrentStreak();
    final longestStreak = habit.calculateLongestStreak();

    // Calculate formation progress
    final formationProgress = habit.calculateHabitProbability();

    // Calculate completion rate
    final completionRate = habit.calculateWeightedProgressPercentageFromFirstCompletion();

    // This month data
    final now = DateTime.now();
    final thisMonthCompletions = habit.getCompletionsForMonth(now.year, now.month);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final thisMonthRate = thisMonthCompletions.length / daysInMonth;

    // Weekly data (last 7 days)
    final today = DateUtils.dateOnly(DateTime.now());
    final weeklyData = <double>[];
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final ratio = habit.getCompletionRatioForDate(date);
      weeklyData.add(ratio);
    }

    return HabitStatistics(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      formationProgress: formationProgress,
      completionRate: completionRate,
      thisMonthCompleted: thisMonthCompletions.length,
      thisMonthTotal: daysInMonth,
      thisMonthRate: thisMonthRate,
      weeklyData: weeklyData,
      lastCalculated: DateTime.now(),
    );
  }
}
