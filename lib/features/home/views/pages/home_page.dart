import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/views/pages/my_account_page.dart';
import '../../../create_habit/create_habit_page.dart';
import '../../../create_habit/provider/create_habit_provider.dart';
import '../../../habit_probability/page/habit_probability_page.dart';
import '../../../purchase/providers/purchase_provider.dart';
import '../../../settings/settings_page.dart';
import '../../provider/home_provider.dart';
import '../widgets/habit_canvas/habit_constellation_view.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginSyncAlert();
    });
  }

  Future<void> _checkLoginSyncAlert() async {
    // 1. Ensure we have the latest status by waiting for the providers to initialize
    // This prevents the dialog from showing incorrectly while data is still loading
    final paywallState = await ref.read(purchaseProvider.future);
    final user = await ref.read(authStateProvider.future);

    final isPro = paywallState.isSubscriptionActive;
    final isLoggedOut = user == null;

    // 2. Already signed in and is pro? No need to show sync alert.
    if (isPro && !isLoggedOut) return;

    // 3. Already pro but logged out? Recommend cloud sync (account linking/signup).
    // Or not pro? Recommend cloud sync + pro features.

    // 4. Show Alert
    if (!mounted) return;

    showAppAlertDialog(
      context: context,
      title: Text(
        isLoggedOut ? context.tr(LocaleKeys.auth_pro_login_alert_title) : context.tr(LocaleKeys.auth_cloud_sync_pro_title),
        style: context.titleMedium.copyWith(fontWeight: FontWeight.w600),
      ),
      content: Text(
        isLoggedOut ? context.tr(LocaleKeys.auth_pro_login_alert_message) : context.tr(LocaleKeys.auth_cloud_sync_pro_message),
        style: context.bodyMedium,
      ),
      actions: [
        appAlertTextButton(
          context: context,
          label: context.tr(LocaleKeys.common_later),
          onPressed: () => Navigator.pop(context),
        ),
        appAlertTextButton(
          context: context,
          label: isLoggedOut ? context.tr(LocaleKeys.auth_pro_login_alert_action) : context.tr(LocaleKeys.auth_cloud_sync_pro_cta),
          onPressed: () {
            Navigator.pop(context);
            if (isLoggedOut) {
              showAppModalSheet(
                context: context,
                builder: (contextFromSheet) => const MyAccountPage(isFromHome: true),
              );
            } else {
              ref.read(purchaseProvider.notifier).presentPaywall(isFromOnboarding: false);
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: CupertinoPageScaffold(
        backgroundColor: isDark ? CupertinoColors.black : CupertinoColors.systemGrey6,
        child: Stack(
          children: [
            // Constellation view (full screen) - lazy loaded for better initial performance
            // Use summaries provider for lightweight data on main page
            Consumer(
              builder: (context, ref, _) {
                final summariesStateAsyncValue = ref.watch(homeSummariesProvider);

                return summariesStateAsyncValue.when(
                  data: (summariesState) {
                    return Consumer(
                      builder: (context, ref, _) {
                        // Optimized: Use select to only rebuild when list length changes significantly
                        final filteredSummaries = ref.watch(filteredHabitSummariesProvider);
                        final summariesLength = filteredSummaries.length;

                        if (summariesLength == 0) {
                          return _noHabitsWidget(ref, context);
                        }

                        // Lazy load constellation view to prevent blocking initial page render
                        // This helps when there are many habits with heavy completion data
                        return _LazyConstellationView(habits: filteredSummaries);
                      },
                    );
                  },
                  loading: () => _loadingWidget(),
                  error: (error, stack) {
                    LogHelper.shared.errorPrint('Error loading summaries: $error');
                    LogHelper.shared.errorPrint('Stack: $stack');
                    return _errorWidget();
                  },
                );
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
      ),
    );
  }

  Widget _buildFloatingNavBar(WidgetRef ref, BuildContext context, bool isDark) {
    final paywallState = ref.watch(purchaseProvider);
    final authState = ref.watch(authStateProvider).valueOrNull;
    final userProfile = ref.watch(userProfileProvider).valueOrNull;
    final paywallValue = paywallState.valueOrNull;
    final isPurchasing = paywallValue?.isPurchasing ?? false;
    final isRestoring = paywallValue?.isRestoring ?? false;
    final bool isLoading = paywallState is AsyncLoading;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Settings button
            CircularActionButton(
              onPressed: () {
                showAppModalSheet(
                  context: context,
                  builder: (contextFromSheet) => const SettingsPage(),
                );
              },
              icon: FontAwesomeIcons.gear,
              size: 40,
              iconSize: 18,
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
                TextSpan(
                  children: [
                    const TextSpan(text: "Habit"),
                    TextSpan(
                      text: "Form",
                      style: TextStyle(color: context.primary),
                    ),
                  ],
                ),
                style: context.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ),

            const Spacer(),

            // Right side buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile → My Account (Pro not required; upgrade via Settings / account banner)
                if (isLoading || isPurchasing || isRestoring)
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    child: const CupertinoActivityIndicator(),
                  )
                else
                  CircularActionButton(
                    onPressed: () {
                      showAppModalSheet(
                        context: context,
                        builder: (contextFromSheet) => const MyAccountPage(isFromHome: true),
                      );
                    },
                    imageUrl: userProfile?.photoUrl ?? authState?.photoURL,
                    icon: CupertinoIcons.person_fill,
                    size: 40,
                    iconSize: 22,
                  ),

                const SizedBox(width: 8),

                // Statistics button
                CircularActionButton(
                  onPressed: () {
                    showAppModalSheet(
                      context: context,
                      builder: (contextFromSheet) => const HabitProbabilityPage(),
                    );
                  },
                  icon: FontAwesomeIcons.chartLine,
                  size: 40,
                  iconSize: 18,
                ),

                const SizedBox(width: 8),

                // Add habit button
                CircularActionButton(
                  onPressed: () async {
                    // Use summaries for count check (lighter weight)
                    final summariesState = ref.read(homeSummariesProvider).value;
                    final homeState = ref.read(homeProvider).value;
                    final habitCount = summariesState?.summaries.length ?? homeState?.habits.length ?? 0;
                    if (habitCount > 0 || homeState != null) {
                      final canCreate = await ref.watch(createHabitProvider.notifier).canCreateHabit(
                            habitCount,
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
                  icon: CupertinoIcons.plus,
                  backgroundColor: context.primary,
                  iconColor: Colors.white,
                  size: 40,
                  iconSize: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _noHabitsWidget(WidgetRef ref, BuildContext context) {
    // Show empty constellation view in background to motivate user
    // Keep the create habit button visible on top
    return Stack(
      children: [
        // Empty constellation view as motivational background
        const RepaintBoundary(
          child: HabitConstellationView(habits: []),
        ),
        // Create habit button and message overlay
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.tr(LocaleKeys.habit_no_habit_found),
                style: context.titleLarge.copyWith(
                  fontWeight: FontWeight.w500,
                  color: CupertinoTheme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => _openCreateHabitPage(context),
                style: FilledButton.styleFrom(
                  backgroundColor: context.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: Text(
                  context.tr(LocaleKeys.create_habit_create_habit),
                  style: context.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _errorWidget() {
    return Center(
      child: Builder(
        builder: (context) {
          return Text(
            context.tr(LocaleKeys.errors_something_went_wrong),
            style: context.bodyMedium,
            textAlign: TextAlign.center,
          );
        },
      ),
    );
  }

  Widget _loadingWidget() {
    return Builder(
      builder: (context) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CupertinoActivityIndicator(),
              const SizedBox(height: 10),
              Text(
                context.tr(LocaleKeys.common_loading_habits),
                style: context.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handlePaywallAction(BuildContext context) async {
    await ref.read(purchaseProvider.notifier).presentPaywall(isFromOnboarding: false);
  }

  Future<dynamic> _openCreateHabitPage(BuildContext context) {
    return showAppModalSheet(
      context: context,
      maxWidth: 720,
      builder: (contextFromSheet) {
        return const CreateHabitPage();
      },
    );
  }
}

/// Lazy loaded constellation view widget
/// Defers rendering until after the current frame to improve initial page load performance
/// Accepts both Habit and HabitSummary for performance optimization
class _LazyConstellationView extends StatefulWidget {
  final List<dynamic> habits; // Can be List<Habit> or List<HabitSummary>

  const _LazyConstellationView({required this.habits});

  @override
  State<_LazyConstellationView> createState() => _LazyConstellationViewState();
}

class _LazyConstellationViewState extends State<_LazyConstellationView> {
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    // Defer loading until after the current frame
    // This allows the page UI to render first before processing heavy habit data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isLoaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      // Show a minimal placeholder while loading
      return const SizedBox.shrink();
    }

    // Wrap constellation view in RepaintBoundary to prevent unnecessary repaints
    return RepaintBoundary(
      child: HabitConstellationView(habits: widget.habits),
    );
  }
}
