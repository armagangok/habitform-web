import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '/core/core.dart' hide showCupertinoSheet;
import '../provider/habit_formation_provider.dart';
import '../widgets/formation_widget/formation_insights_widget.dart';
import '../widgets/habit_selector/habit_selector.dart';

// Seçili alışkanlık indeksi için provider
final selectedHabitIndexProvider = StateProvider<int>((ref) => -1);

class HabitFormationPage extends ConsumerWidget {
  const HabitFormationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      navigationBar: SheetHeader(
        closeButtonPosition: CloseButtonPosition.left,
        middle: Text(LocaleKeys.statistics_habit_formation.tr()),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Column(
                  children: [
                    Consumer(
                      builder: (context, ref, child) {
                        final statisticsAsyncValue = ref.watch(formationProvider);

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
                                        color: Colors.blueAccent,
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
                                const FormationInsightsWidget(),
                                const SizedBox(height: 100), // Extra space for watermark
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),

            // Watermark for mock data
            Consumer(
              builder: (context, ref, child) {
                final statisticsAsyncValue = ref.watch(formationProvider);

                if (statisticsAsyncValue is AsyncData && statisticsAsyncValue.value?.isMockData == true && statisticsAsyncValue.value?.habitStatistics.isNotEmpty == true) {
                  return Positioned(
                    bottom: 10,
                    left: 30,
                    right: 30,
                    child: SafeArea(
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CustomBlurWidget(
                            child: CupertinoCard(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Shimmer.fromColors(
                                        baseColor: context.titleSmall.color ?? Colors.deepOrange,
                                        highlightColor: context.titleSmall.color?.withValues(alpha: 0.5) ?? Colors.blueAccent,
                                        period: const Duration(seconds: 2),
                                        direction: ShimmerDirection.ltr,
                                        child: Text(
                                          LocaleKeys.statistics_chart_labels_demo_data_message.tr(),
                                          style: context.titleSmall.copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                      child: CustomButton(
                                        onPressed: () {
                                          navigator.navigateTo(
                                            path: KRoute.prePaywall,
                                            data: {'isFromOnboarding': false},
                                          );
                                        },
                                        child: Shimmer.fromColors(
                                          baseColor: Colors.deepOrange,
                                          highlightColor: Colors.orange,
                                          period: const Duration(seconds: 1),
                                          direction: ShimmerDirection.ltr,
                                          child: Text(
                                            LocaleKeys.statistics_chart_labels_upgrade_button.tr(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepOrange,
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
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
