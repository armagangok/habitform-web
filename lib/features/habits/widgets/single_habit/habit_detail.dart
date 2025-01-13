import '/core/core.dart';
import '/models/models.dart';
import '../../bloc/single_habit/single_habit_bloc.dart';
import 'single_habit_detail_grid.dart';

class SingleHabitDetailPage extends StatefulWidget {
  const SingleHabitDetailPage({
    super.key,
    required this.habit,
  });

  final Habit habit;

  @override
  State<SingleHabitDetailPage> createState() => _SingleHabitDetailPageState();
}

class _SingleHabitDetailPageState extends State<SingleHabitDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CupertinoPageScaffold(
          navigationBar: SheetHeader(title: "Habit Detail"),
          child: ListView(
            padding: EdgeInsets.all(10),
            children: [
              SafeArea(
                child: item(
                  widget.habit,
                ),
              ),
              SizedBox(height: 10),
              SingleHabitDetailGrid(habit: widget.habit),
            ],
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  spacing: 15,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: CupertinoButton.tinted(
                        color: CupertinoColors.destructiveRed,
                        sizeStyle: CupertinoButtonSize.small,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          context.read<SingleHabitBloc>().add(DeleteSingleHabitEvent(habit: widget.habit));
                          navigator.pop();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Delete",
                              style: TextStyle(
                                color: CupertinoColors.destructiveRed,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              FontAwesomeIcons.solidTrashCan,
                              color: CupertinoColors.destructiveRed,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: CupertinoButton.tinted(
                        color: CupertinoColors.activeGreen,
                        sizeStyle: CupertinoButtonSize.small,
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Edit",
                              style: TextStyle(
                                color: CupertinoColors.activeGreen,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              FontAwesomeIcons.solidPenToSquare,
                              color: CupertinoColors.activeGreen,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: CupertinoButton.tinted(
                        color: CupertinoColors.activeBlue,
                        padding: EdgeInsets.zero,
                        sizeStyle: CupertinoButtonSize.small,
                        onPressed: () {},
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Share",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: CupertinoColors.activeBlue,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              FontAwesomeIcons.share,
                              color: CupertinoColors.activeBlue,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget item(Habit habit) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              habit.habitName,
              style: context.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (habit.habitDescription.isNotNull)
              Text(
                habit.habitDescription!,
                style: context.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }
}
