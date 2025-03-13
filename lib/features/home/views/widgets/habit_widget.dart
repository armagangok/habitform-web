import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../../../models/models.dart';
import '../../../habit_detail/page/habit_detail.dart';
import '../../../habit_detail/providers/habit_detail_provider.dart';
import '../../provider/home_provider.dart';
import 'home_habit_grid.dart';

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

    return CustomButton(
      onPressed: _openHabitDetail,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  habitName,
                  style: context.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Card(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HomeHabitGrid(habit: currentHabit),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
