import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitrise/core/extension/extensions.dart';

import '/features/translation/constants/locale_keys.g.dart';
import '../../page/statistics_page.dart';
import '../../provider/statistics_provider.dart';

class InsightsWidget extends ConsumerWidget {
  const InsightsWidget({super.key});

  // Alışkanlık oturma durumunu hesapla
  String _getHabitFormationStatus(double completionRate, int completedDays) {
    if (completedDays < 10) {
      return LocaleKeys.statistics_formation_status_early.tr();
    }

    final percentage = completionRate.toStringAsFixed(0);
    if (completionRate >= 90) {
      return LocaleKeys.statistics_formation_status_excellent.tr(namedArgs: {'percentage': percentage});
    } else if (completionRate >= 80) {
      return LocaleKeys.statistics_formation_status_very_good.tr(namedArgs: {'percentage': percentage});
    } else if (completionRate >= 70) {
      return LocaleKeys.statistics_formation_status_good.tr(namedArgs: {'percentage': percentage});
    } else if (completionRate >= 50) {
      return LocaleKeys.statistics_formation_status_improving.tr(namedArgs: {'percentage': percentage});
    } else {
      return LocaleKeys.statistics_formation_status_needs_work.tr(namedArgs: {'percentage': percentage});
    }
  }

  // Tahmini alışkanlık oturma süresini hesapla
  String _getEstimatedFormationTime(double completionRate, int completedDays, DateTime startDate) {
    if (completedDays < 5) {
      return LocaleKeys.statistics_formation_time_not_enough_data.tr();
    }

    // Başlangıçtan bugüne kadar geçen gün sayısı
    final daysSinceStart = DateTime.now().difference(startDate).inDays + 1;

    // Sabit 66 günlük ortalama süre kullan
    const int averageFormationDays = 66;

    // Kalan gün hesabı
    int remainingDays = averageFormationDays - daysSinceStart;
    remainingDays = remainingDays < 0 ? 0 : remainingDays;

    if (remainingDays == 0) {
      if (completionRate >= 90) {
        return LocaleKeys.statistics_formation_time_completed_successful.tr();
      } else if (completionRate >= 70) {
        return LocaleKeys.statistics_formation_time_completed_good.tr(namedArgs: {'percentage': completionRate.toStringAsFixed(0)});
      } else {
        return LocaleKeys.statistics_formation_time_completed_needs_work.tr();
      }
    } else {
      return LocaleKeys.statistics_formation_time_remaining_days.tr(namedArgs: {'days': remainingDays.toString()});
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(statisticsProvider);
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

        if (selectedHabitIndex != -1) {
          final selectedHabit = data.habitStatistics.values.elementAt(selectedHabitIndex);
          habitFormationStatus = _getHabitFormationStatus(selectedHabit.progressPercentage, selectedHabit.completedDays);
          estimatedFormationTime = _getEstimatedFormationTime(selectedHabit.progressPercentage, selectedHabit.completedDays, selectedHabit.startDate);
        }

        return CupertinoListSection.insetGrouped(
          backgroundColor: Colors.transparent,
          header: Text(headerText),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedHabitIndex != -1) ...[
                    _buildHabitFormationChart(context, data.habitStatistics.values.elementAt(selectedHabitIndex).progressPercentage),
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
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 24,
                              color: context.theme.hintColor,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                LocaleKeys.statistics_formation_info.tr(),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: context.bodySmall?.color?.withValues(alpha: .75),
                                    ),
                                maxLines: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHabitFormationChart(BuildContext context, double progressPercentage) {
    // Renk belirleme
    Color progressColor;
    List<Color> progressGradient;

    if (progressPercentage >= 90) {
      progressColor = const Color(0xFF4CAF50);
      progressGradient = [
        const Color(0xFF66BB6A),
        const Color(0xFF43A047),
      ];
    } else if (progressPercentage >= 70) {
      progressColor = const Color(0xFF8BC34A);
      progressGradient = [
        const Color(0xFF9CCC65),
        const Color(0xFF7CB342),
      ];
    } else if (progressPercentage >= 50) {
      progressColor = const Color(0xFFFFC107);
      progressGradient = [
        const Color(0xFFFFD54F),
        const Color(0xFFFFB300),
      ];
    } else {
      progressColor = const Color(0xFFF44336);
      progressGradient = [
        const Color(0xFFEF5350),
        const Color(0xFFE53935),
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: Container(
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
                        value: progressPercentage,
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
                        value: 100 - progressPercentage,
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
                          '${progressPercentage.toStringAsFixed(0)}%',
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
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(
                  context,
                  const Color(0xFFF44336),
                  LocaleKeys.statistics_chart_labels_below_50.tr(),
                  LocaleKeys.statistics_chart_labels_insufficient.tr(),
                  isSelected: progressPercentage < 50,
                ),
                _buildLegendItem(
                  context,
                  const Color(0xFFFFC107),
                  LocaleKeys.statistics_chart_labels_between_50_70.tr(),
                  LocaleKeys.statistics_chart_labels_moderate.tr(),
                  isSelected: progressPercentage >= 50 && progressPercentage < 70,
                ),
                _buildLegendItem(
                  context,
                  const Color(0xFF8BC34A),
                  LocaleKeys.statistics_chart_labels_between_70_90.tr(),
                  LocaleKeys.statistics_chart_labels_good.tr(),
                  isSelected: progressPercentage >= 70 && progressPercentage < 90,
                ),
                _buildLegendItem(
                  context,
                  const Color(0xFF4CAF50),
                  LocaleKeys.statistics_chart_labels_above_90.tr(),
                  LocaleKeys.statistics_chart_labels_excellent.tr(),
                  isSelected: progressPercentage >= 90,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label, String description, {bool isSelected = false}) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ],
        ),
        Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).hintColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ],
    );
  }
}
