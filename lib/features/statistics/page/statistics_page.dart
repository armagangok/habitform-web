import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/features/home/provider/home_provider.dart';
import '../provider/statistics_provider.dart';
import '../widgets/general_progress/general_progress_stats.dart';
import '../widgets/habit_selector/habit_selector.dart';
import '../widgets/insights/insights_widget.dart';

// Seçili alışkanlık indeksi için provider
final selectedHabitIndexProvider = StateProvider<int>((ref) => -1);

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // HomeProvider'ı da dinle, böylece alışkanlıklar güncellendiğinde istatistikler de güncellenir
    ref.watch(homeProvider);

    return Material(
      color: Colors.transparent,
      child: CupertinoPageScaffold(
        backgroundColor: Colors.transparent,
        navigationBar: SheetHeader(
          closeButtonPosition: CloseButtonPosition.left,
          middle: Text(LocaleKeys.statistics_title.tr()),
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
                          error: (error, stackTrace) => Center(child: Text('${LocaleKeys.errors_something_went_wrong.tr()}: $error')),
                          data: (state) {
                            if (state.habitStatistics.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.surface,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context).shadowColor.withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.analytics_outlined,
                                        size: 48,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      LocaleKeys.statistics_no_data_title.tr(),
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onBackground,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      LocaleKeys.statistics_no_data_description.tr(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    SizedBox(
                                      width: double.infinity,
                                      child: CupertinoButton(
                                        color: Colors.deepOrangeAccent,
                                        onPressed: () {
                                          navigator.pop();
                                        },
                                        child: Text(
                                          LocaleKeys.habit_add_habit.tr(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return Column(
                              spacing: 20,
                              children: [
                                HabitSelector(
                                  selectedHabitIndex: ref.watch(selectedHabitIndexProvider),
                                  habitStats: state.habitStatistics.values.toList(),
                                  onHabitSelected: (index) {
                                    ref.read(selectedHabitIndexProvider.notifier).state = index;
                                  },
                                ),
                                const GeneralProgressStats(),
                                const InsightsWidget(),
                                const SizedBox(height: 30),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
