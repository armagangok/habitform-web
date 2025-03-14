import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitrise/models/completion_entry/completion_extension.dart';

import '/core/core.dart';
import '/models/models.dart';
import 'habit_calendar_widget.dart';

class HabitDataWidget extends ConsumerStatefulWidget {
  final Habit habit;

  const HabitDataWidget({
    super.key,
    required this.habit,
  });

  @override
  ConsumerState<HabitDataWidget> createState() => _HabitDataWidgetState();
}

class _HabitDataWidgetState extends ConsumerState<HabitDataWidget> {
  late PageController _pageController;
  late int selectedYear;
  late int initialPage;

  late final int currentYear;
  late final int currentMonth;
  late final int currentDay;

  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    currentYear = now.year;
    currentMonth = now.month;
    currentDay = now.day;

    selectedYear = now.year;
    initialPage = ((now.year - 2020) * 4) + (now.month - 1) ~/ 3;
    _pageController = PageController(
      initialPage: initialPage,
      viewportFraction: 1.0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _isDisposed = true;
    super.dispose();
  }

  void _onPageChanged(int page) {
    if (_isDisposed) return;

    final maxPage = ((currentYear - 2020) * 4) + (currentMonth - 1) ~/ 3;

    if (page > maxPage) {
      _pageController.jumpToPage(maxPage);
      return;
    }

    setState(() {
      selectedYear = 2020 + ((page * 3 + (currentMonth - 1) ~/ 3 * 3) ~/ 12);
    });
  }

  Map<String, int> _calculateMonthlyStats(int year, int month) {
    final completionsForMonth = widget.habit.completions.getCompletionsForMonth(year, month + 1);

    return {
      'total': completionsForMonth.length,
      'weekdays': completionsForMonth.where((date) => date.weekday <= 5).length,
      'weekends': completionsForMonth.where((date) => date.weekday > 5).length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onPressed: () {
        showCupertinoModalBottomSheet(
          enableDrag: false,
          context: context,
          builder: (context) => HabitCalendarCompletionSheet(habit: widget.habit),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 10),
              LayoutBuilder(builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final monthWidth = (screenWidth - 16) / 3;
                final gridSquareSize = (monthWidth - 8) / 6;
                final gridHeight = (gridSquareSize * 7) + 40;

                return SizedBox(
                  height: gridHeight,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    physics: ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final quarterStartMonth = ((index * 3) + (currentMonth - 1) ~/ 3 * 3) % 12;
                      final year = 2020 + ((index * 3 + (currentMonth - 1) ~/ 3 * 3) ~/ 12);
                      return _buildQuarterView(
                        color: Color(widget.habit.colorCode),
                        startMonth: quarterStartMonth,
                        year: year,
                        gridSquareSize: gridSquareSize,
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final maxPage = ((currentYear - 2020) * 4) + (currentMonth - 1) ~/ 3;
    final currentPage = _pageController.hasClients ? _pageController.page?.round() ?? 0 : initialPage;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          minSize: 0,
          onPressed: () {
            _pageController.previousPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeIn,
            );
          },
          child: Icon(CupertinoIcons.chevron_left),
        ),
        Text(
          selectedYear.toString(),
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: context.theme.primaryColor,
          ),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          minSize: 0,
          onPressed: currentPage >= maxPage
              ? null
              : () {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                },
          child: Icon(
            CupertinoIcons.chevron_right,
            color: currentPage >= maxPage ? context.theme.disabledColor : null,
          ),
        ),
      ],
    );
  }

  Widget _buildQuarterView({
    required Color color,
    required int startMonth,
    required int year,
    required double gridSquareSize,
  }) {
    return Row(
      children: List.generate(3, (index) {
        final month = (startMonth + index) % 12;
        final isCurrentMonth = year == currentYear && month == currentMonth - 1;
        final monthStats = _calculateMonthlyStats(year, month);

        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: _buildCompactMonthCard(
              color: color,
              monthIndex: month,
              year: year,
              isCurrentMonth: isCurrentMonth,
              stats: monthStats,
              gridSquareSize: gridSquareSize,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCompactMonthCard({
    required Color color,
    required int monthIndex,
    required int year,
    required bool isCurrentMonth,
    required Map<String, int> stats,
    required double gridSquareSize,
  }) {
    final isFutureMonth = year > currentYear || (year == currentYear && monthIndex + 1 > currentMonth);
    final opacity = isFutureMonth ? 0.5 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _getLocalizedMonth(monthIndex),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isCurrentMonth ? color : context.theme.primaryColor,
                ),
              ),
            ),
            Expanded(
              child: _buildCompactMonthGrid(
                color: color,
                monthIndex: monthIndex,
                context: context,
                year: year,
                gridSquareSize: gridSquareSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactMonthGrid({
    required Color color,
    required int monthIndex,
    required BuildContext context,
    required int year,
    required double gridSquareSize,
  }) {
    final date = DateTime(year, monthIndex + 1);
    final daysInMonth = DateUtils.getDaysInMonth(date.year, date.month);
    final firstDayOfMonth = DateTime(year, monthIndex + 1, 1);
    final firstWeekday = firstDayOfMonth.weekday - 1; // 0 = Monday, 6 = Sunday

    // Her ay için sabit 6 sütun kullanıyoruz
    const numberOfWeeks = 6;

    // Get all completion dates for this month
    final completions = widget.habit.completions.getCompletionsForMonth(year, monthIndex + 1);
    completions.sort((a, b) => a.compareTo(b));

    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(4),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: numberOfWeeks,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemCount: 7 * numberOfWeeks,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final weekday = index ~/ numberOfWeeks;
        final week = index % numberOfWeeks;

        final dayNumber = week * 7 + weekday + 1 - firstWeekday;

        final isDayInMonth = dayNumber > 0 && dayNumber <= daysInMonth;
        if (!isDayInMonth) return SizedBox.shrink();

        final currentDate = DateTime(year, monthIndex + 1, dayNumber);
        final isToday = currentDate.isToday;
        final isInFuture = currentDate.isAfter(DateTime.now());

        bool isCompleted = false;
        bool isBetweenCompletions = false;

        if (!isInFuture) {
          isCompleted = completions.any((date) => date.isSameDayWith(currentDate));

          if (!isCompleted && completions.length >= 2) {
            for (int i = 0; i < completions.length - 1; i++) {
              final startDate = completions[i];
              final endDate = completions[i + 1];
              if (currentDate.isBetween(startDate, endDate)) {
                isBetweenCompletions = true;
                break;
              }
            }
          }
        }

        Color getCardColor({
          required bool isCompleted,
          required bool isBetweenCompletions,
          required Color baseColor,
        }) {
          if (isCompleted) return baseColor;
          if (isBetweenCompletions) return baseColor.withValues(alpha: 0.25);
          return context.theme.disabledColor.withValues(alpha: 0.25);
        }

        final cardColor = getCardColor(
          isCompleted: isCompleted,
          isBetweenCompletions: isBetweenCompletions,
          baseColor: color,
        );

        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(4),
            border: isToday ? Border.all(color: color, width: 1.25) : null,
          ),
          child: Center(
            child: Text(
              "",
              style: TextStyle(
                fontSize: 12,
                color: isToday ? color : context.theme.primaryColor,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  String _getLocalizedMonth(int monthIndex) {
    final date = DateTime(2024, monthIndex + 1);
    return DateFormat.MMM(context.locale.languageCode).format(date);
  }
}
