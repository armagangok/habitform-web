import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitform/models/completion_entry/completion_extension.dart';

import '/core/core.dart';
import '/features/home/provider/home_provider.dart';
import '/features/purchase/providers/purchase_provider.dart';
import '/models/habit/habit_difficulty.dart';
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
    double total = 0.0;
    for (final habit in habits) {
      total += habit.completions.calculateWeightedFormationScore(habit.dailyTarget);
    }
    return total.round();
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
          difficulty: habit.difficulty,
          formationProbability: 0.0,
          estimatedFormationDays: habit.difficulty.estimatedFormationDays,
          remainingFormationDays: habit.difficulty.estimatedFormationDays,
        );
        continue;
      }

      // Get habit creation date - handle both timestamp IDs and string IDs
      final habitCreationDate = _getHabitCreationDate(habit);
      final startDate = DateUtils.dateOnly(habitCreationDate);

      // Use extension methods for consistent calculations based on first completion date
      final completedDays = habit.completions.calculateWeightedFormationScore(habit.dailyTarget).round();
      final progressPercentage = habit.completions.calculateWeightedProgressPercentageFromFirstCompletion(habit.dailyTarget);

      // Calculate total days since first completion (for remaining days calculation)
      final firstCompletionDate = habit.completions.getFirstCompletionDate();
      final daysSinceFirstCompletion = firstCompletionDate != null ? today.difference(DateUtils.dateOnly(firstCompletionDate)).inDays + 1 : 0;

      // Calculate formation probability and remaining days
      final estimatedFormationDays = habit.difficulty.estimatedFormationDays;
      final formationProbability = habit.completions.calculateFormationProbability(
        habitCreationDate, // This parameter is now ignored, but kept for compatibility
        estimatedFormationDays,
        habit.difficulty.minimumCompletionRate,
        habit.dailyTarget,
      );

      final remainingFormationDays = (estimatedFormationDays - daysSinceFirstCompletion).clamp(0, estimatedFormationDays);

      result[habit.id] = HabitStatistic(
        habitId: habit.id,
        habitName: habit.habitName,
        totalDays: daysSinceFirstCompletion,
        completedDays: completedDays,
        progressPercentage: progressPercentage,
        startDate: firstCompletionDate != null ? DateUtils.dateOnly(firstCompletionDate) : startDate,
        difficulty: habit.difficulty,
        formationProbability: formationProbability,
        estimatedFormationDays: estimatedFormationDays,
        remainingFormationDays: remainingFormationDays,
      );
    }

    return result;
  }

  /// Helper method to get habit creation date from habit ID
  /// Handles both timestamp-based IDs (real habits) and string IDs (mock habits)
  DateTime _getHabitCreationDate(Habit habit) {
    try {
      // Try to parse as timestamp (for real habits)
      final timestamp = int.parse(habit.id);
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      // If parsing fails, it's a mock habit with string ID
      // For mock habits, use a fixed date 60 days ago to simulate formation data
      return DateTime.now().subtract(const Duration(days: 60));
    }
  }

  /// Refreshes all statistics
  Future<void> refreshStatistics() async {
    // HomeProvider'ı yenile, bu otomatik olarak statisticsProvider'ı da güncelleyecek
    ref.invalidate(homeProvider);
  }

  /// Manually refresh formation statistics without invalidating home provider
  Future<void> refreshFormationStatistics() async {
    final purchaseState = ref.read(purchaseProvider);
    final isProUser = purchaseState.value?.isSubscriptionActive ?? false;
    state = AsyncData(await _getStatistics(isProUser));
  }
}
