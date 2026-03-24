import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/habit/habit_extension.dart';

import '/core/core.dart';
import '/features/home/provider/home_provider.dart';
import '/features/purchase/providers/purchase_provider.dart';
import '/models/habit/habit_difficulty.dart';
import '/models/habit/habit_model.dart';
import '/services/habit_service/habit_service_interface.dart';
import '/services/habit_service/mock_habit_service.dart';
import 'habit_probability_state.dart';

/// Provider for managing statistics
final probabilityProvider = AutoDisposeAsyncNotifierProvider<ProbabilityNotifier, ProbabilityState>(() {
  return ProbabilityNotifier();
});

/// Notifier class that handles all statistics-related operations
class ProbabilityNotifier extends AutoDisposeAsyncNotifier<ProbabilityState> {
  late final MockHabitService _mockHabitService = MockHabitService();

  // Caching and debouncing
  ProbabilityState? _cachedState;
  DateTime? _lastCalculation;
  Timer? _debounceTimer;
  static const Duration _cacheValidityDuration = Duration(minutes: 1);
  static const Duration _debounceDelay = Duration(milliseconds: 500);

  @override
  Future<ProbabilityState> build() async {
    // Clean up timer when provider is disposed
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    // Check if user is pro
    final purchaseState = ref.watch(purchaseProvider);
    final isProUser = purchaseState.value?.isSubscriptionActive ?? false;

    // HomeProvider'dan alışkanlıkları dinle
    ref.listen(homeProvider, (previous, next) async {
      if (next is AsyncData && next.value != null) {
        // HomeProvider güncellendiğinde istatistikleri yeniden hesapla
        // Use the optimized refresh method instead of direct calculation
        await refreshFormationStatistics();
      }
    });

    // Listen to purchase state changes to refresh stats when subscription status changes
    ref.listen(purchaseProvider, (previous, next) async {
      if (previous?.value?.isSubscriptionActive != next.value?.isSubscriptionActive) {
        // Force refresh when subscription status changes (clear cache)
        await forceRefreshFormationStatistics();
      }
    });

    return _getStatistics(isProUser);
  }

  Future<ProbabilityState> _getStatistics(bool isProUser) async {
    final calculationStart = DateTime.now();
    LogHelper.shared.debugPrint("🔄 [PERF] FormationProvider: _getStatistics called for ${isProUser ? 'pro' : 'free'} user");

    ProbabilityState result;

    if (isProUser) {
      // Pro user - use real data
      final homeState = ref.watch(homeProvider);

      result = await homeState.when(
        data: (data) async {
          LogHelper.shared.debugPrint("🔄 [PERF] FormationProvider: Calculating statistics for ${data.habits.length} habits");
          return calculateStatistics(data.habits);
        },
        loading: () async {
          // HomeProvider yüklenirken, servis katmanından alışkanlıkları al
          LogHelper.shared.debugPrint("🔄 [PERF] FormationProvider: HomeProvider loading, fetching habits from service");
          final habits = await habitService.getHabits();
          return calculateStatistics(habits);
        },
        error: (error, stackTrace) async {
          // Hata durumunda boş istatistikler döndür
          LogHelper.shared.errorPrint("❌ [PERF] FormationProvider: Error in homeProvider: $error");
          return ProbabilityState.initial();
        },
      );
    } else {
      // Free user - use mock data
      LogHelper.shared.debugPrint("🔄 [PERF] FormationProvider: Using mock data for free user");
      final mockHabits = await _mockHabitService.getHabits();
      result = calculateStatistics(mockHabits, isMockData: true);
    }

    final calculationEnd = DateTime.now();
    LogHelper.shared.debugPrint("✅ [PERF] FormationProvider: _getStatistics completed in ${calculationEnd.difference(calculationStart).inMilliseconds}ms");

    return result;
  }

  /// Calculates all statistics based on habits data
  ProbabilityState calculateStatistics(List<Habit> habits, {bool isMockData = false}) {
    final calculationStart = DateTime.now();
    LogHelper.shared.debugPrint("🔄 [PERF] FormationProvider: calculateStatistics called for ${habits.length} habits");

    // Hiç alışkanlık yoksa veya tüm alışkanlıkların tamamlanma verisi yoksa boş istatistikler döndür
    if (habits.isEmpty || _hasNoCompletionData(habits)) {
      LogHelper.shared.debugPrint("⚡ [PERF] FormationProvider: No completion data, returning initial state");
      return ProbabilityState.initial(isMockData: isMockData);
    }

    final totalCompletionsStart = DateTime.now();
    final totalCompletions = _countTotalCompletions(habits);
    final totalCompletionsEnd = DateTime.now();
    LogHelper.shared.debugPrint("📊 [PERF] FormationProvider: Total completions calculated in ${totalCompletionsEnd.difference(totalCompletionsStart).inMilliseconds}ms");

    // Calculate habit-specific statistics
    final habitStatsStart = DateTime.now();
    final habitStatistics = _calculateHabitStatistics(habits);
    final habitStatsEnd = DateTime.now();
    LogHelper.shared.debugPrint("📈 [PERF] FormationProvider: Habit statistics calculated in ${habitStatsEnd.difference(habitStatsStart).inMilliseconds}ms");

    final result = ProbabilityState(
      totalCompletedDays: totalCompletions,
      habitStatistics: habitStatistics,
      isMockData: isMockData,
    );

    final calculationEnd = DateTime.now();
    LogHelper.shared.debugPrint("✅ [PERF] FormationProvider: calculateStatistics completed in ${calculationEnd.difference(calculationStart).inMilliseconds}ms");

    return result;
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
      total += habit.calculateWeightedFormationScore();
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
          probabilityScore: 0.0,
          estimatedProbabilityDays: habit.difficulty.estimatedProbabilityDays,
          remainingProbabilityDays: habit.difficulty.estimatedProbabilityDays,
        );
        continue;
      }

      // Use extension methods for consistent calculations based on first completion date
      final completedDays = habit.calculateWeightedFormationScore().round();
      final progressPercentage = habit.calculateWeightedProgressPercentageFromFirstCompletion();

      // Calculate total days since first completion (for remaining days calculation)
      final firstCompletionDate = habit.getFirstCompletionDate();
      final daysSinceFirstCompletion = firstCompletionDate != null ? today.difference(DateUtils.dateOnly(firstCompletionDate)).inDays + 1 : 0;

      // Calculate formation probability and remaining days
      final estimatedProbabilityDays = habit.difficulty.estimatedProbabilityDays;
      final probabilityScore = habit.calculateHabitProbability();

      final remainingProbabilityDays = habit.getRemainingProbabilityDays();

      result[habit.id] = HabitStatistic(
        habitId: habit.id,
        habitName: habit.habitName,
        totalDays: daysSinceFirstCompletion,
        completedDays: completedDays,
        progressPercentage: progressPercentage,
        startDate: firstCompletionDate != null ? DateUtils.dateOnly(firstCompletionDate) : today,
        difficulty: habit.difficulty,
        probabilityScore: probabilityScore,
        estimatedProbabilityDays: estimatedProbabilityDays,
        remainingProbabilityDays: remainingProbabilityDays,
      );
    }

    return result;
  }

  /// Refreshes all statistics
  Future<void> refreshStatistics() async {
    // HomeProvider'ı yenile, bu otomatik olarak statisticsProvider'ı da güncelleyecek
    ref.invalidate(homeProvider);
  }

  /// Manually refresh formation statistics without invalidating home provider
  Future<void> refreshFormationStatistics() async {
    final startTime = DateTime.now();
    LogHelper.shared.debugPrint("🔄 [PERF] FormationProvider: refreshFormationStatistics called");

    // Check if we have valid cached data
    if (_cachedState != null && _lastCalculation != null && DateTime.now().difference(_lastCalculation!) < _cacheValidityDuration) {
      LogHelper.shared.debugPrint("⚡ [PERF] FormationProvider: Using cached data (${DateTime.now().difference(_lastCalculation!).inMilliseconds}ms old)");
      state = AsyncData(_cachedState!);
      return;
    }

    // Cancel any pending debounced updates
    _debounceTimer?.cancel();

    // Debounce the actual calculation
    _debounceTimer = Timer(_debounceDelay, () async {
      await _performStatisticsCalculation();
    });

    final totalTime = DateTime.now().difference(startTime);
    LogHelper.shared.debugPrint("✅ [PERF] FormationProvider: refreshFormationStatistics completed in ${totalTime.inMilliseconds}ms");
  }

  /// Perform the actual statistics calculation
  Future<void> _performStatisticsCalculation() async {
    final calculationStart = DateTime.now();
    LogHelper.shared.debugPrint("🔄 [PERF] FormationProvider: Starting actual statistics calculation");

    try {
      final purchaseState = ref.read(purchaseProvider);
      final isProUser = purchaseState.value?.isSubscriptionActive ?? false;
      final newState = await _getStatistics(isProUser);

      // Cache the result
      _cachedState = newState;
      _lastCalculation = DateTime.now();

      // Update the state
      state = AsyncData(newState);

      final calculationEnd = DateTime.now();
      LogHelper.shared.debugPrint("✅ [PERF] FormationProvider: Statistics calculation completed in ${calculationEnd.difference(calculationStart).inMilliseconds}ms");
    } catch (e) {
      LogHelper.shared.errorPrint("❌ [PERF] FormationProvider: Error calculating statistics: $e");
    }
  }

  /// Force refresh without using cache
  Future<void> forceRefreshFormationStatistics() async {
    final startTime = DateTime.now();
    LogHelper.shared.debugPrint("🔄 [PERF] FormationProvider: forceRefreshFormationStatistics called");

    // Cancel any pending debounced updates
    _debounceTimer?.cancel();

    // Clear cache
    _cachedState = null;
    _lastCalculation = null;

    // Perform immediate calculation
    await _performStatisticsCalculation();

    final totalTime = DateTime.now().difference(startTime);
    LogHelper.shared.debugPrint("✅ [PERF] FormationProvider: forceRefreshFormationStatistics completed in ${totalTime.inMilliseconds}ms");
  }
}
