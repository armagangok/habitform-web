import 'package:habitrise/core/extension/datetime_extension.dart';

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
    final dateKey = date.toIso8601DateString;
    return containsKey(dateKey) && this[dateKey]?.isCompleted == true;
  }

  // Calculate formation score based on completed days
  int calculateFormationScore() {
    if (isEmpty) return 0;
    // Count distinct completed entries
    return values.where((entry) => entry.isCompleted == true).length;
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

  // Calculate progress percentage like statistics page (completion rate from start to today)
  double calculateProgressPercentage() {
    if (isEmpty) return 0.0;

    // Get all completion dates and find the earliest
    final sortedDates = values.map((entry) => entry.date).toList()..sort();
    final startDate = sortedDates.first;
    final today = DateTime.now();

    // Calculate days since start (including today)
    final daysSinceStart = today.difference(startDate).inDays + 1;

    // Count completed entries
    final completedEntries = values.where((entry) => entry.isCompleted).length;

    // Calculate completion rate percentage
    return daysSinceStart > 0 ? (completedEntries / daysSinceStart) * 100.0 : 0.0;
  }
}
