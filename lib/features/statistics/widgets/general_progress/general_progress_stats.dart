import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/features/home/provider/home_provider.dart';
import '/models/completion_entry/completion_extension.dart';
import '/models/habit/habit_model.dart';
import '../../page/statistics_page.dart'; // selectedHabitIndexProvider için
import '../../provider/statistics_provider.dart';
import 'statistic_card.dart';

class GeneralProgressStats extends ConsumerWidget {
  const GeneralProgressStats({
    super.key,
  });

  // Calculate the longest streak for a specific habit
  int _calculateHabitLongestStreak(Habit habit) {
    final sortedCompletions = habit.completions.values.where((entry) => entry.isCompleted).toList()..sort((a, b) => a.date.compareTo(b.date));

    if (sortedCompletions.isEmpty) return 0;

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

    return longestStreak;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // StatisticsProvider'dan verileri al
    final statisticsAsyncValue = ref.watch(statisticsProvider);
    // Seçili alışkanlık indeksi
    final selectedHabitIndex = ref.watch(selectedHabitIndexProvider);
    // HomeProvider'dan alışkanlıkları al
    final homeAsyncValue = ref.watch(homeProvider);

    // Eğer hiçbir alışkanlık seçili değilse (genel görünüm) bu widget'ı göster
    // Artık tam tersine, bir alışkanlık seçiliyse göstereceğiz
    if (selectedHabitIndex == -1) {
      return const SizedBox.shrink();
    }

    return statisticsAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('${LocaleKeys.errors_something_went_wrong.tr()}: $error')),
      data: (statisticsState) {
        // Seçili alışkanlığı al
        final habitStats = statisticsState.habitStatistics.values.toList();

        // Eğer seçili alışkanlık indeksi geçerli değilse
        if (selectedHabitIndex >= habitStats.length) {
          return const SizedBox.shrink();
        }

        // Seçili alışkanlığı al
        final selectedHabit = habitStats[selectedHabitIndex];

        return homeAsyncValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('${LocaleKeys.errors_something_went_wrong.tr()}: $error')),
          data: (homeState) {
            // Seçili alışkanlığın tam modelini bul
            final habitModel = homeState.habits.firstWhere(
              (h) => h.id == selectedHabit.habitId,
              orElse: () => Habit(
                id: '',
                habitName: '',
                colorCode: 0,
                completions: {},
              ),
            );

            // Eğer alışkanlık bulunamadıysa
            if (habitModel.id.isEmpty) {
              return const SizedBox.shrink();
            }

            // Alışkanlığa özel en uzun seriyi hesapla
            final longestStreak = _calculateHabitLongestStreak(habitModel);

            // Mevcut seriyi hesapla
            final currentStreak = habitModel.completions.calculateCurrentStreak();

            // Veri kontrolü
            if (selectedHabit.totalDays == 0) {
              return CupertinoListSection.insetGrouped(
                backgroundColor: Colors.transparent,
                header: Text(LocaleKeys.statistics_overview.tr()),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.assessment,
                            size: 48,
                            color: Theme.of(context).hintColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            LocaleKeys.statistics_no_data_for_habit.tr(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            LocaleKeys.statistics_start_tracking_habit.tr(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).hintColor.withOpacity(0.7),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return CupertinoListSection.insetGrouped(
              backgroundColor: Colors.transparent,
              header: Text(LocaleKeys.statistics_overview.tr()),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: StatisticCard(
                              icon: Icons.check_circle_outline,
                              title: LocaleKeys.statistics_completed.tr(),
                              value: selectedHabit.completedDays.toString(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StatisticCard(
                              icon: Icons.calendar_today,
                              title: LocaleKeys.statistics_total_days.tr(),
                              value: selectedHabit.totalDays.toString(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: StatisticCard(
                              icon: Icons.local_fire_department,
                              title: LocaleKeys.statistics_longest_streak.tr(),
                              value: longestStreak.toString(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StatisticCard(
                              icon: Icons.trending_up,
                              title: LocaleKeys.statistics_current_streak.tr(),
                              value: currentStreak.toString(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
