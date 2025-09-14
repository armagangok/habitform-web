import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitrise/models/completion_entry/completion_extension.dart';

import '/core/core.dart';
import '/features/home/provider/home_provider.dart';
import '/features/purchase/providers/purchase_provider.dart';
import '/models/habit/habit_model.dart';
import '/services/habit_service/habit_service_interface.dart';
import '/services/habit_service/mock_habit_service.dart';
import 'habit_formation_state.dart';

/// Provider for managing statistics
final formationProvider = AutoDisposeAsyncNotifierProvider<FormationNotifier, FormtionState>(() {
  return FormationNotifier();
});

/// Notifier class that handles all statistics-related operations
class FormationNotifier extends AutoDisposeAsyncNotifier<FormtionState> {
  late final MockHabitService _mockHabitService = MockHabitService();

  @override
  Future<FormtionState> build() async {
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

  Future<FormtionState> _getStatistics(bool isProUser) async {
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
          return FormtionState.initial();
        },
      );
    } else {
      // Free user - use mock data
      final mockHabits = await _mockHabitService.getHabits();
      return calculateStatistics(mockHabits, isMockData: true);
    }
  }

  /// Calculates all statistics based on habits data
  FormtionState calculateStatistics(List<Habit> habits, {bool isMockData = false}) {
    // Hiç alışkanlık yoksa veya tüm alışkanlıkların tamamlanma verisi yoksa boş istatistikler döndür
    if (habits.isEmpty || _hasNoCompletionData(habits)) {
      return FormtionState.initial(isMockData: isMockData);
    }

    final totalCompletions = _countTotalCompletions(habits);

    // Calculate habit-specific statistics
    final habitStatistics = _calculateHabitStatistics(habits);

    return FormtionState(
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

  /// Counts total number of completed days across all habits using extension methods
  int _countTotalCompletions(List<Habit> habits) {
    int total = 0;
    for (final habit in habits) {
      total += habit.completions.calculateFormationScore();
    }
    return total;
  }

  /// Calculates per-habit statistics using extension methods
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
          difficulty: null,
        );
        continue;
      }

      // Use extension methods for consistent calculations
      final completedDays = habit.completions.calculateFormationScore();
      final progressPercentage = habit.completions.calculateProgressPercentage();

      // Get start date from the earliest completion entry
      final sortedDates = habit.completions.values.map((entry) => DateUtils.dateOnly(entry.date)).toList()..sort();
      final startDate = sortedDates.first;

      // Calculate total days since start
      final daysSinceStart = today.difference(startDate).inDays + 1;

      result[habit.id] = HabitStatistic(
        habitId: habit.id,
        habitName: habit.habitName,
        totalDays: daysSinceStart,
        completedDays: completedDays,
        progressPercentage: progressPercentage,
        startDate: startDate,
        difficulty: null,
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
