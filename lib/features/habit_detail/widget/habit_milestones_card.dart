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
    final currentStreak = habit.completions.calculateCurrentStreak();
    final currentMilestone = _getCurrentMilestone(currentStreak, milestones);

    return CupertinoListSection.insetGrouped(
      header: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FontAwesomeIcons.flagCheckered,
            size: 20,
            color: Color(habit.colorCode),
          ),
          const SizedBox(width: 8),
          Text(
            "Milestones",
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
                    isAchieved: currentStreak >= milestone.days,
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
    return const [
      Milestone(days: 7, title: "One Week Warrior", icon: FontAwesomeIcons.calendar),
      Milestone(days: 30, title: "Monthly Master", icon: FontAwesomeIcons.medal),
      Milestone(days: 66, title: "Habit Hero", icon: FontAwesomeIcons.star),
      Milestone(days: 100, title: "Century Champion", icon: FontAwesomeIcons.trophy),
    ];
  }

  Milestone? _getCurrentMilestone(int currentStreak, List<Milestone> milestones) {
    for (final milestone in milestones) {
      if (currentStreak < milestone.days) {
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
        color: isCurrent ? color.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isCurrent ? Border.all(color: color.withValues(alpha: 0.3)) : null,
      ),
      child: Row(
        children: [
          Icon(
            milestone.icon,
            size: 16,
            color: isAchieved ? color : color.withValues(alpha: 0.4),
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
                    fontWeight: FontWeight.w600,
                    color: isAchieved ? context.titleLarge.color : context.bodyMedium.color?.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  "${milestone.days} days",
                  style: TextStyle(
                    fontSize: 11,
                    color: context.bodyMedium.color?.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          if (isAchieved)
            Icon(
              FontAwesomeIcons.circleCheck,
              size: 16,
              color: Colors.green,
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
