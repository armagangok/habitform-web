import '/core/core.dart';
import '/models/habit/habit_model.dart';
import '../../add_habit/add_habit_page.dart';
import '../bloc/habit_bloc.dart';
import 'habit_widget.dart';

class HabitBuilder extends StatelessWidget {
  const HabitBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitBloc, HabitState>(
      builder: (context, state) {
        if (state is HabitInitial) return SizedBox.shrink();

        if (state is HabitsFetched) {
          final habits = state.habits;

          if (habits.isEmpty) return _noDataWidget();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SafeArea(
                  top: false,
                  bottom: false,
                  child: _buildHabitList(habits),
                ),
              ],
            ),
          );
        }

        if (state is HabitLoading) return Center(child: CupertinoActivityIndicator());

        if (state is HabitFetchError) {
          return Text(
            state.message,
            style: context.bodySmall,
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  Widget _buildHabitList(List<Habit> habits) {
    return Builder(
      builder: (context) {
        if (context.isLandscape) {
          return GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: habits.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              childAspectRatio: 2.5,
              crossAxisSpacing: 20,
            ),
            itemBuilder: (context, index) {
              final habit = habits[index];
              return HabitWidget(habit: habit);
            },
          );
        }

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
                  return HabitWidget(habit: habit);
                },
                separatorBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
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
                  height: 120,
                  width: 120,
                ),
                SizedBox(height: 10),
                Text(
                  LocaleKeys.habit_no_habit_found.tr(),
                  style: context.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                CupertinoButton.tinted(
                  color: Colors.deepOrangeAccent,
                  sizeStyle: CupertinoButtonSize.medium,
                  child: Text(
                    LocaleKeys.habit_create_habit.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.deepOrangeAccent,
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
