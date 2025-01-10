import '/core/core.dart';
import '/models/models.dart';
import '../../../add_habit/enum/days_enum.dart';
import '../../../habits/bloc/single_habit/single_habit_bloc.dart';

class Last7DaysModel {
  final Days day;
  final DateTime dateTime;

  Last7DaysModel({
    required this.day,
    required this.dateTime,
  });
}

class SingleHabitGrid extends StatefulWidget {
  final Habit habit;
  const SingleHabitGrid({
    super.key,
    required this.habit,
  });

  @override
  State<SingleHabitGrid> createState() => _SingleHabitGridState();
}

class _SingleHabitGridState extends State<SingleHabitGrid> {
  final List<Last7DaysModel> last7Days = [];

  @override
  void initState() {
    super.initState();
    // Initialize habits for the last 6 days and today
    DateTime today = DateTime.now();
    for (int i = 6; i >= 0; i--) {
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
    return BlocBuilder<SingleHabitBloc, SingleHabitState>(
      builder: (context, state) {
        if (state is SingleHabitsFetched) {
          return SizedBox(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: last7Days.length, // Number of columns (7 for days)
                crossAxisSpacing: 0,
                mainAxisSpacing: 10, // Spacing between rows
                childAspectRatio: .75, // Aspect ratio of the widget
              ),
              itemCount: last7Days.length,
              itemBuilder: (context, index) {
                final day = last7Days[index].day;
                final dateTimeIn7Days = last7Days[index].dateTime;

                final isToday = dateTimeIn7Days.isToday;
                bool isCompletedDate = false;

                final completionDates = widget.habit.completionDates;

                completionDates?.firstWhere(
                  (d) {
                    final completedDate = DateTime.parse(d);

                    isCompletedDate = completedDate.isSameDayWith(dateTimeIn7Days);

                    return isCompletedDate;
                  },
                  orElse: () {
                    isCompletedDate = false;
                    return "";
                  }, // Null döndürüyoruz
                );

                return CustomButton(
                  onTap: () {
                    final event = UpdateHabitForSelectedDayEvent(
                      habit: widget.habit,
                      dateToSaveOrRemove: dateTimeIn7Days,
                    );

                    context.read<SingleHabitBloc>().add(event);
                  },
                  child: FittedBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Green box
                        Container(
                          padding: EdgeInsets.zero,
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isCompletedDate ? CupertinoColors.activeGreen : context.colors.background,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isToday ? context.cupertinoTheme.textTheme.actionTextStyle.color ?? Colors.transparent : Colors.transparent,
                              width: 1.5,
                              strokeAlign: BorderSide.strokeAlignOutside,
                            ),
                          ),
                          child: isCompletedDate
                              ? Icon(
                                  CupertinoIcons.check_mark_circled,
                                  color: Colors.white70,
                                )
                              : null,
                        ),

                        SizedBox(height: 4),

                        Text(
                          _capitalize(day.toString().split('.').last),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis, // Ellipsis for overflow
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15, // Font size
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
