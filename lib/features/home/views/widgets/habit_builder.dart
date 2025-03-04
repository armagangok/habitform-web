import '/core/core.dart';
import '../../../../models/models.dart';
import '../../../create_habit/create_habit_page.dart';
import 'habit_widget.dart';

class HabitBuilder extends StatelessWidget {
  final List<Habit>? habits;
  final bool isLoading;

  const HabitBuilder({
    super.key,
    this.habits,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading || habits == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(),
            SizedBox(height: 10),
            Text(
              isLoading ? LocaleKeys.common_loading_habits.tr() : LocaleKeys.common_loading_habits.tr(),
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.theme.hintColor,
              ),
            ),
          ],
        ),
      );
    }

    if (habits!.isEmpty) return _noDataWidget();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: SafeArea(
        top: false,
        bottom: false,
        child: _buildHabitList(habits!),
      ),
    );
  }

  Widget _buildHabitList(List<Habit> habits) {
    return Builder(
      builder: (context) {
        if (context.isLandscape) {
          return GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: ClampingScrollPhysics(),
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
                    padding: EdgeInsets.symmetric(vertical: 12.5),
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
                        return CreateHabitPage();
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
