import '/core/core.dart';
import '/models/models.dart';
import '../../../reminder/extension/easy_day.dart';
import '../../../reminder/models/days/days_enum.dart';
import '../../bloc/habit_bloc.dart';

class Last7DaysModel {
  final Days day;
  final DateTime dateTime;

  Last7DaysModel({
    required this.day,
    required this.dateTime,
  });
}

class WeeklyHabitGrid extends StatefulWidget {
  final Habit habit;
  const WeeklyHabitGrid({
    super.key,
    required this.habit,
  });

  @override
  State<WeeklyHabitGrid> createState() => _WeeklyHabitGridState();
}

class _WeeklyHabitGridState extends State<WeeklyHabitGrid> {
  final List<Last7DaysModel> last7Days = [];
  late Habit currentHabit;

  @override
  void initState() {
    super.initState();
    currentHabit = widget.habit;
    // Initialize habits for the last 6 days and today
    DateTime today = DateTime.now();
    for (int i = 9; i >= 0; i--) {
      DateTime day = today.subtract(Duration(days: i));

      last7Days.add(
        Last7DaysModel(
          day: getDayEnum(day.weekday),
          dateTime: day,
        ),
      );
    }
  }

  @override
  void didUpdateWidget(WeeklyHabitGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    LogHelper.shared.debugPrint('didUpdateWidget called in WeeklyHabitGrid');
    LogHelper.shared.debugPrint('Old habit: ${oldWidget.habit}');
    LogHelper.shared.debugPrint('New habit: ${widget.habit}');
    if (oldWidget.habit != widget.habit) {
      LogHelper.shared.debugPrint('Habit updated in WeeklyHabitGrid');
      currentHabit = widget.habit;
      setState(() {});
    }
  }

  void _updateCurrentHabit(Habit updatedHabit) {
    if (currentHabit != updatedHabit) {
      setState(() {
        currentHabit = updatedHabit;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HabitBloc, HabitState>(
      listenWhen: (previous, current) {
        LogHelper.shared.debugPrint('listenWhen called with current state: $current');
        return current is SingleHabitsFetched;
      },
      listener: (context, state) {
        if (state is SingleHabitsFetched) {
          final updatedHabit = state.habits.firstWhere(
            (h) => h.id == currentHabit.id,
            orElse: () => currentHabit,
          );

          LogHelper.shared.debugPrint('State changed in WeeklyHabitGrid');
          LogHelper.shared.debugPrint('Current habit: $currentHabit');
          LogHelper.shared.debugPrint('Updated habit from state: $updatedHabit');
          LogHelper.shared.debugPrint('Are habits equal? ${updatedHabit == currentHabit}');

          _updateCurrentHabit(updatedHabit);
        }
      },
      buildWhen: (previous, current) {
        return current is SingleHabitsFetched;
      },
      builder: (context, state) {
        LogHelper.shared.debugPrint('Building WeeklyHabitGrid with habit: ${currentHabit.id}');
        LogHelper.shared.debugPrint('Completion dates: ${currentHabit.completionDates}');

        final habitColor = currentHabit.colorCode;
        final emoji = currentHabit.emoji;

        return SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 0,
            children: List.generate(last7Days.length, (index) {
              final day = last7Days[index].day;
              final dateTimeIn7Days = last7Days[index].dateTime;

              final isToday = dateTimeIn7Days.isToday;
              bool isCompletedDate = false;

              final completionDates = currentHabit.completionDates;

              if (completionDates != null && completionDates.isNotEmpty) {
                isCompletedDate = completionDates.any((d) => d.isSameDayWith(dateTimeIn7Days));
              }

              return CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 0,
                onPressed: () {
                  LogHelper.shared.debugPrint('Tapped on date: $dateTimeIn7Days');
                  LogHelper.shared.debugPrint('Current completion status: $isCompletedDate');

                  final event = UpdateHabitForSelectedDayEvent(
                    dateToSaveOrRemove: dateTimeIn7Days,
                    habit: currentHabit,
                  );
                  context.read<HabitBloc>().add(event);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: isToday ? context.primary : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      color: isCompletedDate ? Color(habitColor) : null,
                      child: FittedBox(
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: isCompletedDate
                              ? Center(
                                  child: Text(
                                    emoji ?? "",
                                    style: TextStyle(fontSize: 22),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      day.getDayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: context.bodySmall?.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
