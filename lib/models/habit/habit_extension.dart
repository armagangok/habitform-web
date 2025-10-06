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

extension HabitUtils on Habit {
  // Get all completions for a specific month and year
  List<DateTime> getCompletionsForMonth(int year, int month) {
    return completions.values.where((completion) => completion.isCompleted && completion.date.year == year && completion.date.month == month).map((completion) => completion.date).toList();
  }

  // Calculate the longest streak of consecutive days completed
  int calculateLongestStreak() {
    // Get completed dates and sort them chronologically
    final completedDates = <DateTime>{};
    for (final completion in completions.values) {
      if (completion.isCompleted) {
        completedDates.add(completion.date.normalized);
      }
    }

    if (completedDates.isEmpty) return 0;
    if (completedDates.length == 1) return 1;

    // Sort dates chronologically
    final sortedDates = completedDates.toList()..sort((a, b) => a.compareTo(b));

    int currentStreak = 1;
    int longestStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      // Check if current date is exactly one day after previous date
      final daysDifference = sortedDates[i].difference(sortedDates[i - 1]).inDays;

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
  int calculateCurrentStreak() {
    // Get completed dates
    final completedDates = <DateTime>{};
    for (final completion in completions.values) {
      if (completion.isCompleted) {
        completedDates.add(completion.date.normalized);
      }
    }

    if (completedDates.isEmpty) return 0;

    // Sort dates in descending order (newest first)
    final sortedDates = completedDates.toList()..sort((a, b) => b.compareTo(a));

    final today = DateTime.now().normalized;
    final yesterday = today.subtract(const Duration(days: 1));

    // Check if the most recent completion is today or yesterday
    final mostRecentDate = sortedDates.first;
    if (!mostRecentDate.isSameDayWith(today) && !mostRecentDate.isSameDayWith(yesterday)) {
      return 0;
    }

    int streak = 1;
    DateTime currentDate = mostRecentDate;

    // Check consecutive days going backwards
    for (int i = 1; i < sortedDates.length; i++) {
      final expectedPreviousDay = currentDate.subtract(const Duration(days: 1));

      if (sortedDates[i].isSameDayWith(expectedPreviousDay)) {
        // Found consecutive day
        streak++;
        currentDate = sortedDates[i];
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
  int getCountForDate(DateTime date) {
    final normalizedDate = date.normalized;
    final dateKey = '${normalizedDate.year}-${normalizedDate.month}-${normalizedDate.day}';

    // Try direct key lookup first (most efficient)
    final directEntry = completions[dateKey];
    if (directEntry != null && directEntry.date.normalized.isSameDayWith(normalizedDate)) {
      return directEntry.count;
    }

    // Fallback to linear search for legacy data
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
  int getRemainingFormationDays() {
    final completedDays = calculateFormationScoreFromFirstCompletion();
    final remaining = difficulty.estimatedFormationDays - completedDays;
    return remaining > 0 ? remaining : 0;
  }

  // Calculate probabilistic habit formation using step-by-step model from article
  // P_{n+1} = P_n + α(1 - P_n) for success, P_{n+1} = (1 - β)P_n for failure
  // Returns percentage in range [0, 100] representing habit strength
  double calculateHabitProbability() {
    if (completions.isEmpty) return 0.0;

    // Get habit creation date from ID
    final habitCreationDate = _getHabitCreationDate();

    // Get chronological list of completion attempts (success/failure per day)
    // Start from the earlier of habit creation date or first completion date
    final attempts = _getChronologicalAttempts(habitCreationDate);
    if (attempts.isEmpty) return 0.0;

    // Calculate growth rate (α) and decay rate (β) based on habit difficulty
    final double alpha = _calculateGrowthRate();
    final double beta = _calculateDecayRate();

    // Start with initial probability (10% as per article example)
    double currentProbability = 0.10;

    // Apply step-by-step probabilistic updates
    for (final attempt in attempts) {
      if (attempt.isSuccess) {
        // Success: P_{n+1} = P_n + α(1 - P_n)
        currentProbability = currentProbability + alpha * (1 - currentProbability);
      } else {
        // Failure: P_{n+1} = (1 - β)P_n
        currentProbability = (1 - beta) * currentProbability;
      }
    }

    // Convert to percentage and ensure bounds [0, 100]
    final double percentage = (currentProbability * 100.0).clamp(0.0, 100.0);
    return percentage;
  }

  // Get chronological list of completion attempts (success/failure per day)
  List<CompletionAttempt> _getChronologicalAttempts(DateTime habitCreationDate) {
    final firstCompletionDate = getFirstCompletionDate();

    // Start from the earlier of habit creation date or first completion date
    // This ensures we account for all days since the habit was created
    final DateTime startDate;
    if (firstCompletionDate != null) {
      startDate = DateUtils.dateOnly(firstCompletionDate.isBefore(habitCreationDate) ? firstCompletionDate : habitCreationDate);
    } else {
      startDate = DateUtils.dateOnly(habitCreationDate);
    }

    final today = DateUtils.dateOnly(DateTime.now());
    final List<CompletionAttempt> attempts = [];

    // Iterate through each day from start date to today
    DateTime currentDate = startDate;
    while (!currentDate.isAfter(today)) {
      final ratio = getCompletionRatioForDate(currentDate);
      final isSuccess = ratio >= 0.5; // Consider 50%+ completion as success

      attempts.add(CompletionAttempt(
        date: currentDate,
        isSuccess: isSuccess,
        completionRatio: ratio,
      ));

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return attempts;
  }

  // Calculate growth rate (α) based on habit difficulty
  // Easier habits have higher growth rates
  double _calculateGrowthRate() {
    // Base growth rate inversely related to formation days
    // Easier habits (fewer days) get higher growth rates
    final double baseRate = 66.0 / difficulty.estimatedFormationDays; // Normalize to 66-day baseline

    // Adjust based on minimum completion rate (easier habits have higher requirements)
    final double adjustedRate = baseRate * (0.8 + difficulty.minimumCompletionRate * 0.4);

    // Clamp to reasonable bounds [0.05, 0.2]
    return adjustedRate.clamp(0.05, 0.2);
  }

  // Calculate decay rate (β) based on habit difficulty
  // Easier habits have lower decay rates (more resilient)
  double _calculateDecayRate() {
    // Base decay rate directly related to formation days
    // Easier habits (fewer days) get lower decay rates
    final double baseRate = difficulty.estimatedFormationDays / 66.0; // Normalize to 66-day baseline

    // Adjust based on minimum completion rate
    final double adjustedRate = baseRate * (0.8 + (1 - difficulty.minimumCompletionRate) * 0.4);

    // Clamp to reasonable bounds [0.02, 0.1]
    return adjustedRate.clamp(0.02, 0.1);
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

  // Helper method to get habit creation date from habit ID
  DateTime _getHabitCreationDate() {
    try {
      // Try to parse as timestamp (for real habits)
      final timestamp = int.parse(id);
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      // If parsing fails, it's a mock habit with string ID
      // For mock habits, use a fixed date 60 days ago to simulate formation data
      return DateTime.now().subtract(const Duration(days: 60));
    }
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
