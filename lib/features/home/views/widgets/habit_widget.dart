import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '/core/core.dart';
import '/models/models.dart';
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
    ref.watch(habitDetailProvider.notifier).initHabit(widget.habit);

    CupertinoScaffold.showCupertinoModalBottomSheet(
      enableDrag: false,
      context: context,
      builder: (contextFromSheet) => HabitDetailPage(),
    );
  }

  void _uncompleteHabit() {
    final today = DateTime.now();
    ref.read(homeProvider.notifier).toggleHabitCompletion(widget.habit.id, today);
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
    final today = DateTime.now();
    final isTodayCompleted = today.isCompletedInEntries(currentHabit.completions);

    return CustomButton(
      onPressed: _openHabitDetail,
      child: LayoutBuilder(
        builder: (context, constraints) {
          Widget content = Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
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
                  HomeHabitGrid(habit: currentHabit),
                ],
              ),
            ),
          );

          if (isTodayCompleted) {
            final habitColor = Color(currentHabit.colorCode);
            final emoji = widget.habit.emoji;
            content = Stack(
              children: [
                // Blurred background
                content,
                // Completion overlay that covers the entire habit item
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomBlurWidget(
                      blurValue: 15,
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.theme.cardTheme.color?.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: habitColor.withValues(alpha: 0.6),
                            width: 1.25,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Center completion message
                            Center(
                              child: AnimatedSwitcher(
                                duration: Duration(milliseconds: 600),
                                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                                child: Container(
                                  key: ValueKey('completed-today'),
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: Row(
                                          children: [
                                            if (emoji != null) ...[
                                              FittedBox(
                                                child: Text(
                                                  emoji,
                                                  style: context.bodyLarge?.copyWith(
                                                    color: habitColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 32,
                                                  ),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                            ],
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  FittedBox(
                                                    child: Text(
                                                      habitName,
                                                      style: context.bodyLarge?.copyWith(
                                                        color: habitColor,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                  FittedBox(
                                                    child: Text(
                                                      LocaleKeys.habit_todayCompleted.tr(),
                                                      style: context.bodyLarge?.copyWith(
                                                        color: context.bodyLarge?.color?.withValues(alpha: 0.8),
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 14,
                                                      ),
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            SizedBox(
                                              width: 60,
                                              height: 60,
                                              child: Lottie.asset(
                                                Assets.animations.completion,
                                                repeat: false,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: CupertinoButton(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(8),
                                          padding: EdgeInsets.zero,
                                          minSize: 0,
                                          sizeStyle: CupertinoButtonSize.small,
                                          onPressed: _uncompleteHabit,
                                          child: Icon(
                                            CupertinoIcons.xmark_circle_fill,
                                            color: habitColor,
                                            size: 32,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Uncomplete button positioned on top
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return content;
        },
      ),
    );
  }
}
