import 'package:table_calendar/table_calendar.dart';

import '/core/core.dart';
import '../../../models/models.dart';
import '../../habits/bloc/habit_bloc.dart';

class HabitCalendarCompletionSheet extends StatefulWidget {
  final Habit habit;

  const HabitCalendarCompletionSheet({
    super.key,
    required this.habit,
  });

  @override
  State<HabitCalendarCompletionSheet> createState() => _HabitCalendarCompletionSheetState();
}

class _HabitCalendarCompletionSheetState extends State<HabitCalendarCompletionSheet> with SingleTickerProviderStateMixin {
  static final _firstDay = DateTime.utc(2023, 1, 1);
  static final _lastDay = DateTime.now();

  late final DateTime _today;
  late DateTime _focusedDay;
  late Set<DateTime> _completedDays;

  @override
  void dispose() {
    // Ensure all resources are properly disposed
    super.dispose();
  }

  Future<void> _loadCompletionDates() async {
    // Implement the logic to load completion dates from the database
    // Example: _completedDays = await DatabaseService.getCompletionDates(widget.habit.id);
    setState(() {}); // Update the state after loading
  }

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _focusedDay = _today;
    _completedDays = widget.habit.completionDates?.map((date) => DateTime(date.year, date.month, date.day)).toSet() ?? {};
    _loadCompletionDates(); // Load completion dates from the database
    print('Completion Dates: \\${widget.habit.completionDates}'); // Debugging line to check completion dates
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      final normalizedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
      if (_completedDays.contains(normalizedDay)) {
        _completedDays.remove(normalizedDay);
      } else {
        _completedDays.add(normalizedDay);
      }

      // Update the habit with new completion dates
      final updatedHabit = widget.habit.copyWith(completionDates: _completedDays.toList());
      // Dispatch the event to update the habit

      // Save changes to the database
      context.read<HabitBloc>().add(UpdateHabitEvent(habit: updatedHabit));
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const SheetHeader(
        title: "",
        closeButtonPosition: CloseButtonPosition.left,
      ),
      child: ListView(
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        children: [
          Material(
            child: TableCalendar(
              locale: context.locale.languageCode,
              firstDay: _firstDay,
              lastDay: _lastDay,
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                defaultDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8),
                ),
                weekendTextStyle: TextStyle(),
                weekNumberTextStyle: TextStyle(),
                weekendDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8),
                ),
                outsideDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8),
                ),
                todayDecoration: BoxDecoration(
                  color: Color(widget.habit.colorCode).withOpacity(.2),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8),
                ),
                markerDecoration: BoxDecoration(
                  color: Color(widget.habit.colorCode),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(widget.habit.colorCode),
                    width: 1.5,
                  ),
                ),
                markersMaxCount: 1,
                markerSize: 10,
                markersAlignment: Alignment.center,
                markerMargin: const EdgeInsets.only(top: 2),
                cellPadding: EdgeInsets.all(0),
                cellMargin: EdgeInsets.all(10),
                todayTextStyle: TextStyle(
                  color: context.theme.textTheme.bodyLarge?.color,
                ),
              ),
              onDaySelected: _onDaySelected,
              eventLoader: (day) {
                final normalizedDay = DateTime(day.year, day.month, day.day);
                return _completedDays.contains(normalizedDay) ? [normalizedDay] : [];
              },
            ),
          ),
          const SizedBox(height: 16),
          SafeArea(
            top: false,
            child: Text(
              LocaleKeys.habit_calendar_tap_info.tr(),
              style: context.bodySmall?.copyWith(
                color: context.theme.hintColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
