import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '../../../create_habit/create_habit_page.dart';
import '../../../create_habit/provider/create_habit_provider.dart';
import '../../../purchase/page/paywall_page.dart';
import '../../../purchase/providers/purchase_provider.dart';
import '../../../settings/settings_page.dart';
import '../../../statistics/page/statistics_page.dart';
import '../../provider/home_provider.dart';
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
              children: <Widget>[
                SizedBox(height: 16),

                // Habits list
                homeStateAsyncValue.when(
                  data: (homeState) {
                    // Simple approach - no animations that cause flickering
                    return HabitBuilder(
                      habits: homeState.habits,
                      isLoading: false,
                    ).animate(controller: controller).fadeIn(curve: Curves.easeIn);
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

  CupertinoNavigationBar _homePageNavigationBar() {
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
                style: TextStyle(color: Colors.deepOrangeAccent),
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
                final canCreate = await ref.read(createHabitProvider.notifier).canCreateHabit(homeState.habits.length);
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
