import '/core/core.dart';
import '../../../../core/helpers/spacing_helper.dart';
import '../../../../core/theme/bloc/theme_bloc.dart';
import '../../../../models/habit/habit_model.dart';
import '../../../add_habit/add_habit_page.dart';
import '../../../habit_detail/page/habit_detail.dart';
import '../../bloc/habit_bloc.dart';
import '../complete_today_button.dart';
import 'weekly_habit_grid.dart';

class SingleHabitBuilder extends StatelessWidget {
  const SingleHabitBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitBloc, HabitState>(
      builder: (context, state) {
        if (state is SingleHabitInitial) return SizedBox.shrink();

        if (state is SingleHabitsFetched) {
          final habits = state.habits;

          if (habits.isEmpty) return _noDataWidget();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _habitBuilder(habits),
              ],
            ),
          );
        }

        if (state is SingleHabitLoading) return Center(child: CupertinoActivityIndicator());

        if (state is SingleHabitFetchError) {
          return Text(
            state.message,
            style: context.bodySmall,
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget _habitBuilder(List<Habit> habits) {
    return Builder(builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: ClampingScrollPhysics(),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                final habitIcon = habit.emoji;
                final reminderTime = habit.reminderModel?.reminderTime;
                final habitDescription = habit.habitDescription;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomButton(
                      onTap: () {
                        CupertinoScaffold.showCupertinoModalBottomSheet(
                          enableDrag: false,
                          context: context,
                          builder: (contextFromSheet) {
                            return HabitDetailPage(habit: habit);
                          },
                        );
                      },
                      child: Column(
                        children: [
                          BlocBuilder<ThemeBloc, ThemeState>(
                            builder: (context, state) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        if (habitIcon != null)
                                          Text(
                                            habitIcon,
                                            style: context.headlineMedium,
                                            maxLines: 1,
                                          ),
                                        if (habitIcon != null) SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                habit.habitName,
                                                style: context.bodyMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                              if (habitDescription != null && habitDescription.isNotEmpty)
                                                Text(
                                                  habitDescription,
                                                  style: context.bodySmall?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  if (reminderTime != null)
                                    Text(
                                      reminderTime.toHHMM(),
                                      style: context.bodySmall,
                                      textAlign: TextAlign.end,
                                    ),
                                ],
                              );
                            },
                          ),
                          SizedBox(height: 10),
                          WeeklyHabitGrid(habit: habit),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    CompleteTodayButton(currentHabit: habit),
                  ],
                );
              },
              separatorBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: KSpacing.betweenListItems),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _noDataWidget() => Align(
        alignment: Alignment.center,
        child: Builder(
          builder: (context) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: context.height(.075)),
                Image.asset(
                  context.theme.brightness == Brightness.dark ? Assets.app.habitriseDarkTransparent.path : Assets.app.habitriseLightTransparent.path,
                  height: 100,
                  width: 100,
                ),
                SizedBox(height: 10),
                Text(
                  "No habit found",
                  style: context.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Let's gain a new habit",
                  style: context.titleMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                CupertinoButton.tinted(
                  sizeStyle: CupertinoButtonSize.medium,
                  child: Text(
                    "Create Habit",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () {
                    CupertinoScaffold.showCupertinoModalBottomSheet(
                      enableDrag: false,
                      context: context,
                      builder: (contextFromSheet) {
                        return AddHabitPage();
                      },
                    );
                  },
                ),
              ],
            );
          },
        ),
      );
}
