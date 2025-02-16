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

class _WeeklyHabitGridState extends State<WeeklyHabitGrid> with SingleTickerProviderStateMixin {
  final List<Last7DaysModel> last7Days = [];
  late Habit currentHabit;

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this);
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
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
        return current is HabitsFetched;
      },
      listener: (context, state) {
        if (state is HabitsFetched) {
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
        return current is HabitsFetched;
      },
      builder: (context, state) {
        LogHelper.shared.debugPrint('Building WeeklyHabitGrid with habit: ${currentHabit.id}');
        LogHelper.shared.debugPrint('Completion dates: ${currentHabit.completionDates}');

        final habitColor = currentHabit.colorCode;
        final emoji = currentHabit.emoji;

        return LayoutBuilder(
          builder: (context, constraints) {
            // Calculate the available width for each day
            final availableWidth = constraints.maxWidth;
            final itemWidth = (availableWidth - (last7Days.length - 1) * 5) / last7Days.length; // 5 is the spacing between items

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                last7Days.length,
                (index) {
                  final dateTimeIn7Days = last7Days[index].dateTime;
                  bool isCompletedDate = false;

                  final completionDates = currentHabit.completionDates;

                  if (completionDates != null && completionDates.isNotEmpty) {
                    isCompletedDate = completionDates.any((d) => d.isSameDayWith(dateTimeIn7Days));
                  }

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3),
                      child: SizedBox(
                        height: itemWidth,
                        width: itemWidth, // Set the width of each item
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          minSize: 0,
                          onPressed: null,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 1),
                            child: Card(
                              margin: EdgeInsets.zero,
                              shadowColor: Colors.transparent,
                              surfaceTintColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: context.primary.withAlpha(50),
                                  width: .5,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              color: isCompletedDate ? Color(habitColor) : null,
                              child: SizedBox(
                                child: Align(
                                  child: Center(
                                    child: Text(
                                      isCompletedDate ? emoji ?? "" : "",
                                      style: TextStyle(fontSize: context.isPortrait ? 22 : 24),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ).animate(controller: _animationController).fadeIn(
                              duration: Duration(milliseconds: 750),
                            ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

                      // SizedBox(height: 2),
                      // Text(
                      //   day.getDayName,
                      //   maxLines: 1,
                      //   overflow: TextOverflow.ellipsis,
                      //   textAlign: TextAlign.center,
                      //   style: context.bodySmall?.copyWith(fontSize: 11),
                      // ),