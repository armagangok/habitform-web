import '../../../core/core.dart';
import '../../../models/models.dart';
import '../bloc/habit_bloc.dart';

class CompleteTodayButton extends StatefulWidget {
  const CompleteTodayButton({
    super.key,
    required this.currentHabit,
  });

  final Habit currentHabit;

  @override
  State<CompleteTodayButton> createState() => _CompleteTodayButtonState();
}

class _CompleteTodayButtonState extends State<CompleteTodayButton> with TickerProviderStateMixin {
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
  Widget build(BuildContext context) {
    final habitColor = Color(widget.currentHabit.colorCode);
    final isCompletedToday = widget.currentHabit.isCompletedToday;

    return isCompletedToday
        ? CupertinoButton(
            key: const ValueKey('completed'),
            sizeStyle: CupertinoButtonSize.small,
            color: habitColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onPressed: () {
              controller1.forward(from: 0);
              controller2.forward(from: 0);

              final event = UpdateHabitForSelectedDayEvent(
                dateToSaveOrRemove: DateTime.now(),
                habit: widget.currentHabit,
              );
              context.read<HabitBloc>().add(event);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocaleKeys.habit_todayCompleted.tr(),
                  style: TextStyle(
                    color: habitColor.colorRegardingToBrightness,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 5),
                Icon(
                  CupertinoIcons.checkmark_alt,
                  color: habitColor.colorRegardingToBrightness,
                ),
              ],
            ),
          ).animate(controller: controller1).fadeIn(duration: 400.ms) // Blur kaybolduktan sonra tekrar fadeIn
        : CupertinoButton.tinted(
            sizeStyle: CupertinoButtonSize.small,
            key: const ValueKey('uncompleted'),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: habitColor,
            onPressed: () {
              controller1.forward(from: 0);
              controller2.forward(from: 0);

              final event = UpdateHabitForSelectedDayEvent(
                dateToSaveOrRemove: DateTime.now(),
                habit: widget.currentHabit,
              );
              context.read<HabitBloc>().add(event);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocaleKeys.habit_complete.tr(),
                  style: TextStyle(
                    color: habitColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 5),
                Icon(
                  CupertinoIcons.calendar_today,
                  color: habitColor,
                ),
              ],
            ),
          ).animate(controller: controller1).fadeIn();
  }
}
