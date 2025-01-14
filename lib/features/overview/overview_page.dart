import 'package:habitrise/features/settings/settings_home/settings_home_page.dart';

import '/core/core.dart';
import '../add_habit/add_habit_page.dart';
import '../habits/bloc/single_habit/single_habit_bloc.dart';
import '../habits/widgets/single_habit/single_habit_builder.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

enum HabitSelection { today, allTime }

class _OverviewPageState extends State<OverviewPage> with SingleTickerProviderStateMixin {
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
      context.read<SingleHabitBloc>().add(FetchSingleHabitEvent());
    });
    super.initState();
  }

  HabitSelection selectedVal = HabitSelection.today;

  @override
  Widget build(BuildContext context) {
    return CupertinoScaffold(
      body: CupertinoPageScaffold(
        child: CustomScrollView(
          slivers: <Widget>[
            CupertinoSliverNavigationBar(
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
              largeTitle: Text('HabitRise').animate().fadeIn(
                    duration: Duration(milliseconds: 300),
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
            ),
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
}

const Color kHeaderFooterColor = CupertinoDynamicColor(
  color: Color.fromRGBO(108, 108, 108, 1.0),
  darkColor: Color.fromRGBO(142, 142, 146, 1.0),
  highContrastColor: Color.fromRGBO(74, 74, 77, 1.0),
  darkHighContrastColor: Color.fromRGBO(176, 176, 183, 1.0),
  elevatedColor: Color.fromRGBO(108, 108, 108, 1.0),
  darkElevatedColor: Color.fromRGBO(142, 142, 146, 1.0),
  highContrastElevatedColor: Color.fromRGBO(108, 108, 108, 1.0),
  darkHighContrastElevatedColor: Color.fromRGBO(142, 142, 146, 1.0),
);
