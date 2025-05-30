import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/features/home/provider/home_provider.dart';
import '/features/purchase/providers/purchase_provider.dart';
import '/models/habit/habit_model.dart';
import '/services/habit_service/habit_service_interface.dart';
import '/services/habit_service/mock_habit_service.dart';
import 'statistics_state.dart';

/// Provider for managing statistics
final statisticsProvider = AutoDisposeAsyncNotifierProvider<StatisticsNotifier, StatisticsState>(() {
  return StatisticsNotifier();
});

/// Notifier class that handles all statistics-related operations
class StatisticsNotifier extends AutoDisposeAsyncNotifier<StatisticsState> {
  late final MockHabitService _mockHabitService = MockHabitService();

  @override
  Future<StatisticsState> build() async {
    // Check if user is pro
    final purchaseState = ref.watch(purchaseProvider);
    final isProUser = purchaseState.value?.isSubscriptionActive ?? false;

    // HomeProvider'dan alışkanlıkları dinle
    ref.listen(homeProvider, (previous, next) async {
      if (next is AsyncData && next.value != null) {
        // HomeProvider güncellendiğinde istatistikleri yeniden hesapla
        final purchaseState = ref.read(purchaseProvider);
        final isProUser = purchaseState.value?.isSubscriptionActive ?? false;
        state = AsyncData(await _getStatistics(isProUser));
      }
    });

    // Listen to purchase state changes to refresh stats when subscription status changes
    ref.listen(purchaseProvider, (previous, next) async {
      if (previous?.value?.isSubscriptionActive != next.value?.isSubscriptionActive) {
        final isProUser = next.value?.isSubscriptionActive ?? false;
        state = AsyncData(await _getStatistics(isProUser));
      }
    });

    return _getStatistics(isProUser);
  }

  Future<StatisticsState> _getStatistics(bool isProUser) async {
    if (isProUser) {
      // Pro user - use real data
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
    } else {
      // Free user - use mock data
      final mockHabits = await _mockHabitService.getHabits();
      return calculateStatistics(mockHabits, isMockData: true);
    }
  }

  /// Calculates all statistics based on habits data
  StatisticsState calculateStatistics(List<Habit> habits, {bool isMockData = false}) {
    // Hiç alışkanlık yoksa veya tüm alışkanlıkların tamamlanma verisi yoksa boş istatistikler döndür
    if (habits.isEmpty || _hasNoCompletionData(habits)) {
      return StatisticsState.initial(isMockData: isMockData);
    }

    final totalCompletions = _countTotalCompletions(habits);

    // Calculate habit-specific statistics
    final habitStatistics = _calculateHabitStatistics(habits);

    return StatisticsState(
      totalCompletedDays: totalCompletions,
      habitStatistics: habitStatistics,
      isMockData: isMockData,
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
