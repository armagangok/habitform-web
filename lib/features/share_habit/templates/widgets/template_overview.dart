import '../../../../core/core.dart';
import '../../../../models/habit/habit_model.dart';
import '../../../habit_detail/widget/habit_overview_widget.dart';

class TemplateOverview extends StatelessWidget {
  final Habit habit;
  final Color accentColor;

  const TemplateOverview({super.key, required this.habit, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final onAccent = accentColor.colorRegardingToBrightness;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accentColor.withValues(alpha: .9), accentColor],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: context.primaryContrastingColor.withValues(alpha: 0.1),
                  child: Text(
                    habit.emoji ?? '🌟',
                    style: TextStyle(fontSize: 60),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  habit.habitName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: onAccent),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: HabitOverviewCompact(
                    habit: habit,
                    textColor: context.scaffoldBackgroundColor.colorRegardingToBrightness,
                    secondaryTextColor: context.scaffoldBackgroundColor.colorRegardingToBrightness,
                    cardBackgroundColor: context.scaffoldBackgroundColor,
                  ),
                ),
              ],
            ),
            Spacer(flex: 10),
            Row(
              children: [
                Assets.app.appLogoDark.image(height: 22, width: 22),
                const SizedBox(width: 6),
                Text(
                  'HabitRise',
                  style: context.bodySmall.copyWith(
                    color: onAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
