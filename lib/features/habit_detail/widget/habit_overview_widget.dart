import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/models/completion_entry/completion_extension.dart';
import '/models/habit/habit_model.dart';
import 'statistic_card.dart';

class HabitOverviewWidget extends ConsumerWidget {
  final Habit habit;

  const HabitOverviewWidget({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate statistics for this specific habit
    final currentStreak = habit.completions.calculateCurrentStreak();
    final longestStreak = habit.completions.calculateLongestStreak();

    if (habit.completions.isEmpty) {
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

    // Calculate additional statistics using extension methods
    final successRate = habit.completions.calculateProgressPercentage();
    final completedEntries = habit.completions.calculateFormationScore();

    // Calculate days since start for display
    final today = DateUtils.dateOnly(DateTime.now());
    final sortedDates = habit.completions.values.map((e) => DateUtils.dateOnly(e.date)).toList()..sort();
    final startDate = sortedDates.first;
    final daysSinceStart = today.difference(startDate).inDays + 1;

    // Calculate formation progress using extension method
    final estimatedFormationDays = 66;
    final formationProgress = habit.completions.calculateFormationProgress(estimatedFormationDays) * 100.0;

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
                      value: successRate.toStringAsFixed(1),
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
                      value: completedEntries.toString(),
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
                      value: daysSinceStart.toString(),
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
                      value: formationProgress.toStringAsFixed(0),
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
}
