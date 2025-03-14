import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/features/home/provider/home_provider.dart';
import '/models/habit/habit_model.dart';
import '/services/habit_service/habit_service_interface.dart';
import 'statistics_state.dart';

/// Provider for managing statistics
final statisticsProvider = AsyncNotifierProvider<StatisticsNotifier, StatisticsState>(() {
  return StatisticsNotifier();
});

/// Notifier class that handles all statistics-related operations
class StatisticsNotifier extends AsyncNotifier<StatisticsState> {
  @override
  Future<StatisticsState> build() async {
    // HomeProvider'dan alışkanlıkları dinle
    ref.listen(homeProvider, (previous, next) {
      if (next is AsyncData && next.value != null) {
        // HomeProvider güncellendiğinde istatistikleri yeniden hesapla
        state = AsyncData(calculateStatistics(next.value!.habits));
      }
    });

    // İlk yükleme için HomeProvider'dan alışkanlıkları al
    final homeState = ref.watch(homeProvider);

    return homeState.when(
      data: (data) => calculateStatistics(data.habits),
      loading: () async {
        // HomeProvider yüklenirken, servis katmanından alışkanlıkları al
        final habits = await habitService.getHabits();
        return calculateStatistics(habits);
      },
      error: (error, stackTrace) async {
        // Hata durumunda boş istatistikler döndür
        return StatisticsState.initial();
      },
    );
  }

  /// Calculates all statistics based on habits data
  StatisticsState calculateStatistics(List<Habit> habits) {
    // Hiç alışkanlık yoksa veya tüm alışkanlıkların tamamlanma verisi yoksa boş istatistikler döndür
    if (habits.isEmpty || _hasNoCompletionData(habits)) {
      return StatisticsState.initial();
    }

    final totalCompletions = _countTotalCompletions(habits);

    // Tüm alışkanlıklar için başlangıç tarihinden bugüne kadar olan toplam gün sayısını hesapla
    final today = DateUtils.dateOnly(DateTime.now());
    int totalDaysSinceStart = 0;

    for (final habit in habits) {
      if (habit.completions.isEmpty) continue;

      // Alışkanlığın başlangıç tarihini bul
      final sortedDates = habit.completions.values.map((entry) => DateUtils.dateOnly(entry.date)).toList()..sort();

      final startDate = sortedDates.first;

      // Başlangıç tarihinden bugüne kadar geçen gün sayısını ekle
      totalDaysSinceStart += today.difference(startDate).inDays + 1;
    }

    // Tamamlama oranı: toplam tamamlanan gün / toplam geçen gün
    final completionRate = totalDaysSinceStart > 0 ? (totalCompletions / totalDaysSinceStart) * 100.0 : 0.0;

    final activeDaysCount = _countActiveDays(habits);
    final longestStreak = _calculateLongestStreak(habits);

    // Calculate weekly/monthly progress
    final weeklyProgress = _calculateWeeklyProgress(habits);
    final monthlyProgress = _calculateMonthlyProgress(habits);

    // Calculate habit-specific statistics
    final habitStatistics = _calculateHabitStatistics(habits);

    // Calculate insights
    final mostProductiveDay = _findMostProductiveDay(habits);
    final mostSkippedDay = _findMostSkippedDay(habits);
    final averageDuration = _calculateAverageCompletionDuration(habits);

    // Calculate time-based comparisons
    final lastMonthVsThisMonth = _compareLastMonthToThisMonth(habits);

    // Alışkanlık bazlı haftalık ve aylık ilerleme verilerini hesapla
    final habitWeeklyProgress = _calculateHabitWeeklyProgress(habits);
    final habitMonthlyProgress = _calculateHabitMonthlyProgress(habits);

    // Alışkanlık ID'lerini ve haftalık/aylık ilerleme verilerini eşleştir
    final Map<String, Map<String, double>> habitWeeklyProgressMap = {};
    final Map<String, Map<String, double>> habitMonthlyProgressMap = {};

    for (int i = 0; i < habits.length; i++) {
      final habit = habits[i];
      habitWeeklyProgressMap[habit.id] = habitWeeklyProgress[i];
      habitMonthlyProgressMap[habit.id] = habitMonthlyProgress[i];
    }

    return StatisticsState(
      totalCompletedDays: totalCompletions,
      completionRate: completionRate,
      activeDaysCount: activeDaysCount,
      longestStreak: longestStreak,
      weeklyProgress: weeklyProgress,
      monthlyProgress: monthlyProgress,
      habitStatistics: habitStatistics,
      mostProductiveDay: mostProductiveDay,
      mostSkippedDay: mostSkippedDay,
      averageHabitDuration: averageDuration,
      monthlyComparison: lastMonthVsThisMonth,
      habitWeeklyProgressMap: habitWeeklyProgressMap,
      habitMonthlyProgressMap: habitMonthlyProgressMap,
    );
  }

  /// Tüm alışkanlıkların tamamlanma verisi olup olmadığını kontrol eder
  bool _hasNoCompletionData(List<Habit> habits) {
    for (final habit in habits) {
      if (habit.completions.isNotEmpty) {
        return false; // En az bir alışkanlığın tamamlanma verisi var
      }
    }
    return true; // Hiçbir alışkanlığın tamamlanma verisi yok
  }

  /// Counts total number of completed days across all habits
  int _countTotalCompletions(List<Habit> habits) {
    int total = 0;
    for (final habit in habits) {
      total += habit.completions.values.where((entry) => entry.isCompleted).length;
    }
    return total;
  }

  /// Counts the number of unique days with activity
  int _countActiveDays(List<Habit> habits) {
    final Set<String> activeDays = {};

    for (final habit in habits) {
      for (final entry in habit.completions.values) {
        if (entry.isCompleted) {
          // Format: yyyy-MM-dd
          final dateString = DateFormat('yyyy-MM-dd').format(entry.date);
          activeDays.add(dateString);
        }
      }
    }

    return activeDays.length;
  }

  /// Calculates the longest streak across all habits
  int _calculateLongestStreak(List<Habit> habits) {
    int maxStreak = 0;

    for (final habit in habits) {
      final sortedCompletions = habit.completions.values.where((entry) => entry.isCompleted).toList()..sort((a, b) => a.date.compareTo(b.date));

      if (sortedCompletions.isEmpty) continue;

      int currentStreak = 1;
      int longestStreak = 1;

      for (int i = 1; i < sortedCompletions.length; i++) {
        final previousDate = DateUtils.dateOnly(sortedCompletions[i - 1].date);
        final currentDate = DateUtils.dateOnly(sortedCompletions[i].date);

        final difference = currentDate.difference(previousDate).inDays;

        if (difference == 1) {
          currentStreak++;
          longestStreak = math.max(longestStreak, currentStreak);
        } else if (difference > 1) {
          currentStreak = 1;
        }
      }

      maxStreak = math.max(maxStreak, longestStreak);
    }

    return maxStreak;
  }

  /// Calculates weekly progress for chart display
  Map<String, double> _calculateWeeklyProgress(List<Habit> habits) {
    final Map<String, int> completedByDay = {};
    final Map<String, int> totalByDay = {};
    final Map<String, double> progressByDay = {};

    // Initialize days of week
    for (int i = 0; i < 7; i++) {
      final dayName = DateFormat('E').format(DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).add(Duration(days: i)));
      completedByDay[dayName] = 0;
      totalByDay[dayName] = 0;
    }

    // Get start of current week
    final startOfWeek = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    bool hasData = false;

    for (final habit in habits) {
      for (final entry in habit.completions.values) {
        if (entry.date.isAfter(startOfWeek) && entry.date.isBefore(endOfWeek.add(const Duration(days: 1)))) {
          final dayName = DateFormat('E').format(entry.date);
          totalByDay[dayName] = (totalByDay[dayName] ?? 0) + 1;
          hasData = true;

          if (entry.isCompleted) {
            completedByDay[dayName] = (completedByDay[dayName] ?? 0) + 1;
          }
        }
      }
    }

    // Eğer hiç veri yoksa boş harita döndür
    if (!hasData) {
      return {};
    }

    // Calculate progress percentage for each day
    for (final day in totalByDay.keys) {
      if (totalByDay[day]! > 0) {
        progressByDay[day] = (completedByDay[day] ?? 0) / totalByDay[day]!;
      } else {
        progressByDay[day] = 0;
      }
    }

    return progressByDay;
  }

  /// Calculates monthly progress for chart display
  Map<String, double> _calculateMonthlyProgress(List<Habit> habits) {
    final Map<String, int> completedByDay = {};
    final Map<String, int> totalByDay = {};
    final Map<String, double> progressByDay = {};

    // Initialize days of month
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);

    for (int i = 1; i <= daysInMonth; i++) {
      final dayString = i.toString();
      completedByDay[dayString] = 0;
      totalByDay[dayString] = 0;
    }

    // Get start and end of current month
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    bool hasData = false;

    for (final habit in habits) {
      for (final entry in habit.completions.values) {
        if (entry.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) && entry.date.isBefore(endOfMonth.add(const Duration(days: 1)))) {
          final dayString = entry.date.day.toString();
          totalByDay[dayString] = (totalByDay[dayString] ?? 0) + 1;
          hasData = true;

          if (entry.isCompleted) {
            completedByDay[dayString] = (completedByDay[dayString] ?? 0) + 1;
          }
        }
      }
    }

    // Eğer hiç veri yoksa boş harita döndür
    if (!hasData) {
      return {};
    }

    // Calculate progress percentage for each day
    for (final day in totalByDay.keys) {
      if (totalByDay[day]! > 0) {
        progressByDay[day] = (completedByDay[day] ?? 0) / totalByDay[day]!;
      } else {
        progressByDay[day] = 0;
      }
    }

    return progressByDay;
  }

  /// Calculates per-habit statistics
  Map<String, HabitStatistic> _calculateHabitStatistics(List<Habit> habits) {
    final Map<String, HabitStatistic> result = {};
    final today = DateUtils.dateOnly(DateTime.now());

    for (final habit in habits) {
      // Eğer hiç tamamlama verisi yoksa, boş istatistik döndür
      if (habit.completions.isEmpty) {
        result[habit.id] = HabitStatistic(
          habitId: habit.id,
          habitName: habit.habitName,
          totalDays: 0,
          completedDays: 0,
          progressPercentage: 0,
          startDate: today,
        );
        continue;
      }

      // Alışkanlığın başlangıç tarihini bul (en eski tamamlama kaydı)
      final sortedDates = habit.completions.values.map((entry) => DateUtils.dateOnly(entry.date)).toList()..sort();

      final startDate = sortedDates.first;

      // Başlangıç tarihinden bugüne kadar geçen toplam gün sayısı
      final daysSinceStart = today.difference(startDate).inDays + 1; // Bugünü de dahil et

      // Tamamlanan günlerin sayısı
      final completedEntries = habit.completions.values.where((entry) => entry.isCompleted).length;

      // Tamamlama oranı: tamamlanan gün sayısı / başlangıçtan bugüne geçen gün sayısı
      final completionRate = daysSinceStart > 0 ? (completedEntries / daysSinceStart) * 100.0 : 0.0;

      result[habit.id] = HabitStatistic(
        habitId: habit.id,
        habitName: habit.habitName,
        totalDays: daysSinceStart,
        completedDays: completedEntries,
        progressPercentage: completionRate,
        startDate: startDate,
      );
    }

    return result;
  }

  /// Finds the most productive day of the week
  String _findMostProductiveDay(List<Habit> habits) {
    final Map<String, int> completionsByDay = {};
    final Map<String, int> totalByDay = {};

    // Initialize days
    for (int i = 0; i < 7; i++) {
      final dayName = DateFormat('EEEE').format(DateTime.now().subtract(Duration(days: i)));
      completionsByDay[dayName] = 0;
      totalByDay[dayName] = 0;
    }

    bool hasData = false;

    for (final habit in habits) {
      for (final entry in habit.completions.values) {
        final dayName = DateFormat('EEEE').format(entry.date);
        totalByDay[dayName] = (totalByDay[dayName] ?? 0) + 1;
        hasData = true;

        if (entry.isCompleted) {
          completionsByDay[dayName] = (completionsByDay[dayName] ?? 0) + 1;
        }
      }
    }

    // Eğer hiç veri yoksa boş string döndür
    if (!hasData) {
      return "";
    }

    // Find day with highest completion rate
    String mostProductiveDay = "";
    double highestRate = 0;

    for (final day in totalByDay.keys) {
      if (totalByDay[day]! > 0) {
        final rate = (completionsByDay[day] ?? 0) / totalByDay[day]!;
        if (rate > highestRate) {
          highestRate = rate;
          mostProductiveDay = day;
        }
      }
    }

    return mostProductiveDay;
  }

  /// Finds the most skipped day of the week
  String _findMostSkippedDay(List<Habit> habits) {
    final Map<String, int> skipsByDay = {};
    final Map<String, int> totalByDay = {};

    // Initialize days
    for (int i = 0; i < 7; i++) {
      final dayName = DateFormat('EEEE').format(DateTime.now().subtract(Duration(days: i)));
      skipsByDay[dayName] = 0;
      totalByDay[dayName] = 0;
    }

    bool hasData = false;

    for (final habit in habits) {
      for (final entry in habit.completions.values) {
        final dayName = DateFormat('EEEE').format(entry.date);
        totalByDay[dayName] = (totalByDay[dayName] ?? 0) + 1;
        hasData = true;

        if (!entry.isCompleted) {
          skipsByDay[dayName] = (skipsByDay[dayName] ?? 0) + 1;
        }
      }
    }

    // Eğer hiç veri yoksa boş string döndür
    if (!hasData) {
      return "";
    }

    // Find day with highest skip rate
    String mostSkippedDay = "";
    double highestRate = 0;

    for (final day in totalByDay.keys) {
      if (totalByDay[day]! > 0) {
        final rate = (skipsByDay[day] ?? 0) / totalByDay[day]!;
        if (rate > highestRate) {
          highestRate = rate;
          mostSkippedDay = day;
        }
      }
    }

    return mostSkippedDay;
  }

  /// Calculates average time spent on habits (if available)
  double _calculateAverageCompletionDuration(List<Habit> habits) {
    // This would depend on additional tracking of duration which may not be implemented
    // For now, return a placeholder value or estimate
    return 0; // minutes
  }

  /// Compares this month's progress to last month
  MonthlyComparison _compareLastMonthToThisMonth(List<Habit> habits) {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    final lastMonth = DateTime(thisMonth.year, thisMonth.month - 1);

    int thisMonthCompleted = 0;
    int thisMonthTotal = 0;
    int lastMonthCompleted = 0;
    int lastMonthTotal = 0;

    bool hasData = false;

    for (final habit in habits) {
      for (final entry in habit.completions.values) {
        final entryMonth = DateTime(entry.date.year, entry.date.month);

        if (entryMonth.isAtSameMomentAs(thisMonth)) {
          thisMonthTotal++;
          hasData = true;
          if (entry.isCompleted) {
            thisMonthCompleted++;
          }
        } else if (entryMonth.isAtSameMomentAs(lastMonth)) {
          lastMonthTotal++;
          hasData = true;
          if (entry.isCompleted) {
            lastMonthCompleted++;
          }
        }
      }
    }

    // Eğer hiç veri yoksa varsayılan karşılaştırma döndür
    if (!hasData) {
      return MonthlyComparison(
        thisMonthRate: 0,
        lastMonthRate: 0,
        difference: 0,
        isImprovement: false,
      );
    }

    final thisMonthRate = thisMonthTotal > 0 ? (thisMonthCompleted / thisMonthTotal) * 100.0 : 0.0;
    final lastMonthRate = lastMonthTotal > 0 ? (lastMonthCompleted / lastMonthTotal) * 100.0 : 0.0;
    final difference = thisMonthRate - lastMonthRate;

    return MonthlyComparison(
      thisMonthRate: thisMonthRate,
      lastMonthRate: lastMonthRate,
      difference: difference,
      isImprovement: difference > 0,
    );
  }

  /// Calculates weekly progress for each habit
  List<Map<String, double>> _calculateHabitWeeklyProgress(List<Habit> habits) {
    List<Map<String, double>> result = [];

    for (final habit in habits) {
      final Map<String, int> completedByDay = {};
      final Map<String, int> totalByDay = {};
      final Map<String, double> progressByDay = {};

      // Initialize days of week
      for (int i = 0; i < 7; i++) {
        final dayName = DateFormat('E').format(DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).add(Duration(days: i)));
        completedByDay[dayName] = 0;
        totalByDay[dayName] = 0;
      }

      // Get start of current week
      final startOfWeek = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      bool hasData = false;

      // Sadece bu alışkanlık için verileri hesapla
      for (final entry in habit.completions.values) {
        if (entry.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && entry.date.isBefore(endOfWeek.add(const Duration(days: 1)))) {
          final dayName = DateFormat('E').format(entry.date);
          totalByDay[dayName] = (totalByDay[dayName] ?? 0) + 1;
          hasData = true;

          if (entry.isCompleted) {
            completedByDay[dayName] = (completedByDay[dayName] ?? 0) + 1;
          }
        }
      }

      // Eğer hiç veri yoksa boş harita döndür
      if (!hasData) {
        result.add({});
        continue;
      }

      // Calculate progress percentage for each day
      for (final day in totalByDay.keys) {
        if (totalByDay[day]! > 0) {
          progressByDay[day] = (completedByDay[day] ?? 0) / totalByDay[day]!;
        } else {
          progressByDay[day] = 0;
        }
      }

      result.add(progressByDay);
    }

    return result;
  }

  /// Calculates monthly progress for each habit
  List<Map<String, double>> _calculateHabitMonthlyProgress(List<Habit> habits) {
    List<Map<String, double>> result = [];

    for (final habit in habits) {
      final Map<String, int> completedByDay = {};
      final Map<String, int> totalByDay = {};
      final Map<String, double> progressByDay = {};

      // Initialize days of month
      final now = DateTime.now();
      final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);

      for (int i = 1; i <= daysInMonth; i++) {
        final dayString = i.toString();
        completedByDay[dayString] = 0;
        totalByDay[dayString] = 0;
      }

      // Get start and end of current month
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      bool hasData = false;

      // Sadece bu alışkanlık için verileri hesapla
      for (final entry in habit.completions.values) {
        if (entry.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) && entry.date.isBefore(endOfMonth.add(const Duration(days: 1)))) {
          final dayString = entry.date.day.toString();
          totalByDay[dayString] = (totalByDay[dayString] ?? 0) + 1;
          hasData = true;

          if (entry.isCompleted) {
            completedByDay[dayString] = (completedByDay[dayString] ?? 0) + 1;
          }
        }
      }

      // Eğer hiç veri yoksa boş harita döndür
      if (!hasData) {
        result.add({});
        continue;
      }

      // Calculate progress percentage for each day
      for (final day in totalByDay.keys) {
        if (totalByDay[day]! > 0) {
          progressByDay[day] = (completedByDay[day] ?? 0) / totalByDay[day]!;
        } else {
          progressByDay[day] = 0;
        }
      }

      result.add(progressByDay);
    }

    return result;
  }

  /// Refreshes all statistics
  Future<void> refreshStatistics() async {
    // HomeProvider'ı yenile, bu otomatik olarak statisticsProvider'ı da güncelleyecek
    ref.invalidate(homeProvider);
  }
}
