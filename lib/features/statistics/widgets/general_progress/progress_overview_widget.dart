import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/features/home/provider/home_provider.dart';
import '/models/completion_entry/completion_extension.dart';
import '/models/habit/habit_model.dart';
import '../../page/statistics_page.dart'; // selectedHabitIndexProvider için
import '../../provider/statistics_provider.dart';
import 'statistic_card.dart';

class ProgressOverviewWidget extends ConsumerWidget {
  const ProgressOverviewWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // StatisticsProvider'dan verileri al
    final statisticsAsyncValue = ref.watch(statisticsProvider);
    // Seçili alışkanlık indeksi
    final selectedHabitIndex = ref.watch(selectedHabitIndexProvider);
    // HomeProvider'dan alışkanlıkları al
    final homeAsyncValue = ref.watch(homeProvider);

    // Remove the condition that hides this widget when no habit is selected
    // We want to show it for all cases now, including mock data for non-pro users

    return statisticsAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('${LocaleKeys.errors_something_went_wrong.tr()}: $error')),
      data: (statisticsState) {
        // Seçili alışkanlığı al
        final habitStats = statisticsState.habitStatistics.values.toList();

        // Eğer seçili alışkanlık indeksi geçerli değilse
        if (selectedHabitIndex >= habitStats.length || selectedHabitIndex < 0) {
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

            // For mock data, we might not find the habit in the homeState
            // In that case, we'll use the statistics data directly
            bool usingMockData = statisticsState.isMockData && habitModel.id.isEmpty;

            // If we're using mock data and couldn't find the habit in homeState
            if (usingMockData) {
              // Use mock data to display statistics
              return CupertinoListSection.insetGrouped(
                header: Text(LocaleKeys.statistics_overview.tr()),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // First row
                        Row(
                          children: [
                            Expanded(
                              child: StatisticCard(
                                icon: Icons.local_fire_department,
                                title: LocaleKeys.statistics_current_streak.tr(),
                                value: "28", // Mock value for current streak
                                unit: "days",
                                cardColor: Colors.orange.withValues(alpha: 0.15),
                                iconColor: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatisticCard(
                                icon: Icons.emoji_events,
                                title: LocaleKeys.statistics_longest_streak.tr(),
                                value: "28", // Mock value for longest streak
                                unit: "days",
                                cardColor: Colors.amber.withValues(alpha: 0.15),
                                iconColor: Colors.amber,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatisticCard(
                                icon: Icons.track_changes,
                                title: "Success Rate",
                                value: "100.0",
                                unit: "%",
                                cardColor: Colors.red.withValues(alpha: 0.15),
                                iconColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Second row
                        Row(
                          children: [
                            Expanded(
                              child: StatisticCard(
                                icon: Icons.check_circle_outline,
                                title: LocaleKeys.statistics_completed.tr(),
                                value: selectedHabit.completedDays.toString(),
                                unit: "days",
                                cardColor: Colors.green.withValues(alpha: 0.15),
                                iconColor: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatisticCard(
                                icon: Icons.calendar_today,
                                title: "Days Active",
                                value: selectedHabit.totalDays.toString(),
                                unit: "days",
                                cardColor: Colors.blue.withValues(alpha: 0.15),
                                iconColor: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatisticCard(
                                icon: Icons.eco,
                                title: "Formation Progress",
                                value: "42",
                                unit: "%",
                                cardColor: Colors.purple.withValues(alpha: 0.15),
                                iconColor: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            // Eğer alışkanlık bulunamadıysa
            if (habitModel.id.isEmpty) {
              return const SizedBox.shrink();
            }

            // Alışkanlığa özel en uzun seriyi hesapla
            final longestStreak = habitModel.completions.calculateLongestStreak();

            // Mevcut seriyi hesapla
            final currentStreak = habitModel.completions.calculateCurrentStreak();

            // Veri kontrolü
            if (selectedHabit.totalDays == 0) {
              return CupertinoListSection.insetGrouped(
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
                            color: Theme.of(context).hintColor.withValues(alpha: 0.5),
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
                                  color: Theme.of(context).hintColor.withValues(alpha: 0.7),
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
              header: Text(LocaleKeys.statistics_overview.tr()),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // First row
                      Row(
                        children: [
                          Expanded(
                            child: StatisticCard(
                              icon: Icons.local_fire_department,
                              title: LocaleKeys.statistics_current_streak.tr(),
                              value: currentStreak.toString(),
                              unit: "days",
                              cardColor: Colors.orange.withValues(alpha: 0.15),
                              iconColor: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatisticCard(
                              icon: Icons.emoji_events,
                              title: LocaleKeys.statistics_longest_streak.tr(),
                              value: longestStreak.toString(),
                              unit: "days",
                              cardColor: Colors.amber.withValues(alpha: 0.15),
                              iconColor: Colors.amber,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatisticCard(
                              icon: Icons.track_changes,
                              title: "Success Rate",
                              value: selectedHabit.totalDays > 0 ? ((selectedHabit.completedDays / selectedHabit.totalDays) * 100).toStringAsFixed(1) : "0.0",
                              unit: "%",
                              cardColor: Colors.red.withValues(alpha: 0.15),
                              iconColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Second row
                      Row(
                        children: [
                          Expanded(
                            child: StatisticCard(
                              icon: Icons.check_circle_outline,
                              title: LocaleKeys.statistics_completed.tr(),
                              value: selectedHabit.completedDays.toString(),
                              unit: "days",
                              cardColor: Colors.green.withValues(alpha: 0.15),
                              iconColor: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatisticCard(
                              icon: Icons.calendar_today,
                              title: "Days Active",
                              value: selectedHabit.totalDays.toString(),
                              unit: "days",
                              cardColor: Colors.blue.withValues(alpha: 0.15),
                              iconColor: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatisticCard(
                              icon: Icons.eco,
                              title: "Formation Progress",
                              value: selectedHabit.totalDays > 0 ? ((selectedHabit.totalDays / 66) * 100).clamp(0, 100).toStringAsFixed(0) : "0",
                              unit: "%",
                              cardColor: Colors.purple.withValues(alpha: 0.15),
                              iconColor: Colors.purple,
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
