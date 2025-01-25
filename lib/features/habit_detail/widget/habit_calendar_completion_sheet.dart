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
  // Use static final instead of const for DateTime
  static final _firstDay = DateTime.utc(2023, 1, 1);
  static final _lastDay = DateTime.now();

  late final DateTime _today;
  late DateTime _focusedDay;
  late Set<DateTime> _completedDays;

  // Cache the calendar style
  late final CalendarStyle _calendarStyle;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _focusedDay = _today;
    _completedDays = widget.habit.completionDates?.map((date) => DateTime(date.year, date.month, date.day)).toSet() ?? {};

    // Initialize calendar style
    _calendarStyle = CalendarStyle(
      defaultDecoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8),
      ),
      weekendTextStyle: const TextStyle(),
      weekNumberTextStyle: const TextStyle(),
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
      cellPadding: EdgeInsets.zero,
      cellMargin: const EdgeInsets.all(10),
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    final normalizedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

    setState(() {
      _focusedDay = focusedDay;

      if (_completedDays.contains(normalizedDay)) {
        _completedDays.remove(normalizedDay);
      } else {
        _completedDays.add(normalizedDay);
      }
    });

    // Update the habit with new completion dates outside setState
    final updatedHabit = widget.habit.copyWith(completionDates: _completedDays.toList());
    context.read<HabitBloc>().add(UpdateHabitEvent(habit: updatedHabit));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const SheetHeader(
        title: "",
        closeButtonPosition: CloseButtonPosition.left,
      ),
      child: ListView(
        physics: const ClampingScrollPhysics(),
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
              calendarStyle: _calendarStyle,
              onDaySelected: _onDaySelected,
              eventLoader: (day) {
                final normalizedDay = DateTime(day.year, day.month, day.day);
                return _completedDays.contains(normalizedDay) ? [normalizedDay] : const [];
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
