import '/core/core.dart';
import '/features/paywall/bloc/paywall_bloc.dart';
import '/features/paywall/widgets/paywall_widget.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitBloc>().add(FetchHabitEvent());

      setState(() {});
    });

    super.initState();
    _checkPaywall();
  }

  Future<void> _checkPaywall() async {
    // Initialize paywall and show if needed
    context.read<PaywallBloc>().add(InitializePaywallEvent());

    // Listen for paywall state changes
    final paywallState = context.read<PaywallBloc>().state;
    if (paywallState is PaywallLoaded && !paywallState.isSubscriptionActive) {
      await Future.delayed(Duration(milliseconds: 700));
      if (!mounted) return;

      showCupertinoModalBottomSheet(
        expand: true,
        elevation: 0,
        enableDrag: false,
        context: context,
        builder: (contextFromSheet) => PaywallWidget(),
      );
    }
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
          Image.asset(
            context.theme.brightness == Brightness.dark ? Assets.app.habitriseDarkTransparent.path : Assets.app.habitriseLightTransparent.path,
            height: 25,
            width: 25,
          ),
          SizedBox(width: 10),
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
              CupertinoScaffold.showCupertinoModalBottomSheet(
                enableDrag: false,
                context: context,
                builder: (contextFromSheet) {
                  return AddHabitPage();
                },
              );
            },
          );
        }),
      ).animate().fadeIn(duration: Duration(milliseconds: 300)),
    );
  }
}
