import '../../../core/core.dart';
import '../bloc/day_selection/day_selection_cubit.dart';
import '../bloc/reminder/reminder_bloc.dart';
import '../models/days/days_enum.dart';
import 'reminder_widget.dart';

class DaysGridViewBuilder extends StatelessWidget {
  const DaysGridViewBuilder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DaySelectionCubit, List<Days>>(
      builder: (context, state) {
        final selectedDays = state;
        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: allDays.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 8,
            mainAxisSpacing: 20,
          ),
          itemBuilder: (context, index) {
            final currentDay = allDays[index];
            final isSelected = selectedDays.contains(currentDay);

            return CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                final selectedDay = allDays[index];
                context.read<DaySelectionCubit>().selectOneByOne(selectedDay);

                context.read<ReminderBloc>().add(UpdateReminderDaysEvent(days: state));
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: context.theme.dividerColor.withAlpha(75),
                    width: .75,
                  ),
                ),
                color: isSelected ? context.primary : context.cupertinoTheme.scaffoldBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Center(
                    child: FittedBox(
                      child: Text(
                        currentDay.capitalized,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
