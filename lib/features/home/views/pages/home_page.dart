import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '../../../create_habit/create_habit_page.dart';
import '../../../purchase/page/paywall_page.dart';
import '../../../purchase/providers/purchase_provider.dart';
import '../../../settings/settings_page.dart';
import '../../provider/home_provider.dart';
import '../widgets/habit_builder.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsyncValue = ref.watch(homeProvider);
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final navBarHeight = 44.0; // CupertinoNavigationBar default height

    ref.listen(homeProvider, (previous, next) {
      if (next.hasError) {
        // Show error message using AppFlushbar
        AppFlushbar.shared.errorFlushbar(next.error.toString().contains('Exception:') ? next.error.toString().split('Exception:')[1].trim() : 'An error occurred while managing habits');
      }
    });

    return CupertinoScaffold(
      body: Stack(
        children: [
          // Main content
          CupertinoPageScaffold(
            navigationBar: null, // Remove the navigation bar from here
            child: ListView(
              controller: _scrollController,
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                top: statusBarHeight + navBarHeight + 15, // Add padding for the navigation bar
                bottom: 15,
                left: 0,
                right: 0,
              ),
              children: <Widget>[
                habitsAsyncValue.when(
                  data: (habits) => HabitBuilder(
                    habits: habits,
                    isLoading: false,
                  ).animate().fadeIn(
                        duration: Duration(milliseconds: 350),
                      ),
                  loading: () => Column(
                    children: [
                      CupertinoActivityIndicator(),
                      SizedBox(height: 10),
                      Text(
                        'Alışkanlıklar yükleniyor...',
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
                        'Hata: $error',
                        style: context.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Navigation bar with animation
          ScrollableNavigationBar(
            scrollController: _scrollController,
            navigationBar: _homePageNavigationBar(),
          ),
        ],
      ),
    );
  }

  CupertinoNavigationBar _homePageNavigationBar() {
    final paywallState = ref.watch(purchaseProvider);
    return CupertinoNavigationBar(
      enableBackgroundFilterBlur: false,
      border: null, // Remove the bottom border
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
            ).animate().fadeIn(
                  curve: Curves.easeInOutCubic,
                  duration: Duration(milliseconds: 350),
                ),
          );
        },
      ),
      middle: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'HabitRise',
            textAlign: TextAlign.center,
          ).animate().fadeIn(
                curve: Curves.easeInOutCubic,
                duration: Duration(milliseconds: 350),
              ),
        ],
      ),
      trailing: Builder(
        builder: (context) {
          final isSubActive = paywallState.value?.isSubscriptionActive ?? false;
          final isPurchasing = paywallState.value?.isPurchasing ?? false;
          final isRestoring = paywallState.value?.isRestoring ?? false;
          final bool isLoading = paywallState is AsyncLoading;

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
              ).animate().fadeIn(
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
                  final habits = ref.read(homeProvider).value;
                  if (habits != null && habits.length <= 3) {
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
            ).animate().fadeIn(duration: Duration(milliseconds: 350)),
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
        },
      ),
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
