import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/features/home/provider/home_provider.dart';
import '/models/habit/habit_model.dart';
import '/services/habit_service/habit_service_interface.dart';
import 'statistics_state.dart';

/// Provider for managing statistics
final statisticsProvider = AutoDisposeAsyncNotifierProvider<StatisticsNotifier, StatisticsState>(() {
  return StatisticsNotifier();
});

/// Notifier class that handles all statistics-related operations
class StatisticsNotifier extends AutoDisposeAsyncNotifier<StatisticsState> {
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

    final longestStreak = _calculateLongestStreak(habits);

    // Calculate weekly/monthly progress
    final weeklyProgress = _calculateWeeklyProgress(habits);
    final monthlyProgress = _calculateMonthlyProgress(habits);

    // Calculate habit-specific statistics
    final habitStatistics = _calculateHabitStatistics(habits);

    return StatisticsState(
      totalCompletedDays: totalCompletions,
      completionRate: completionRate,
      longestStreak: longestStreak,
      weeklyProgress: weeklyProgress,
      monthlyProgress: monthlyProgress,
      habitStatistics: habitStatistics,
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
        if (entry.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && entry.date.isBefore(endOfWeek.add(const Duration(days: 1)))) {
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

  /// Refreshes all statistics
  Future<void> refreshStatistics() async {
    // HomeProvider'ı yenile, bu otomatik olarak statisticsProvider'ı da güncelleyecek
    ref.invalidate(homeProvider);
  }
}
