import 'package:habitrise/features/paywall/widgets/paywall_widget.dart';

import '/core/core.dart';
import '/features/paywall/bloc/paywall_bloc.dart';
import '../add_habit/add_habit_page.dart';
import '../settings/settings_home_page.dart';
import 'bloc/habit_bloc.dart';
import 'widgets/single_habit/single_habit_builder.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum HabitSelection { today, allTime }

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 250));

    context.read<PaywallBloc>().add(InitializePaywallEvent());

    context.read<HabitBloc>().add(FetchHabitEvent());

    super.initState();
  }

  // Future<void> _checkPaywall() async {
  //   final paywallState = context.watch<PaywallBloc>().state;

  //   print(paywallState);
  //   if (paywallState is PaywallLoaded && !paywallState.isSubscriptionActive) {
  //     if (!mounted) return;

  //     showCupertinoModalBottomSheet(
  //       expand: true,
  //       elevation: 0,
  //       enableDrag: false,
  //       context: context,
  //       builder: (contextFromSheet) => PaywallWidget(),
  //     );
  //   }
  // }

  HabitSelection selectedVal = HabitSelection.today;

  @override
  Widget build(BuildContext context) {
    return CupertinoScaffold(
      body: CupertinoPageScaffold(
        child: CustomScrollView(
          slivers: <Widget>[
            _homePageNavigationBar(),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 15),
                      SingleHabitBuilder().animate().fadeIn(
                            duration: Duration(milliseconds: 300),
                          ),
                      SizedBox(height: 40),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  CupertinoSliverNavigationBar _homePageNavigationBar() {
    return CupertinoSliverNavigationBar(
      leading: Builder(builder: (context) {
        return Align(
          widthFactor: 1,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(
              CupertinoIcons.gear,
              size: 32,
            ),
            onPressed: () {
              CupertinoScaffold.showCupertinoModalBottomSheet(
                enableDrag: false,
                context: context,
                builder: (contextFromSheet) {
                  return SettingsPage();
                },
              );
            },
          ).animate().fadeIn(
                duration: Duration(milliseconds: 300),
              ),
        );
      }),
      largeTitle: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'HabitRise',
            textAlign: TextAlign.center,
          ).animate().fadeIn(
                duration: Duration(milliseconds: 300),
              ),
        ],
      ),
      trailing: Align(
        widthFactor: 1,
        child: Builder(builder: (context) {
          return CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(
              CupertinoIcons.add_circled,
              size: 32,
            ),
            onPressed: () {
              final paywallState = context.read<PaywallBloc>().state;

              if (paywallState is PaywallLoaded) {
                final isSubActive = paywallState.isSubscriptionActive;

                if (isSubActive) {
                  _openAddHabitPage(context);
                } else {
                  final habitState = context.read<HabitBloc>().state;

                  if (habitState is HabitsFetched) {
                    final createdTaskAmount = habitState.habits.length;
                    if (createdTaskAmount <= 3) {
                      _openAddHabitPage(context);
                    } else {
                      showCupertinoModalBottomSheet(
                        enableDrag: false,
                        context: context,
                        builder: (_) => PaywallWidget(),
                      );
                    }
                  }
                }
              }
            },
          );
        }),
      ).animate().fadeIn(duration: Duration(milliseconds: 300)),
    );
  }

  Future<dynamic> _openAddHabitPage(BuildContext context) {
    return CupertinoScaffold.showCupertinoModalBottomSheet(
      enableDrag: false,
      context: context,
      builder: (contextFromSheet) {
        return AddHabitPage();
      },
    );
  }
}
