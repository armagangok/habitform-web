import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/models/completion_entry/completion_extension.dart';
import '/models/models.dart';

class HabitMilestonesCard extends ConsumerWidget {
  final Habit habit;

  const HabitMilestonesCard({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestones = _getMilestones();
    // Use weighted completed days to drive milestone achievements/highlight (rounded)
    final totalCompletedDays = habit.completions.calculateWeightedFormationScore(habit.dailyTarget).round();
    final currentMilestone = _getCurrentMilestone(totalCompletedDays, milestones);

    return CupertinoListSection.insetGrouped(
      header: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            FontAwesomeIcons.flagCheckered,
            size: 20,
            color: Color(habit.colorCode),
          ),
          const SizedBox(width: 8),
          Text(
            LocaleKeys.habit_detail_milestones.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.titleLarge.color,
            ),
          ),
        ],
      ),
      children: [
        CupertinoListTile(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...milestones.map((milestone) => _MilestoneItem(
                    milestone: milestone,
                    // Mark milestone achieved if total completed days reached threshold
                    isAchieved: totalCompletedDays >= milestone.days,
                    isCurrent: milestone == currentMilestone,
                    color: Color(habit.colorCode),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  List<Milestone> _getMilestones() {
    return [
      Milestone(days: 7, title: LocaleKeys.habit_detail_milestone_one_week_warrior.tr(), icon: Icons.calendar_today_outlined),
      Milestone(days: 30, title: LocaleKeys.habit_detail_milestone_monthly_master.tr(), icon: Icons.workspace_premium_outlined),
      Milestone(days: 60, title: LocaleKeys.habit_detail_milestone_habit_hero.tr(), icon: Icons.star_border),
      Milestone(days: 90, title: LocaleKeys.habit_detail_milestone_quarter_champion.tr(), icon: Icons.emoji_events_outlined),
      Milestone(days: 150, title: LocaleKeys.habit_detail_milestone_streak_pro.tr(), icon: Icons.military_tech_outlined),
      Milestone(days: 180, title: LocaleKeys.habit_detail_milestone_half_year_hero.tr(), icon: Icons.flag_outlined),
      Milestone(days: 365, title: LocaleKeys.habit_detail_milestone_one_year_legend.tr(), icon: Icons.emoji_events_outlined),
    ];
  }

  Milestone? _getCurrentMilestone(int completedDays, List<Milestone> milestones) {
    for (final milestone in milestones) {
      if (completedDays < milestone.days) {
        return milestone;
      }
    }
    return null;
  }
}

class _MilestoneItem extends StatelessWidget {
  final Milestone milestone;
  final bool isAchieved;
  final bool isCurrent;
  final Color color;

  const _MilestoneItem({
    required this.milestone,
    required this.isAchieved,
    required this.isCurrent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrent ? color.withValues(alpha: 0.9) : (isAchieved ? color.withValues(alpha: 0.12) : Colors.transparent),
        borderRadius: BorderRadius.circular(8),
        border: isCurrent ? Border.all(color: color.withValues(alpha: 0.35)) : (isAchieved ? Border.all(color: color.withValues(alpha: 0.25)) : null),
      ),
      child: Row(
        children: [
          Icon(
            milestone.icon,
            size: 16,
            color: isCurrent ? Colors.white : (isAchieved ? color : color.withValues(alpha: 0.6)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                    color: isCurrent ? Colors.white : (isAchieved ? color : context.bodyMedium.color?.withValues(alpha: 0.88)),
                  ),
                ),
                Text(
                  "${milestone.days} ${LocaleKeys.habit_detail_days.tr()}",
                  style: TextStyle(
                    fontSize: 11,
                    color: isCurrent ? Colors.white : (isAchieved ? color.withValues(alpha: 0.9) : context.bodyMedium.color?.withValues(alpha: 0.75)),
                  ),
                ),
              ],
            ),
          ),
          if (isAchieved)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.35)),
              ),
              alignment: Alignment.center,
              child: Icon(
                FontAwesomeIcons.check,
                size: 14,
                color: isCurrent ? Colors.white : color,
              ),
            ),
        ],
      ),
    );
  }
}

class Milestone {
  final int days;
  final String title;
  final IconData icon;

  const Milestone({
    required this.days,
    required this.title,
    required this.icon,
  });
}
