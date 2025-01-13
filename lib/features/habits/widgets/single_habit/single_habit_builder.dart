import 'package:habitrise/features/habits/widgets/single_habit/habit_detail.dart';

import '/core/core.dart';
import '/models/single_habit/habit_model.dart';
import '../../bloc/single_habit/single_habit_bloc.dart';
import 'single_habit_grid.dart';

class SingleHabitBuilder extends StatelessWidget {
  const SingleHabitBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SingleHabitBloc, SingleHabitState>(
      builder: (context, state) {
        if (state is SingleHabitInitial) return SizedBox.shrink();

        if (state is SingleHabitsFetched) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              state.habits.isEmpty
                  ? _noDataWidget()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ListView.separated(
                            padding: EdgeInsets.all(20),
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            itemCount: state.habits.length,
                            itemBuilder: (context, index) {
                              final habit = state.habits[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "🚀",
                                                    style: context.headlineMedium,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        habit.habitName,
                                                        style: context.bodyMedium?.copyWith(
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        habit.habitName,
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
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        DateTime.parse(habit.reminderModel?.reminderTime ?? DateTime.now().toString()).toHHMM() ?? "",
                                        style: context.bodySmall,
                                        textAlign: TextAlign.end,
                                      )
                                    ],
                                  ),
                                ],
                              );
                            },
                            separatorBuilder: (context, index) => Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SizedBox(
                                  height: 30,
                                  child: VerticalDivider(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          );
        }

        if (state is SingleHabitLoading) return Center(child: CupertinoActivityIndicator());

        if (state is SingleHabitFetchError) {
          return Text(state.message);
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget _singleHabitItem(Habit habit, int index) {
    return Builder(
      builder: (context) {
        return CupertinoButton(
          padding: EdgeInsets.zero,
          minSize: 0,
          onPressed: () {
            CupertinoScaffold.showCupertinoModalBottomSheet(
              enableDrag: false,
              context: context,
              builder: (context) {
                return SingleHabitDetailPage(habit: habit);
              },
            );
          },
          child: Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.water_drop_outlined,
                            ),
                            SizedBox(width: 5),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    habit.habitName,
                                    style: context.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (habit.habitDescription != null && habit.habitDescription!.isNotEmpty)
                                    Text(
                                      habit.habitDescription!,
                                      style: context.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  SingleHabitGrid(habit: habit),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  SizedBox _noDataWidget() {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("You have not created habit yet"),
          ],
        ),
      ),
    );
  }
}
