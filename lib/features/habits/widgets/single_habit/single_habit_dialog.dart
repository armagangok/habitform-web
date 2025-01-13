import '/core/core.dart';
import '/models/models.dart';
import '../../bloc/single_habit/single_habit_bloc.dart';

class SingleHabitDialog extends StatefulWidget {
  const SingleHabitDialog({
    super.key,
    required this.habit,
  });

  final Habit habit;

  @override
  State<SingleHabitDialog> createState() => _SingleHabitDialogState();
}

class _SingleHabitDialogState extends State<SingleHabitDialog> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        FontAwesomeIcons.twitter,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.habit.habitName,
                          style: context.titleLarge?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        if (widget.habit.habitDescription.isNotNullAndNotEmpty)
                          Text(
                            widget.habit.habitDescription!,
                            style: context.bodyMedium,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            SizedBox(height: 10),
            Row(
              children: [
                completeTodayButton(),
                SizedBox(width: 10),
                _deleteHabitButton(),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _deleteHabitButton() {
    return Builder(
      builder: (context) {
        return CupertinoButton.filled(
          sizeStyle: CupertinoButtonSize.large,
          padding: EdgeInsets.all(10),
          minSize: 0,
          onPressed: () {
            context.read<SingleHabitBloc>().add(DeleteSingleHabitEvent(habit: widget.habit));
            navigator.pop();
          },
          child: Icon(CupertinoIcons.trash),
        );
      },
    );
  }

  Widget completeTodayButton() {
    return Builder(
      builder: (context) {
        return CupertinoButton.filled(
          sizeStyle: CupertinoButtonSize.large,
          padding: EdgeInsets.all(10),
          minSize: 0,
          onPressed: () {
            final event = UpdateHabitForSelectedDayEvent(
              habit: widget.habit,
              dateToSaveOrRemove: DateTime.now(),
            );

            context.read<SingleHabitBloc>().add(event);
          },
          child: Icon(CupertinoIcons.check_mark),
        );
      },
    );
  }
}
