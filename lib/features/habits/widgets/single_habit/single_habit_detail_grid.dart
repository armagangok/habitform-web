// ignore_for_file: public_member_api_docs, sort_constructors_first
import '/core/core.dart';
import '../../../../models/models.dart';
import '../../../add_habit/enum/days_enum.dart';
import 'weekly_habit_grid.dart';

class SingleHabitDetailGrid extends StatefulWidget {
  final Habit habit;
  const SingleHabitDetailGrid({
    super.key,
    required this.habit,
  });

  @override
  State<SingleHabitDetailGrid> createState() => _SingleHabitDetailGridState();
}

class _SingleHabitDetailGridState extends State<SingleHabitDetailGrid> {
  final List<Last7DaysModel> last90Days = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize habits for the last 6 days and today
    DateTime today = DateTime.now();
    for (int i = 180; i >= 0; i--) {
      DateTime day = today.subtract(Duration(days: i));

      last90Days.add(
        Last7DaysModel(
          day: getDayEnum(day.weekday),
          dateTime: day,
        ),
      );
    }

    // Scroll to the end after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: context.width(1),
      child: GridView.builder(
        controller: _scrollController, // Add the controller here
        scrollDirection: Axis.horizontal,
        itemCount: last90Days.length,
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7, // Number of columns (7 for days)
          crossAxisSpacing: 6,
          mainAxisSpacing: 11, // Spacing between rows
          childAspectRatio: 1, // Aspect ratio of the widget
        ),
        itemBuilder: (context, index) {
          final dateTimeIn90Days = last90Days[index].dateTime;
          final isToday = last90Days[index].dateTime.isToday;
          bool isCompletedDate = false;

          final completionDates = widget.habit.completionDates;

          completionDates?.firstWhere(
            (d) {
              final completedDate = DateTime.parse(d);

              isCompletedDate = completedDate.isSameDayWith(dateTimeIn90Days);

              return isCompletedDate;
            },
            orElse: () {
              isCompletedDate = false;
              return "";
            }, // Null döndürüyoruz
          );

          return Container(
            decoration: BoxDecoration(
              color: isCompletedDate ? Colors.green : context.theme.cardColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isToday ? context.primary : Colors.transparent,
                width: 2,
              ),
            ),
          );
        },
      ),
    );
  }
}
