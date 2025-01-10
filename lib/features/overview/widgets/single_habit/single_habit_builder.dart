import 'package:habitrise/features/overview/widgets/single_habit/habit_detail.dart';

import '/core/core.dart';
import '/models/single_habit/habit_model.dart';
import '../../../habits/bloc/single_habit/single_habit_bloc.dart';
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
              CupertinoListSection(
                dividerMargin: 0,
                additionalDividerMargin: 0,
                separatorColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                header: Text(
                  "SINGLE HABITS",
                ),
                children: [
                  state.habits.isEmpty
                      ? _noDataWidget()
                      : SizedBox(
                          height: 170,
                          child: GridView.builder(
                            padding: const EdgeInsets.all(10.0),
                            scrollDirection: Axis.horizontal,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1, // Tek satır
                              mainAxisSpacing: 30, // Elemanlar arası boşluk
                              childAspectRatio: .625, // Genişliği serbestçe kontrol et
                            ),
                            itemCount: state.habits.length,
                            itemBuilder: (context, index) {
                              final singleHabit = state.habits[index];

                              return _singleHabitItem(singleHabit, index);
                            },
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                style: context.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
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
