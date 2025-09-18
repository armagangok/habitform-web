import '../../../../core/core.dart';
import '../../../../models/habit/habit_model.dart';
import '../../../habit_detail/widget/habit_data_widget.dart';
import 'share_stats.dart';

class TemplatePoster extends StatelessWidget {
  final Habit habit;
  final Color accentColor;
  final ScrollController? controller;

  const TemplatePoster({super.key, required this.habit, required this.accentColor, this.controller});

  @override
  Widget build(BuildContext context) {
    final onAccent = accentColor.colorRegardingToBrightness;
    final bg = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [accentColor.darken(.15), accentColor, accentColor.lighten(.05)],
    );
    final stats = buildShareStats(habit);

    return Container(
      decoration: BoxDecoration(gradient: bg),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: onAccent.withValues(alpha: .12), borderRadius: BorderRadius.circular(10)),
                  child: Text(DateTime.now().year.toString(), style: context.labelLarge.copyWith(color: onAccent)),
                )
              ],
            ),
            Spacer(),
            Text(
              habit.emoji ?? '',
              style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            Text(habit.habitName, style: context.displaySmall.copyWith(color: onAccent, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Row(
              children: [
                _Badge(text: LocaleKeys.share_templates_streak_days.tr(namedArgs: {'days': stats.currentStreak.toString()}), color: onAccent),
                const SizedBox(width: 8),
                _Badge(text: LocaleKeys.share_templates_progress_percent.tr(namedArgs: {'percent': stats.progressPercent.round().toString()}), color: onAccent),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                color: context.selectionHandleColor.withValues(alpha: .2),
                padding: const EdgeInsets.all(12),
                child: CupertinoScrollbar(
                  controller: controller,
                  child: SingleChildScrollView(
                    controller: controller,
                    physics: const BouncingScrollPhysics(),
                    child: HabitDataWidget(habit: habit),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Assets.app.appLogoDark.image(height: 22, width: 22),
                const SizedBox(width: 6),
                Text(LocaleKeys.share_templates_app_name.tr(), style: context.bodySmall.copyWith(color: onAccent, fontWeight: FontWeight.bold)),
              ],
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: context.labelLarge.copyWith(color: color)),
    );
  }
}
