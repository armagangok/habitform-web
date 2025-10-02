import 'dart:math' as math;

import '../../core/core.dart';
import 'completion_entry.dart';

extension CompletionEntryUtils on Map<String, CompletionEntry> {
  // Get all completions for a specific month and year
  List<DateTime> getCompletionsForMonth(int year, int month) {
    return values.where((completion) => completion.isCompleted && completion.date.year == year && completion.date.month == month).map((completion) => completion.date).toList();
  }

  // Calculate the longest streak of consecutive days completed
  int calculateLongestStreak() {
    // Tamamlanmış günleri al ve kronolojik sırala
    final completions = values.where((completion) => completion.isCompleted).map((completion) => completion.date.normalized).toList();

    // Boş liste kontrolü
    if (completions.isEmpty) return 0;

    // Mükerrer günleri kaldır (aynı günde birden fazla kayıt olmaması için)
    final uniqueDates = <DateTime>{};
    for (var date in completions) {
      uniqueDates.add(date);
    }

    // Kronolojik sıralama yap
    final sortedDates = uniqueDates.toList()..sort((a, b) => a.compareTo(b));

    if (sortedDates.isEmpty) return 0;
    if (sortedDates.length == 1) return 1;

    int currentStreak = 1;
    int longestStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      // Mevcut tarih ile önceki tarih arasındaki fark tam olarak 1 gün mü?
      final expectedPreviousDay = DateTime(sortedDates[i].year, sortedDates[i].month, sortedDates[i].day - 1);

      if (sortedDates[i - 1].isSameDayWith(expectedPreviousDay)) {
        // Ardışık günler - streak'i artır
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        // Ardışık değil - yeni streak başlat
        currentStreak = 1;
      }
    }

    return longestStreak;
  }

  // Calculate the current streak (consecutive days until today or yesterday)
  int calculateCurrentStreak() {
    // Tamamlanmış günleri al
    final completions = values.where((completion) => completion.isCompleted).map((completion) => completion.date.normalized).toList();

    if (completions.isEmpty) return 0;

    // Mükerrer günleri kaldır
    final uniqueDates = <DateTime>{};
    for (var date in completions) {
      uniqueDates.add(date);
    }

    // Azalan sıralama yap (en yeni tarihten eskiye)
    final sortedDates = uniqueDates.toList()..sort((a, b) => b.compareTo(a));

    final today = DateTime.now().normalized;
    final yesterday = DateTime(today.year, today.month, today.day - 1);

    // En son tamamlanan gün bugün veya dün değilse, streak yoktur
    if (!sortedDates.first.isSameDayWith(today) && !sortedDates.first.isSameDayWith(yesterday)) {
      return 0;
    }

    int streak = 1;
    DateTime currentDate = sortedDates.first;

    // Ardışık günleri geriye doğru kontrol et
    for (int i = 1; i < sortedDates.length; i++) {
      final expectedNextDay = DateTime(currentDate.year, currentDate.month, currentDate.day - 1);

      if (sortedDates[i].isSameDayWith(expectedNextDay)) {
        // Ardışık bir gün bulundu
        streak++;
        currentDate = sortedDates[i];
      } else {
        // Ardışık olmayan bir gün bulundu, streak sona erdi
        break;
      }
    }

    return streak;
  }

  // Check if a specific date has a completion
  bool isDateCompleted(DateTime date) {
    // Look through all completion entries to find one with the same date
    for (final entry in values) {
      if (entry.date.normalized.isSameDayWith(date.normalized) && entry.isCompleted) {
        return true;
      }
    }
    return false;
  }

  // Get recorded count for a specific date (0 if none)
  int getCountForDate(DateTime date) {
    for (final entry in values) {
      if (entry.date.normalized.isSameDayWith(date.normalized)) {
        return entry.count;
      }
    }
    return 0;
  }

  // Get completion ratio for a date given a dailyTarget
  double getCompletionRatioForDate(DateTime date, int dailyTarget) {
    if (dailyTarget <= 0) return 0.0;
    final count = getCountForDate(date);
    final ratio = count / dailyTarget;
    return ratio.clamp(0.0, 1.0);
  }

  // Calculate weighted formation score using per-day ratio (sum of ratios)
  double calculateWeightedFormationScore(int dailyTarget) {
    if (isEmpty) return 0.0;
    if (dailyTarget <= 0) dailyTarget = 1;

    // Sum ratios per calendar day (cap 1.0 per day)
    final Map<DateTime, double> ratioByDay = {};
    for (final entry in values) {
      final day = entry.date.normalized;
      final ratio = (entry.count / dailyTarget).clamp(0.0, 1.0);
      final current = ratioByDay[day] ?? 0.0;
      ratioByDay[day] = (current + ratio).clamp(0.0, 1.0);
    }
    return ratioByDay.values.fold(0.0, (sum, r) => sum + r);
  }

  // Calculate formation score based on first completion date (for proper formation calculation)
  int calculateFormationScoreFromFirstCompletion() {
    if (isEmpty) return 0;

    final firstCompletionDate = getFirstCompletionDate();
    if (firstCompletionDate == null) return 0;

    final startDate = DateUtils.dateOnly(firstCompletionDate);

    // Count completed entries that occur on or after the first completion date
    return values.where((entry) => entry.isCompleted && !entry.date.normalized.isBefore(startDate)).length;
  }

  // Calculate formation progress percentage (0.0 to 1.0)
  double calculateFormationProgress(int totalFormationDays, int dailyTarget) {
    if (totalFormationDays <= 0) return 0.0;
    final weighted = calculateWeightedFormationScore(dailyTarget);
    return (weighted / totalFormationDays).clamp(0.0, 1.0);
  }

  // Get remaining days for formation
  int getRemainingFormationDays(int totalFormationDays) {
    final completedDays = calculateFormationScoreFromFirstCompletion();
    final remaining = totalFormationDays - completedDays;
    return remaining > 0 ? remaining : 0;
  }

  // Calculate probabilistic habit formation using P(t) = 1 - exp(-alpha * R / D)
  // Returns percentage in range [0, 99.9] to respect asymptote at 100
  // Habit Formation Probability
  double calculateHabitProbability(DateTime habitCreationDate, int estimatedFormationDays, double minimumCompletionRate, int dailyTarget) {
    if (isEmpty) return 0.0;

    // R(t): repetitions up to now. We use weighted day-count based on dailyTarget, capped at 1.0 per day
    final double repetitions = calculateWeightedFormationScore(dailyTarget);

    // D: difficulty scale derived from estimated formation days
    // Using half of estimated days moderates growth speed and avoids instant saturation
    final double difficultyScale = (estimatedFormationDays / 2).clamp(1, double.infinity).toDouble();

    // alpha: emotional reward factor. Until explicit signals exist, use a neutral base
    // We lightly bias alpha by minimumCompletionRate to reflect habit demand/reinforcement
    final double alpha = (0.8 + (minimumCompletionRate * 0.4)).clamp(0.1, 2.0);

    // Compute probability
    final double exponent = -alpha * (repetitions / difficultyScale);
    final double probability = 1 - math.exp(exponent);

    // Convert to percentage and cap below 100 to honor asymptote
    final double percentage = (probability * 100.0).clamp(0.0, 99.9);
    return percentage;
  }

  // Get the first completion date (earliest date when user started tracking this habit)
  DateTime? getFirstCompletionDate() {
    if (isEmpty) return null;

    // Find the earliest completion entry
    DateTime? earliestDate;
    for (final entry in values) {
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
    if (isEmpty) return 0.0;

    // Get all completion dates and find the earliest
    final sortedDates = values.map((entry) => entry.date).toList()..sort();
    final startDate = sortedDates.first;
    final today = DateTime.now();

    // Calculate days since start (including today)
    final daysSinceStart = today.difference(startDate).inDays + 1;

    // Count completed entries, excluding retroactive ones
    final completedEntries = values.where((entry) => entry.isCompleted).length;

    // Calculate completion rate percentage
    return daysSinceStart > 0 ? (completedEntries / daysSinceStart) * 100.0 : 0.0;
  }

  // Calculate progress percentage based on first completion date (for proper formation calculation)
  double calculateProgressPercentageFromFirstCompletion() {
    if (isEmpty) return 0.0;

    final today = DateTime.now();
    final firstCompletionDate = getFirstCompletionDate();
    if (firstCompletionDate == null) return 0.0;

    final startDate = DateUtils.dateOnly(firstCompletionDate);

    // Calculate days since first completion (including today)
    final daysSinceStart = today.difference(startDate).inDays + 1;

    // Count completed entries that occur on or after the first completion date
    final completedEntries = values.where((entry) => entry.isCompleted && !entry.date.normalized.isBefore(startDate)).length;

    // Calculate completion rate percentage (cap at 100%)
    final percentage = daysSinceStart > 0 ? (completedEntries / daysSinceStart) * 100.0 : 0.0;
    return percentage.clamp(0.0, 100.0);
  }

  // Weighted progress percentage since first completion using per-day ratios (0..100)
  double calculateWeightedProgressPercentageFromFirstCompletion(int dailyTarget) {
    if (isEmpty) return 0.0;

    final firstCompletionDate = getFirstCompletionDate();
    if (firstCompletionDate == null) return 0.0;

    final startDate = DateUtils.dateOnly(firstCompletionDate);
    final today = DateTime.now();
    final daysSinceStart = today.difference(startDate).inDays + 1;
    if (daysSinceStart <= 0) return 0.0;

    final effectiveTarget = dailyTarget <= 0 ? 1 : dailyTarget;
    final Map<DateTime, double> ratioByDay = {};
    for (final entry in values) {
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
