import '../../../../core/core.dart';
import '../../../../models/habit/habit_model.dart';
import 'this_month_calendar_widget.dart';

class TemplateCalendar extends StatelessWidget {
  final Habit habit;
  final Color accentColor;
  final ScrollController? controller;

  const TemplateCalendar({super.key, required this.habit, required this.accentColor, this.controller});

  @override
  Widget build(BuildContext context) {
    final textOnAccent = accentColor.colorRegardingToBrightness;

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
          CupertinoScrollbar(
            controller: controller,
            child: SingleChildScrollView(
              controller: controller,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 40, // Reduced from 50 to save space
                          backgroundColor: context.cupertinoTheme.selectionHandleColor.withValues(alpha: .2),
                          child: Center(
                            child: Text(
                              habit.emoji ?? '🌟',
                              style: const TextStyle(
                                fontSize: 44, // Reduced from 56 to save space
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6), // Reduced from 8
                      Text(
                        habit.habitName,
                        style: context.titleLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: textOnAccent,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),

                      const SizedBox(height: 32), // Reduced from 16
                    ],
                  ),
                  // Add "dismount running" text

                  // New calendar widget
                  ThisMonthCalendarWidget(habit: habit),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 12,
            child: Row(
              children: [
                Assets.app.appLogoDark.image(height: 22, width: 22),
                const SizedBox(width: 6),
                Text(
                  'HabitForm',
                  style: context.bodySmall.copyWith(
                    color: textOnAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
