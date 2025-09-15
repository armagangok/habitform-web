import '../../../../core/core.dart';
import '../../../../models/habit/habit_model.dart';
import '../../../habit_detail/widget/habit_heatmap_card.dart';
import '../../../habit_detail/widget/habit_overview_widget.dart';

class TemplateHeatmap extends StatelessWidget {
  final Habit habit;
  final Color accentColor;

  const TemplateHeatmap({super.key, required this.habit, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final onAccent = accentColor.colorRegardingToBrightness;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [accentColor.darken(.05), accentColor],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Text(
                  habit.emoji ?? '🌟',
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: onAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(habit.habitName, style: context.titleLarge.copyWith(color: onAccent, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                color: context.cupertinoTheme.selectionHandleColor,
                padding: const EdgeInsets.all(12),
                child: HabitHeatmapCompact(habit: habit),
              ),
            ),
            Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: HabitOverviewCompact(
                habit: habit,
                textColor: context.scaffoldBackgroundColor.colorRegardingToBrightness,
                secondaryTextColor: context.scaffoldBackgroundColor.colorRegardingToBrightness,
                cardBackgroundColor: context.scaffoldBackgroundColor,
              ),
            ),
            Spacer(flex: 3),
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
