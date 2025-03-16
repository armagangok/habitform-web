import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '/core/core.dart';
import '/features/home/provider/home_provider.dart';
import '../../purchase/page/paywall_page.dart';
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
      child: CupertinoScaffold(
        transitionBackgroundColor: Colors.transparent,
        body: CupertinoPageScaffold(
          navigationBar: SheetHeader(
            closeButtonPosition: CloseButtonPosition.left,
            middle: Text(LocaleKeys.statistics_title.tr()),
          ),
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                CustomScrollView(
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
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Icon(
                                              FontAwesomeIcons.chartLine,
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
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            LocaleKeys.statistics_no_data_description.tr(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
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
                                      const SizedBox(height: 100), // Extra space for watermark
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

                // Watermark for mock data
                Consumer(
                  builder: (context, ref, child) {
                    final statisticsAsyncValue = ref.watch(statisticsProvider);

                    if (statisticsAsyncValue is AsyncData && statisticsAsyncValue.value?.isMockData == true && statisticsAsyncValue.value?.habitStatistics.isNotEmpty == true) {
                      return Positioned(
                        bottom: 10,
                        left: 30,
                        right: 30,
                        child: SafeArea(
                          child: Center(
                            child: CustomBlurWidget(
                              blurValue: 6,
                              child: Card(
                                color: Colors.deepOrangeAccent.withValues(alpha: .3),
                                clipBehavior: Clip.antiAlias,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Shimmer.fromColors(
                                          baseColor: Colors.white,
                                          highlightColor: Colors.white.withOpacity(0.5),
                                          period: const Duration(seconds: 2),
                                          direction: ShimmerDirection.ltr,
                                          child: Text(
                                            LocaleKeys.statistics_demo_data_message.tr(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Card(
                                        color: Colors.white.withValues(alpha: .85),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                          child: CustomButton(
                                            onPressed: () {
                                              showCupertinoModalBottomSheet(
                                                context: context,
                                                builder: (context) => const PaywallPage(),
                                              );
                                            },
                                            child: Shimmer.fromColors(
                                              baseColor: Colors.deepOrange,
                                              highlightColor: Colors.orange,
                                              period: const Duration(seconds: 1),
                                              direction: ShimmerDirection.ltr,
                                              child: Text(
                                                LocaleKeys.statistics_upgrade_button.tr(),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.deepOrange,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
