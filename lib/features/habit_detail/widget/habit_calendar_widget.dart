import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import 'package:table_calendar/table_calendar.dart';

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
        showAppModalSheet(
          context: context,
          builder: (context) => HabitCalendarCompletionSheet(habit: currentHabit!),
        );
      },
      child: const Icon(
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

  // Track per-day completion ratio (0.0 - 1.0) for progressive coloring
  late Map<DateTime, double> _ratioByDay;

  // Track whether a given day is in decreasing mode (tap should decrement)
  final Map<String, bool> _decreasingModeByDateKey = {};

  // Cache the calendar style
  late final CalendarStyle _calendarStyle;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _focusedDay = _today;
    _completedDays = widget.habit.completions.values.where((completion) => completion.isCompleted).map((completion) => completion.date.normalized).toSet();

    // Build initial ratios map for multi-completion visualization
    final int target = widget.habit.dailyTarget <= 0 ? 1 : widget.habit.dailyTarget;
    _ratioByDay = {};
    for (final entry in widget.habit.completions.values) {
      final day = entry.date.normalized;
      final ratio = (entry.count / target).clamp(0.0, 1.0);
      final current = _ratioByDay[day] ?? 0.0;
      _ratioByDay[day] = (current + ratio).clamp(0.0, 1.0);
      // Initialize decreasing mode for this day
      final dateKey = day.toIso8601DateString;
      if (_ratioByDay[day]! >= 1.0) {
        _decreasingModeByDateKey[dateKey] = true;
      } else if (_ratioByDay[day] == 0.0) {
        _decreasingModeByDateKey[dateKey] = false;
      }
    }

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
    setState(() {
      _focusedDay = focusedDay;
    });

    // Use latest habit state from provider
    final latestHabit = ref.read(habitDetailProvider) ?? widget.habit;

    // Optimized lookup: try direct key lookup first (O(1) instead of O(n))
    final normalizedDate = selectedDateTime.normalized;
    final dateKey = normalizedDate.toIso8601DateString;
    CompletionEntry? existingEntry = latestHabit.completions[dateKey];

    // Verify the entry matches the date (in case of key collision)
    if (existingEntry != null && !existingEntry.date.normalized.isSameDayWith(normalizedDate)) {
      // Try alternative key format
      final altKey = '${normalizedDate.year}-${normalizedDate.month}-${normalizedDate.day}';
      existingEntry = latestHabit.completions[altKey];
      if (existingEntry != null && !existingEntry.date.normalized.isSameDayWith(normalizedDate)) {
        existingEntry = null;
      }
    }

    // Fallback to linear search only if direct lookup fails (should be rare)
    if (existingEntry == null) {
      for (var entry in latestHabit.completions.values) {
        if (entry.date.normalized.isSameDayWith(normalizedDate)) {
          existingEntry = entry;
          break;
        }
      }
    }

    final target = latestHabit.dailyTarget <= 0 ? 1 : latestHabit.dailyTarget;
    final currentCount = existingEntry?.count ?? 0;
    bool isDecreasing = _decreasingModeByDateKey[dateKey] ?? (currentCount >= target);

    int nextCount;
    bool incrementAction;
    if (isDecreasing) {
      // Decrement path
      nextCount = (currentCount - 1) < 0 ? 0 : (currentCount - 1);
      incrementAction = false;
      if (nextCount == 0) {
        // Switch back to increasing mode once we hit 0
        _decreasingModeByDateKey[dateKey] = false;
      }
    } else {
      // Increment path
      nextCount = (currentCount + 1) > target ? target : (currentCount + 1);
      incrementAction = true;
      if (nextCount >= target) {
        // Switch to decreasing mode once target is reached
        _decreasingModeByDateKey[dateKey] = true;
      }
    }

    final willBeFull = nextCount >= target;
    final willDropBelowFull = currentCount >= target && nextCount < target;

    // Optimistic UI updates
    setState(() {
      if (willBeFull) {
        _completedDays.add(selectedDateTime);
      }
      if (willDropBelowFull) {
        _completedDays.remove(selectedDateTime);
      }
      _ratioByDay[selectedDateTime] = (nextCount / target).clamp(0.0, 1.0);
    });

    final completion = CompletionEntry(
      id: dateKey,
      date: selectedDateTime,
      // true -> increment, false -> decrement
      isCompleted: incrementAction,
    );

    try {
      await ref.read(habitDetailProvider.notifier).markHabitAsComplete(latestHabit.id, completion);
    } catch (e) {
      // Revert optimistic changes on error
      setState(() {
        if (willBeFull) {
          _completedDays.remove(selectedDateTime);
        }
        if (willDropBelowFull) {
          _completedDays.add(selectedDateTime);
        }
        _ratioByDay[selectedDateTime] = (currentCount / target).clamp(0.0, 1.0);
        // Revert decreasing mode to previous state
        _decreasingModeByDateKey[dateKey] = isDecreasing;
      });
    }
  }

  void _onDayLongPressed(DateTime selectedDay, DateTime focusedDay) async {
    final selectedDateTime = selectedDay.normalized;

    // Use latest habit state from provider
    final latestHabit = ref.read(habitDetailProvider) ?? widget.habit;

    // Optimized lookup: try direct key lookup first (O(1) instead of O(n))
    final normalizedDate = selectedDateTime.normalized;
    final dateKey = normalizedDate.toIso8601DateString;
    CompletionEntry? existingEntry = latestHabit.completions[dateKey];

    // Verify the entry matches the date (in case of key collision)
    if (existingEntry != null && !existingEntry.date.normalized.isSameDayWith(normalizedDate)) {
      // Try alternative key format
      final altKey = '${normalizedDate.year}-${normalizedDate.month}-${normalizedDate.day}';
      existingEntry = latestHabit.completions[altKey];
      if (existingEntry != null && !existingEntry.date.normalized.isSameDayWith(normalizedDate)) {
        existingEntry = null;
      }
    }

    // Fallback to linear search only if direct lookup fails (should be rare)
    if (existingEntry == null) {
      for (var entry in latestHabit.completions.values) {
        if (entry.date.normalized.isSameDayWith(normalizedDate)) {
          existingEntry = entry;
          break;
        }
      }
    }

    final target = latestHabit.dailyTarget <= 0 ? 1 : latestHabit.dailyTarget;
    final currentCount = existingEntry?.count ?? 0;
    final nextCount = (currentCount - 1) < 0 ? 0 : (currentCount - 1);
    final willNoLongerBeFull = currentCount >= target && nextCount < target;

    // Optimistic UI: apply removal from completed and ratio update
    setState(() {
      if (willNoLongerBeFull) {
        _completedDays.remove(selectedDateTime);
      }
      _ratioByDay[selectedDateTime] = (nextCount / target).clamp(0.0, 1.0);
    });

    final completion = CompletionEntry(
      id: selectedDateTime.toIso8601DateString,
      date: selectedDateTime,
      // false here signals decrement by 1 (service floors at 0)
      isCompleted: false,
    );

    try {
      await ref.read(habitDetailProvider.notifier).markHabitAsComplete(latestHabit.id, completion);
    } catch (e) {
      // Revert potential optimistic change
      if (willNoLongerBeFull) {
        setState(() {
          _completedDays.add(selectedDateTime);
        });
      }
      setState(() {
        _ratioByDay[selectedDateTime] = (currentCount / target).clamp(0.0, 1.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPopupSurface(
      isSurfacePainted: true,
      child: CupertinoPageScaffold(
        navigationBar: SheetHeader(
          title: LocaleKeys.habit_detail_calendar.tr(),
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
                selectedDayPredicate: (day) => _completedDays.contains(day.normalized),
                onDaySelected: _onDaySelected,
                onDayLongPressed: _onDayLongPressed,
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) => _buildRatioCell(day, context, isOutside: false, isToday: false),
                  todayBuilder: (context, day, focusedDay) => _buildRatioCell(day, context, isOutside: false, isToday: true),
                  outsideBuilder: (context, day, focusedDay) => _buildRatioCell(day, context, isOutside: true, isToday: false),
                ),
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
                style: context.bodySmall.copyWith(
                  color: context.hintColor,
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

extension _RatioCellBuilder on _HabitCalendarCompletionSheetState {
  Widget _buildRatioCell(DateTime day, BuildContext context, {required bool isOutside, required bool isToday}) {
    final normalized = day.normalized;
    final baseColor = Color(widget.habit.colorCode);
    final ratio = _ratioByDay[normalized] ?? 0.0;

    // Map ratio to progressive alpha similar to Last 7 Days
    double alpha;
    if (ratio <= 0.0) {
      alpha = 0.0;
    } else if (ratio < 0.34) {
      alpha = 0.15;
    } else if (ratio < 0.67) {
      alpha = 0.35;
    } else if (ratio < 1.0) {
      alpha = 0.55;
    } else {
      alpha = 0.80;
    }

    final backgroundColor = alpha == 0.0 ? Colors.transparent : baseColor.withValues(alpha: alpha);

    final borderRadius = BorderRadius.circular(8);
    final textColor = isOutside ? Theme.of(context).hintColor.withValues(alpha: 0.5) : context.bodyMedium.color;

    final todayOutline = isToday ? baseColor.withValues(alpha: 0.6) : Colors.transparent;

    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: Border.all(color: todayOutline, width: isToday ? 1.5 : 0),
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
