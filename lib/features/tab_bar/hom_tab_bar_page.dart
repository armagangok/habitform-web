import 'package:flutter/cupertino.dart';
import 'package:habitrise/features/habits/pages/habits_page.dart';
import 'package:habitrise/features/overview/overview_page.dart';

import '../settings/settings_home/settings_home_page.dart';

class HomeTabScaffoldPage extends StatefulWidget {
  const HomeTabScaffoldPage({super.key});

  @override
  State<HomeTabScaffoldPage> createState() => _HomeTabScaffoldPageState();
}

class _HomeTabScaffoldPageState extends State<HomeTabScaffoldPage> {
  final List<Widget> _pages = [
    OverviewPage(),
    HabitsPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    selectedPage = _pages[0];
    super.initState();
  }

  late Widget selectedPage;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        onTap: (value) {
          setState(() {
            selectedPage = _pages[value];
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_pie),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.folder),
            label: 'Habits',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.gear),
            label: 'Settings',
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        return selectedPage;
      },
    );
  }
}
