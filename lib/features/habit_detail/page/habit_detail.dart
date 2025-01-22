import '/core/core.dart';
import '/features/habit_detail/widget/habit_calendar_widget.dart';
import '/features/reminder/extension/easy_day.dart';
import '/models/models.dart';
import '../../edit_habit/edit_habit_page.dart';
import '../../habits/bloc/habit_bloc.dart';
import '../../habits/widgets/complete_today_button.dart';
import '../../habits/widgets/single_habit/single_habit_detail_grid.dart';
import '../../share_habit/share_habit_button.dart';
import '../bloc/habit_detail_bloc.dart';
import '../providers/habit_detail_bloc_provider.dart';

class HabitDetailPage extends StatelessWidget {
  const HabitDetailPage({
    super.key,
    required this.habit,
  });

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    return HabitDetailProvider(
      habit: habit,
      child: BlocConsumer<HabitBloc, HabitState>(
        listener: (context, state) {
          if (state is HabitsFetched) {
            final updatedHabit = state.habits.firstWhere(
              (habit) => habit.id == this.habit.id,
              orElse: () => habit,
            );
            if (updatedHabit != habit) {
              context.read<HabitDetailBloc>().add(UpdateHabitDetailEvent(habit: updatedHabit));
            }
          }
        },
        builder: (context, state) {
          return BlocBuilder<HabitDetailBloc, HabitDetailState>(
            builder: (context, state) {
              if (state is! HabitDetailLoaded) {
                return const Center(child: CupertinoActivityIndicator());
              }

              final currentHabit = state.habit;
              final days = currentHabit.reminderModel?.days;
              final remindTime = currentHabit.reminderModel?.reminderTime?.toHHMM();

              print("Current Habit: ${currentHabit.habitName}");

              return Stack(
                children: [
                  CupertinoPageScaffold(
                    navigationBar: SheetHeader(
                      title: LocaleKeys.habit_detail_habitDetail.tr(),
                      closeButtonPosition: CloseButtonPosition.left,
                    ),
                    child: ListView(
                      children: [
                        SafeArea(
                          child: Column(
                            spacing: 30,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15) + EdgeInsets.only(top: 10),
                                child: CustomHeader(
                                  text: LocaleKeys.common_general.tr(),
                                  child: item(
                                    currentHabit.habitName,
                                    subtitle: currentHabit.habitDescription,
                                    emoji: currentHabit.emoji,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: CustomHeader(
                                  text: LocaleKeys.habit_reminder.tr().toUpperCase(),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Card(
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              remindTime ?? LocaleKeys.common_none.tr(),
                                              style: context.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                            ),
                                            if (days != null && days.isNotEmpty)
                                              SizedBox(
                                                height: 20,
                                                child: ListView.separated(
                                                  scrollDirection: Axis.horizontal,
                                                  shrinkWrap: true,
                                                  itemCount: days.length,
                                                  separatorBuilder: (context, index) {
                                                    return Text(
                                                      ", ",
                                                      style: context.bodyMedium?.copyWith(
                                                        color: context.primary.withAlpha(170),
                                                      ),
                                                    );
                                                  },
                                                  itemBuilder: (context, index) {
                                                    final dayName = days[index].capitalized;
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
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: CustomHeader(
                                  text: LocaleKeys.habit_habit_data.tr(),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      SingleHabitDetailGrid(habit: currentHabit),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        spacing: 10,
                                        children: [
                                          HabitCalendarWidget(habit: currentHabit),
                                          CompleteTodayButton(currentHabit: currentHabit),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 40),
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
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            spacing: 15,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: CupertinoButton.tinted(
                                  sizeStyle: CupertinoButtonSize.small,
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    _showDeleteConfirmationDialog(context, currentHabit);
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        LocaleKeys.common_delete.tr(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Icon(
                                        FontAwesomeIcons.solidTrashCan,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Builder(builder: (context) {
                                  return CupertinoButton.tinted(
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
                                          LocaleKeys.common_edit.tr(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Icon(
                                          FontAwesomeIcons.solidPenToSquare,
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
        },
      ),
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
                        style: TextStyle(fontSize: 32),
                      ),
                    if (emoji != null) SizedBox(width: 10),
                    Expanded(
                      child: Builder(builder: (context) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: context.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (subtitle != null && subtitle.isNotEmpty)
                              Text(
                                subtitle,
                                style: context.bodyMedium?.copyWith(
                                  color: context.bodyMedium?.color?.withAlpha(180),
                                ),
                              ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Habit habit) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(LocaleKeys.common_delete.tr()),
          content: Text(LocaleKeys.habit_detail_areYouSureToDeleteHabit.tr()),
          actions: [
            CupertinoDialogAction(
              child: Text(LocaleKeys.common_cancel.tr()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text(
                LocaleKeys.common_delete.tr(),
                style: TextStyle(color: CupertinoColors.destructiveRed),
              ),
              onPressed: () {
                context.read<HabitBloc>().add(DeleteHabitEvent(habit: habit));
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
