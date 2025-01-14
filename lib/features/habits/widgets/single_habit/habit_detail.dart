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
  @override
  Widget build(BuildContext context) {
    final days = widget.habit.reminderModel?.days;
    final remindTime = widget.habit.reminderModel?.reminderTime?.toHHMM();

    return BlocBuilder<SingleHabitBloc, SingleHabitState>(
      builder: (context, state) {
        print(state);
        return Stack(
          children: [
            CupertinoPageScaffold(
              navigationBar: SheetHeader(title: "Habit Detail"),
              child: ListView(
                padding: EdgeInsets.all(10),
                children: [
                  SafeArea(
                    bottom: false,
                    child: CustomHeader(
                      text: "INFORMATION",
                      child: item(
                        widget.habit.habitName,
                        widget.habit.habitDescription,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  CustomHeader(
                    text: "REMINDER",
                    child: item(
                      remindTime ?? "None",
                      days?.toString(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SingleHabitDetailGrid(habit: widget.habit),
                      SizedBox(height: 10),
                      CupertinoButton.tinted(
                        sizeStyle: CupertinoButtonSize.small,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Complete Today"),
                            SizedBox(width: 5),
                            Icon(
                              CupertinoIcons.calendar_today,
                            )
                          ],
                        ),
                        onPressed: () {
                          final event = UpdateHabitForSelectedDayEvent(
                            dateToSaveOrRemove: DateTime.now(),
                            habit: widget.habit,
                          );

                          context.read<SingleHabitBloc>().add(event);
                        },
                      ),
                    ],
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
                              context.read<SingleHabitBloc>().add(DeleteSingleHabitEvent(habit: widget.habit));
                              navigator.pop();
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Archive",
                                  style: TextStyle(
                                    color: CupertinoColors.destructiveRed,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Icon(
                                  FontAwesomeIcons.boxArchive,
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
                                    return EditHabitPage(habit: widget.habit);
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
