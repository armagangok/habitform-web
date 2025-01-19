import '../../../core/core.dart';
import '../bloc/day_selection/day_selection_cubit.dart';
import '../bloc/reminder/reminder_bloc.dart';
import '../models/days/days_enum.dart';
import '../extension/easy_day.dart';
class DaysGridViewBuilder extends StatefulWidget {
  const DaysGridViewBuilder({super.key});

  @override
  State<DaysGridViewBuilder> createState() => _DaysGridViewBuilderState();
}

class _DaysGridViewBuilderState extends State<DaysGridViewBuilder> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reminderState = context.read<ReminderBloc>().state;
      if (reminderState.reminder?.days != null) {
        context.read<DaySelectionCubit>().initializeDays(reminderState.reminder!.days!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DaySelectionCubit, List<Days>>(
      builder: (context, selectedDays) {
        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: allDays.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final currentDay = allDays[index];
            final isSelected = selectedDays.contains(currentDay);
            final dayName = currentDay.getDayName;

            return CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                final daySelectionCubit = context.read<DaySelectionCubit>();
                daySelectionCubit.selectOneByOne(currentDay, context);
                // Güncel seçili günleri al ve ReminderBloc'u güncelle
                final updatedDays = List<Days>.from(daySelectionCubit.state);
                context.read<ReminderBloc>().add(UpdateReminderDaysEvent(days: updatedDays));
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
                  padding: const EdgeInsets.all(1),
                  child: Center(
                    child: Text(
                      dayName,
                      maxLines: 1,
                      style: context.bodySmall?.copyWith(
                        color: isSelected ? Colors.white : null,
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
