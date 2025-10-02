import '../../../../core/core.dart';
import '../../../../models/habit/habit_model.dart';
import 'share_stats.dart';

class TemplateMinimal extends StatelessWidget {
  final Habit habit;
  final Color accentColor;

  const TemplateMinimal({super.key, required this.habit, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final onPrimary = accentColor.colorRegardingToBrightness;
    final stats = buildShareStats(habit);

    return Container(
      decoration: BoxDecoration(color: accentColor),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(habit.emoji ?? LocaleKeys.share_templates_default_emoji.tr(), style: context.displaySmall.copyWith(color: onPrimary)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    habit.habitName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.headlineSmall.copyWith(color: onPrimary, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _Metric(title: LocaleKeys.share_templates_current_streak.tr(), value: '${stats.currentStreak}d', color: onPrimary),
                const SizedBox(width: 16),
                _Metric(title: LocaleKeys.share_templates_best_streak.tr(), value: '${stats.longestStreak}d', color: onPrimary),
                const SizedBox(width: 16),
                _Metric(title: LocaleKeys.share_templates_completed.tr(), value: '${stats.completedDays}', color: onPrimary),
              ],
            ),
            const Spacer(),
            LinearProgressIndicator(
              value: stats.progressPercent.clamp(0.0, 1.0),
              backgroundColor: onPrimary.withValues(alpha: .18),
              color: onPrimary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Assets.app.appLogoDark.image(height: 22, width: 22),
                const SizedBox(width: 8),
                Text(LocaleKeys.share_templates_app_name.tr(), style: context.bodySmall.copyWith(color: onPrimary, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _Metric({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.labelMedium.copyWith(color: color.withValues(alpha: .85))),
          const SizedBox(height: 6),
          Text(value, style: context.titleLarge.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
