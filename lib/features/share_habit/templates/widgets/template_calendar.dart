import '../../../../core/core.dart';
import '../../../../models/habit/habit_model.dart';
import '../../../habit_detail/widget/habit_data_widget.dart';
import 'share_stats.dart';

class TemplateCalendar extends StatelessWidget {
  final Habit habit;
  final Color accentColor;
  final ScrollController? controller;

  const TemplateCalendar({super.key, required this.habit, required this.accentColor, this.controller});

  @override
  Widget build(BuildContext context) {
    final textOnAccent = accentColor.colorRegardingToBrightness;
    final stats = buildShareStats(habit);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: .8),
            accentColor.withValues(alpha: .95),
          ],
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: context.cupertinoTheme.selectionHandleColor.withValues(alpha: .2),
                      child: Center(
                        child: Text(
                          habit.emoji ?? '🌟',
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    habit.habitName,
                    style: context.titleLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: textOnAccent,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    '${LocaleKeys.share_templates_this_month.tr()} ${stats.thisMonthCompleted}',
                    style: context.labelLarge.copyWith(
                      color: textOnAccent.withValues(alpha: .9),
                    ),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: 16),
                ],
              ),
              CupertinoScrollbar(
                controller: controller,
                child: SingleChildScrollView(
                  controller: controller,
                  physics: const BouncingScrollPhysics(),
                  child: HabitDataWidget(habit: habit),
                ),
              ),
            ],
          ),
          Positioned(
            left: 16,
            bottom: 12,
            child: Row(
              children: [
                Assets.app.appLogoDark.image(height: 22, width: 22),
                const SizedBox(width: 6),
                Text('HabitRise', style: context.bodySmall.copyWith(color: textOnAccent, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
