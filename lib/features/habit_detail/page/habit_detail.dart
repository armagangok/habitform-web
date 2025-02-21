import 'package:habitrise/core/widgets/blur_widget.dart';
import 'package:habitrise/features/habit_detail/widget/habit_data_widget.dart';
import 'package:habitrise/features/share_habit/share_habit_button.dart';

import '/core/core.dart';
import '/features/reminder/extension/easy_day.dart';
import '/features/reminder/models/days/days_enum.dart';
import '/models/models.dart';
import '../../edit_habit/edit_habit_page.dart';
import '../../habits/bloc/habit_bloc.dart';
import '../../habits/widgets/mark_today_home_button.dart';
import '../bloc/habit_detail_bloc.dart';
import '../providers/habit_detail_bloc_provider.dart';
import '../widget/habit_calendar_widget.dart';

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
            buildWhen: (previous, current) {
              // Only rebuild if the habit data has changed
              if (previous is HabitDetailLoaded && current is HabitDetailLoaded) {
                return previous.habit != current.habit;
              }
              return true;
            },
            builder: (context, state) {
              if (state is! HabitDetailLoaded) {
                return const Center(child: CupertinoActivityIndicator());
              }

              final currentHabit = state.habit;
              final days = currentHabit.reminderModel?.days;
              final remindTime = currentHabit.reminderModel?.reminderTime?.toHHMM();

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
                                padding: const EdgeInsets.symmetric(horizontal: 15) + const EdgeInsets.only(top: 10),
                                child: CustomHeader(
                                  text: LocaleKeys.common_general.tr().toUpperCase(),
                                  child: _HabitGeneralInfo(
                                    name: currentHabit.habitName,
                                    description: currentHabit.habitDescription,
                                    emoji: currentHabit.emoji,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: CustomHeader(
                                  text: LocaleKeys.habit_reminder.tr().toUpperCase(),
                                  child: _ReminderInfo(
                                    remindTime: remindTime,
                                    days: days,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    HabitDataWidget(habit: currentHabit),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      spacing: 10,
                                      children: [
                                        MarkTodayHomeButton(currentHabit: currentHabit),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: CustomBlurWidget(
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              spacing: 8,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(child: HabitCalendarWidget(habit: currentHabit)),
                                Expanded(
                                  child: _DeleteButton(habit: currentHabit),
                                ),
                                Expanded(child: ShareHabitButton(habit: habit)),
                                Expanded(
                                  child: _EditButton(habit: currentHabit),
                                ),
                              ],
                            ),
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
}

class _HabitGeneralInfo extends StatelessWidget {
  const _HabitGeneralInfo({
    required this.name,
    this.description,
    this.emoji,
  });

  final String name;
  final String? description;
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: context.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (description.isNotNullAndNotEmpty)
                Text(
                  description!,
                  style: context.bodyMedium?.copyWith(color: context.bodyMedium?.color?.withAlpha(170)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderInfo extends StatelessWidget {
  const _ReminderInfo({
    required this.remindTime,
    this.days,
  });

  final String? remindTime;
  final List<Days>? days;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                remindTime ?? LocaleKeys.common_none.tr(),
                style: context.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (days != null && days!.isNotEmpty)
                SizedBox(
                  height: 20,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: days!.length,
                    separatorBuilder: (context, index) {
                      return Text(
                        ", ",
                        style: context.bodyMedium?.copyWith(
                          color: context.primary.withAlpha(170),
                        ),
                      );
                    },
                    itemBuilder: (context, index) {
                      final dayName = days![index].capitalized;
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
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton.tinted(
      sizeStyle: CupertinoButtonSize.small,
      onPressed: () => _showDeleteConfirmationDialog(context, habit),
      child: Icon(
        FontAwesomeIcons.solidTrashCan,
        size: 20,
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton.tinted(
      sizeStyle: CupertinoButtonSize.small,
      onPressed: () {
        showCupertinoModalBottomSheet(
          enableDrag: false,
          context: context,
          builder: (context) => EditHabitPage(habit: habit),
        );
      },
      child: Icon(
        FontAwesomeIcons.solidPenToSquare,
        size: 20,
      ),
    );
  }
}

void _showDeleteConfirmationDialog(BuildContext context, Habit habit) {
  showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(LocaleKeys.common_delete.tr()),
      content: Text(LocaleKeys.habit_detail_areYouSureToDeleteHabit.tr()),
      actions: [
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
            context.read<HabitBloc>().add(DeleteHabitEvent(habit: habit));
            Navigator.pop(context);
          },
          child: Text(LocaleKeys.common_delete.tr()),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: Text(LocaleKeys.common_cancel.tr()),
        ),
      ],
    ),
  );
}
