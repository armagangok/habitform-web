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
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HabitBloc, HabitState>(
      listener: (context, state) {
        if (state is HabitsFetched) {
          // Force rebuild when state changes
          setState(() {});
        }
      },
      builder: (context, state) {
        // Get the updated habit from state
        Habit currentHabit = widget.currentHabit;
        if (state is HabitsFetched) {
          currentHabit = state.habits.firstWhere(
            (h) => h.id == widget.currentHabit.id,
            orElse: () => widget.currentHabit,
          );
        }

        final habitColor = Color(currentHabit.colorCode);
        final isCompletedToday = currentHabit.isCompletedToday;

        if (isCompletedToday) {
          return CupertinoButton(
            key: const ValueKey('completed'),
            color: habitColor,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            minSize: 0,
            borderRadius: BorderRadius.circular(8),
            onPressed: () {
              controller1.forward(from: 0);
              controller2.forward(from: 0);

              final event = UpdateHabitForSelectedDayEvent(
                dateToSaveOrRemove: DateTime.now(),
                habit: currentHabit,
              );
              context.read<HabitBloc>().add(event);
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
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            minSize: 0,
            borderRadius: BorderRadius.circular(8),
            color: habitColor,
            onPressed: () async {
              controller1.forward(from: 0);
              controller2.forward(from: 0);

              final event = UpdateHabitForSelectedDayEvent(
                dateToSaveOrRemove: DateTime.now(),
                habit: currentHabit,
              );

              context.read<HabitBloc>().add(event);
            },
            child: Icon(
              CupertinoIcons.circle,
              size: 24,
              color: habitColor,
            ),
          ).animate(controller: controller1).scale(duration: 350.ms);
        }
      },
    );
  }
}
