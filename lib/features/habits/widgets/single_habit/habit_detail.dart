import 'package:habitrise/features/edit_habit/edit_habit_page.dart';

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
  late Habit currentHabit;

  @override
  void initState() {
    super.initState();
    currentHabit = widget.habit;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SingleHabitBloc, SingleHabitState>(
      listener: (context, state) {
        if (state is SingleHabitsFetched) {
          final updatedHabit = state.habits.firstWhere(
            (habit) => habit.id == currentHabit.id,
            orElse: () => currentHabit,
          );
          setState(() {
            currentHabit = updatedHabit;
          });
        }
      },
      builder: (context, state) {
        final days = currentHabit.reminderModel?.days;
        final remindTime = currentHabit.reminderModel?.reminderTime?.toHHMM();

        return Stack(
          children: [
            CupertinoPageScaffold(
              navigationBar: SheetHeader(
                title: "Habit Detail",
                closeButtonPosition: CloseButtonPosition.left,
              ),
              child: ListView(
                padding: EdgeInsets.all(20),
                children: [
                  SafeArea(
                    bottom: false,
                    child: CustomHeader(
                      text: "INFORMATION",
                      child: item(
                        currentHabit.habitName,
                        currentHabit.habitDescription,
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  CustomHeader(
                    text: "REMINDER",
                    child: item(
                      remindTime ?? "None",
                      days?.toString(),
                    ),
                  ),
                  SizedBox(height: 25),
                  CustomHeader(
                    text: "HABIT DATA",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SingleHabitDetailGrid(habit: currentHabit),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          spacing: 10,
                          children: [
                            CupertinoButton.tinted(
                              sizeStyle: CupertinoButtonSize.small,
                              onPressed: () {},
                              child: Row(
                                spacing: 5,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Calendar"),
                                  Icon(CupertinoIcons.calendar),
                                ],
                              ),
                            ),
                            CupertinoButton.tinted(
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
                                            "Uncomplete Today",
                                            style: TextStyle(
                                              color: currentHabit.isCompletedToday ? Color(currentHabit.colorCode) : Colors.grey.shade500,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Icon(
                                            CupertinoIcons.calendar_badge_minus,
                                            color: currentHabit.isCompletedToday ? Color(currentHabit.colorCode) : Colors.grey.shade500,
                                          ),
                                        ],
                                      )
                                    : Row(
                                        key: ValueKey('uncompleted'),
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Complete Today",
                                            style: TextStyle(
                                              color: currentHabit.isCompletedToday ? Color(currentHabit.colorCode) : Colors.grey.shade500,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Icon(
                                            CupertinoIcons.calendar_badge_plus,
                                            color: currentHabit.isCompletedToday ? Color(currentHabit.colorCode) : Colors.grey.shade500,
                                          ),
                                        ],
                                      ),
                              ),
                              onPressed: () {
                                final event = UpdateHabitForSelectedDayEvent(
                                  dateToSaveOrRemove: DateTime.now(),
                                  habit: currentHabit,
                                );

                                context.read<SingleHabitBloc>().add(event);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                              context.read<SingleHabitBloc>().add(DeleteSingleHabitEvent(habit: currentHabit));
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
                          child: Builder(builder: (context) {
                            return CupertinoButton.tinted(
                              color: CupertinoColors.activeOrange,
                              sizeStyle: CupertinoButtonSize.small,
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                showCupertinoModalBottomSheet(
                                  enableDrag: false,
                                  context: context,
                                  builder: (context) {
                                    return EditHabitPage(habit: currentHabit);
                                  },
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Edit",
                                    style: TextStyle(
                                      color: CupertinoColors.activeOrange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Icon(
                                    FontAwesomeIcons.solidPenToSquare,
                                    color: CupertinoColors.activeOrange,
                                  ),
                                ],
                              ),
                            );
                          }),
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
      },
    );
  }

  Widget item(String title, String? subtitle) {
    return title.isEmpty && subtitle == null
        ? SizedBox.shrink()
        : Card(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title.isNotEmpty)
                      Text(
                        title,
                        style: context.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (subtitle != null && subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: context.bodyMedium?.copyWith(
                          color: context.cupertinoTextStyle.color?.withAlpha(170),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
  }
}

class CustomHeader extends StatelessWidget {
  final String text;
  final Widget? child;

  const CustomHeader({
    super.key,
    required this.text,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child != null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2.5,
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  text,
                  style: context.bodyMedium?.copyWith(color: context.bodyMedium?.color?.withAlpha(170)),
                ),
              ),
              if (child != null) child!,
            ],
          )
        : SizedBox.shrink();
  }
}
