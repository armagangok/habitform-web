import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../../../models/habit/habit_difficulty.dart';
import '../../page/habit_formation_page.dart';
import '../../provider/habit_formation_provider.dart';

class FormationWidget extends ConsumerWidget {
  const FormationWidget({super.key});

  // Alışkanlık oturma durumunu hesapla - difficulty-aware
  String _getHabitFormationStatus(double completionRate, int completedDays, HabitDifficulty difficulty, double formationProbability) {
    if (completedDays < 10) {
      return LocaleKeys.statistics_formation_status_early.tr();
    }

    // Use formation probability instead of raw completion rate for consistency
    final percentage = formationProbability.toStringAsFixed(0);
    final probabilityPercentage = formationProbability.toStringAsFixed(0);

    if (formationProbability >= 90) {
      return LocaleKeys.statistics_formation_status_excellent.tr(namedArgs: {
        'percentage': percentage,
        'probability': probabilityPercentage,
      });
    } else if (formationProbability >= 75) {
      return LocaleKeys.statistics_formation_status_very_good.tr(namedArgs: {
        'percentage': percentage,
        'probability': probabilityPercentage,
      });
    } else if (formationProbability >= 60) {
      return LocaleKeys.statistics_formation_status_good.tr(namedArgs: {
        'percentage': percentage,
        'probability': probabilityPercentage,
      });
    } else if (formationProbability >= 40) {
      return LocaleKeys.statistics_formation_status_improving.tr(namedArgs: {
        'percentage': percentage,
        'probability': probabilityPercentage,
      });
    } else {
      return LocaleKeys.statistics_formation_status_needs_work.tr(namedArgs: {
        'percentage': percentage,
        'probability': probabilityPercentage,
      });
    }
  }

  // Tahmini alışkanlık oturma süresini hesapla - difficulty-aware
  String _getEstimatedFormationTime(double completionRate, int completedDays, DateTime startDate, HabitDifficulty difficulty, int remainingFormationDays, int estimatedFormationDays) {
    if (completedDays < 5) {
      return LocaleKeys.statistics_formation_time_not_enough_data.tr();
    }

    final minimumCompletionRate = difficulty.minimumCompletionRate * 100;

    if (remainingFormationDays == 0) {
      if (completionRate >= minimumCompletionRate + 15) {
        return LocaleKeys.statistics_formation_time_completed_successful.tr();
      } else if (completionRate >= minimumCompletionRate) {
        return LocaleKeys.statistics_formation_time_completed_good.tr(namedArgs: {'percentage': completionRate.toStringAsFixed(0)});
      } else {
        return LocaleKeys.statistics_formation_time_completed_needs_work.tr();
      }
    } else {
      return LocaleKeys.statistics_formation_time_remaining_days.tr(namedArgs: {
        'days': remainingFormationDays.toString(),
        'total': estimatedFormationDays.toString(),
      });
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(formationProvider);
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).hintColor,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        LocaleKeys.statistics_start_tracking_habit.tr(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
        String headerText = LocaleKeys.statistics_habit_formation.tr();

        // Alışkanlık oturma durumu ve tahmini süre
        String habitFormationStatus = '';
        String estimatedFormationTime = '';

        // Check if we have a valid selected habit index
        if (selectedHabitIndex >= 0 && selectedHabitIndex < data.habitStatistics.values.length) {
          final selectedHabit = data.habitStatistics.values.elementAt(selectedHabitIndex);
          final HabitDifficulty selectedDifficulty = selectedHabit.difficulty ?? HabitDifficulty.moderate;
          habitFormationStatus = _getHabitFormationStatus(
            selectedHabit.progressPercentage,
            selectedHabit.completedDays,
            selectedDifficulty,
            selectedHabit.formationProbability,
          );
          estimatedFormationTime = _getEstimatedFormationTime(
            selectedHabit.progressPercentage,
            selectedHabit.completedDays,
            selectedHabit.startDate,
            selectedDifficulty,
            selectedHabit.remainingFormationDays,
            selectedHabit.estimatedFormationDays,
          );
        } else {
          // No valid habit selected, return empty widget
          return const SizedBox.shrink();
        }

        return CupertinoListSection.insetGrouped(
          header: Text(headerText),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Always show the chart and information when a habit is selected
                  _buildHabitFormationChart(
                    context,
                    data.habitStatistics.values.elementAt(selectedHabitIndex).progressPercentage,
                    data.habitStatistics.values.elementAt(selectedHabitIndex).difficulty ?? HabitDifficulty.moderate,
                    data.habitStatistics.values.elementAt(selectedHabitIndex).formationProbability,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    LocaleKeys.statistics_about_formation.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 3,
                  ),
                  Text(
                    habitFormationStatus,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 10,
                  ),
                  Text(
                    estimatedFormationTime,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 10,
                  ),
                  CupertinoCard(
                    color: context.primary.withValues(alpha: .075),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 24,
                            color: context.theme.selectionHandleColor.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              LocaleKeys.statistics_formation_info.tr(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: context.bodySmall.color?.withValues(alpha: .75),
                                  ),
                              maxLines: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHabitFormationChart(BuildContext context, double progressPercentage, HabitDifficulty difficulty, double formationProbability) {
    // Formation probability-based color determination
    Color progressColor;
    List<Color> progressGradient;

    if (formationProbability >= 90) {
      progressColor = const Color(0xFF4CAF50); // Green - Excellent formation probability
      progressGradient = [
        const Color(0xFF66BB6A),
        const Color(0xFF43A047),
      ];
    } else if (formationProbability >= 75) {
      progressColor = const Color(0xFF8BC34A); // Light Green - Very good formation probability
      progressGradient = [
        const Color(0xFF9CCC65),
        const Color(0xFF7CB342),
      ];
    } else if (formationProbability >= 60) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                      value: formationProbability,
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
                      value: 100 - formationProbability,
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
                        '${formationProbability.toStringAsFixed(0)}%',
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
        ),
        const SizedBox(height: 24),
        IntrinsicHeight(
          child: CupertinoCard(
            color: context.primary.withValues(alpha: .075),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegendItem(
                    context,
                    const Color(0xFFF44336),
                    'Below 60%',
                    'Needs Work',
                    isSelected: formationProbability < 60,
                  ),
                  _verticalDivider(),
                  _buildLegendItem(
                    context,
                    const Color(0xFFFFC107),
                    '60-75%',
                    'Good Progress',
                    isSelected: formationProbability >= 60 && formationProbability < 75,
                  ),
                  _verticalDivider(),
                  _buildLegendItem(
                    context,
                    const Color(0xFF8BC34A),
                    '75-90%',
                    'Very Good',
                    isSelected: formationProbability >= 75 && formationProbability < 90,
                  ),
                  _verticalDivider(),
                  _buildLegendItem(
                    context,
                    const Color(0xFF4CAF50),
                    'Above 90%',
                    'Excellent',
                    isSelected: formationProbability >= 90,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Sabit boyutlu daire
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 2.5,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 3),
              // Etiket için FittedBox kullanarak metni küçültme
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 5),

        // Açıklama metni için FittedBox kullanarak metni küçültme
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).hintColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
