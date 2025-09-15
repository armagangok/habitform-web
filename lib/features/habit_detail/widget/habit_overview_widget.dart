import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/features/habit_formation/provider/habit_formation_provider.dart';
import '/models/completion_entry/completion_extension.dart';
import '/models/habit/habit_model.dart';
import '../../habit_formation/provider/habit_formation_state.dart';
import 'statistic_card.dart';

class HabitOverviewWidget extends ConsumerWidget {
  final Habit habit;

  const HabitOverviewWidget({
    super.key,
    required this.habit,
  });

  /// Calculate days since first completion
  int _calculateDaysSinceFirstCompletion(Habit habit) {
    if (habit.completions.isEmpty) return 0;

    final today = DateTime.now();
    final firstCompletionDate = habit.completions.getFirstCompletionDate();
    if (firstCompletionDate == null) return 0;

    final startDate = DateUtils.dateOnly(firstCompletionDate);
    return today.difference(startDate).inDays + 1;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formationState = ref.watch(formationProvider);

    // Get habit statistic from formation provider
    HabitStatistic? habitStatistic;
    if (formationState.hasValue && formationState.value != null) {
      habitStatistic = formationState.value!.habitStatistics[habit.id];
    }

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

    // Use formation provider data if available, otherwise fallback to local calculation
    final completedEntries = habitStatistic?.completedDays ?? habit.completions.calculateFormationScoreFromFirstCompletion();

    // Calculate days since first completion for "Days Active"
    final daysSinceStart = habitStatistic?.totalDays ?? _calculateDaysSinceFirstCompletion(habit);

    return CupertinoListSection.insetGrouped(
      header: Text(LocaleKeys.statistics_overview.tr()),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
                      cardColor: context.scaffoldBackgroundColor,
                      iconColor: Colors.deepOrangeAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatisticCard(
                      icon: Icons.emoji_events,
                      title: LocaleKeys.statistics_longest_streak.tr(),
                      value: longestStreak.toString(),
                      unit: "days",
                      cardColor: context.scaffoldBackgroundColor,
                      iconColor: Colors.redAccent,
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
                      cardColor: context.scaffoldBackgroundColor,
                      iconColor: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatisticCard(
                      icon: Icons.calendar_today,
                      title: LocaleKeys.statistics_total_days.tr(),
                      value: daysSinceStart.toString(),
                      unit: "days",
                      cardColor: context.scaffoldBackgroundColor,
                      iconColor: Colors.blue,
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

/// Compact variant for sharing: only statistic cards without section headers
class HabitOverviewCompact extends ConsumerWidget {
  final Habit habit;
  final Color? textColor;
  final Color? secondaryTextColor;
  final Color? iconColor;
  final Color? cardBackgroundColor;

  const HabitOverviewCompact({
    super.key,
    required this.habit,
    this.textColor,
    this.secondaryTextColor,
    this.iconColor,
    this.cardBackgroundColor,
  });

  int _calculateDaysSinceFirstCompletion(Habit habit) {
    if (habit.completions.isEmpty) return 0;
    final today = DateTime.now();
    final firstCompletionDate = habit.completions.getFirstCompletionDate();
    if (firstCompletionDate == null) return 0;
    final startDate = DateUtils.dateOnly(firstCompletionDate);
    return today.difference(startDate).inDays + 1;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formationState = ref.watch(formationProvider);

    HabitStatistic? habitStatistic;
    if (formationState.hasValue && formationState.value != null) {
      habitStatistic = formationState.value!.habitStatistics[habit.id];
    }

    final currentStreak = habit.completions.calculateCurrentStreak();
    final longestStreak = habit.completions.calculateLongestStreak();

    if (habit.completions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.assessment, size: 36, color: Theme.of(context).hintColor.withValues(alpha: 0.5)),
              const SizedBox(height: 8),
              Text(
                LocaleKeys.statistics_no_data_for_habit.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final completedEntries = habitStatistic?.completedDays ?? habit.completions.calculateFormationScoreFromFirstCompletion();
    final daysSinceStart = habitStatistic?.totalDays ?? _calculateDaysSinceFirstCompletion(habit);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: StatisticCard(
                  icon: CupertinoIcons.flame_fill,
                  title: LocaleKeys.statistics_current_streak.tr(),
                  value: currentStreak.toString(),
                  unit: "days",
                  cardColor: cardBackgroundColor,
                  iconColor: iconColor ?? Colors.deepOrangeAccent,
                  valueColor: textColor,
                  titleColor: secondaryTextColor,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: StatisticCard(
                  icon: CupertinoIcons.flame_fill,
                  title: LocaleKeys.statistics_longest_streak.tr(),
                  value: longestStreak.toString(),
                  unit: "days",
                  cardColor: context.scaffoldBackgroundColor,
                  iconColor: iconColor ?? Colors.redAccent,
                  valueColor: textColor,
                  titleColor: secondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatisticCard(
                  icon: CupertinoIcons.checkmark_circle_fill,
                  title: LocaleKeys.statistics_completed.tr(),
                  value: completedEntries.toString(),
                  unit: "days",
                  cardColor: context.scaffoldBackgroundColor,
                  iconColor: iconColor ?? Colors.green.shade300,
                  valueColor: textColor,
                  titleColor: secondaryTextColor,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: StatisticCard(
                  icon: CupertinoIcons.calendar,
                  title: LocaleKeys.statistics_total_days.tr(),
                  value: daysSinceStart.toString(),
                  unit: "days",
                  cardColor: context.scaffoldBackgroundColor,
                  iconColor: iconColor ?? Colors.greenAccent,
                  valueColor: textColor,
                  titleColor: secondaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
