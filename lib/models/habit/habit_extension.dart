import 'dart:math' as math;

import 'package:habitform/models/habit/habit_difficulty.dart';

import '../../core/core.dart';
import 'habit_model.dart';

/// Represents a single completion attempt (success or failure) for probabilistic habit formation
class CompletionAttempt {
  final DateTime date;
  final bool isSuccess;
  final double completionRatio; // 0.0 to 1.0

  const CompletionAttempt({
    required this.date,
    required this.isSuccess,
    required this.completionRatio,
  });
}

/// Helper class for sorted completion data used in optimized probability calculations
class _CompletionData {
  final DateTime date;
  final double rewardRating;

  _CompletionData({
    required this.date,
    required this.rewardRating,
  });
}

extension HabitUtils on Habit {
  // Get all completions for a specific month and year
  // Optimized single-pass filter
  List<DateTime> getCompletionsForMonth(int year, int month) {
    final result = <DateTime>[];
    for (final completion in completions.values) {
      if (completion.isCompleted) {
        final normalizedDate = completion.date.normalized;
        if (normalizedDate.year == year && normalizedDate.month == month) {
          result.add(normalizedDate);
        }
      }
    }
    return result;
  }

  // Calculate the longest streak of consecutive days completed
  // Optimized to use a single pass through completions
  int calculateLongestStreak() {
    if (completions.isEmpty) return 0;

    // Collect completed dates in a single pass
    final completedDates = <DateTime>[];
    for (final completion in completions.values) {
      if (completion.isCompleted) {
        completedDates.add(completion.date.normalized);
      }
    }

    if (completedDates.isEmpty) return 0;
    if (completedDates.length == 1) return 1;

    // Sort dates chronologically (single sort operation)
    completedDates.sort((a, b) => a.compareTo(b));

    int currentStreak = 1;
    int longestStreak = 1;

    // Single pass to find longest streak
    for (int i = 1; i < completedDates.length; i++) {
      // Check if current date is exactly one day after previous date
      final daysDifference = completedDates[i].difference(completedDates[i - 1]).inDays;

      if (daysDifference == 1) {
        // Consecutive days - increment streak
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        // Not consecutive - start new streak
        currentStreak = 1;
      }
    }

    return longestStreak;
  }

  // Calculate the current streak (consecutive days until today or yesterday)
  // Optimized to use a single pass through completions
  int calculateCurrentStreak() {
    if (completions.isEmpty) return 0;

    // Collect completed dates in a single pass
    final completedDates = <DateTime>[];
    for (final completion in completions.values) {
      if (completion.isCompleted) {
        completedDates.add(completion.date.normalized);
      }
    }

    if (completedDates.isEmpty) return 0;

    // Sort dates in descending order (newest first) - single sort operation
    completedDates.sort((a, b) => b.compareTo(a));

    final today = DateTime.now().normalized;
    final yesterday = today.subtract(const Duration(days: 1));

    // Check if the most recent completion is today or yesterday
    final mostRecentDate = completedDates.first;
    if (!mostRecentDate.isSameDayWith(today) && !mostRecentDate.isSameDayWith(yesterday)) {
      return 0;
    }

    int streak = 1;
    DateTime currentDate = mostRecentDate;

    // Check consecutive days going backwards (single pass)
    for (int i = 1; i < completedDates.length; i++) {
      final expectedPreviousDay = currentDate.subtract(const Duration(days: 1));

      if (completedDates[i].isSameDayWith(expectedPreviousDay)) {
        // Found consecutive day
        streak++;
        currentDate = completedDates[i];
      } else {
        // Non-consecutive day found, streak ended
        break;
      }
    }

    return streak;
  }

  // Check if a specific date has a completion
  bool isDateCompleted(DateTime date) {
    // Look through all completion entries to find one with the same date
    for (final entry in completions.values) {
      if (entry.date.normalized.isSameDayWith(date.normalized) && entry.isCompleted) {
        return true;
      }
    }
    return false;
  }

  // Get recorded count for a specific date (0 if none)
  // Optimized to try multiple key formats for O(1) lookup
  int getCountForDate(DateTime date) {
    final normalizedDate = date.normalized;

    // Try ISO8601 format first (YYYY-MM-DD) - most common format
    final isoKey = normalizedDate.toIso8601DateString;
    final isoEntry = completions[isoKey];
    if (isoEntry != null && isoEntry.date.normalized.isSameDayWith(normalizedDate)) {
      return isoEntry.count;
    }

    // Try numeric format (Y-M-D) - used in some legacy data
    final numericKey = '${normalizedDate.year}-${normalizedDate.month}-${normalizedDate.day}';
    final numericEntry = completions[numericKey];
    if (numericEntry != null && numericEntry.date.normalized.isSameDayWith(normalizedDate)) {
      return numericEntry.count;
    }

    // Try padded numeric format (YYYY-MM-DD) - alternative format
    final paddedKey = '${normalizedDate.year.toString().padLeft(4, '0')}-${normalizedDate.month.toString().padLeft(2, '0')}-${normalizedDate.day.toString().padLeft(2, '0')}';
    if (paddedKey != isoKey) {
      final paddedEntry = completions[paddedKey];
      if (paddedEntry != null && paddedEntry.date.normalized.isSameDayWith(normalizedDate)) {
        return paddedEntry.count;
      }
    }

    // Fallback to linear search only for truly legacy data (should be rare)
    for (final entry in completions.values) {
      if (entry.date.normalized.isSameDayWith(normalizedDate)) {
        return entry.count;
      }
    }
    return 0;
  }

  // Get completion ratio for a date given a dailyTarget
  double getCompletionRatioForDate(DateTime date) {
    if (dailyTarget <= 0) return 0.0;
    final count = getCountForDate(date);
    final ratio = count / dailyTarget;
    return ratio.clamp(0.0, 1.0);
  }

  // Calculate weighted formation score using per-day ratio (sum of ratios)
  double calculateWeightedFormationScore() {
    if (completions.isEmpty) return 0.0;
    final effectiveTarget = dailyTarget <= 0 ? 1 : dailyTarget;

    // Sum ratios per calendar day (cap 1.0 per day)
    final Map<DateTime, double> ratioByDay = {};
    for (final entry in completions.values) {
      final day = entry.date.normalized;
      final ratio = (entry.count / effectiveTarget).clamp(0.0, 1.0);
      final current = ratioByDay[day] ?? 0.0;
      ratioByDay[day] = (current + ratio).clamp(0.0, 1.0);
    }
    return ratioByDay.values.fold(0.0, (sum, r) => sum + r);
  }

  // Calculate formation score based on first completion date (for proper formation calculation)
  int calculateFormationScoreFromFirstCompletion() {
    if (completions.isEmpty) return 0;

    final firstCompletionDate = getFirstCompletionDate();
    if (firstCompletionDate == null) return 0;

    final startDate = DateUtils.dateOnly(firstCompletionDate);

    // Count completed entries that occur on or after the first completion date
    return completions.values.where((entry) => entry.isCompleted && !entry.date.normalized.isBefore(startDate)).length;
  }

  // Get remaining days for formation
  int getRemainingProbabilityDays() {
    final completedDays = calculateFormationScoreFromFirstCompletion();
    final remaining = difficulty.estimatedProbabilityDays - completedDays;
    return remaining > 0 ? remaining : 0;
  }

  // Calculate probabilistic habit formation using the Probabilistic Habit Formation Theory
  // Formula: P(t) = 1 - exp(-α · R(t) / D)
  // Where:
  //   P(t) = Probability of habit performance at time t (0 to 1)
  //   R(t) = Cumulative number of successful repetitions performed up to time t
  //   D = Difficulty coefficient of the habit (D > 0)
  //   α = Reward factor representing emotional reinforcement (α > 0)
  //
  // Each completion can have its own reward rating (α), so we use the average reward rating
  // across all completions. If a completion doesn't have a rating, we use the habit's default rewardFactor.
  // Returns percentage in range [0, 100] representing habit strength
  double calculateHabitProbability() {
    if (completions.isEmpty) return 0.0;

    // Calculate R(t): Cumulative number of successful repetitions
    final double cumulativeRepetitions = _calculateCumulativeRepetitions();
    if (cumulativeRepetitions == 0) return 0.0;

    // Get D: Difficulty coefficient
    final double difficultyCoefficient = _getDifficultyCoefficient();

    // Get α: Average reward factor across all completions
    // Each completion can have its own reward rating, so we calculate the weighted average
    final double averageRewardFactor = _calculateAverageRewardFactor();

    // Apply the exponential formula: P(t) = 1 - exp(-α · R(t) / D)
    final double probability = 1.0 - _exp(-averageRewardFactor * cumulativeRepetitions / difficultyCoefficient);

    // Convert to percentage and ensure bounds [0, 100]
    final double percentage = (probability * 100.0).clamp(0.0, 100.0);
    return percentage;
  }

  // Calculate R(t): Cumulative number of successful repetitions
  // According to theory, this is the total number of successful habit performances up to time t
  // We count each day with >= 50% completion as one successful repetition
  double _calculateCumulativeRepetitions() {
    if (completions.isEmpty) return 0.0;

    int successfulRepetitions = 0;

    // Count all days with successful completion (>= 50% of daily target)
    for (final entry in completions.values) {
      if (entry.isCompleted) {
        final ratio = getCompletionRatioForDate(entry.date);
        // Consider >= 50% completion as a successful repetition
        if (ratio >= 0.5) {
          successfulRepetitions++;
        }
      }
    }

    return successfulRepetitions.toDouble();
  }

  // Get D: Difficulty coefficient
  // Maps estimatedProbabilityDays to a difficulty coefficient D
  // According to theory, harder habits have larger D values
  // We use estimatedProbabilityDays directly as D, as it represents the difficulty
  double _getDifficultyCoefficient() {
    // Use estimatedProbabilityDays as the difficulty coefficient D
    // Higher estimatedProbabilityDays = higher difficulty = larger D
    // Ensure D > 0 (always true since estimatedProbabilityDays is always positive)
    return difficulty.estimatedProbabilityDays.toDouble();
  }

  // Calculate average reward factor (α) across all completions
  // Each completion can have its own reward rating, so we calculate the weighted average
  // If a completion doesn't have a rating, we use the habit's default rewardFactor
  double _calculateAverageRewardFactor() {
    if (completions.isEmpty) {
      // No completions, use default reward factor
      return rewardFactor.clamp(0.1, 2.0);
    }

    double totalWeightedRating = 0.0;
    int totalCompletions = 0;

    // Calculate weighted average based on completion ratios
    for (final entry in completions.values) {
      if (entry.isCompleted) {
        final ratio = getCompletionRatioForDate(entry.date);
        if (ratio >= 0.5) {
          // Use completion's reward rating if available, otherwise use habit's default
          final rating = entry.rewardRating ?? rewardFactor;
          totalWeightedRating += rating * ratio; // Weight by completion ratio
          totalCompletions++;
        }
      }
    }

    if (totalCompletions == 0) {
      // No valid completions, use default
      return rewardFactor.clamp(0.1, 2.0);
    }

    // Calculate average (weighted by completion ratio)
    final average = totalWeightedRating / totalCompletions;
    return average.clamp(0.1, 2.0);
  }

  // Calculate exp(x) using Dart's built-in exponential function
  // This is a helper method for clarity
  double _exp(double x) {
    // Handle very large negative values to prevent underflow
    if (x < -50) return 0.0;
    // Handle very large positive values to prevent overflow
    if (x > 50) return double.infinity;
    return math.exp(x);
  }

  /// Calculate historical probability values for a specific year
  /// Returns a map of date (month) to average probability for that period
  /// Always returns 12 months for the selected year
  /// Optimized version that uses incremental calculation instead of recalculating for every day
  Map<DateTime, double> calculateHistoricalProbabilityForYear(int year) {
    if (completions.isEmpty) return {};

    final today = DateUtils.dateOnly(DateTime.now());
    final firstCompletionDate = getFirstCompletionDate();
    final isCurrentYear = year == today.year;

    // Pre-sort and filter completions once for efficiency
    final sortedCompletions = <_CompletionData>[];
    final effectiveTarget = dailyTarget <= 0 ? 1 : dailyTarget;
    final difficultyCoefficient = _getDifficultyCoefficient();

    for (final entry in completions.values) {
      final entryDate = DateUtils.dateOnly(entry.date);
      // Only include completions up to the end of the selected year
      if (entryDate.year > year) continue;

      if (entry.isCompleted) {
        final ratio = (entry.count / effectiveTarget).clamp(0.0, 1.0);
        if (ratio >= 0.5) {
          sortedCompletions.add(_CompletionData(
            date: entryDate,
            rewardRating: entry.rewardRating ?? rewardFactor,
          ));
        }
      }
    }

    // Sort by date for efficient incremental processing
    sortedCompletions.sort((a, b) => a.date.compareTo(b.date));

    if (sortedCompletions.isEmpty) return {};

    final Map<DateTime, double> historicalData = {};
    final Map<String, List<double>> groupedData = {}; // Key: "YYYY-MM"

    // Iterate through all 12 months of the selected year
    for (int month = 1; month <= 12; month++) {
      final monthStart = DateTime(year, month, 1);
      final monthEnd = DateTime(year, month + 1, 0); // Last day of the month
      final actualEndDate = isCurrentYear && monthEnd.isAfter(today) ? today : monthEnd;

      // If this month hasn't started yet (future), skip it
      if (isCurrentYear && monthStart.isAfter(today)) {
        continue;
      }

      // If habit started after this month, skip it
      if (firstCompletionDate != null && monthEnd.isBefore(DateUtils.dateOnly(firstCompletionDate))) {
        continue;
      }

      // Calculate probability at the end of the month (or today if current month)
      // This is much more efficient than calculating for every single day
      final probabilityAtMonthEnd = _calculateProbabilityUpToDateOptimized(
        actualEndDate,
        sortedCompletions,
        difficultyCoefficient,
      );

      // Group by month: "YYYY-MM"
      final monthKey = '$year-${month.toString().padLeft(2, '0')}';
      groupedData.putIfAbsent(monthKey, () => []).add(probabilityAtMonthEnd);

      // For better visualization, also calculate at the start of the month if different
      if (monthStart.isBefore(actualEndDate)) {
        final probabilityAtMonthStart = _calculateProbabilityUpToDateOptimized(
          monthStart.subtract(const Duration(days: 1)), // Day before month starts
          sortedCompletions,
          difficultyCoefficient,
        );
        // Add start probability to get a better average
        groupedData[monthKey]!.add(probabilityAtMonthStart);
      }
    }

    // Calculate average for each group
    for (final entry in groupedData.entries) {
      final parts = entry.key.split('-');
      if (parts.length >= 2) {
        final entryYear = int.parse(parts[0]);
        final month = int.parse(parts[1]);

        final date = DateTime(entryYear, month, 1);
        final average = entry.value.reduce((a, b) => a + b) / entry.value.length;
        historicalData[date] = average;
      }
    }

    return historicalData;
  }

  /// Calculate historical probability values for the last year
  /// Returns a map of date (month or day) to average probability for that period
  /// Grouped by month for better visualization
  /// @deprecated Use calculateHistoricalProbabilityForYear instead
  Map<DateTime, double> calculateHistoricalProbability({
    bool groupByMonth = true,
    int daysBack = 365,
  }) {
    // Default to current year
    return calculateHistoricalProbabilityForYear(DateTime.now().year);
  }

  /// Optimized version that uses pre-sorted completion data
  /// This avoids iterating through all completions for each date calculation
  /// Uses a rolling window approach (90 days) to reflect recent performance rather than cumulative
  double _calculateProbabilityUpToDateOptimized(
    DateTime targetDate,
    List<_CompletionData> sortedCompletions,
    double difficultyCoefficient,
  ) {
    if (sortedCompletions.isEmpty) return 0.0;

    final target = DateUtils.dateOnly(targetDate);
    // Use a 90-day rolling window to reflect recent performance
    // This ensures probability decreases when user has low completion rates in recent months
    final windowStart = target.subtract(const Duration(days: 90));

    int successfulRepetitions = 0;
    double totalRewardRating = 0.0;
    int ratedCompletions = 0;

    // Since completions are pre-sorted, iterate and only count those within the rolling window
    for (final completion in sortedCompletions) {
      // Skip completions before the window
      if (completion.date.isBefore(windowStart)) continue;
      // Stop if we've passed the target date
      if (completion.date.isAfter(target)) break;

      successfulRepetitions++;
      totalRewardRating += completion.rewardRating;
      ratedCompletions++;
    }

    if (successfulRepetitions == 0) return 0.0;

    // Calculate average reward factor
    final double averageRewardFactor = (totalRewardRating / ratedCompletions).clamp(0.1, 2.0);

    // Apply the exponential formula: P(t) = 1 - exp(-α · R(t) / D)
    // Using recent repetitions (rolling window) instead of cumulative
    final double probability = 1.0 - _exp(-averageRewardFactor * successfulRepetitions / difficultyCoefficient);

    // Convert to percentage
    return (probability * 100.0).clamp(0.0, 100.0);
  }

  // Get the first completion date (earliest date when user started tracking this habit)
  DateTime? getFirstCompletionDate() {
    if (completions.isEmpty) return null;

    // Find the earliest completion entry
    DateTime? earliestDate;
    for (final entry in completions.values) {
      if (entry.isCompleted) {
        if (earliestDate == null || entry.date.isBefore(earliestDate)) {
          earliestDate = entry.date;
        }
      }
    }

    return earliestDate;
  }

  // Calculate progress percentage like statistics page (completion rate from start to today)
  double calculateProgressPercentage() {
    if (completions.isEmpty) return 0.0;

    // Get all completion dates and find the earliest
    final sortedDates = completions.values.map((entry) => entry.date).toList()..sort();
    final startDate = sortedDates.first;
    final today = DateTime.now();

    // Calculate days since start (including today)
    final daysSinceStart = today.difference(startDate).inDays + 1;

    // Count completed entries, excluding retroactive ones
    final completedEntries = completions.values.where((entry) => entry.isCompleted).length;

    // Calculate completion rate percentage
    return daysSinceStart > 0 ? (completedEntries / daysSinceStart) * 100.0 : 0.0;
  }

  // Calculate progress percentage based on first completion date (for proper formation calculation)
  double calculateProgressPercentageFromFirstCompletion() {
    if (completions.isEmpty) return 0.0;

    final today = DateTime.now();
    final firstCompletionDate = getFirstCompletionDate();
    if (firstCompletionDate == null) return 0.0;

    final startDate = DateUtils.dateOnly(firstCompletionDate);

    // Calculate days since first completion (including today)
    final daysSinceStart = today.difference(startDate).inDays + 1;

    // Count completed entries that occur on or after the first completion date
    final completedEntries = completions.values.where((entry) => entry.isCompleted && !entry.date.normalized.isBefore(startDate)).length;

    // Calculate completion rate percentage (cap at 100%)
    final percentage = daysSinceStart > 0 ? (completedEntries / daysSinceStart) * 100.0 : 0.0;
    return percentage.clamp(0.0, 100.0);
  }

  // Weighted progress percentage since first completion using per-day ratios (0..100)
  double calculateWeightedProgressPercentageFromFirstCompletion() {
    if (completions.isEmpty) return 0.0;

    final firstCompletionDate = getFirstCompletionDate();
    if (firstCompletionDate == null) return 0.0;

    final startDate = DateUtils.dateOnly(firstCompletionDate);
    final today = DateTime.now();
    final daysSinceStart = today.difference(startDate).inDays + 1;
    if (daysSinceStart <= 0) return 0.0;

    final effectiveTarget = dailyTarget <= 0 ? 1 : dailyTarget;
    final Map<DateTime, double> ratioByDay = {};
    for (final entry in completions.values) {
      if (!entry.date.normalized.isBefore(startDate)) {
        final ratio = (entry.count / effectiveTarget).clamp(0.0, 1.0);
        final day = entry.date.normalized;
        final current = ratioByDay[day] ?? 0.0;
        ratioByDay[day] = (current + ratio).clamp(0.0, 1.0);
      }
    }
    final weightedDays = ratioByDay.values.fold(0.0, (sum, r) => sum + r);
    return ((weightedDays / daysSinceStart) * 100.0).clamp(0.0, 100.0);
  }
}
