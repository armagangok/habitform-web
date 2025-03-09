import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../../../models/models.dart';
import '../../provider/home_provider.dart';

class MarkTodayHomeButton extends ConsumerStatefulWidget {
  const MarkTodayHomeButton({
    super.key,
    required this.currentHabit,
  });

  final Habit currentHabit;

  @override
  ConsumerState<MarkTodayHomeButton> createState() => _MarkTodayHomeButtonState();
}

class _MarkTodayHomeButtonState extends ConsumerState<MarkTodayHomeButton> with TickerProviderStateMixin {
  late AnimationController controller1;
  late AnimationController controller2;

  @override
  void initState() {
    controller1 = AnimationController(
      vsync: this,
      duration: 500.ms,
    );
    controller2 = AnimationController(
      vsync: this,
      duration: 500.ms,
    );

    super.initState();
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsyncValue = ref.watch(homeProvider);

    return habitsAsyncValue.when(
      data: (homeState) {
        // Get the updated habit from state
        Habit currentHabit = widget.currentHabit;
        currentHabit = homeState.habits.firstWhere(
          (h) => h.id == widget.currentHabit.id,
          orElse: () => widget.currentHabit,
        );

        final habitColor = Color(currentHabit.colorCode);
        final today = DateTime.now();
        final isCompletedToday = today.isCompletedInEntries(currentHabit.completions);

        if (isCompletedToday) {
          return CupertinoButton(
            key: const ValueKey('completed'),
            color: habitColor,
            padding: EdgeInsets.all(8),
            minSize: 0,
            borderRadius: BorderRadius.circular(10),
            onPressed: () async {
              controller1.forward(from: 0);
              controller2.forward(from: 0);

              await ref.read(homeProvider.notifier).toggleHabitCompletion(currentHabit.id, today);
            },
            child: Icon(
              CupertinoIcons.checkmark_circle,
              color: habitColor.colorRegardingToBrightness,
              size: 24,
            ),
          ).animate(controller: controller1).scale(duration: 350.ms);
        } else {
          return CupertinoButton.tinted(
            key: const ValueKey('uncompleted'),
            padding: EdgeInsets.all(8),
            minSize: 0,
            borderRadius: BorderRadius.circular(10),
            color: habitColor,
            onPressed: () async {
              controller1.forward(from: 0);
              controller2.forward(from: 0);

              await ref.read(homeProvider.notifier).toggleHabitCompletion(currentHabit.id, today);
            },
            child: Icon(
              CupertinoIcons.circle,
              size: 24,
              color: habitColor,
            ),
          ).animate(controller: controller1).scale(duration: 350.ms);
        }
      },
      loading: () => Center(child: CupertinoActivityIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
}
