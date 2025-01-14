import '/core/core.dart';
import '../../bloc/single_habit/single_habit_bloc.dart';
import 'habit_detail.dart';
import 'weekly_habit_grid.dart';

class SingleHabitBuilder extends StatelessWidget {
  const SingleHabitBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SingleHabitBloc, SingleHabitState>(
      builder: (context, state) {
        if (state is SingleHabitInitial) return SizedBox.shrink();

        if (state is SingleHabitsFetched) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                state.habits.isEmpty ? _noDataWidget() : _item(state),
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

  Widget _item(SingleHabitsFetched state) {
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
              itemCount: state.habits.length,
              itemBuilder: (context, index) {
                final habit = state.habits[index];
                final habitIcon = habit.emoji;
                final reminderTime = habit.reminderModel?.reminderTime;
                final habitDescription = habit.habitDescription;

                return CustomButton(
                  onTap: () {
                    CupertinoScaffold.showCupertinoModalBottomSheet(
                      enableDrag: false,
                      context: context,
                      builder: (contextFromSheet) {
                        return SingleHabitDetailPage(habit: habit);
                      },
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              child: Row(
                                children: [
                                  if (habitIcon != null)
                                    Text(
                                      habitIcon,
                                      style: context.headlineMedium,
                                    ),
                                  if (habitIcon != null) SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        habit.habitName,
                                        style: context.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (habitDescription != null && habitDescription.isNotEmpty)
                                        Text(
                                          habitDescription,
                                          style: context.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
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
                      ),
                      SizedBox(height: 10),
                      WeeklyHabitGrid(habit: habit),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: SizedBox(
                      height: 30,
                      child: VerticalDivider(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _noDataWidget() => SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Builder(
                builder: (context) {
                  return Text(
                    "You have not created habit yet",
                    style: context.bodySmall,
                  );
                },
              ),
            ],
          ),
        ),
      );
}
