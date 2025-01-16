import '/core/core.dart';
import '/models/models.dart';
import '../../../add_habit/enum/days_enum.dart';
import '../../bloc/single_habit_bloc.dart';

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

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    final habitColor = widget.habit.colorCode;
    return BlocBuilder<SingleHabitBloc, SingleHabitState>(
      builder: (context, state) {
        if (state is SingleHabitsFetched) {
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

                final completionDates = widget.habit.completionDates;

                completionDates?.firstWhere(
                  (d) {
                    isCompletedDate = d.isSameDayWith(dateTimeIn7Days);

                    return isCompletedDate;
                  },
                  orElse: () {
                    isCompletedDate = false;
                    return DateTime.now();
                  }, // Null döndürüyoruz
                );

                return CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 0,
                  onPressed: null,
                  // () {
                  //   final event = UpdateHabitForSelectedDayEvent(
                  //     habit: widget.habit,
                  //     dateToSaveOrRemove: dateTimeIn7Days,
                  //   );

                  //   context.read<SingleHabitBloc>().add(event);
                  // },
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
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: isCompletedDate
                              ? Icon(
                                  CupertinoIcons.check_mark_circled,
                                  color: Color(habitColor).colorRegardingToBrightness,
                                  size: 14,
                                )
                              : null,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        _capitalize(day.toString().split('.').last),
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
        }

        return const SizedBox.shrink(); // Return empty widget if state is different
      },
    );
  }

  String _capitalize(String string) {
    if (string.isEmpty) return string;
    return string[0].toUpperCase() + string.substring(1);
  }
}

List<DateTime>? convertStringListToDateTimeList(List<String>? stringList) {
  if (stringList == null) return null;

  return stringList.map((str) => DateTime.parse(str)).toList();
}
