import '../../../core/core.dart';
import '../bloc/day_selection/day_selection_cubit.dart';
import '../bloc/reminder/reminder_bloc.dart';

class SelectionButtons extends StatelessWidget {
  const SelectionButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CupertinoButton.tinted(
            sizeStyle: CupertinoButtonSize.small,
            borderRadius: BorderRadius.circular(8),
            onPressed: () {
              context.read<DaySelectionCubit>().selectAll();
              context.read<ReminderBloc>().add(UpdateReminderDaysEvent(days: allDays.toList()));
            },
            child: Text(
              "Select All",
              style: TextStyle(color: context.primary),
            ),
          ).animate().fadeIn(),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: CupertinoButton.tinted(
              sizeStyle: CupertinoButtonSize.small,
              borderRadius: BorderRadius.circular(8),
              onPressed: () {
                context.read<DaySelectionCubit>().deselectAll(context);
              },
              child: Text(
                "Deselect All",
                style: TextStyle(color: context.primary),
              ).animate().fadeIn(),
            ).animate().fadeIn(),
          ),
        ],
      ),
    );
  }
}
