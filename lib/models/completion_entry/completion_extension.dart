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

  // Calculate formation score based on completed days
  int calculateFormationScore() {
    if (isEmpty) return 0;
    // Count distinct completed entries, excluding retroactive ones
    return values.where((entry) => entry.isCompleted == true).length;
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
  double calculateFormationProgress(int totalFormationDays) {
    if (totalFormationDays <= 0) return 0.0;
    final completedDays = calculateFormationScore();
    return (completedDays / totalFormationDays).clamp(0.0, 1.0);
  }

  // Get remaining days for formation
  int getRemainingFormationDays(int totalFormationDays) {
    final completedDays = calculateFormationScore();
    final remaining = totalFormationDays - completedDays;
    return remaining > 0 ? remaining : 0;
  }

  // Calculate formation likelihood score (0-100) based on completion rate vs difficulty requirements
  double calculateFormationLikelihoodScore(int totalFormationDays, double minimumCompletionRate) {
    if (totalFormationDays <= 0) return 0.0;

    final completedDays = calculateFormationScore();
    final completionRate = (completedDays / totalFormationDays) * 100;

    // Calculate how much above/below the minimum requirement
    final scoreAboveMinimum = completionRate - (minimumCompletionRate * 100);

    // Scale the score: 0-100 where 100 means excellent formation likelihood
    if (scoreAboveMinimum >= 15) {
      return 100.0; // Excellent (>90% likelihood)
    } else if (scoreAboveMinimum >= 5) {
      return 70.0 + (scoreAboveMinimum - 5) * 3; // Good (70-90% likelihood)
    } else if (scoreAboveMinimum >= 0) {
      return 50.0 + scoreAboveMinimum * 4; // Moderate (50-70% likelihood)
    } else {
      // For below minimum, show progress from 0-50 based on how close to minimum
      final progressToMinimum = (completionRate / (minimumCompletionRate * 100)).clamp(0.0, 1.0);
      return progressToMinimum * 50.0; // 0-50 range for below minimum
    }
  }

  // Calculate habit formation probability based on difficulty and completion history
  double calculateFormationProbability(DateTime habitCreationDate, int estimatedFormationDays, double minimumCompletionRate) {
    if (isEmpty || estimatedFormationDays <= 0) return 0.0;

    final today = DateTime.now();

    // Find the first completion date (the earliest date when user started tracking this habit)
    final firstCompletionDate = getFirstCompletionDate();
    if (firstCompletionDate == null) return 0.0;

    final startDate = DateUtils.dateOnly(firstCompletionDate);
    final daysSinceStart = today.difference(startDate).inDays + 1;

    // Calculate completion rate from first completion to today (or up to estimated formation days)
    final completedDays = values.where((entry) => entry.isCompleted && !entry.date.normalized.isBefore(startDate)).length;

    // Use the minimum of days since start or estimated formation days for calculation
    final calculationPeriod = daysSinceStart < estimatedFormationDays ? daysSinceStart : estimatedFormationDays;
    final completionRate = calculationPeriod > 0 ? (completedDays / calculationPeriod) : 0.0;

    // If we haven't reached the formation period yet, calculate probability based on current performance
    if (daysSinceStart < estimatedFormationDays) {
      // Calculate what the completion rate would be if maintained for the full formation period
      final projectedCompletionRate = completionRate; // Current rate if maintained

      // For very early stages (less than 7 days), be more generous with scoring
      if (daysSinceStart < 7) {
        if (projectedCompletionRate >= 1.0) {
          return 100.0; // Perfect completion
        } else if (projectedCompletionRate >= 0.85) {
          // 85%+ completion in early stages shows strong commitment
          return 85.0 + (projectedCompletionRate - 0.85) * 100.0; // 85-100%
        } else if (projectedCompletionRate >= 0.70) {
          // 70-85% completion in early stages is good progress
          return 70.0 + (projectedCompletionRate - 0.70) * 100.0; // 70-85%
        } else {
          // Below 70% in early stages needs improvement
          return projectedCompletionRate * 100.0; // Direct percentage
        }
      }

      // For longer periods (7+ days), use the standard calculation but with better confidence adjustment
      if (projectedCompletionRate >= minimumCompletionRate) {
        // Above minimum - calculate probability based on how much above minimum
        final excessRate = projectedCompletionRate - minimumCompletionRate;
        final baseProbability = 70.0 + (excessRate * 200.0).clamp(0.0, 30.0); // 70-100%

        // For perfect completion rate (100%), show 100% probability
        if (projectedCompletionRate >= 1.0) {
          return 100.0;
        }

        // For excellent completion rates (90%+), use minimal confidence penalty
        if (projectedCompletionRate >= 0.90) {
          final dataConfidence = (daysSinceStart / estimatedFormationDays).clamp(0.0, 1.0);
          final confidenceAdjustment = 0.9 + (dataConfidence * 0.1); // 0.9 to 1.0
          return (baseProbability * confidenceAdjustment).clamp(0.0, 100.0);
        }

        // For good completion rates (80%+), use moderate confidence penalty
        if (projectedCompletionRate >= 0.80) {
          final dataConfidence = (daysSinceStart / estimatedFormationDays).clamp(0.0, 1.0);
          final confidenceAdjustment = 0.8 + (dataConfidence * 0.2); // 0.8 to 1.0
          return (baseProbability * confidenceAdjustment).clamp(0.0, 100.0);
        }

        // Apply standard confidence factor for other cases
        final dataConfidence = (daysSinceStart / estimatedFormationDays).clamp(0.0, 1.0);
        final confidenceAdjustment = 0.7 + (dataConfidence * 0.3); // 0.7 to 1.0

        return (baseProbability * confidenceAdjustment).clamp(0.0, 100.0);
      } else {
        // Below minimum - calculate progress towards minimum with better scaling
        final progressToMinimum = (projectedCompletionRate / minimumCompletionRate).clamp(0.0, 1.0);
        final baseProbability = progressToMinimum * 70.0; // 0-70%

        // Apply confidence factor based on how much data we have
        final dataConfidence = (daysSinceStart / estimatedFormationDays).clamp(0.0, 1.0);
        final confidenceAdjustment = 0.7 + (dataConfidence * 0.3); // 0.7 to 1.0

        return (baseProbability * confidenceAdjustment).clamp(0.0, 100.0);
      }
    } else {
      // We've reached or exceeded the formation period - calculate final probability
      if (completionRate >= minimumCompletionRate) {
        // Successfully formed the habit
        final excessRate = completionRate - minimumCompletionRate;
        return (80.0 + (excessRate * 200.0)).clamp(80.0, 100.0); // 80-100%
      } else {
        // Failed to form the habit within the estimated time
        final progressToMinimum = (completionRate / minimumCompletionRate).clamp(0.0, 1.0);
        return (progressToMinimum * 80.0).clamp(0.0, 80.0); // 0-80%
      }
    }
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

  // Migration function to mark existing past date completions as retroactive
  Map<String, CompletionEntry> migrateRetroactiveCompletions() {
    final today = DateTime.now().normalized;
    final migratedCompletions = <String, CompletionEntry>{};

    for (final entry in entries) {
      final isPastDate = entry.value.date.normalized.isBefore(today);
      final shouldBeRetroactive = isPastDate;

      if (shouldBeRetroactive) {
        // Mark as retroactive
        migratedCompletions[entry.key] = entry.value;
      } else {
        // Keep as is
        migratedCompletions[entry.key] = entry.value;
      }
    }

    return migratedCompletions;
  }
}
