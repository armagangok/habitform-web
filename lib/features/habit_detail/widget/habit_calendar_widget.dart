import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitrise/core/core.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../models/completion_entry/completion_entry.dart';
import '../../../models/models.dart';
import '../providers/habit_detail_provider.dart';

class HabitCalendarWidget extends ConsumerWidget {
  const HabitCalendarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentHabit = ref.watch(habitDetailProvider);

    return CupertinoButton.tinted(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      sizeStyle: CupertinoButtonSize.small,
      onPressed: () {
        showCupertinoModalBottomSheet(
          enableDrag: false,
          context: context,
          builder: (context) => HabitCalendarCompletionSheet(habit: currentHabit!),
        );
      },
      child: Icon(
        FontAwesomeIcons.solidCalendarDays,
        size: 20,
      ),
    );
  }
}

class HabitCalendarCompletionSheet extends ConsumerStatefulWidget {
  final Habit habit;

  const HabitCalendarCompletionSheet({
    super.key,
    required this.habit,
  });

  @override
  ConsumerState<HabitCalendarCompletionSheet> createState() => _HabitCalendarCompletionSheetState();
}

class _HabitCalendarCompletionSheetState extends ConsumerState<HabitCalendarCompletionSheet> with SingleTickerProviderStateMixin {
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
    _completedDays = widget.habit.completions.values.where((completion) => completion.isCompleted).map((completion) => completion.date.normalized).toSet();

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
        color: Color(widget.habit.colorCode).withValues(alpha: .2),
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

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    final selectedDateTime = selectedDay.normalized;
    final wasCompleted = _completedDays.contains(selectedDateTime);
    final willBeCompleted = !wasCompleted;

    setState(() {
      _focusedDay = focusedDay;

      // Update completed days based on new state
      if (willBeCompleted) {
        _completedDays.add(selectedDateTime);
      } else {
        _completedDays.remove(selectedDateTime);
      }
    });

    // Mevcut bir tamamlama kaydı var mı kontrol et
    CompletionEntry? existingEntry;
    for (var entry in widget.habit.completions.values) {
      if (entry.date.normalized.isSameDayWith(selectedDateTime)) {
        existingEntry = entry;
        LogHelper.shared.debugPrint('Found existing completion entry for the selected date');
        break;
      }
    }

    // Var olan kaydı güncelle veya yeni oluştur
    final completion = existingEntry != null
        ? existingEntry.copyWith(isCompleted: willBeCompleted)
        : CompletionEntry(
            id: selectedDateTime.toIso8601DateString,
            date: selectedDateTime,
            isCompleted: willBeCompleted,
          );

    try {
      // Update the habit with new completion using habitDetailProvider
      await ref.read(habitDetailProvider.notifier).markHabitAsComplete(widget.habit.id, completion);

      // Verify the updated habit
      final updatedHabit = ref.read(habitDetailProvider);
      if (updatedHabit != null) {}
    } catch (e) {
      // Hata durumunda UI'ı eski haline getir
      setState(() {
        if (willBeCompleted) {
          _completedDays.remove(selectedDateTime);
        } else {
          _completedDays.add(selectedDateTime);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPopupSurface(
      isSurfacePainted: true,
      child: CupertinoPageScaffold(
        backgroundColor: Colors.transparent,
        navigationBar: const SheetHeader(
          title: "",
          closeButtonPosition: CloseButtonPosition.left,
        ),
        child: ListView(
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
          children: [
            Material(
              color: Colors.transparent,
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
                selectedDayPredicate: (day) => _completedDays.contains(day),
                onDaySelected: _onDaySelected,
                eventLoader: (day) {
                  final normalizedDay = DateTime(day.year, day.month, day.day);
                  return _completedDays.contains(normalizedDay) ? [normalizedDay] : const [];
                },
                sixWeekMonthsEnforced: false,
                rowHeight: 52,
                daysOfWeekHeight: 40,
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
      ),
    );
  }
}
