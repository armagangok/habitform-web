import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/models/habit/habit_difficulty.dart';
import '/models/habit/habit_extension.dart';
import '/models/habit/habit_model.dart';
import '../../../../features/home/provider/home_provider.dart';
import '../../provider/habit_probability_provider.dart';
import '../../provider/selected_habit_index_provider.dart';

class FormationInsightsWidget extends ConsumerStatefulWidget {
  const FormationInsightsWidget({super.key});

  @override
  ConsumerState<FormationInsightsWidget> createState() => _FormationInsightsWidgetState();
}

class _FormationInsightsWidgetState extends ConsumerState<FormationInsightsWidget> {
  int _selectedYear = DateTime.now().year;

  // Cache for historical probability data to avoid recalculating when switching habits
  final Map<String, Map<DateTime, double>> _historicalDataCache = {};

  // Alışkanlık oturma durumunu hesapla - difficulty-aware
  String _getHabitProbabilityStatus(double completionRate, int completedDays, HabitDifficulty difficulty, double probabilityScore) {
    if (completedDays < 10) {
      return LocaleKeys.statistics_probability_status_early.tr();
    }

    // Use formation probability instead of raw completion rate for consistency
    final percentage = probabilityScore.toStringAsFixed(0);

    if (probabilityScore >= 90) {
      return LocaleKeys.statistics_probability_status_excellent.tr(namedArgs: {
        'percentage': percentage,
      });
    } else if (probabilityScore >= 75) {
      return LocaleKeys.statistics_probability_status_very_good.tr(namedArgs: {
        'percentage': percentage,
      });
    } else if (probabilityScore >= 60) {
      return LocaleKeys.statistics_probability_status_good.tr(namedArgs: {
        'percentage': percentage,
      });
    } else if (probabilityScore >= 40) {
      return LocaleKeys.statistics_probability_status_improving.tr(namedArgs: {
        'percentage': percentage,
      });
    } else {
      return LocaleKeys.statistics_probability_status_needs_work.tr(namedArgs: {
        'percentage': percentage,
      });
    }
  }

  // Tahmini alışkanlık oturma süresini hesapla - difficulty-aware
  String _getEstimatedFormationTime(double completionRate, int completedDays, DateTime startDate, HabitDifficulty difficulty, int remainingFormationDays, int estimatedFormationDays) {
    if (completedDays < 5) {
      return LocaleKeys.statistics_probability_time_not_enough_data.tr();
    }

    final minimumCompletionRate = difficulty.minimumCompletionRate * 100;

    if (remainingFormationDays == 0) {
      if (completionRate >= minimumCompletionRate + 15) {
        return LocaleKeys.statistics_probability_time_completed_successful.tr();
      } else if (completionRate >= minimumCompletionRate) {
        return LocaleKeys.statistics_probability_time_completed_good.tr(namedArgs: {'percentage': completionRate.toStringAsFixed(0)});
      } else {
        return LocaleKeys.statistics_probability_time_completed_needs_work.tr();
      }
    } else {
      return LocaleKeys.statistics_probability_time_remaining_days.tr(namedArgs: {
        'days': remainingFormationDays.toString(),
        'total': estimatedFormationDays.toString(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(probabilityProvider);
    final selectedHabitIndex = ref.watch(selectedHabitIndexProvider);

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('${LocaleKeys.errors_something_went_wrong.tr()}: $error')),
      data: (data) {
        // Veri kontrolü
        if (data.totalCompletedDays == 0) {
          return CupertinoListSection.insetGrouped(
            backgroundColor: Colors.transparent,
            header: Text(LocaleKeys.statistics_habit_formation.tr()),
            children: [
              CupertinoListTile(
                backgroundColor: Colors.transparent,
                padding: const EdgeInsets.all(16),
                title: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.insights,
                        size: 48,
                        color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        LocaleKeys.statistics_no_data_for_habit.tr(),
                        style: context.bodyMedium.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        LocaleKeys.statistics_start_tracking_habit.tr(),
                        style: context.bodySmall.copyWith(
                          color: Theme.of(context).hintColor.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        // Seçili alışkanlığa göre filtreleme yap

        // Alışkanlık oturma durumu ve tahmini süre
        String habitFormationStatus = '';
        String estimatedFormationTime = '';

        // Check if we have a valid selected habit index
        if (selectedHabitIndex >= 0 && selectedHabitIndex < data.habitStatistics.values.length) {
          final selectedHabit = data.habitStatistics.values.elementAt(selectedHabitIndex);
          final HabitDifficulty selectedDifficulty = selectedHabit.difficulty ?? HabitDifficulty.moderate;
          habitFormationStatus = _getHabitProbabilityStatus(
            selectedHabit.progressPercentage,
            selectedHabit.completedDays,
            selectedDifficulty,
            selectedHabit.probabilityScore,
          );
          estimatedFormationTime = _getEstimatedFormationTime(
            selectedHabit.progressPercentage,
            selectedHabit.completedDays,
            selectedHabit.startDate,
            selectedDifficulty,
            selectedHabit.remainingProbabilityDays,
            selectedHabit.estimatedProbabilityDays,
          );
        } else {
          // No valid habit selected, return empty widget
          return const SizedBox.shrink();
        }

        // Get the actual habit to calculate historical data
        final habitId = data.habitStatistics.values.elementAt(selectedHabitIndex).habitId;
        final habits = ref.watch(homeProvider).maybeWhen(
              data: (homeState) => homeState.habits,
              orElse: () => <Habit>[],
            );
        final selectedHabit = habits.firstWhere(
          (h) => h.id == habitId,
          orElse: () => throw StateError('Habit not found'),
        );

        return Column(
          children: [
            // Score Section - Formation Probability Chart
            _buildScoreSection(
              context,
              data.habitStatistics.values.elementAt(selectedHabitIndex).progressPercentage,
              data.habitStatistics.values.elementAt(selectedHabitIndex).difficulty ?? HabitDifficulty.moderate,
              data.habitStatistics.values.elementAt(selectedHabitIndex).probabilityScore,
            ),

            const SizedBox(height: 20),

            // Historical Probability Line Chart (Last Year)
            _buildHistoricalProbabilityChart(context, selectedHabit),

            const SizedBox(height: 20),

            // Percentage Legend Section
            _buildPercentageLegendSection(
              context,
              data.habitStatistics.values.elementAt(selectedHabitIndex).probabilityScore,
            ),

            const SizedBox(height: 20),

            // About Habit Probability Section
            _buildAboutFormationSection(
              context,
              habitFormationStatus,
              estimatedFormationTime,
            ),
          ],
        );
      },
    );
  }

  // Score Section - Formation Probability Chart
  Widget _buildScoreSection(BuildContext context, double progressPercentage, HabitDifficulty difficulty, double probabilityScore) {
    return CupertinoListSection.insetGrouped(
      backgroundColor: Colors.transparent,
      header: Text(LocaleKeys.statistics_probability_score.tr()),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildHabitProbabilityChart(context, progressPercentage, difficulty, probabilityScore),
        ),
      ],
    );
  }

  // Percentage Legend Section
  Widget _buildPercentageLegendSection(BuildContext context, double probabilityScore) {
    return CupertinoListSection.insetGrouped(
      backgroundColor: Colors.transparent,
      header: Text(LocaleKeys.statistics_score_breakdown.tr()),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildPercentageLegend(context, probabilityScore),
        ),
      ],
    );
  }

  // About Habit Probability Section with separate subsections
  Widget _buildAboutFormationSection(BuildContext context, String habitFormationStatus, String estimatedFormationTime) {
    return CupertinoListSection.insetGrouped(
      backgroundColor: Colors.transparent,
      header: Text(LocaleKeys.statistics_about_formation.tr()),
      children: [
        // Good Progress Subsection
        CupertinoListTile(
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.all(16),
          title: Text(
            LocaleKeys.statistics_progress_status.tr(),
            style: context.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              habitFormationStatus,
              style: context.bodyMedium,
              maxLines: 999,
            ),
          ),
        ),

        // Estimated Time Subsection
        CupertinoListTile(
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.all(16),
          title: Text(
            LocaleKeys.statistics_estimated_probability_time.tr(),
            style: context.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              estimatedFormationTime,
              style: context.bodyMedium,
              maxLines: 999,
            ),
          ),
        ),

        // Info Subsection
        CupertinoListTile(
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.all(16),
          title: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: context.hintColor,
              ),
              const SizedBox(width: 8),
              Text(
                LocaleKeys.statistics_about_formation_title.tr(),
                style: context.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              LocaleKeys.statistics_formation_info.tr(),
              style: context.bodySmall.copyWith(
                color: context.bodySmall.color?.withValues(alpha: .75),
              ),
              maxLines: 999,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHabitProbabilityChart(BuildContext context, double progressPercentage, HabitDifficulty difficulty, double probabilityScore) {
    // Formation probability-based color determination
    Color progressColor;
    List<Color> progressGradient;

    if (probabilityScore >= 90) {
      progressColor = const Color(0xFF4CAF50); // Green - Excellent formation probability
      progressGradient = [
        const Color(0xFF66BB6A),
        const Color(0xFF43A047),
      ];
    } else if (probabilityScore >= 75) {
      progressColor = const Color(0xFF8BC34A); // Light Green - Very good formation probability
      progressGradient = [
        const Color(0xFF9CCC65),
        const Color(0xFF7CB342),
      ];
    } else if (probabilityScore >= 60) {
      progressColor = const Color(0xFFFFC107); // Amber - Good formation probability
      progressGradient = [
        const Color(0xFFFFD54F),
        const Color(0xFFFFB300),
      ];
    } else {
      progressColor = const Color(0xFFF44336); // Red - Needs improvement
      progressGradient = [
        const Color(0xFFEF5350),
        const Color(0xFFE53935),
      ];
    }

    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 60,
              sections: [
                PieChartSectionData(
                  color: progressColor,
                  value: probabilityScore,
                  title: '',
                  radius: 25,
                  titleStyle: const TextStyle(
                    fontSize: 0,
                  ),
                  badgeWidget: null,
                  badgePositionPercentageOffset: 0,
                  borderSide: BorderSide.none,
                  gradient: LinearGradient(
                    colors: progressGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.grey.shade200,
                  value: 100 - probabilityScore,
                  title: '',
                  radius: 20,
                  titleStyle: const TextStyle(
                    fontSize: 0,
                  ),
                  badgeWidget: null,
                  badgePositionPercentageOffset: 0,
                  borderSide: BorderSide.none,
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey.shade300,
                      Colors.grey.shade200,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ],
              pieTouchData: PieTouchData(
                enabled: false,
              ),
              borderData: FlBorderData(
                show: false,
              ),
            ),
            swapAnimationDuration: const Duration(milliseconds: 800),
            swapAnimationCurve: Curves.easeInOutQuart,
          ),
          // Percentage text in the center
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    '${probabilityScore.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: progressColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Separate percentage legend method
  Widget _buildPercentageLegend(BuildContext context, double probabilityScore) {
    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        child: Row(
          children: [
            Expanded(
              child: _buildLegendItem(
                context,
                const Color(0xFFF44336),
                LocaleKeys.statistics_legend_less_60.tr(),
                LocaleKeys.statistics_legend_needs_work.tr(),
                isSelected: probabilityScore < 60,
              ),
            ),
            _verticalDivider(),
            Expanded(
              child: _buildLegendItem(
                context,
                const Color(0xFFFFC107),
                LocaleKeys.statistics_legend_60_75.tr(),
                LocaleKeys.statistics_legend_good.tr(),
                isSelected: probabilityScore >= 60 && probabilityScore < 75,
              ),
            ),
            _verticalDivider(),
            Expanded(
              child: _buildLegendItem(
                context,
                const Color(0xFF8BC34A),
                LocaleKeys.statistics_legend_75_90.tr(),
                LocaleKeys.statistics_legend_very_good.tr(),
                isSelected: probabilityScore >= 75 && probabilityScore < 90,
              ),
            ),
            _verticalDivider(),
            Expanded(
              child: _buildLegendItem(
                context,
                const Color(0xFF4CAF50),
                LocaleKeys.statistics_legend_greater_90.tr(),
                LocaleKeys.statistics_legend_excellent.tr(),
                isSelected: probabilityScore >= 90,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding _verticalDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.5),
      child: VerticalDivider(
        thickness: .75,
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label, String description, {bool isSelected = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Daire ve etiket satırı
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Sabit boyutlu daire
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 4),
            // Etiket için Flexible kullanarak metni küçültme
            Flexible(
              child: Text(
                label,
                style: context.bodySmall.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // Açıklama metni için Flexible kullanarak metni küçültme
        Flexible(
          child: Text(
            description,
            style: context.bodySmall.copyWith(
              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).hintColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  // Historical Probability Line Chart Section
  Widget _buildHistoricalProbabilityChart(BuildContext context, Habit habit) {
    // Use cache key: habitId_year
    final cacheKey = '${habit.id}_$_selectedYear';

    // Check cache first
    Map<DateTime, double> historicalData;
    if (_historicalDataCache.containsKey(cacheKey)) {
      historicalData = _historicalDataCache[cacheKey]!;
    } else {
      // Calculate and cache
      final calculationStart = DateTime.now();
      historicalData = habit.calculateHistoricalProbabilityForYear(_selectedYear);
      final calculationEnd = DateTime.now();
      LogHelper.shared.debugPrint("📊 [PERF] Historical probability calculated in ${calculationEnd.difference(calculationStart).inMilliseconds}ms for habit ${habit.habitName} year $_selectedYear");

      _historicalDataCache[cacheKey] = historicalData;

      // Limit cache size to prevent memory issues (keep last 10 calculations)
      if (_historicalDataCache.length > 10) {
        final oldestKey = _historicalDataCache.keys.first;
        _historicalDataCache.remove(oldestKey);
      }
    }
    final today = DateTime.now();
    final isCurrentYear = _selectedYear == today.year;
    final currentMonth = today.month;
    final currentDay = today.day;
    final daysInCurrentMonth = DateTime(today.year, today.month + 1, 0).day;
    // Current month is complete if we're on the last day of the month
    final isCurrentMonthComplete = isCurrentYear && currentDay == daysInCurrentMonth;

    // Create all 12 months for the selected year
    final List<MapEntry<DateTime, double?>> allMonths = [];
    for (int month = 1; month <= 12; month++) {
      final monthDate = DateTime(_selectedYear, month, 1);

      // Skip future months if current year
      if (isCurrentYear && monthDate.isAfter(today)) {
        continue;
      }

      // Get probability for this month if available
      final probability = historicalData[monthDate];
      allMonths.add(MapEntry(monthDate, probability));
    }

    if (allMonths.isEmpty) {
      return const SizedBox.shrink();
    }

    // Prepare data for fl_chart - always 12 months
    final List<FlSpot> spots = [];
    final List<FlSpot> dashedSpots = [];

    int currentMonthIndex = -1;
    for (int i = 0; i < allMonths.length; i++) {
      final entry = allMonths[i];
      final probability = entry.value ?? 0.0;
      final spot = FlSpot(i.toDouble(), probability);
      spots.add(spot);

      // Track current month index
      if (isCurrentYear && entry.key.month == currentMonth) {
        currentMonthIndex = i;
      }
    }

    // If current month is complete, add dashed line to next month (or end of chart if no next month)
    if (isCurrentMonthComplete && currentMonthIndex >= 0) {
      final currentProbability = allMonths[currentMonthIndex].value ?? 0.0;
      if (currentMonthIndex < allMonths.length - 1) {
        // There's a next month in the data
        final nextMonthEntry = allMonths[currentMonthIndex + 1];
        final nextMonthProbability = nextMonthEntry.value ?? currentProbability;
        // Add dashed line from current month to next month
        dashedSpots.add(FlSpot(currentMonthIndex.toDouble(), currentProbability));
        dashedSpots.add(FlSpot((currentMonthIndex + 1).toDouble(), nextMonthProbability));
      } else {
        // No next month, extend dashed line to the end of chart
        final nextMonthIndex = currentMonthIndex + 1;
        dashedSpots.add(FlSpot(currentMonthIndex.toDouble(), currentProbability));
        dashedSpots.add(FlSpot(nextMonthIndex.toDouble(), currentProbability));
      }
    }

    if (spots.length < 2) {
      return const SizedBox.shrink();
    }

    // Get color based on current probability
    final currentProbability = habit.calculateHabitProbability();
    final chartColor = _getProbabilityColor(currentProbability);

    // Get available years (from first completion to current year)
    final firstCompletionDate = habit.getFirstCompletionDate();
    final availableYears = <int>[];
    if (firstCompletionDate != null) {
      final startYear = firstCompletionDate.year;
      final endYear = today.year;
      for (int year = startYear; year <= endYear; year++) {
        availableYears.add(year);
      }
    } else {
      availableYears.add(today.year);
    }

    return CupertinoListSection.insetGrouped(
      backgroundColor: Colors.transparent,
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Probability Over Time'),
          // Year selector
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _showYearPicker(context, availableYears),
            minimumSize: Size(0, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_selectedYear',
                  style: context.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  CupertinoIcons.chevron_down,
                  size: 16,
                  color: context.hintColor,
                ),
              ],
            ),
          ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: allMonths.length > 12 ? (allMonths.length / 6).ceil().toDouble() : 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < allMonths.length) {
                            final date = allMonths[index].key;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('MMM').format(date),
                                style: context.bodySmall.copyWith(
                                  fontSize: 10,
                                  color: context.hintColor,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 25,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: context.bodySmall.copyWith(
                              fontSize: 10,
                              color: context.hintColor,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  minX: 0,
                  maxX: (allMonths.length - 1).toDouble(),
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    // Main line (solid)
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: chartColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: chartColor.withValues(alpha: 0.1),
                      ),
                    ),
                    // Dashed line for current month continuation (if complete)
                    if (dashedSpots.isNotEmpty)
                      LineChartBarData(
                        spots: dashedSpots,
                        isCurved: true,
                        color: chartColor.withValues(alpha: 0.5),
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dashArray: [5, 5],
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots
                            .map((barSpot) {
                              final index = barSpot.x.toInt();
                              if (index >= 0 && index < allMonths.length) {
                                final date = allMonths[index].key;
                                final probability = allMonths[index].value ?? 0.0;
                                return LineTooltipItem(
                                  '${DateFormat('MMM yyyy').format(date)}\n${probability.toStringAsFixed(1)}%',
                                  context.bodyMedium.copyWith(
                                    color: chartColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }
                              return null;
                            })
                            .whereType<LineTooltipItem>()
                            .toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getProbabilityColor(double probability) {
    if (probability >= 90) {
      return const Color(0xFF4CAF50); // Green
    } else if (probability >= 75) {
      return const Color(0xFF8BC34A); // Light Green
    } else if (probability >= 60) {
      return const Color(0xFFFFC107); // Amber
    } else {
      return const Color(0xFFF44336); // Red
    }
  }

  void _showYearPicker(BuildContext context, List<int> availableYears) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('Select Year'),
        actions: availableYears.reversed.map((year) {
          return CupertinoActionSheetAction(
            onPressed: () {
              setState(() {
                _selectedYear = year;
              });
              Navigator.of(context).pop();
            },
            child: Text(
              year.toString(),
              style: TextStyle(
                fontWeight: _selectedYear == year ? FontWeight.bold : FontWeight.normal,
                color: _selectedYear == year ? context.primary : null,
              ),
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: false,
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
      ),
    );
  }
}
