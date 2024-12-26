import 'package:flutter/cupertino.dart';
import 'package:habitrise/pages/habits/habits_page.dart';
import 'package:habitrise/pages/overview/overview_page.dart';

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
    print(initState);
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
            icon: Icon(CupertinoIcons.home),
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

        // CupertinoTabView(
        //   builder: (BuildContext context) {
        //     return CupertinoPageScaffold(
        //       navigationBar: CupertinoNavigationBar(
        //         middle: Text('Page 1 of tab $index'),
        //       ),
        //       child: Center(
        //         child: CupertinoButton(
        //           child: const Text('Next page'),
        //           onPressed: () {
        //             Navigator.of(context).push(
        //               CupertinoPageRoute<void>(
        //                 builder: (BuildContext context) {
        //                   return CupertinoPageScaffold(
        //                     navigationBar: CupertinoNavigationBar(
        //                       middle: Text('Page 2 of tab $index'),
        //                     ),
        //                     child: Center(
        //                       child: CupertinoButton(
        //                         child: const Text('Back'),
        //                         onPressed: () {
        //                           Navigator.of(context).pop();
        //                         },
        //                       ),
        //                     ),
        //                   );
        //                 },
        //               ),
        //             );
        //           },
        //         ),
        //       ),
        //     );
        //   },
        // );
      },
    );
  }
}
