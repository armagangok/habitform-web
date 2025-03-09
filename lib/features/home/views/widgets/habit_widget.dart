import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../../../models/models.dart';
import '../../../habit_detail/page/habit_detail.dart';
import '../../../habit_detail/providers/habit_detail_provider.dart';
import '../../provider/home_provider.dart';
import 'home_habit_grid.dart';
import 'mark_today_home_button.dart';

class HabitWidget extends ConsumerStatefulWidget {
  const HabitWidget({super.key, required this.habit});

  final Habit habit;

  @override
  ConsumerState<HabitWidget> createState() => _HabitWidgetState();
}

class _HabitWidgetState extends ConsumerState<HabitWidget> {
  void _openHabitDetail() {
    ref.watch(habitDetailProvider.notifier).updateHabit(widget.habit);

    CupertinoScaffold.showCupertinoModalBottomSheet(
      enableDrag: false,
      context: context,
      builder: (contextFromSheet) => HabitDetailPage(habit: widget.habit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentHabit = ref.watch(homeProvider).maybeWhen(
          data: (homeState) => homeState.habits.firstWhere(
            (h) => h.id == widget.habit.id,
            orElse: () => widget.habit,
          ),
          orElse: () => widget.habit,
        );

    final habitName = currentHabit.habitName;
    final habitDescription = currentHabit.habitDescription;
    final habitEmoji = currentHabit.emoji;

    return CustomButton(
      onPressed: _openHabitDetail,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Card(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.5),
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
                            MarkTodayHomeButton(currentHabit: currentHabit),
                          ],
                        ),
                        SizedBox(height: 10),
                        HomeHabitGrid(habit: currentHabit),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
