import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '../../../create_habit/create_habit_page.dart';
import '../../../purchase/page/paywall_page.dart';
import '../../../purchase/providers/purchase_provider.dart';
import '../../../settings/settings_page.dart';
import '../../provider/home_provider.dart';
import '../../provider/home_state.dart';
import '../widgets/habit_builder.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: 350.ms);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeStateAsyncValue = ref.watch(homeProvider);

    ref.listen(homeProvider, (previous, next) {
      if (next.hasError) {
        // Show error message using AppFlushbar
        AppFlushbar.shared.errorFlushbar(next.error.toString().contains('Exception:') ? next.error.toString().split('Exception:')[1].trim() : LocaleKeys.errors_something_went_wrong.tr());
      }
    });

    return CupertinoScaffold(
      body: Stack(
        children: [
          // Main content
          CupertinoPageScaffold(
            navigationBar: _homePageNavigationBar(),
            child: ListView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: 8),
              children: <Widget>[
                // Time of day filter
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: _buildTimeFilterWidget(),
                  ),
                ),

                // Habits list
                homeStateAsyncValue.when(
                  data: (homeState) {
                    // Simple approach - no animations that cause flickering
                    return HabitBuilder(
                      habits: homeState.filteredHabits,
                      isLoading: false,
                    ).animate(controller: controller).fadeIn(
                          duration: 350.ms,
                        );
                  },
                  loading: () => Column(
                    children: [
                      CupertinoActivityIndicator(),
                      SizedBox(height: 10),
                      Text(
                        LocaleKeys.common_loading_habits.tr(),
                        style: context.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  error: (error, stack) {
                    LogHelper.shared.debugPrint('Error loading habits: $error');
                    LogHelper.shared.debugPrint('Stack trace: $stack');
                    return Center(
                      child: Text(
                        LocaleKeys.errors_something_went_wrong.tr(),
                        style: context.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build the time filter widget
  Widget _buildTimeFilterWidget() {
    return ref.watch(homeProvider).when(
          data: (homeState) {
            return _buildFilterCarousel(homeState);
          },
          loading: () => const SizedBox(),
          error: (_, __) => const SizedBox(),
        );
  }

  // Build a horizontally scrolling filter carousel
  Widget _buildFilterCarousel(HomeState homeState) {
    // List of all filters
    final filters = [
      TimeOfDayFilter.all,
      TimeOfDayFilter.morning,
      TimeOfDayFilter.afternoon,
      TimeOfDayFilter.evening,
    ];

    // Names for each filter
    final filterNames = {
      TimeOfDayFilter.all: LocaleKeys.habit_filter_all.tr(),
      TimeOfDayFilter.morning: LocaleKeys.habit_filter_morning.tr(),
      TimeOfDayFilter.afternoon: LocaleKeys.habit_filter_afternoon.tr(),
      TimeOfDayFilter.evening: LocaleKeys.habit_filter_evening.tr(),
    };

    // Build a simple row of filter buttons - NO PageView, NO animations
    return Row(
      children: filters.map((filter) {
        final isSelected = filter == homeState.timeFilter;

        return Expanded(
          child: CustomButton(
            onPressed: () {
              controller.forward(from: 0);
              // Set filter directly with no animations
              ref.read(homeProvider.notifier).setTimeFilter(filter);
            },
            child: Card(
              color: isSelected ? context.theme.cardTheme.color : Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 2.5),
                child: Center(
                  child: FittedBox(
                    child: Text(
                      filterNames[filter] ?? '',
                      style: context.bodyMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? context.theme.primaryColor : context.theme.hintColor,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  CupertinoNavigationBar _homePageNavigationBar() {
    final paywallState = ref.watch(purchaseProvider);
    final isSubActive = paywallState.value?.isSubscriptionActive ?? false;
    final isPurchasing = paywallState.value?.isPurchasing ?? false;
    final isRestoring = paywallState.value?.isRestoring ?? false;
    final bool isLoading = paywallState is AsyncLoading;

    return CupertinoNavigationBar(
      enableBackgroundFilterBlur: true,
      border: Border(
        bottom: BorderSide(
          color: context.theme.dividerColor.withValues(alpha: .25),
        ),
      ),
      leading: Builder(
        builder: (context) {
          return Align(
            widthFactor: 1,
            child: CustomButton(
              onPressed: () {
                CupertinoScaffold.showCupertinoModalBottomSheet(
                  enableDrag: false,
                  context: context,
                  builder: (contextFromSheet) {
                    return SettingsPage();
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
          Text(
            LocaleKeys.common_app.tr(),
            textAlign: TextAlign.center,
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
            ).animate(autoPlay: true).fadeIn(
                  curve: Curves.easeInOutCubic,
                  duration: Duration(milliseconds: 350),
                ),
          );
        }

        // Add habit button
        buttons.add(
          CustomButton(
            onPressed: () {
              if (isSubActive) {
                _openAddHabitPage(context);
              } else {
                final homeState = ref.read(homeProvider).value;
                if (homeState != null && homeState.habits.length <= 3) {
                  _openAddHabitPage(context);
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
          ).animate(autoPlay: true).fadeIn(duration: Duration(milliseconds: 350)),
        );

        // Add spacing between buttons and display in Row
        List<Widget> rowChildren = [];
        for (int i = 0; i < buttons.length; i++) {
          rowChildren.add(buttons[i]);
          if (i < buttons.length - 1) {
            rowChildren.add(SizedBox(width: 10));
          }
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: rowChildren,
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

  Future<dynamic> _openAddHabitPage(BuildContext context) {
    return CupertinoScaffold.showCupertinoModalBottomSheet(
      enableDrag: false,
      context: context,
      builder: (contextFromSheet) {
        return CreateHabitPage();
      },
    );
  }
}
