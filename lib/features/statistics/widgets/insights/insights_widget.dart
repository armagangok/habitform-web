import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitrise/core/extension/extensions.dart';

import '../../page/statistics_page.dart';
import '../../provider/statistics_provider.dart';
import '../../provider/statistics_state.dart';

class InsightsWidget extends ConsumerWidget {
  const InsightsWidget({super.key});

  String _formatDayName(String shortDay) {
    // Kısa gün adlarını tam formata çevir
    final Map<String, String> dayNames = {
      'Mon': 'Pazartesi',
      'Tue': 'Salı',
      'Wed': 'Çarşamba',
      'Thu': 'Perşembe',
      'Fri': 'Cuma',
      'Sat': 'Cumartesi',
      'Sun': 'Pazar',
      'Pzt': 'Pazartesi',
      'Sal': 'Salı',
      'Çar': 'Çarşamba',
      'Per': 'Perşembe',
      'Cum': 'Cuma',
      'Cmt': 'Cumartesi',
      'Paz': 'Pazar',
    };
    return dayNames[shortDay] ?? shortDay;
  }

  (String day, double rate) _getMostProductiveDay(Map<String, double> progress) {
    if (progress.isEmpty) return ('', 0);

    var maxEntry = progress.entries.reduce((a, b) => a.value > b.value ? a : b);
    return (maxEntry.key, maxEntry.value);
  }

  (String day, double rate) _getMostSkippedDay(Map<String, double> progress) {
    if (progress.isEmpty) return ('', 0);

    var minEntry = progress.entries.reduce((a, b) => a.value < b.value ? a : b);
    return (minEntry.key, minEntry.value);
  }

  // Alışkanlık oturma durumunu hesapla
  String _getHabitFormationStatus(double completionRate, int completedDays) {
    if (completedDays < 10) {
      return 'Henüz başlangıç aşamasındasınız. Alışkanlığın oturması için en az 18-66 gün düzenli tekrar gerekiyor.';
    }

    if (completionRate >= 90) {
      return 'Harika! %${completionRate.toStringAsFixed(0)} tamamlama oranıyla alışkanlığınız büyük ölçüde otomatikleşmiş durumda.';
    } else if (completionRate >= 80) {
      return 'Çok iyi! %${completionRate.toStringAsFixed(0)} tamamlama oranıyla alışkanlığınız yerleşmeye başlamış.';
    } else if (completionRate >= 70) {
      return 'İyi gidiyorsunuz. %${completionRate.toStringAsFixed(0)} tamamlama oranı alışkanlık oluşturmak için yeterli bir seviye.';
    } else if (completionRate >= 50) {
      return 'Gelişme gösteriyorsunuz. %${completionRate.toStringAsFixed(0)} tamamlama oranını %70\'in üzerine çıkarmaya çalışın.';
    } else {
      return 'Alışkanlık oluşturmak için tamamlama oranınızı artırmanız gerekiyor. Şu an %${completionRate.toStringAsFixed(0)}.';
    }
  }

  // Tahmini alışkanlık oturma süresini hesapla
  String _getEstimatedFormationTime(double completionRate, int completedDays, DateTime startDate) {
    if (completedDays < 5) {
      return 'Henüz yeterli veri yok.';
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
        return "Tebrikler! Alışkanlığınız büyük olasılıkla yerleşmiş durumda.";
      } else if (completionRate >= 70) {
        return 'Tebrikler! 66 günlük ortalama süreyi tamamladınız ve %${completionRate.toStringAsFixed(0)} tamamlama oranıyla alışkanlığınız tahmini olarak, büyük olasılıkla yerleşmiş durumda.';
      } else {
        return '66 günlük ortalama süreyi tamamladınız, ancak alışkanlığın tam olarak yerleşmesi için tamamlama oranınızı %70\'in üzerine çıkarmanız önerilir.';
      }
    } else {
      return 'Alışkanlığın oluşması için, tahmini $remainingDays gününüz kaldı. Düzenli tekrar etmeye devam edin.';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(statisticsProvider);
    final selectedHabitIndex = ref.watch(selectedHabitIndexProvider);

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Hata: $error')),
      data: (data) {
        // Veri kontrolü
        if (data.weeklyProgress.isEmpty || data.totalCompletedDays == 0) {
          return CupertinoListSection.insetGrouped(
            backgroundColor: Colors.transparent,
            header: Text('Alışkanlık Oluşum'),
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
                        'Henüz yeterli veri yok',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).hintColor,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Alışkanlıklarınızı takip etmeye devam edin',
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
        final StatisticsState filteredState = selectedHabitIndex == -1
            ? data
            : data.filterByHabit(
                data.habitStatistics.values.elementAt(selectedHabitIndex).habitId,
              );

        // Başlık metnini belirle
        String headerText = 'Alışkanlık Oluşum';

        // Seçili alışkanlık için en verimli ve en az verimli günleri hesapla
        final (productiveDay, productiveRate) = _getMostProductiveDay(filteredState.weeklyProgress);
        final (skippedDay, skippedRate) = _getMostSkippedDay(filteredState.weeklyProgress);

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedHabitIndex != -1) ...[
                    _buildHabitFormationChart(context, data.habitStatistics.values.elementAt(selectedHabitIndex).progressPercentage),
                    const SizedBox(height: 30),
                    Text(
                      'Alışkanlık Oluşumu Hakkında',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      habitFormationStatus,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 10,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      estimatedFormationTime,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 10,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Araştırmalara göre, bir alışkanlığın yerleşmesi için gereken ortalama süre 66 gündür. Bu süre boyunca düzenli tekrar, alışkanlığın otomatik hale gelmesini sağlar.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.bodySmall?.color?.withValues(alpha: .75),
                          ),
                      maxLines: 10,
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                  ],
                  _buildInsightItem(
                    context,
                    icon: Icons.calendar_today,
                    title: 'En Verimli Gün',
                    value: productiveDay.isNotEmpty ? '${_formatDayName(productiveDay)} (%${(productiveRate * 100).toStringAsFixed(0)})' : 'Henüz yeterli veri yok',
                  ),
                  const SizedBox(height: 16),
                  _buildInsightItem(
                    context,
                    icon: Icons.skip_next,
                    title: 'En Çok Atlanan Gün',
                    value: skippedDay.isNotEmpty ? '${_formatDayName(skippedDay)} (%${(skippedRate * 100).toStringAsFixed(0)})' : 'Henüz yeterli veri yok',
                  ),
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
                          '%${progressPercentage.toStringAsFixed(0)}',
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
                  '< %50',
                  'Yetersiz',
                  isSelected: progressPercentage < 50,
                ),
                _buildLegendItem(
                  context,
                  const Color(0xFFFFC107),
                  '%50-70',
                  'Orta',
                  isSelected: progressPercentage >= 50 && progressPercentage < 70,
                ),
                _buildLegendItem(
                  context,
                  const Color(0xFF8BC34A),
                  '%70-90',
                  'İyi',
                  isSelected: progressPercentage >= 70 && progressPercentage < 90,
                ),
                _buildLegendItem(
                  context,
                  const Color(0xFF4CAF50),
                  '> %90',
                  'Mükemmel',
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

  Widget _buildInsightItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
