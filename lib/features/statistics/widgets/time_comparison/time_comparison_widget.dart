import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../page/statistics_page.dart';
import '../../provider/statistics_provider.dart';

class TimeComparisonWidget extends ConsumerWidget {
  const TimeComparisonWidget({super.key});

  String _getMonthlyComparisonDescription(dynamic comparison) {
    if (comparison.difference == 0) {
      return 'Bu ay geçen ayla aynı performansı gösteriyorsun.';
    }

    if (comparison.isImprovement) {
      if (comparison.difference >= 20) {
        return 'Harika ilerleme! Bu ay çok daha başarılısın! 🎉';
      } else if (comparison.difference >= 10) {
        return 'Güzel gelişme! Performansın artıyor! 📈';
      } else {
        return 'İyi gidiyorsun, küçük de olsa bir ilerleme var! 👍';
      }
    } else {
      if (comparison.difference.abs() >= 20) {
        return 'Bu ay biraz zorlandın gibi görünüyor. Pes etme! 💪';
      } else if (comparison.difference.abs() >= 10) {
        return 'Küçük bir düşüş var ama toparlanabilirsin! 🎯';
      } else {
        return 'Neredeyse geçen ayki gibisin, biraz daha çaba ile geçebilirsin! 🌱';
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(statisticsProvider);
    // Seçili alışkanlık indeksi
    final selectedHabitIndex = ref.watch(selectedHabitIndexProvider);

    // Eğer belirli bir alışkanlık seçiliyse bu widget'ı gösterme
    if (selectedHabitIndex != -1) {
      return const SizedBox.shrink();
    }

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Hata: $error')),
      data: (data) {
        if (data.totalCompletedDays == 0 || (data.monthlyComparison.thisMonthRate == 0 && data.monthlyComparison.lastMonthRate == 0)) {
          return CupertinoListSection.insetGrouped(
            backgroundColor: Colors.transparent,
            header: Text('Aylık Karşılaştırma'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.compare_arrows,
                        size: 48,
                        color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz karşılaştırma yapacak veri yok',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).hintColor,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bir ay boyunca alışkanlıklarınızı takip edin',
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

        final comparison = data.monthlyComparison;
        final comparisonDescription = _getMonthlyComparisonDescription(comparison);

        return CupertinoListSection.insetGrouped(
          backgroundColor: Colors.transparent,
          header: Text('Aylık Karşılaştırma'),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildComparisonItem(
                          context,
                          title: 'Bu Ay',
                          value: '${comparison.thisMonthRate.toStringAsFixed(1)}%',
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildComparisonItem(
                          context,
                          title: 'Geçen Ay',
                          value: '${comparison.lastMonthRate.toStringAsFixed(1)}%',
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDifferenceIndicator(context, comparison),
                  const SizedBox(height: 16),
                  Text(
                    comparisonDescription,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildComparisonItem(
    BuildContext context, {
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifferenceIndicator(BuildContext context, dynamic comparison) {
    final isImprovement = comparison.isImprovement;
    final difference = comparison.difference.abs();

    final color = isImprovement ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error;

    final icon = isImprovement ? Icons.arrow_upward : Icons.arrow_downward;
    final text = isImprovement ? 'Geçen aya göre %${difference.toStringAsFixed(1)} artış' : 'Geçen aya göre %${difference.toStringAsFixed(1)} düşüş';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
            maxLines: 10,
          ),
        ),
      ],
    );
  }
}
