import 'package:habitrise/features/habits/widgets/home_habit_grid.dart';

import '../../../core/core.dart';
import '../../../core/widgets/spring_button.dart';
import '../../../models/models.dart';
import '../../habit_detail/page/habit_detail.dart';
import 'mark_today_home_button.dart';

class HabitWidget extends StatefulWidget {
  const HabitWidget({super.key, required this.habit});

  final Habit habit;

  @override
  State<HabitWidget> createState() => _HabitWidgetState();
}

class _HabitWidgetState extends State<HabitWidget> with SingleTickerProviderStateMixin {
  void _openHabitDetail() {
    CupertinoScaffold.showCupertinoModalBottomSheet(
      enableDrag: false,
      context: context,
      builder: (contextFromSheet) {
        return HabitDetailPage(habit: widget.habit);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitName = widget.habit.habitName;
    final habitDescription = widget.habit.habitDescription;
    final habitEmoji = widget.habit.emoji;

    return SpringButton(
      onTap: _openHabitDetail,
      child: Card(
        color: context.theme.cardTheme.color?.withValues(alpha: .75),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: context.theme.dividerColor.withValues(alpha: .2),
            width: .5,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  if (habitEmoji != null) ...[
                                    Text(
                                      habitEmoji,
                                      style: TextStyle(
                                        fontSize: 36,
                                      ),
                                      maxLines: 1,
                                    ),
                                    SizedBox(width: 5),
                                  ],
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          habitName,
                                          style: context.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        if (habitDescription != null && habitDescription.isNotEmpty)
                                          Text(
                                            habitDescription,
                                            style: context.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w500,
                                              color: context.bodySmall?.color?.withAlpha(175),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 5),
                            MarkTodayHomeButton(currentHabit: widget.habit),
                          ],
                        ),
                        SizedBox(height: 10),
                        HomeHabitGrid(habit: widget.habit),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
