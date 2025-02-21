import 'package:habitrise/core/widgets/spring_button.dart';

import '/core/core.dart';
import '/features/paywall/bloc/paywall_bloc.dart';
import '../add_habit/add_habit_page.dart';
import '../paywall/widgets/paywall_widget.dart';
import '../settings/settings_home_page.dart';
import 'bloc/habit_bloc.dart';
import 'widgets/habit_builder.dart';

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
                      HabitBuilder().animate().fadeIn(
                            duration: Duration(milliseconds: 350),
                          ),
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
          child: SpringButton(
            duration: 200,
            scaleCoefficient: 0.8,
            onTap: () {
              CupertinoScaffold.showCupertinoModalBottomSheet(
                enableDrag: false,
                context: context,
                builder: (contextFromSheet) {
                  return SettingsPage();
                },
              );
            },
            child: Icon(
              FontAwesomeIcons.gear,
              size: 24,
              color: context.theme.primaryColor.withValues(alpha: .72),
            ),
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
          final paywallState = context.watch<PaywallBloc>().state;
          final isSubActive = paywallState is PaywallResult ? paywallState.isSubscriptionActive : false;
          final isPurchasing = paywallState is PaywallResult ? paywallState.isPurchasing : false;
          final isRestoring = paywallState is PaywallResult ? paywallState.isRestoring : false;

          final bool paywallStateisLoading = paywallState is PaywallInitializing;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              paywallStateisLoading || isPurchasing || isRestoring
                  ? CupertinoActivityIndicator()
                  : isSubActive
                      ? SizedBox.shrink()
                      : SpringButton(
                          duration: 200,
                          scaleCoefficient: 0.8,
                          onTap: () {
                            showCupertinoModalBottomSheet(
                              enableDrag: false,
                              context: context,
                              builder: (_) => PaywallWidget(),
                            );
                          },
                          child: FaIcon(
                            FontAwesomeIcons.crown,
                            color: CupertinoColors.systemYellow,
                            size: 24,
                          ),
                        ).animate().fadeIn(duration: Duration(milliseconds: 300)),
              SizedBox(width: 15),
              SpringButton(
                duration: 200,
                scaleCoefficient: 0.8,
                onTap: () {
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
                },
                child: Icon(
                  FontAwesomeIcons.circlePlus,
                  size: 24,
                  color: context.theme.primaryColor.withValues(alpha: .72),
                ),
              ).animate().fadeIn(duration: Duration(milliseconds: 300)),
            ],
          );
        }),
      ),
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
