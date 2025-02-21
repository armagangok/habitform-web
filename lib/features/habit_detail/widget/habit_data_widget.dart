import '/core/core.dart';
import '/models/habit/habit_model.dart';

class HabitDataWidget extends StatefulWidget {
  final Habit habit;

  const HabitDataWidget({
    super.key,
    required this.habit,
  });

  @override
  State<HabitDataWidget> createState() => _HabitDataWidgetState();
}

class _HabitDataWidgetState extends State<HabitDataWidget> with SingleTickerProviderStateMixin {
  final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  late int selectedYear;

  final int currentYear = DateTime.now().year;
  final int currentMonth = DateTime.now().month;
  final int currentDay = DateTime.now().day;

  bool _isDisposed = false;

  final bool _isAnimating = false;

  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    selectedYear = currentYear;
  }

  @override
  void didUpdateWidget(HabitDataWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.habit != widget.habit) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    controller.dispose();
    _isDisposed = true;

    super.dispose();
  }

  void _onYearChanged(bool isNext) {
    final firstCompletionDate = widget.habit.completionDates?.reduce((a, b) => a.isBefore(b) ? a : b);
    final minYear = firstCompletionDate?.year ?? currentYear;

    bool canChange = isNext ? selectedYear < currentYear : selectedYear > minYear;
    if (!canChange || _isAnimating) return;

    if (!_isDisposed) {
      setState(() {
        if (isNext) {
          selectedYear++;
        } else {
          selectedYear--;
        }
      });

      controller.forward(from: 0);
    }
  }

  int _calculateStreak() {
    if (widget.habit.completionDates == null || widget.habit.completionDates!.isEmpty) return 0;

    final sortedDates = widget.habit.completionDates!.toList()..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime? lastDate;

    for (var date in sortedDates) {
      if (lastDate == null) {
        lastDate = date;
        streak = 1;
        continue;
      }

      if (lastDate.difference(date).inDays == 1) {
        streak++;
        lastDate = date;
      } else {
        break;
      }
    }

    return streak;
  }

  int _calculateLongestStreak() {
    if (widget.habit.completionDates == null || widget.habit.completionDates!.isEmpty) return 0;

    final sortedDates = widget.habit.completionDates!.toList()..sort((a, b) => a.compareTo(b));

    int currentStreak = 1;
    int longestStreak = 1;
    DateTime lastDate = sortedDates.first;

    for (int i = 1; i < sortedDates.length; i++) {
      if (sortedDates[i].difference(lastDate).inDays == 1) {
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        currentStreak = 1;
      }
      lastDate = sortedDates[i];
    }

    return longestStreak;
  }

  void _showYearPicker() {
    final firstCompletionDate = widget.habit.completionDates?.reduce((a, b) => a.isBefore(b) ? a : b);
    final minYear = firstCompletionDate?.year ?? currentYear;

    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(LocaleKeys.habit_data_select_year.tr()),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: currentYear - minYear + 1,
                  itemBuilder: (context, index) {
                    final year = currentYear - index;
                    final isSelected = year == selectedYear;

                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        if (year != selectedYear) {
                          setState(() {
                            selectedYear = year;
                          });
                        }
                      },
                      child: Container(
                        height: 44,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            year.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: _buildHabitSection(
        habitId: widget.habit.id,
        title: '${widget.habit.habitName} ${widget.habit.emoji ?? ''}',
        subtitle: widget.habit.habitDescription ?? '',
        color: Color(widget.habit.colorCode),
        year: selectedYear,
        longestStreak: _calculateLongestStreak(),
        currentStreak: _calculateStreak(),
        onYearChanged: _onYearChanged,
      ),
    );
  }

  Widget _buildMonthsRow(Color color, double cellSize) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_getVisibleMonths().length, (monthIndex) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          months[monthIndex],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      _buildMonthGrid(color, months[monthIndex], cellSize, context),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHabitSection({
    required String habitId,
    required String title,
    required String subtitle,
    required Color color,
    required int year,
    required int longestStreak,
    required int currentStreak,
    required Function(bool) onYearChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 10.0,
            left: 10.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minSize: 0,
                onPressed: () => onYearChanged(false),
                child: Icon(
                  CupertinoIcons.chevron_left,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 0,
                onPressed: _showYearPicker,
                child: Text(
                  year.toString(),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minSize: 0,
                onPressed: () => onYearChanged(true),
                child: Icon(
                  CupertinoIcons.chevron_right,
                ),
              ),  
            ],
          ),
        ),
        const SizedBox(height: 10),
        _buildMonthsRow(color, 18).animate(controller: controller).fadeIn(duration: 350.ms),
        const SizedBox(height: 12),
        Wrap(
          runAlignment: WrapAlignment.start,
          spacing: 8,
          runSpacing: 8,
          children: [
            if (longestStreak > 0) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '${LocaleKeys.habit_data_longest_streak.tr()}: $longestStreak',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        ' ⭐️',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (currentStreak > 0) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '${LocaleKeys.habit_data_current_streak.tr()}: $currentStreak',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        ' 🏆',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMonthGrid(Color color, String month, double cellSize, BuildContext context) {
    final monthIndex = months.indexOf(month);
    final date = DateTime(selectedYear, monthIndex + 1);
    final daysInMonth = DateUtils.getDaysInMonth(date.year, date.month);
    final firstWeekday = DateUtils.firstDayOffset(
      date.year,
      date.month,
      MaterialLocalizations.of(context),
    );

    final numberOfWeeks = ((daysInMonth + firstWeekday) / 7).ceil();

    return SizedBox(
      width: cellSize * numberOfWeeks,
      height: cellSize * 7,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(numberOfWeeks, (weekIndex) {
          return SizedBox(
            width: cellSize,
            child: Column(
              children: List.generate(7, (dayInWeek) {
                final dayNumber = (weekIndex * 7) + dayInWeek - firstWeekday + 1;
                final isDayInMonth = dayNumber > 0 && dayNumber <= daysInMonth;
                final currentDate = DateTime(selectedYear, monthIndex + 1, dayNumber);

                final isToday = currentDate.isToday;

                final isInFuture = selectedYear == currentYear && (monthIndex > currentMonth - 1 || (monthIndex == currentMonth - 1 && dayNumber > currentDay));

                bool isCompleted = false;
                if (isDayInMonth && !isInFuture) {
                  isCompleted = widget.habit.completionDates?.any((date) => date.year == currentDate.year && date.month == currentDate.month && date.day == currentDate.day) ?? false;
                }

                return SizedBox(
                  height: cellSize,
                  child: Container(
                    margin: const EdgeInsets.all(1.25),
                    decoration: BoxDecoration(
                      color: isDayInMonth ? (isInFuture ? Colors.transparent : (isCompleted ? color : context.theme.dividerColor.withValues(alpha: .25))) : Colors.transparent,
                      borderRadius: BorderRadius.circular(5),
                      border: isInFuture
                          ? Border.all(color: context.theme.dividerColor.withValues(alpha: .25))
                          : isDayInMonth
                              ? Border.all(color: context.theme.dividerColor.withValues(alpha: .35))
                              : null,
                    ),
                    child: isToday
                        ? Center(
                            child: Icon(
                              CupertinoIcons.calendar_today,
                              size: 13,
                              color: color.colorRegardingToBrightness,
                            ),
                          )
                        : Center(),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  List<int> _getVisibleMonths() {
    if (selectedYear < currentYear) {
      // Önceki yıllar için tüm ayları göster
      return List.generate(12, (index) => index);
    }
    // Mevcut yıl için sadece şu ana kadar olan ayları göster
    return List.generate(currentMonth, (index) => index);
  }
}
