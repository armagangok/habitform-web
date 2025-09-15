import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitrise/features/habit_detail/widget/habit_calendar_widget.dart';

import '/core/core.dart';
import '/features/purchase/providers/purchase_provider.dart';
import '/models/models.dart';
import '../../purchase/page/paywall_page.dart';

class HabitHeatmapCard extends ConsumerWidget {
  final Habit habit;

  const HabitHeatmapCard({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseState = ref.watch(purchaseProvider);
    final bool isProUser = purchaseState.value?.isSubscriptionActive ?? false;
    // Safety check to prevent rendering issues
    if (habit.completions.isEmpty) {
      return CupertinoListSection.insetGrouped(
        header: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FontAwesomeIcons.calendarDays,
              size: 20,
              color: Color(habit.colorCode),
            ),
            const SizedBox(width: 8),
            Text(
              LocaleKeys.habit_detail_heatmap_title.tr(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.titleLarge.color,
              ),
            ),
          ],
        ),
        children: [
          CupertinoListTile(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            title: Center(
              child: Text(
                LocaleKeys.habit_detail_heatmap_no_data.tr(),
                style: TextStyle(
                  color: context.bodyMedium.color?.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    return CupertinoListSection.insetGrouped(
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FontAwesomeIcons.calendarDays,
                size: 20,
                color: Color(habit.colorCode),
              ),
              const SizedBox(width: 8),
              Text(
                LocaleKeys.habit_detail_heatmap_title.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.titleLarge.color,
                ),
              ),
            ],
          ),
          CustomButton(
            onPressed: () {
              if (!isProUser) {
                navigator.navigateTo(
                  path: KRoute.prePaywall,
                  data: {'isFromOnboarding': false},
                );
                return;
              }
              showCupertinoSheet(
                enableDrag: false,
                context: context,
                builder: (context) => HabitCalendarCompletionSheet(habit: habit),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(habit.colorCode).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isProUser ? LocaleKeys.habit_detail_view_full.tr() : LocaleKeys.habit_detail_unlock.tr(),
                style: TextStyle(
                  fontSize: 12,
                  color: Color(habit.colorCode),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      children: [
        CupertinoListTile(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          title: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OptimizedHeatmapGrid(habit: habit),
                  const SizedBox(height: 16),
                  _OptimizedHeatmapLegend(habit: habit),
                ],
              ),
              if (!isProUser)
                Positioned.fill(
                  child: CustomBlurWidget(
                    borderRadius: BorderRadius.circular(5),
                    blurValue: 5,
                    child: Container(
                      color: context.cupertinoTheme.scaffoldBackgroundColor.withValues(alpha: .4),
                    ),
                  ),
                ),
              if (!isProUser)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  color: Colors.transparent,
                  onPressed: () {
                    showCupertinoSheet(
                      enableDrag: false,
                      context: context,
                      builder: (context) => PaywallPage(isFromOnboarding: false),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: context.cupertinoTheme.barBackgroundColor.withValues(alpha: .95),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.lock_fill, size: 14, color: context.titleLarge.color),
                        const SizedBox(width: 6),
                        Text(LocaleKeys.habit_detail_unlock.tr(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.titleLarge.color)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Compact variant for sharing: shows only the grid and a single stats line.
class HabitHeatmapCompact extends StatelessWidget {
  final Habit habit;

  const HabitHeatmapCompact({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final stats = calculateHeatmapStatsForHabit(habit);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grid with month/day labels
        _OptimizedHeatmapGrid(habit: habit),
        const SizedBox(height: 12),
        // Only the stats text
        Text(
          LocaleKeys.habit_detail_heatmap_stats_description.tr().replaceAll('{{days}}', stats.completedDays.toString()),
          style: TextStyle(
            fontSize: 12,
            color: context.bodyMedium.color?.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _OptimizedHeatmapGrid extends StatefulWidget {
  final Habit habit;

  const _OptimizedHeatmapGrid({required this.habit});

  @override
  State<_OptimizedHeatmapGrid> createState() => _OptimizedHeatmapGridState();
}

class _OptimizedHeatmapGridState extends State<_OptimizedHeatmapGrid> {
  late final ScrollController _scrollController;
  late final ScrollController _monthLabelsScrollController;
  late final HeatmapData heatmapData;
  late List<String> visibleMonthLabels;

  // Pre-processed completion data for O(1) lookup
  late Map<String, bool> _completionMap;

  // Cache for cell widgets to avoid rebuilding
  final Map<String, Widget> _cellWidgetCache = {};

  // Track the current scroll offset to update visible month labels
  double _currentScrollOffset = 0;

  // Debounce scroll updates
  bool _isUpdatingScroll = false;

  @override
  void initState() {
    super.initState();

    // Pre-process completion data for fast lookup
    _completionMap = _buildCompletionMap();

    heatmapData = _generateHeatmapData();
    _scrollController = ScrollController();
    _monthLabelsScrollController = ScrollController();

    // Optimized scroll listener with debouncing
    _scrollController.addListener(_onScrollChanged);
    _monthLabelsScrollController.addListener(_onMonthLabelsScrollChanged);

    // Start at the current month to show the most recent data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollToCurrentMonth();
        _updateVisibleMonths();
      }
    });

    // Initialize visible month labels with all months initially
    visibleMonthLabels = List<String>.from(heatmapData.monthLabels);
  }

  @override
  void didUpdateWidget(_OptimizedHeatmapGrid oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the habit completions have changed
    if (oldWidget.habit.completions != widget.habit.completions) {
      // Rebuild completion map with new data
      _completionMap = _buildCompletionMap();

      // Clear cache to force rebuild of all cells
      _cellWidgetCache.clear();

      // Force a rebuild to reflect the changes
      setState(() {});
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _monthLabelsScrollController.dispose();
    _cellWidgetCache.clear();
    super.dispose();
  }

  // Pre-process completion data for O(1) lookup instead of O(n) search
  Map<String, bool> _buildCompletionMap() {
    final Map<String, bool> completionMap = {};
    final now = DateTime.now();
    final oneYearAgo = now.subtract(const Duration(days: 365));

    LogHelper.shared.debugPrint('DEBUG: Building completion map for habit: ${widget.habit.habitName}');
    LogHelper.shared.debugPrint('DEBUG: Total completions: ${widget.habit.completions.length}');
    LogHelper.shared.debugPrint('DEBUG: Date range: ${oneYearAgo.toString()} to ${now.toString()}');

    for (final entry in widget.habit.completions.values) {
      final entryDate = DateUtils.dateOnly(entry.date);
      final dateKey = '${entryDate.year}-${entryDate.month}-${entryDate.day}';

      LogHelper.shared.debugPrint('DEBUG: Processing entry: $dateKey, completed: ${entry.isCompleted}, date: ${entryDate.toString()}');

      if (entryDate.isAfter(oneYearAgo) && entryDate.isBefore(now.add(const Duration(days: 1)))) {
        completionMap[dateKey] = entry.isCompleted;
        LogHelper.shared.debugPrint('DEBUG: Added to map: $dateKey = ${entry.isCompleted}');
      } else {
        LogHelper.shared.debugPrint('DEBUG: Skipped entry outside range: $dateKey');
      }
    }

    LogHelper.shared.debugPrint('DEBUG: Final completion map size: ${completionMap.length}');
    LogHelper.shared.debugPrint('DEBUG: Completion map keys: ${completionMap.keys.toList()}');
    return completionMap;
  }

  // Debounced scroll handling for better performance
  void _onScrollChanged() {
    if (_isUpdatingScroll) return;

    _isUpdatingScroll = true;
    Future.delayed(const Duration(milliseconds: 16), () {
      if (mounted) {
        _updateVisibleMonths();
        // Sync month labels scroll with main grid
        _syncMonthLabelsScroll();
        _isUpdatingScroll = false;
      }
    });
  }

  void _onMonthLabelsScrollChanged() {
    if (_isUpdatingScroll) return;

    _isUpdatingScroll = true;
    Future.delayed(const Duration(milliseconds: 16), () {
      if (mounted) {
        // Sync main grid scroll with month labels
        _syncMainGridScroll();
        _isUpdatingScroll = false;
      }
    });
  }

  void _syncMonthLabelsScroll() {
    if (_monthLabelsScrollController.hasClients && _scrollController.hasClients) {
      final mainScrollOffset = _scrollController.offset;
      _monthLabelsScrollController.jumpTo(mainScrollOffset);
    }
  }

  void _syncMainGridScroll() {
    if (_scrollController.hasClients && _monthLabelsScrollController.hasClients) {
      final monthLabelsScrollOffset = _monthLabelsScrollController.offset;
      _scrollController.jumpTo(monthLabelsScrollOffset);
    }
  }

  void _scrollToCurrentMonth() {
    if (!_scrollController.hasClients) return;

    // Calculate which month index corresponds to the current month
    // Month labels are generated from oldest to newest (11 months ago to current month)
    final currentMonthIndex = 11; // Current month is always the last (12th) month in our 12-month range

    // Calculate scroll position to show the current month
    // Each month takes approximately 1/12 of the total width
    final totalWidth = _scrollController.position.maxScrollExtent + _scrollController.position.viewportDimension;
    final monthWidth = totalWidth / 12; // 12 months total
    final targetScrollPosition = monthWidth * currentMonthIndex;

    // Ensure we don't scroll beyond the maximum scroll extent
    final clampedPosition = targetScrollPosition.clamp(0.0, _scrollController.position.maxScrollExtent);

    _scrollController.jumpTo(clampedPosition);
  }

  void _updateVisibleMonths() {
    if (!_scrollController.hasClients) return;

    // Clamp offset to avoid negative values from bouncing physics
    final clampedOffset = _scrollController.offset.clamp(0.0, _scrollController.position.maxScrollExtent);
    final newScrollOffset = clampedOffset.toDouble();

    // Only update if there's a significant change
    if ((newScrollOffset - _currentScrollOffset).abs() < 10) return;

    setState(() {
      _currentScrollOffset = newScrollOffset;

      // Calculate which months are currently visible based on scroll position
      final totalWidth = _scrollController.position.maxScrollExtent + _scrollController.position.viewportDimension;
      final visibleStart = totalWidth == 0 ? 0.0 : _currentScrollOffset / totalWidth;

      // Each month is approximately 1/12 of the total width for a year
      final totalMonths = heatmapData.monthLabels.length;
      final rawStartIndex = (visibleStart * totalMonths).floor();
      final startMonthIndex = math.max(0, math.min(rawStartIndex, math.max(0, totalMonths - 1)));
      final endMonthIndex = math.min(totalMonths, startMonthIndex + 6);

      // Update visible month labels (ensure non-empty range)
      visibleMonthLabels = heatmapData.monthLabels.sublist(startMonthIndex, endMonthIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildUnifiedHeatmap(context);
  }

  Widget _buildUnifiedHeatmap(BuildContext context) {
    return Column(
      children: [
        // Month labels row
        Row(
          children: [
            const SizedBox(width: 24), // Space for day labels
            Expanded(
              child: SingleChildScrollView(
                controller: _monthLabelsScrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: heatmapData.weeks * 12.0, // Same width as the grid
                  child: Row(
                    children: visibleMonthLabels
                        .map(
                          (month) => Expanded(
                            child: Text(
                              month,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: context.bodyMedium.color?.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Heatmap grid with day labels
        _buildHeatmapGrid(context),
      ],
    );
  }

  Widget _buildHeatmapGrid(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day labels - static, no need to rebuild
        _buildDayLabels(context),
        const SizedBox(width: 4),
        // Grid with horizontal scrolling - optimized
        Expanded(
          child: SizedBox(
            height: 84, // Fixed height for the heatmap grid (7 rows * 12px)
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: _buildScrollableGrid(context),
                ),
                // Fade indicators - only rebuild when scroll changes
                _buildFadeIndicators(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayLabels(BuildContext context) {
    return Column(
      children: heatmapData.dayLabels.asMap().entries.map((entry) {
        return Container(
          height: 12,
          width: 20,
          alignment: Alignment.centerRight,
          child: entry.key.isEven
              ? Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 9,
                    color: context.bodyMedium.color?.withValues(alpha: 0.6),
                  ),
                )
              : null,
        );
      }).toList(),
    );
  }

  Widget _buildScrollableGrid(BuildContext context) {
    return SizedBox(
      // Make the width proportional to the number of weeks
      width: heatmapData.weeks * 12.0, // Each cell is 10px + 2px margin = 12px
      child: Column(
        children: List.generate(7, (dayIndex) {
          return SizedBox(
            width: heatmapData.weeks * 12.0,
            height: 12, // Each row height: 10px cell + 2px margin = 12px
            child: Row(
              children: List.generate(
                heatmapData.weeks,
                (weekIndex) => _buildCachedCell(context, weekIndex, dayIndex),
              ),
            ),
          );
        }),
      ),
    );
  }

  // Cached cell building for performance
  Widget _buildCachedCell(BuildContext context, int weekIndex, int dayIndex) {
    final cellKey = '$weekIndex-$dayIndex';

    if (_cellWidgetCache.containsKey(cellKey)) {
      return _cellWidgetCache[cellKey]!;
    }

    final cellData = _getCellDataOptimized(heatmapData, weekIndex, dayIndex);
    final cellWidget = Container(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: _getCellColor(cellData.intensity, context),
        borderRadius: BorderRadius.circular(1),
      ),
    );

    // Cache the widget
    _cellWidgetCache[cellKey] = cellWidget;
    return cellWidget;
  }

  Widget _buildFadeIndicators(BuildContext context) {
    return Stack(
      children: [
        // Left fade indicator
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: AnimatedOpacity(
            opacity: _currentScrollOffset > 20 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              width: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    context.cupertinoTheme.scaffoldBackgroundColor,
                    context.cupertinoTheme.scaffoldBackgroundColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Right fade indicator
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: AnimatedOpacity(
            opacity: _scrollController.hasClients && _scrollController.position.maxScrollExtent > 0 && _scrollController.position.maxScrollExtent - _currentScrollOffset > 20 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              width: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    context.cupertinoTheme.scaffoldBackgroundColor,
                    context.cupertinoTheme.scaffoldBackgroundColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  HeatmapData _generateHeatmapData() {
    final now = DateTime.now();
    final endDate = DateUtils.dateOnly(now);
    final startDate = endDate.subtract(const Duration(days: 365)); // Full year

    LogHelper.shared.debugPrint('DEBUG: Heatmap data generation - startDate: $startDate, endDate: $endDate');

    final weeks = 52; // Show full year (52 weeks)
    final monthLabels = <String>[];
    final dayLabels = ['', LocaleKeys.habit_detail_monday.tr(), '', LocaleKeys.habit_detail_wednesday.tr(), '', LocaleKeys.habit_detail_friday.tr(), ''];

    // Generate month labels for the full year (from oldest to newest)
    for (int i = 11; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      monthLabels.add(_getMonthAbbreviation(month.month));
    }

    LogHelper.shared.debugPrint('DEBUG: Generated month labels: $monthLabels');

    return HeatmapData(
      startDate: startDate,
      endDate: endDate,
      weeks: weeks,
      monthLabels: monthLabels,
      dayLabels: dayLabels,
    );
  }

  // Optimized cell data lookup using pre-processed map
  CellData _getCellDataOptimized(HeatmapData data, int weekIndex, int dayIndex) {
    final date = data.startDate.add(Duration(days: weekIndex * 7 + dayIndex));

    if (date.isAfter(data.endDate)) {
      return CellData(
        date: date,
        intensity: 0,
        tooltip: '',
      );
    }

    final dateKey = '${date.year}-${date.month}-${date.day}';
    final isCompleted = _completionMap[dateKey] ?? false;

    // Debug logging for first few cells to understand the mapping
    if (weekIndex < 3 && dayIndex < 3) {
      LogHelper.shared.debugPrint('DEBUG: Cell lookup - week: $weekIndex, day: $dayIndex, date: $date, key: $dateKey, completed: $isCompleted');
    }

    return CellData(
      date: date,
      intensity: isCompleted ? 1 : 0,
      tooltip: isCompleted ? LocaleKeys.habit_detail_tooltip_completed.tr().replaceAll('{{day}}', date.day.toString()).replaceAll('{{month}}', date.month.toString()).replaceAll('{{year}}', date.year.toString()) : LocaleKeys.habit_detail_tooltip_not_completed.tr().replaceAll('{{day}}', date.day.toString()).replaceAll('{{month}}', date.month.toString()).replaceAll('{{year}}', date.year.toString()),
    );
  }

  Color _getCellColor(int intensity, BuildContext context) {
    final habitColor = Color(widget.habit.colorCode);

    switch (intensity) {
      case 0:
        return context.cupertinoTheme.brightness == Brightness.dark ? CupertinoColors.systemGrey6 : CupertinoColors.systemGrey5;
      case 1:
        return habitColor;
      default:
        return habitColor;
    }
  }

  String _getMonthAbbreviation(int month) {
    final months = ['', LocaleKeys.habit_detail_jan.tr(), LocaleKeys.habit_detail_feb.tr(), LocaleKeys.habit_detail_mar.tr(), LocaleKeys.habit_detail_apr.tr(), LocaleKeys.habit_detail_may.tr(), LocaleKeys.habit_detail_jun.tr(), LocaleKeys.habit_detail_jul.tr(), LocaleKeys.habit_detail_aug.tr(), LocaleKeys.habit_detail_sep.tr(), LocaleKeys.habit_detail_oct.tr(), LocaleKeys.habit_detail_nov.tr(), LocaleKeys.habit_detail_dec.tr()];
    return months[month];
  }
}

class _OptimizedHeatmapLegend extends StatefulWidget {
  final Habit habit;

  const _OptimizedHeatmapLegend({required this.habit});

  @override
  State<_OptimizedHeatmapLegend> createState() => _OptimizedHeatmapLegendState();
}

class _OptimizedHeatmapLegendState extends State<_OptimizedHeatmapLegend> {
  late HeatmapStats _cachedStats;

  @override
  void initState() {
    super.initState();
    // Pre-calculate stats once during init for better performance
    _cachedStats = _calculateHeatmapStats();
  }

  @override
  void didUpdateWidget(_OptimizedHeatmapLegend oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the habit completions have changed
    if (oldWidget.habit.completions != widget.habit.completions) {
      // Recalculate stats with new completion data
      _cachedStats = _calculateHeatmapStats();

      // Force a rebuild to reflect the changes
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Legend - static, doesn't need rebuilds
        _buildLegend(context),
        // Stats - using cached value
        _buildStats(context),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      children: [
        Text(
          LocaleKeys.habit_detail_less.tr(),
          style: TextStyle(
            fontSize: 11,
            color: context.bodyMedium.color?.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 4),
        ...List.generate(4, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _getLegendColor(index, context),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
        const SizedBox(width: 4),
        Text(
          LocaleKeys.habit_detail_more.tr(),
          style: TextStyle(
            fontSize: 11,
            color: context.bodyMedium.color?.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context) {
    return Text(
      LocaleKeys.habit_detail_heatmap_stats_description.tr().replaceAll('{{days}}', _cachedStats.completedDays.toString()),
      style: TextStyle(
        fontSize: 11,
        color: context.bodyMedium.color?.withValues(alpha: 0.7),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Color _getLegendColor(int index, BuildContext context) {
    final habitColor = Color(widget.habit.colorCode);
    final baseColor = context.cupertinoTheme.brightness == Brightness.dark ? CupertinoColors.systemGrey6 : CupertinoColors.systemGrey5;

    switch (index) {
      case 0:
        return baseColor;
      case 1:
        return habitColor.withValues(alpha: 0.3);
      case 2:
        return habitColor.withValues(alpha: 0.6);
      case 3:
        return habitColor;
      default:
        return habitColor;
    }
  }

  HeatmapStats _calculateHeatmapStats() => calculateHeatmapStatsForHabit(widget.habit);
}

class HeatmapData {
  final DateTime startDate;
  final DateTime endDate;
  final int weeks;
  final List<String> monthLabels;
  final List<String> dayLabels;

  const HeatmapData({
    required this.startDate,
    required this.endDate,
    required this.weeks,
    required this.monthLabels,
    required this.dayLabels,
  });
}

class CellData {
  final DateTime date;
  final int intensity;
  final String tooltip;

  const CellData({
    required this.date,
    required this.intensity,
    required this.tooltip,
  });
}

class HeatmapStats {
  final int completedDays;
  final int totalDays;
  final double completionRate;

  const HeatmapStats({
    required this.completedDays,
    required this.totalDays,
    required this.completionRate,
  });
}

/// Shared stats calculator for compact and full variants
HeatmapStats calculateHeatmapStatsForHabit(Habit habit) {
  final now = DateTime.now();
  final oneYearAgo = now.subtract(const Duration(days: 365));

  int completedDays = 0;
  int totalDays = 0;

  for (final entry in habit.completions.values) {
    final entryDate = DateUtils.dateOnly(entry.date);
    if (entryDate.isAfter(oneYearAgo) && entryDate.isBefore(now.add(const Duration(days: 1)))) {
      totalDays++;
      if (entry.isCompleted) {
        completedDays++;
      }
    }
  }

  return HeatmapStats(
    completedDays: completedDays,
    totalDays: totalDays,
    completionRate: totalDays > 0 ? (completedDays / totalDays) * 100 : 0.0,
  );
}
