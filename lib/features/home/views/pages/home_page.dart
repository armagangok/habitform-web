import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '../../../create_habit/create_habit_page.dart';
import '../../../create_habit/provider/create_habit_provider.dart';
import '../../../habit_category/widget/home_category_filter.dart';
import '../../../purchase/page/paywall_page.dart';
import '../../../purchase/providers/purchase_provider.dart';
import '../../../settings/settings_page.dart';
import '../../../statistics/page/statistics_page.dart';
import '../../provider/home_provider.dart';
import '../widgets/habit_builder.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeStateAsyncValue = ref.watch(homeProvider);

    return CupertinoScaffold(
      body: Stack(
        children: [
          // Main content
          CupertinoPageScaffold(
            navigationBar: _homePageNavigationBar(ref, context),
            child: ListView(
              physics: AlwaysScrollableScrollPhysics(),
              children: <Widget>[
                SizedBox(height: 16),

                // Category filter
                HomeCategoryFilter(),

                SizedBox(height: 16),

                // Habits list
                homeStateAsyncValue.when(
                  data: (homeState) {
                    // Using the filtered habits provider instead of direct state
                    return Consumer(builder: (context, ref, _) {
                      final filteredHabits = ref.watch(filteredHabitsProvider);
                      return HabitBuilder(
                        habits: filteredHabits,
                        isLoading: false,
                      );
                    });
                  },
                  loading: () => _loadingWidget(context),
                  error: (error, stack) => _errorWidget(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorWidget(BuildContext context) {
    return Center(
      child: Text(
        LocaleKeys.errors_something_went_wrong.tr(),
        style: context.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _loadingWidget(BuildContext context) {
    return Column(
      children: [
        CupertinoActivityIndicator(),
        SizedBox(height: 10),
        Text(
          LocaleKeys.common_loading_habits.tr(),
          style: context.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  CupertinoNavigationBar _homePageNavigationBar(WidgetRef ref, BuildContext context) {
    final paywallState = ref.watch(purchaseProvider);
    final isSubActive = paywallState.value?.isSubscriptionActive ?? false;
    final isPurchasing = paywallState.value?.isPurchasing ?? false;
    final isRestoring = paywallState.value?.isRestoring ?? false;
    final bool isLoading = paywallState is AsyncLoading;

    return CupertinoNavigationBar(
      enableBackgroundFilterBlur: true,
      backgroundColor: context.theme.scaffoldBackgroundColor.withValues(alpha: .1),
      border: Border(
        bottom: BorderSide(
          color: context.theme.dividerColor.withValues(alpha: .25),
        ),
      ),
      leading: Builder(
        builder: (context) {
          return Align(
            widthFactor: 1,
            alignment: Alignment.centerLeft,
            child: CustomButton(
              onPressed: () {
                CupertinoScaffold.showCupertinoModalBottomSheet(
                  enableDrag: false,
                  context: context,
                  builder: (contextFromSheet) {
                    return const SettingsPage();
                  },
                );
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.primary.withValues(alpha: .15),
                ),
                child: Icon(
                  FontAwesomeIcons.gear,
                  size: 20,
                  color: context.theme.primaryColor.withValues(alpha: .9),
                ),
              ),
            ).animate().fadeIn(curve: Curves.easeInOutCubic),
          );
        },
      ),
      middle: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 10),
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: "Habit",
              ),
              TextSpan(
                text: "Rise",
                style: TextStyle(color: Colors.blueAccent),
              ),
            ]),
          ).animate().fadeIn(
                curve: Curves.easeInOutCubic,
                duration: Duration(milliseconds: 350),
              ),
        ],
      ),
      trailing: Builder(builder: (context) {
        // Create buttons as a list
        List<Widget> buttons = [];

        // Premium button or loading indicator
        if (isLoading || isPurchasing || isRestoring) {
          buttons.add(
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              child: CupertinoActivityIndicator(),
            ),
          );
        } else if (!isSubActive) {
          buttons.add(
            CustomButton(
              onPressed: () {
                _handlePaywallAction(context);
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.primary.withValues(alpha: .15),
                ),
                child: Icon(
                  FontAwesomeIcons.crown,
                  color: Colors.yellow,
                  size: 20,
                ),
              ),
            ),
          );
        }

        // Add spacing between buttons
        buttons.add(SizedBox(width: 12));

        // Add statistics button
        buttons.add(
          CustomButton(
            onPressed: () {
              CupertinoScaffold.showCupertinoModalBottomSheet(
                enableDrag: false,
                context: context,
                builder: (contextFromSheet) {
                  return const StatisticsPage();
                },
              );
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.primary.withValues(alpha: .15),
              ),
              child: Icon(
                FontAwesomeIcons.chartLine,
                size: 20,
                color: context.theme.primaryColor.withValues(alpha: .9),
              ),
            ),
          ),
        );

        // Add spacing between buttons
        buttons.add(SizedBox(width: 12));

        // Add habit button
        buttons.add(
          CustomButton(
            onPressed: () async {
              final homeState = ref.read(homeProvider).value;
              if (homeState != null) {
                final canCreate = await ref.read(createHabitProvider.notifier).canCreateHabit(
                      homeState.habits.length,
                    );
                if (canCreate) {
                  _openCreateHabitPage(context);
                } else {
                  _handlePaywallAction(context);
                }
              }
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.primary.withValues(alpha: .15),
              ),
              child: Icon(
                CupertinoIcons.plus_circle_fill,
                size: 24,
                color: context.theme.primaryColor.withValues(alpha: .9),
              ),
            ),
          ).animate().fadeIn(duration: Duration(milliseconds: 350)),
        );

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: buttons,
        );
      }),
    );
  }

  Future<void> _handlePaywallAction(BuildContext context) async {
    return CupertinoScaffold.showCupertinoModalBottomSheet(
      enableDrag: false,
      context: context,
      builder: (_) => PaywallPage(),
    );
  }

  Future<dynamic> _openCreateHabitPage(BuildContext context) {
    return CupertinoScaffold.showCupertinoModalBottomSheet(
      enableDrag: false,
      context: context,
      builder: (contextFromSheet) {
        return CreateHabitPage();
      },
    );
  }
}
