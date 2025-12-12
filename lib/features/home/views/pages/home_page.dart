import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '../../../create_habit/create_habit_page.dart';
import '../../../create_habit/provider/create_habit_provider.dart';
import '../../../habit_probability/page/habit_probability_page.dart';
import '../../../purchase/page/paywall_page.dart';
import '../../../purchase/providers/purchase_provider.dart';
import '../../../settings/settings_page.dart';
import '../../provider/home_provider.dart';
import '../widgets/habit_canvas/habit_constellation_view.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeStateAsyncValue = ref.watch(homeProvider);
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: isDark ? CupertinoColors.black : CupertinoColors.systemGrey6,
      child: Stack(
        children: [
          // Constellation view (full screen)
          homeStateAsyncValue.when(
            data: (homeState) {
              return Consumer(builder: (context, ref, _) {
                final filteredHabits = ref.watch(filteredHabitsProvider);
                if (filteredHabits.isEmpty) {
                  return _noHabitsWidget(ref, context);
                }
                return HabitConstellationView(habits: filteredHabits);
              });
            },
            loading: () => _loadingWidget(context),
            error: (error, stack) {
              LogHelper.shared.errorPrint('Error: $error');
              LogHelper.shared.errorPrint('Stack: $stack');
              return _errorWidget(context);
            },
          ),

          // Floating navigation bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildFloatingNavBar(ref, context, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavBar(WidgetRef ref, BuildContext context, bool isDark) {
    final paywallState = ref.watch(purchaseProvider);
    final isSubActive = paywallState.value?.isSubscriptionActive ?? false;
    final isPurchasing = paywallState.value?.isPurchasing ?? false;
    final isRestoring = paywallState.value?.isRestoring ?? false;
    final bool isLoading = paywallState is AsyncLoading;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Settings button
            _buildNavButton(
              context: context,
              icon: FontAwesomeIcons.gear,
              isDark: isDark,
              onTap: () {
                showCupertinoSheet(
                  enableDrag: false,
                  context: context,
                  builder: (contextFromSheet) => const SettingsPage(),
                );
              },
            ),

            const Spacer(),

            // App title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? CupertinoColors.systemGrey6.darkColor.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text.rich(
                TextSpan(children: [
                  const TextSpan(text: "Habit"),
                  TextSpan(
                    text: "Form",
                    style: TextStyle(color: context.primary),
                  ),
                ]),
                style: context.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ),

            const Spacer(),

            // Right side buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Premium button
                if (isLoading || isPurchasing || isRestoring)
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    child: const CupertinoActivityIndicator(),
                  )
                else if (!isSubActive)
                  _buildNavButton(
                    context: context,
                    icon: FontAwesomeIcons.crown,
                    isDark: isDark,
                    iconColor: Colors.amber,
                    onTap: () => _handlePaywallAction(context),
                  ),

                const SizedBox(width: 8),

                // Statistics button
                _buildNavButton(
                  context: context,
                  icon: FontAwesomeIcons.chartLine,
                  isDark: isDark,
                  onTap: () {
                    showCupertinoSheet(
                      enableDrag: false,
                      context: context,
                      builder: (contextFromSheet) => const HabitProbabilityPage(),
                    );
                  },
                ),

                const SizedBox(width: 8),

                // Add habit button
                _buildNavButton(
                  context: context,
                  icon: CupertinoIcons.plus,
                  isDark: isDark,
                  isPrimary: true,
                  onTap: () async {
                    final homeState = ref.read(homeProvider).value;
                    if (homeState != null) {
                      final canCreate = await ref.watch(createHabitProvider.notifier).canCreateHabit(
                            homeState.habits.length,
                          );
                      if (canCreate) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _openCreateHabitPage(context);
                        });
                      } else {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _handlePaywallAction(context);
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required BuildContext context,
    required IconData icon,
    required bool isDark,
    Color? iconColor,
    bool isPrimary = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isPrimary
              ? context.primary
              : isDark
                  ? CupertinoColors.systemGrey6.darkColor.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: isPrimary ? Colors.white : iconColor ?? (isDark ? Colors.white70 : Colors.black87),
        ),
      ),
    );
  }

  Widget _noHabitsWidget(WidgetRef ref, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.circle_grid_hex,
            size: 80,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 24),
          Text(
            LocaleKeys.habit_no_habit_found.tr(),
            style: context.titleLarge.copyWith(fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Tap + to create your first habit',
            style: context.bodyMedium.copyWith(color: CupertinoColors.systemGrey),
            textAlign: TextAlign.center,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CupertinoActivityIndicator(),
          const SizedBox(height: 10),
          Text(
            LocaleKeys.common_loading_habits.tr(),
            style: context.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _handlePaywallAction(BuildContext context) async {
    showCupertinoSheet(
      enableDrag: false,
      context: context,
      builder: (contextFromSheet) {
        return PaywallPage(isFromOnboarding: false);
      },
    );
  }

  Future<dynamic> _openCreateHabitPage(BuildContext context) {
    return showCupertinoSheet(
      enableDrag: false,
      context: context,
      builder: (contextFromSheet) {
        return CreateHabitPage();
      },
    );
  }
}
