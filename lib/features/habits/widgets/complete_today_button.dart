import '../../../core/core.dart';
import '../../../models/models.dart';
import '../bloc/habit_bloc.dart';

class CompleteTodayButton extends StatelessWidget {
  const CompleteTodayButton({
    super.key,
    required this.currentHabit,
  });

  final Habit currentHabit;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton.tinted(
      color: currentHabit.isCompletedToday ? Color(currentHabit.colorCode) : Colors.grey.shade500,
      sizeStyle: CupertinoButtonSize.small,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 400),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axis: Axis.horizontal, // Yatay eksende animasyon
              axisAlignment: -1, // Soldan hizala
              child: child,
            ),
          );
        },
        child: currentHabit.isCompletedToday
            ? Row(
                key: ValueKey('completed'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Today Completed",
                    style: TextStyle(
                      color: currentHabit.isCompletedToday ? Color(currentHabit.colorCode) : null,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(
                    CupertinoIcons.checkmark_alt,
                    color: currentHabit.isCompletedToday ? Color(currentHabit.colorCode) : null,
                  ),
                ],
              )
            : Row(
                key: ValueKey('uncompleted'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Complete",
                    style: TextStyle(
                      color: currentHabit.isCompletedToday ? Color(currentHabit.colorCode) : null,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(
                    CupertinoIcons.calendar_today,
                    color: currentHabit.isCompletedToday ? Color(currentHabit.colorCode) : null,
                  ),
                ],
              ),
      ),
      onPressed: () {
        final event = UpdateHabitForSelectedDayEvent(
          dateToSaveOrRemove: DateTime.now(),
          habit: currentHabit,
        );

        context.read<HabitBloc>().add(event);
      },
    );
  }
}
