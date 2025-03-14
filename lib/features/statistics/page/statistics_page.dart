import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/features/home/provider/home_provider.dart';
import '../provider/statistics_provider.dart';
import '../widgets/general_progress/general_progress_stats.dart';
import '../widgets/habit_selector/habit_selector.dart';
import '../widgets/insights/insights_widget.dart';
import '../widgets/time_comparison/time_comparison_widget.dart';

// Seçili alışkanlık indeksi için provider
final selectedHabitIndexProvider = StateProvider<int>((ref) => -1);

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // HomeProvider'ı da dinle, böylece alışkanlıklar güncellendiğinde istatistikler de güncellenir
    ref.watch(homeProvider);

    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      navigationBar: const SheetHeader(
        closeButtonPosition: CloseButtonPosition.left,
        middle: Text('İstatistikler'),
      ),
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: () async {
                // İstatistikleri yenile
                await ref.read(statisticsProvider.notifier).refreshStatistics();
              },
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Alışkanlık seçici
                  const SizedBox(height: 16),
                  Consumer(
                    builder: (context, ref, child) {
                      final statisticsAsyncValue = ref.watch(statisticsProvider);

                      return statisticsAsyncValue.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, stackTrace) => Center(child: Text('Hata: $error')),
                        data: (state) {
                          if (state.habitStatistics.isEmpty) {
                            return const Center(
                              child: Text('Henüz istatistik bulunmuyor. Alışkanlıklarınızı takip etmeye başlayın!'),
                            );
                          }

                          return HabitSelector(
                            selectedHabitIndex: ref.watch(selectedHabitIndexProvider),
                            habitStats: state.habitStatistics.values.toList(),
                            onHabitSelected: (index) {
                              ref.read(selectedHabitIndexProvider.notifier).state = index;
                            },
                          );
                        },
                      );
                    },
                  ),

                  const GeneralProgressStats(),

                  const InsightsWidget(),

                  const TimeComparisonWidget(),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
