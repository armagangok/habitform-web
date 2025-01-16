import 'package:habitrise/features/reminder/widget/reminder_widget.dart';

import '/core/core.dart';
import '/models/models.dart';
import '../../edit_habit/edit_habit_page.dart';
import '../../habits/bloc/single_habit/single_habit_bloc.dart';
import '../../habits/widgets/single_habit/single_habit_detail_grid.dart';
import '../../share_habit/share_habit_button.dart';

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
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15) + EdgeInsets.only(top: 10),
                    child: CustomHeader(
                      text: "INFORMATION",
                      child: item(
                        currentHabit.habitName,
                        subtitle: currentHabit.habitDescription,
                        emoji: currentHabit.emoji,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: CustomHeader(
                      text: "REMINDER",
                      child: SizedBox(
                        width: double.infinity,
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  remindTime ?? "None",
                                  style: context.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                if (remindTime != null)
                                  SizedBox(
                                    height: 20,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemCount: days?.length ?? 0,
                                      separatorBuilder: (context, index) {
                                        return Text(
                                          ", ",
                                          style: context.bodyMedium?.copyWith(
                                            color: context.primary.withAlpha(170),
                                          ),
                                        );
                                      },
                                      itemBuilder: (context, index) {
                                        final dayName = days?[index].capitalized ?? "None";
                                        return Text(
                                          dayName,
                                          style: context.bodyMedium?.copyWith(
                                            color: context.primary.withAlpha(170),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: CustomHeader(
                      text: "HABIT DATA",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SingleHabitDetailGrid(habit: currentHabit),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            spacing: 10,
                            children: [
                              CompleteTodayButton(currentHabit: currentHabit),
                            ],
                          ),
                        ],
                      ),
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
                    padding: const EdgeInsets.all(10),
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
                        ShareHabitButton(habit: currentHabit),
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

  Widget item(String title, {String? emoji, String? subtitle}) {
    return title.isEmpty && subtitle == null
        ? SizedBox.shrink()
        : Card(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    if (emoji != null)
                      Text(
                        emoji,
                        style: TextStyle(fontSize: 30),
                      ),
                    if (emoji != null) SizedBox(width: 10),
                    Expanded(
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
                              maxLines: 2,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

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

        context.read<SingleHabitBloc>().add(event);
      },
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
                  style: context.bodySmall?.copyWith(
                    color: context.bodySmall?.color?.withAlpha(170),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (child != null) child!,
            ],
          )
        : SizedBox.shrink();
  }
}
