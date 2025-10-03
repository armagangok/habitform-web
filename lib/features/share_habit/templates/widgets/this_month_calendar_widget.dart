import '../../../../core/core.dart';
import '../../../../models/habit/habit_extension.dart';
import '../../../../models/habit/habit_model.dart';

class ThisMonthCalendarWidget extends StatelessWidget {
  final Habit habit;

  const ThisMonthCalendarWidget({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    final habitColor = Color(habit.colorCode);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: context.scaffoldBackgroundColor.withValues(alpha: 9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.cupertinoTheme.primaryColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildHeader(context, currentYear, currentMonth, habitColor),
            const SizedBox(height: 12),
            _buildCalendarGrid(context, currentYear, currentMonth, habitColor),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int year, int month, Color habitColor) {
    final date = DateTime(year, month);
    final monthName = DateFormat('MMMM yyyy', context.locale.languageCode).format(date);
    // Sum total completions (counts) in this month for multi-completion support
    final int monthlyTotalCount = habit.completions.values.where((entry) => entry.date.year == year && entry.date.month == month && entry.isCompleted).fold<int>(0, (sum, entry) => sum + entry.count);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          monthName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.primaryContrastingColor.withValues(alpha: 0.9),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: context.primaryContrastingColor.withValues(alpha: 0.125),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${LocaleKeys.share_templates_this_month.tr()} $monthlyTotalCount',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.primaryContrastingColor.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(BuildContext context, int year, int month, Color habitColor) {
    final date = DateTime(year, month);
    final daysInMonth = DateUtils.getDaysInMonth(date.year, date.month);
    final firstDayOfMonth = DateTime(year, month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday, 6 = Saturday

    // Get completion data for this month (dates only for ratio calculation)
    final completions = habit.getCompletionsForMonth(year, month);
    final firstCompletionDate = habit.getFirstCompletionDate();

    // Create a map of completion ratios for each date
    final Map<DateTime, double> completionRatios = {};
    for (final date in completions) {
      final normalizedDate = DateUtils.dateOnly(date);
      final ratio = habit.getCompletionRatioForDate(normalizedDate);
      completionRatios[normalizedDate] = ratio;
    }

    return Column(
      children: [
        // Week day headers
        Row(
          children: [
            LocaleKeys.habit_detail_sun.tr().toUpperCase(),
            LocaleKeys.habit_detail_mon.tr().toUpperCase(),
            LocaleKeys.habit_detail_tue.tr().toUpperCase(),
            LocaleKeys.habit_detail_wed.tr().toUpperCase(),
            LocaleKeys.habit_detail_thu.tr().toUpperCase(),
            LocaleKeys.habit_detail_friday.tr().toUpperCase(),
            LocaleKeys.habit_detail_sat.tr().toUpperCase(),
          ]
              .map((day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: context.primaryContrastingColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 6),
        // Calendar grid
        ...List.generate(
          6,
          (weekIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: List.generate(
                  7,
                  (dayIndex) {
                    final dayNumber = (weekIndex * 7) + dayIndex - firstWeekday + 1;

                    if (dayNumber < 1 || dayNumber > daysInMonth) {
                      return const Expanded(child: SizedBox(height: 32));
                    }

                    final currentDate = DateTime(year, month, dayNumber);
                    final isInFuture = currentDate.isAfter(DateTime.now());
                    final isToday = DateUtils.isSameDay(currentDate, DateTime.now());
                    final completionRatio = completionRatios[currentDate] ?? 0.0;

                    // Determine cell style based on completion status and date
                    Widget cellContent;

                    final isBeforeFirstCompletion = firstCompletionDate != null && currentDate.isBefore(DateUtils.dateOnly(firstCompletionDate));

                    if (isToday) {
                      // Today: show bright border and today calendar icon, with progressive background
                      final alpha = (0.1 + (0.9 * completionRatio)).clamp(0.4, 1.0);
                      final isFullyCompleted = completionRatio >= 1.0;

                      cellContent = Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: habitColor.withValues(alpha: alpha),
                          shape: BoxShape.circle,
                          border: Border.all(color: habitColor.withValues(alpha: 0.95), width: 2),
                        ),
                        child: Center(
                          child: Icon(
                            CupertinoIcons.calendar_today,
                            size: 18,
                            color: isFullyCompleted ? Colors.white : habitColor.colorRegardingToBrightness,
                          ),
                        ),
                      );
                    } else if (isBeforeFirstCompletion || isInFuture) {
                      // Grey out days before first completion and future days
                      cellContent = Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            dayNumber.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.primaryContrastingColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      );
                    } else {
                      // Progressive alpha based on completion ratio (match last 7 days behavior)
                      final alpha = (0.1 + (0.9 * completionRatio)).clamp(0.4, 1.0);
                      final isFullyCompleted = completionRatio >= 1.0;

                      cellContent = Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: habitColor.withValues(alpha: alpha),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            dayNumber.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isFullyCompleted ? FontWeight.w700 : FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }

                    return Expanded(
                      child: Center(
                        child: cellContent,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
